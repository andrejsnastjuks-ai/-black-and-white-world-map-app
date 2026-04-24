import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:black_world_map/services/fog_grid_service.dart';

void main() {
  test('creates cells around location', () {
    final cells = FogGridService.cellsAround(const LatLng(56.9496, 24.1052), 70);
    expect(cells.isNotEmpty, true);
    expect(cells.map((e) => e.key).toSet().length, cells.length);
  });
}
