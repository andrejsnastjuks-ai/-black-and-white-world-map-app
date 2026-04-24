# Developer Handoff

## Current status
This project is a Flutter MVP code package, not a compiled APK. It contains the main Dart application code and platform permission templates. To build a real APK/AAB, create a full Flutter project wrapper and copy this package into it.

## Build steps
```bash
flutter create black_world_map
cd black_world_map
# Copy lib/, pubspec.yaml, analysis_options.yaml, android/ and ios/ templates from this package.
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

## Release build output
APK:
```bash
build/app/outputs/flutter-apk/app-release.apk
```

AAB for Google Play:
```bash
build/app/outputs/bundle/release/app-release.aab
```

## Must-fix before public release
- Confirm plugin versions compile with the installed Flutter version.
- Confirm Android targetSdk is API 35+.
- Add signing configuration.
- Test background tracking on real devices.
- Improve fog rendering performance for large discovered areas.
- Add deletion/export controls for privacy compliance.
- Add real app icon and splash screen.

## Recommended backend for paid version
Supabase:
- PostgreSQL/PostGIS for discovered cells and trips.
- Auth for Google/Apple login.
- Storage for GPX/photo exports.

Alternative:
Firebase:
- Firebase Auth.
- Firestore.
- Cloud Storage.
- Crashlytics.
