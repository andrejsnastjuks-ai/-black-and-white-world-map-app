import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../providers/travel_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TravelController>(
      builder: (context, controller, _) {
        final settings = controller.settings;
        Future<void> save(AppSettings next) => controller.updateSettings(next);
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Map opening', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reveal radius: ${settings.revealRadiusMeters.round()} m'),
                      Slider(
                        value: settings.revealRadiusMeters,
                        min: 20,
                        max: 250,
                        divisions: 46,
                        label: '${settings.revealRadiusMeters.round()} m',
                        onChanged: (v) => save(settings.copyWith(revealRadiusMeters: v)),
                      ),
                      Text('GPS accuracy filter: ${settings.maxAccuracyMeters.round()} m'),
                      Slider(
                        value: settings.maxAccuracyMeters,
                        min: 10,
                        max: 150,
                        divisions: 28,
                        label: '${settings.maxAccuracyMeters.round()} m',
                        onChanged: (v) => save(settings.copyWith(maxAccuracyMeters: v)),
                      ),
                      SwitchListTile(
                        value: settings.backgroundTracking,
                        onChanged: (v) => save(settings.copyWith(backgroundTracking: v)),
                        title: const Text('Background tracking'),
                        subtitle: const Text('Records route while the app is minimized. Requires OS permission.'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Important: Android and iOS may still stop GPS if battery saver is aggressive. For best results, allow location “Always” and disable battery optimization for this app.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
