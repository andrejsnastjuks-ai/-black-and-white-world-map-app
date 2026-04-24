import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/track_point.dart';
import 'database_service.dart';
import 'fog_grid_service.dart';
import 'location_service.dart';

class BackgroundTrackingService {
  static const String startAction = 'startTracking';
  static const String stopAction = 'stopTracking';

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();
    const channel = AndroidNotificationChannel(
      'black_world_tracking',
      'Travel tracking',
      description: 'Records your route while the app is in the background.',
      importance: Importance.low,
    );
    final notifications = FlutterLocalNotificationsPlugin();
    await notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: 'black_world_tracking',
        initialNotificationTitle: 'Black World Map',
        initialNotificationContent: 'Tracking your journey',
        foregroundServiceNotificationId: 8842,
      ),
      iosConfiguration: IosConfiguration(onForeground: onStart, onBackground: onIosBackground),
    );
  }

  static Future<void> start(int tripId, double revealRadius, double maxAccuracy) async {
    final service = FlutterBackgroundService();
    final running = await service.isRunning();
    if (!running) await service.startService();
    service.invoke(startAction, {
      'tripId': tripId,
      'revealRadius': revealRadius,
      'maxAccuracy': maxAccuracy,
    });
  }

  static Future<void> stop() async => FlutterBackgroundService().invoke(stopAction);
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async => true;

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await DatabaseService.instance.init();

  StreamSubscription<Position>? sub;
  int? tripId;
  double revealRadius = 70;
  double maxAccuracy = 60;
  LatLng? last;
  final distance = const Distance();

  Future<void> stopTracking() async {
    await sub?.cancel();
    sub = null;
    tripId = null;
  }

  service.on(BackgroundTrackingService.stopAction).listen((event) async => stopTracking());
  service.on('stopService').listen((event) async {
    await stopTracking();
    service.stopSelf();
  });

  service.on(BackgroundTrackingService.startAction).listen((event) async {
    await stopTracking();
    tripId = event?['tripId'] as int?;
    revealRadius = (event?['revealRadius'] as num?)?.toDouble() ?? 70;
    maxAccuracy = (event?['maxAccuracy'] as num?)?.toDouble() ?? 60;
    if (tripId == null) return;

    sub = LocationService.positionStream().listen((position) async {
      if (!LocationService.isUsable(position, maxAccuracy: maxAccuracy)) return;
      final current = LatLng(position.latitude, position.longitude);
      if (last != null && distance(last!, current) < 6) return;
      last = current;
      final id = tripId!;
      await DatabaseService.instance.addTrackPoint(TrackPoint(
        id: null,
        tripId: id,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
        recordedAt: DateTime.now(),
      ));
      await DatabaseService.instance.upsertCells(FogGridService.cellsAround(current, revealRadius));
    });
  });
}
