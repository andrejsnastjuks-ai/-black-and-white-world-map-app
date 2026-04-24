# Google Play Release Checklist — 2026

## Technical requirements
- Target SDK: Android 15 / API 35 or higher for new apps and updates.
- Use Android App Bundle (.aab) for Play Store release.
- Use a signed release build.
- Keep debug logging disabled in release.
- Test on Android 10, 12, 14, and 15 devices if possible.
- Test battery optimization behavior.
- Test background tracking with the screen locked.

## Location and privacy requirements
Because this app records GPS routes and may use background location, the Play Store review must clearly understand why location is needed.

Required:
- In-app permission explanation before requesting location.
- Privacy Policy URL.
- Data Safety form completed in Play Console.
- Background location declaration, if background tracking is enabled.
- Foreground service notification while tracking.
- User control: Start/Stop trip must be obvious.
- User control: export/delete trip data.

## Store listing assets
Required:
- App name.
- Short description.
- Full description.
- App icon 512x512.
- Feature graphic 1024x500.
- Phone screenshots.
- Privacy Policy page.
- Support email.

## Recommended store categories
- Travel & Local
- Health/Fitness may be secondary only if focusing on walking statistics.

## Release channels
1. Internal testing.
2. Closed testing with 10-20 real users.
3. Open testing.
4. Production release.

## Pre-release QA
- Start trip outdoors.
- Lock phone for 15 minutes.
- Walk/drive at least 1 km.
- Stop trip.
- Restart app.
- Confirm route and discovered cells remain saved.
- Export GPX.
- Deny location permission and confirm app handles it gracefully.
- Disable internet and confirm app does not crash.
