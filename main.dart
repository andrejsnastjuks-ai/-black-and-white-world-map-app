import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/travel_controller.dart';
import 'screens/root_screen.dart';
import 'services/background_tracking_service.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  await BackgroundTrackingService.initialize();
  runApp(const BlackWorldMapApp());
}

class BlackWorldMapApp extends StatelessWidget {
  const BlackWorldMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TravelController()..bootstrap(),
      child: MaterialApp(
        title: 'Black World Map',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const RootScreen(),
      ),
    );
  }
}
