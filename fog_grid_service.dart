import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../models/discovered_cell.dart';

class FogGridService {
  static const double cellDegrees = 0.001; // approx. 111 m latitude.

  static String keyFor(int latIndex, int lngIndex) => '$latIndex:$lngIndex';

  static DiscoveredCell cellFor(LatLng point) {
    final latIndex = (point.latitude / cellDegrees).floor();
    final lngIndex = (point.longitude / cellDegrees).floor();
    return DiscoveredCell(
      key: keyFor(latIndex, lngIndex),
      latIndex: latIndex,
      lngIndex: lngIndex,
      discoveredAt: DateTime.now(),
    );
  }

  static List<DiscoveredCell> cellsAround(LatLng center, double radiusMeters) {
    final distance = const Distance();
    final latStepMeters = distance(center, LatLng(center.latitude + cellDegrees, center.longitude));
    final lngStepMeters = max(
      1.0,
      distance(center, LatLng(center.latitude, center.longitude + cellDegrees)),
    );
    final latRange = (radiusMeters / latStepMeters).ceil() + 1;
    final lngRange = (radiusMeters / lngStepMeters).ceil() + 1;
    final base = cellFor(center);
    final result = <DiscoveredCell>[];

    for (var y = -latRange; y <= latRange; y++) {
      for (var x = -lngRange; x <= lngRange; x++) {
        final latIndex = base.latIndex + y;
        final lngIndex = base.lngIndex + x;
        final cellCenter = LatLng(
          (latIndex + 0.5) * cellDegrees,
          (lngIndex + 0.5) * cellDegrees,
        );
        if (distance(center, cellCenter) <= radiusMeters + 90) {
          result.add(DiscoveredCell(
            key: keyFor(latIndex, lngIndex),
            latIndex: latIndex,
            lngIndex: lngIndex,
            discoveredAt: DateTime.now(),
          ));
        }
      }
    }
    return result;
  }

  static List<LatLng> polygonForCell(DiscoveredCell cell) {
    final lat0 = cell.latIndex * cellDegrees;
    final lng0 = cell.lngIndex * cellDegrees;
    final lat1 = lat0 + cellDegrees;
    final lng1 = lng0 + cellDegrees;
    return [LatLng(lat0, lng0), LatLng(lat0, lng1), LatLng(lat1, lng1), LatLng(lat1, lng0)];
  }
}
