# Black World Map — 10/10 MVP

Travel app concept: the world starts dark. When the user walks, drives or travels, GPS points reveal the map using a local discovery grid.

## What is included

- Flutter app structure for Android and iOS.
- OpenStreetMap via `flutter_map`.
- Foreground GPS tracking with filtering.
- Background tracking service template for Android/iOS.
- Local SQLite storage for trips, GPS points and discovered grid cells.
- Improved fog-of-war system using persistent cells, not only temporary circles.
- Trip history and GPX export/share.
- Settings for reveal radius, GPS accuracy and background tracking.
- Android and iOS permission templates.
- Production notes and testing checklist.

## Run

```bash
flutter create black_world_map
cd black_world_map
# copy this ZIP content over the generated project
flutter pub get
flutter analyze
flutter run
```

## Build APK

```bash
flutter build apk --release
```

## Important platform notes

Background GPS is restricted by Android/iOS battery policies. On real devices, test:

1. Location permission: Always / Allow all the time.
2. Battery optimization disabled for the app.
3. Android foreground tracking notification visible.
4. iOS Background Modes > Location Updates enabled in Xcode.

## Next commercial steps

To publish in Google Play / App Store, add:

- unique app icon and splash screen;
- privacy policy;
- clear location permission explanations;
- real device tests for 1–3 hour walks;
- crash reporting, analytics and backup/sync if needed.
