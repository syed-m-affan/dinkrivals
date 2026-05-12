# Dink Rivals

Dink Rivals is a mobile-first retro arcade pickleball prototype built with Flutter and Flame. The playable app lives in `dink_rivals/`; root-level folders hold design docs, build specs, art references, and implementation tickets.

## Repo Layout

- `dink_rivals/` - Flutter/Flame game app.
- `dink_rivals/lib/game/` - gameplay components, systems, models, config, and utilities.
- `dink_rivals/test/` - deterministic gameplay, UI, and visual tests.
- `docs/` - rules, specs, visual direction, and art references.
- `docs/specs/` - product and visual specification documents.
- `tickets/` - implementation tasks grouped into phase folders, plus current ticket status.
- `AGENTS.md` and `CLAUDE.md` - agent-specific development and QA guidance.

## Development

Run Flutter commands from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d <ANDROID_DEVICE_ID>
```

Build and install a debug APK:

```bash
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Local Emulator QA

A reusable Android emulator may be available as `dink_rivals_qa`:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd dink_rivals_qa
```

Then run from `dink_rivals/`:

```bash
flutter devices
flutter run -d emulator-5554
```

For a built APK:

```bash
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

On Windows, use the SDK-local ADB path if `adb` is not on `PATH`:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1
& $adb -s emulator-5554 shell screencap -p /sdcard/dink_rivals_qa.png
& $adb -s emulator-5554 pull /sdcard/dink_rivals_qa.png ..\dink_rivals_qa.png
```

Use emulator QA for quick launch, screenshot, and basic gameplay smoke checks. Required physical-device QA still applies when the build spec or ticket says a phase cannot be closed without it.

## Controls

The current gameplay control contract is:

- Left virtual stick moves the player.
- Right virtual stick controls racket angle and swing velocity.
- The SERVE button charges and releases serve attempts.
- Shot labels such as DINK, DRIVE, LOB, SMASH, BLOCK, and SERVE are automatic contact classifications, not separate shot buttons.

Do not add separate shot buttons unless an accepted playtest ticket explicitly changes the control contract.

## Rules And Specs

Game rules should conform to `docs/pickleball_rules.md`. The roadmap, phase acceptance criteria, Android QA expectations, and visual direction are tracked in `docs/specs/build-spec.md`.

Before starting ticket work, read `tickets/README.md` and the specific ticket file. Keep known issues, verification notes, and deferred QA visible in the relevant ticket or phase notes.
