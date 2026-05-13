# Repository Guidelines

## Project Structure & Module Organization

This repository contains the Flutter/Flame game prototype in `dink_rivals/`. Core gameplay code lives in `dink_rivals/lib/game/`, organized by responsibility:

- `components/`: Flame renderable components such as players, court, ball, net, and overlays.
- `systems/`: gameplay logic for input, movement, ball physics, shots, and opponent AI.
- `models/`: lightweight state and enum types.
- `config/`: tuning, court constants, and debug flags.
- `util/`: shared helpers such as court projection.

Tests are in `dink_rivals/test/` and currently focus on deterministic game logic. Root-level `docs/` holds design notes, `docs/specs/` contains specifications, `docs/art/` contains reference art, and `tickets/` tracks implementation tasks grouped by phase.

## Build, Test, and Development Commands

Run Flutter commands from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d <ANDROID_DEVICE_ID>
flutter run -d emulator-5554
flutter build apk --debug
```

`flutter pub get` installs dependencies. `flutter analyze` applies Dart analyzer and lint checks. `flutter test` runs unit/widget tests. `flutter run` starts the game on a connected device or emulator. `flutter build apk --debug` creates an Android debug APK.

## Local Emulator QA

A local Android QA emulator may be available as `dink_rivals_qa`. Start it from any directory:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd dink_rivals_qa
```

Then run from `dink_rivals/`:

```bash
flutter devices
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d emulator-5554
```

For launcher/screenshot checks on Windows, use the SDK-local ADB path if `adb` is not on `PATH`:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1
& $adb -s emulator-5554 shell screencap -p /sdcard/dink_rivals_qa.png
& $adb -s emulator-5554 pull /sdcard/dink_rivals_qa.png ..\dink_rivals_qa.png
```

Use the emulator for fast smoke tests and screenshots. Physical Android device QA is still required before marking a phase done when the ticket or build spec calls for it.

## Coding Style & Naming Conventions

Use standard Dart formatting with two-space indentation; run `dart format .` from `dink_rivals/` before committing nontrivial edits. Prefer `const` constructors and `final` fields where possible, matching `analysis_options.yaml`. Name Dart files with `snake_case.dart`; use `PascalCase` for classes/enums and `lowerCamelCase` for methods, fields, and local variables. Keep gameplay constants in `config/` rather than scattering magic numbers through systems.

## Testing Guidelines

Use `flutter_test` for tests. Add focused tests under `dink_rivals/test/` with filenames ending in `_test.dart`, for example `ball_physics_system_test.dart`. Favor tests for systems, model transitions, and deterministic geometry/physics helpers. Run `flutter test` and `flutter analyze` before opening a PR.

## Commit & Pull Request Guidelines

Git history currently has only `initial commit`, so use concise imperative commit messages such as `add drive shot tuning` or `fix court projection bounds`. Pull requests should include a short summary, testing performed, linked ticket when applicable, and screenshots or short recordings for visible gameplay changes.

## Agent-Specific Instructions

Keep edits scoped to the requested task. Do not overwrite unrelated local changes. When changing gameplay behavior, update nearby tests or add a ticket note if coverage is intentionally deferred.

## Character Sprite Generation

For player/opponent sprite work, follow `docs/art/visual-overhaul/sprite-generator-skill-workflow.md`. The current accepted art uses the external `character-animation-creator-skill` workflow with imagegen source strips, chroma-key cleanup, validation JSON, and runtime contact sheets.

Do not regenerate production character sheets with `dink_rivals/tool/generate_chibi_64_sprites.py` unless the user explicitly asks for the legacy procedural fallback. That script was part of the rejected manual pass and can reintroduce the old model during swing, serve, or point-result animations.
