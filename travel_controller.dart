import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/discovered_cell.dart';
import '../models/track_point.dart';
import '../models/trip.dart';
import '../services/background_tracking_service.dart';
import '../services/database_service.dart';
import '../services/fog_grid_service.dart';
import '../services/location_service.dart';

class TravelController extends ChangeNotifier {
  final _distance = const Distance();
  StreamSubscription<Position>? _subscription;

  AppSettings settings = const AppSettings();
  List<Trip> trips = [];
  List<TrackPoint> points = [];
  List<DiscoveredCell> discoveredCells = [];
  Trip? activeTrip;
  LatLng? currentLocation;
  String? error;
  bool loading = true;
  double activeDistanceMeters = 0;

  bool get isTracking => activeTrip != null;
  int get discoveredCellCount => discoveredCells.length;
  double get totalDistanceKm => trips.fold(0, (sum, trip) => sum + trip.distanceMeters) / 1000;

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    await _loadSettings();
    activeTrip = await DatabaseService.instance.activeTrip();
    await reload();
    if (activeTrip != null) {
      await _startForegroundTracking(activeTrip!.id!);
    }
    loading = false;
    notifyListeners();
  }

  Future<void> reload() async {
    trips = await DatabaseService.instance.loadTrips();
    points = await DatabaseService.instance.loadPoints();
    discoveredCells = await DatabaseService.instance.loadCells();
    if (activeTrip != null) {
      activeDistanceMeters = _calculateDistance(points.where((p) => p.tripId == activeTrip!.id).toList());
    }
    notifyListeners();
  }

  Future<void> startTrip() async {
    error = null;
    final ok = await LocationService.ensurePermission();
    if (!ok) {
      error = 'Нет разрешения на геолокацию или GPS выключен.';
      notifyListeners();
      return;
    }
    final id = await DatabaseService.instance.createTrip('Trip ${DateTime.now().toString().substring(0, 16)}');
    activeTrip = Trip(id: id, name: 'Trip ${DateTime.now().toString().substring(0, 16)}', startedAt: DateTime.now());
    activeDistanceMeters = 0;
    await _startForegroundTracking(id);
    if (settings.backgroundTracking) {
      await BackgroundTrackingService.start(id, settings.revealRadiusMeters, settings.maxAccuracyMeters);
    }
    await reload();
  }

  Future<void> stopTrip() async {
    final trip = activeTrip;
    if (trip == null || trip.id == null) return;
    await _subscription?.cancel();
    _subscription = null;
    await BackgroundTrackingService.stop();
    await DatabaseService.instance.finishTrip(trip.id!, activeDistanceMeters);
    activeTrip = null;
    activeDistanceMeters = 0;
    await reload();
  }

  Future<void> updateSettings(AppSettings next) async {
    settings = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('revealRadiusMeters', settings.revealRadiusMeters);
    await prefs.setDouble('minDistanceMeters', settings.minDistanceMeters);
    await prefs.setDouble('maxAccuracyMeters', settings.maxAccuracyMeters);
    await prefs.setBool('backgroundTracking', settings.backgroundTracking);
    if (activeTrip?.id != null && settings.backgroundTracking) {
      await BackgroundTrackingService.start(activeTrip!.id!, settings.revealRadiusMeters, settings.maxAccuracyMeters);
    }
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    settings = AppSettings(
      revealRadiusMeters: prefs.getDouble('revealRadiusMeters') ?? 70,
      minDistanceMeters: prefs.getDouble('minDistanceMeters') ?? 8,
      maxAccuracyMeters: prefs.getDouble('maxAccuracyMeters') ?? 60,
      backgroundTracking: prefs.getBool('backgroundTracking') ?? true,
    );
  }

  Future<void> _startForegroundTracking(int tripId) async {
    await _subscription?.cancel();
    LatLng? last;
    _subscription = LocationService.positionStream().listen((position) async {
      if (!LocationService.isUsable(position, maxAccuracy: settings.maxAccuracyMeters)) return;
      final now = LatLng(position.latitude, position.longitude);
      currentLocation = now;
      if (last != null) {
        final step = _distance(last!, now);
        if (step < settings.minDistanceMeters) {
          notifyListeners();
          return;
        }
        if (step < 1000) activeDistanceMeters += step;
      }
      last = now;
      final point = TrackPoint(
        id: null,
        tripId: tripId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        recordedAt: DateTime.now(),
      );
      await DatabaseService.instance.addTrackPoint(point);
      final cells = FogGridService.cellsAround(now, settings.revealRadiusMeters);
      await DatabaseService.instance.upsertCells(cells);
      points = [...points, point];
      final existingKeys = discoveredCells.map((e) => e.key).toSet();
      discoveredCells = [...discoveredCells, ...cells.where((c) => !existingKeys.contains(c.key))];
      notifyListeners();
    }, onError: (Object e) {
      error = e.toString();
      notifyListeners();
    });
  }

  double _calculateDistance(List<TrackPoint> list) {
    if (list.length < 2) return 0;
    var meters = 0.0;
    for (var i = 1; i < list.length; i++) {
      final a = LatLng(list[i - 1].latitude, list[i - 1].longitude);
      final b = LatLng(list[i].latitude, list[i].longitude);
      final step = _distance(a, b);
      if (step < 1000) meters += step;
    }
    return meters;
  }
}
