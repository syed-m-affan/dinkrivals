# Repository Guidelines

## Project Structure & Module Organization

This repository contains the Flutter/Flame game prototype in `dink_rivals/`. Core gameplay code lives in `dink_rivals/lib/game/`, organized by responsibility:

- `components/`: Flame renderable components such as players, court, ball, net, and overlays.
- `systems/`: gameplay logic for input, movement, ball physics, shots, and opponent AI.
- `models/`: lightweight state and enum types.
- `config/`: tuning, court constants, and debug flags.
- `util/`: shared helpers such as court projection.

Tests are in `dink_rivals/test/` and currently focus on deterministic game logic. Root-level `docs/` holds design/build notes, `docs/art/` contains reference art, and `tickets/` tracks implementation tasks.

## Build, Test, and Development Commands

Run Flutter commands from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d <ANDROID_DEVICE_ID>
flutter build apk --debug
```

`flutter pub get` installs dependencies. `flutter analyze` applies Dart analyzer and lint checks. `flutter test` runs unit/widget tests. `flutter run` starts the game on a connected device or emulator. `flutter build apk --debug` creates an Android debug APK.

## Coding Style & Naming Conventions

Use standard Dart formatting with two-space indentation; run `dart format .` from `dink_rivals/` before committing nontrivial edits. Prefer `const` constructors and `final` fields where possible, matching `analysis_options.yaml`. Name Dart files with `snake_case.dart`; use `PascalCase` for classes/enums and `lowerCamelCase` for methods, fields, and local variables. Keep gameplay constants in `config/` rather than scattering magic numbers through systems.

## Testing Guidelines

Use `flutter_test` for tests. Add focused tests under `dink_rivals/test/` with filenames ending in `_test.dart`, for example `ball_physics_system_test.dart`. Favor tests for systems, model transitions, and deterministic geometry/physics helpers. Run `flutter test` and `flutter analyze` before opening a PR.

## Commit & Pull Request Guidelines

Git history currently has only `initial commit`, so use concise imperative commit messages such as `add drive shot tuning` or `fix court projection bounds`. Pull requests should include a short summary, testing performed, linked ticket when applicable, and screenshots or short recordings for visible gameplay changes.

## Agent-Specific Instructions

Keep edits scoped to the requested task. Do not overwrite unrelated local changes. When changing gameplay behavior, update nearby tests or add a ticket note if coverage is intentionally deferred.
