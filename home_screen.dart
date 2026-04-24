import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/travel_controller.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelController>(
      builder: (context, controller, _) {
        final center = controller.currentLocation ?? const LatLng(56.9496, 24.1052);
        final routePoints = controller.points
            .where((p) => controller.activeTrip == null || p.tripId == controller.activeTrip!.id)
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 13, maxZoom: 19),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vsa.blackworldmap',
                  retinaMode: true,
                ),
                PolygonLayer(
                  polygons: controller.discoveredCells.map((cell) {
                    final lat0 = cell.latIndex * 0.001;
                    final lng0 = cell.lngIndex * 0.001;
                    return Polygon(
                      points: [
                        LatLng(lat0, lng0),
                        LatLng(lat0, lng0 + 0.001),
                        LatLng(lat0 + 0.001, lng0 + 0.001),
                        LatLng(lat0 + 0.001, lng0),
                      ],
                      color: Colors.greenAccent.withOpacity(0.20),
                      borderColor: Colors.greenAccent.withOpacity(0.10),
                      borderStrokeWidth: 0.2,
                    );
                  }).toList(),
                ),
                if (routePoints.length > 1)
                  PolylineLayer(
                    polylines: [Polyline(points: routePoints, strokeWidth: 5, color: Colors.greenAccent)],
                  ),
                MarkerLayer(
                  markers: [
                    if (controller.currentLocation != null)
                      Marker(
                        point: controller.currentLocation!,
                        width: 44,
                        height: 44,
                        child: const Icon(Icons.my_location, color: Colors.white, size: 34),
                      ),
                  ],
                ),
              ],
            ),
            IgnorePointer(child: Container(color: Colors.black.withOpacity(0.56))),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatCard(label: 'Opened cells', value: '${controller.discoveredCellCount}', icon: Icons.grid_on)),
                        const SizedBox(width: 8),
                        Expanded(child: StatCard(label: 'Total km', value: controller.totalDistanceKm.toStringAsFixed(1), icon: Icons.timeline)),
                      ],
                    ),
                    if (controller.error != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(controller.error!, style: const TextStyle(color: Colors.orangeAccent)),
                        ),
                      ),
                    const Spacer(),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(controller.isTracking ? 'Trip is recording' : 'Ready to discover', style: Theme.of(context).textTheme.titleMedium),
                                  Text('Radius: ${controller.settings.revealRadiusMeters.round()} m'),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: controller.isTracking ? controller.stopTrip : controller.startTrip,
                              icon: Icon(controller.isTracking ? Icons.stop : Icons.play_arrow),
                              label: Text(controller.isTracking ? 'Stop' : 'Start'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
