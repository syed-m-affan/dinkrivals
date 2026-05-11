# Dink Rivals

Flutter/Flame prototype for Dink Rivals, a mobile-first retro arcade pickleball game.

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
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Local Emulator QA

If the local QA emulator exists, start it from any directory:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd dink_rivals_qa
```

Then run from this directory:

```bash
flutter devices
flutter run -d emulator-5554
```

To install an already-built debug APK:

```bash
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

For launcher and screenshot smoke tests on Windows:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1
& $adb -s emulator-5554 shell screencap -p /sdcard/dink_rivals_qa.png
& $adb -s emulator-5554 pull /sdcard/dink_rivals_qa.png ..\dink_rivals_qa.png
```

## Controls

Left virtual stick moves the player. Right virtual stick swings the racket through the front arc. The SERVE button charges/releases the serve. Shot labels such as DINK, DRIVE, LOB, and SMASH are automatic contact classifications, not separate shot buttons.
