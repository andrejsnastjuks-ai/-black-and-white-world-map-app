import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/travel_controller.dart';
import '../services/database_service.dart';
import '../services/gpx_service.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: Consumer<TravelController>(
        builder: (context, controller, _) {
          if (controller.trips.isEmpty) {
            return const Center(child: Text('No trips yet. Start your first walk.'));
          }
          return RefreshIndicator(
            onRefresh: controller.reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: controller.trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final trip = controller.trips[index];
                return Card(
                  child: ListTile(
                    leading: Icon(trip.isActive ? Icons.radio_button_checked : Icons.route),
                    title: Text(trip.name),
                    subtitle: Text('${date.format(trip.startedAt)} • ${(trip.distanceMeters / 1000).toStringAsFixed(2)} km'),
                    trailing: IconButton(
                      icon: const Icon(Icons.ios_share),
                      onPressed: () async {
                        final points = await DatabaseService.instance.loadPoints(tripId: trip.id);
                        await GpxService.share(trip, points);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
