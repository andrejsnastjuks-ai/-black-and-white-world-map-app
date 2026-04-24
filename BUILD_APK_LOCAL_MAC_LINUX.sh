#!/usr/bin/env bash
set -e
flutter create . --platforms=android --org com.vsaservice.blackworldmap
flutter pub get
flutter build apk --release
echo "APK ready: build/app/outputs/flutter-apk/app-release.apk"
