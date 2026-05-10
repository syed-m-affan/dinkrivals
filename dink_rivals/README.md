# Dink Rivals

Phase 0 gray-box rally prototype built with Flutter and Flame.

## Run on Android

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d <ANDROID_DEVICE_ID>
```

Build a debug APK:

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

The app boots directly into the gameplay scene. Left side drag moves the player. Right side tap dinks. Right side hold and release drives. The reset button restarts the point.
