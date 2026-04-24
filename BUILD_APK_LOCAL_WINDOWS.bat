@echo off
echo Creating Android project files if needed...
flutter create . --platforms=android --org com.vsaservice.blackworldmap
if %errorlevel% neq 0 pause & exit /b %errorlevel%

echo Installing dependencies...
flutter pub get
if %errorlevel% neq 0 pause & exit /b %errorlevel%

echo Building APK...
flutter build apk --release
if %errorlevel% neq 0 pause & exit /b %errorlevel%

echo APK ready: build\app\outputs\flutter-apk\app-release.apk
pause
