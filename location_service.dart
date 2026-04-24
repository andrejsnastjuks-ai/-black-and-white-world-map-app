import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  static Stream<Position> positionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 8,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  static bool isUsable(Position p, {required double maxAccuracy}) {
    if (p.accuracy > maxAccuracy) return false;
    if (p.speed > 75) return false; // filters aircraft-like jumps, m/s.
    return true;
  }
}
