# Project analysis

## Status

This package is a strong production-ready MVP codebase, not a compiled store binary. The code is structured so a Flutter developer can generate Android/iOS native folders, copy the files, install dependencies and run.

## Improvements over previous version

1. Background tracking service template added.
2. Persistent discovered-cell grid added for more realistic map opening.
3. GPS quality filters added: accuracy, minimum distance and jump filtering.
4. Trip history + GPX export preserved.
5. Settings saved in SharedPreferences.
6. Android/iOS permissions prepared.
7. UI improved with dark theme, navigation, stats and settings.

## Known limitations

- APK/IPA was not compiled in this environment because Flutter SDK is not installed here.
- The dark fog is visually implemented as a dark overlay with highlighted discovered cells. For a perfect game-style mask, use Mapbox custom style/layers or a shader-based mask.
- Background tracking must be tested on real devices because OS battery rules differ by phone brand.
- OpenStreetMap public tile server is fine for testing, but commercial release should use a proper tile provider or hosted tile plan.

## Test checklist

- `flutter pub get`
- `flutter analyze`
- Android emulator location permission test
- Real Android walking test with screen locked
- Real iPhone walking test with background location enabled
- Start/Stop trip, close app, reopen app
- GPX export and import into Google Earth / Garmin / Strava-compatible viewer
- Battery consumption test for at least 60 minutes

## Recommended 10/10 future upgrades

- Cloud sync: Supabase or Firebase.
- Account login: Google/Apple.
- Offline map downloads.
- Country/city achievement system.
- Photo pins along route.
- Family shared map.
- Better fog rendering with vector tiles and GPU mask.
