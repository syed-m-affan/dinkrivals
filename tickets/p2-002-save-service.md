---
id: P2-002
phase: 2
status: done
priority: high
parallel_group: B
depends_on: []
blocks: [P2-004, P2-007]
owner: claude
last_updated: 2026-05-10
---

# P2-002 - Save Service

## Goal

Provide a small, testable persistence layer for Phase 2 user preferences (sound on/off, haptics on/off) backed by `shared_preferences`. No game-state, unlocks, or stats are persisted in this ticket.

## Build Spec Coverage

Phase 2 tasks:

- Create save service.
- Save sound/haptics settings.

## Suggested File Ownership

- `dink_rivals/pubspec.yaml` (add `shared_preferences`).
- `dink_rivals/lib/services/save_service.dart`.
- `dink_rivals/lib/game/models/save_data.dart`.
- `dink_rivals/test/save_service_test.dart`.

Avoid editing menu/settings/game screens in this ticket; consumer wiring belongs to `P2-004` and `P2-005`.

## Requirements

- Add `shared_preferences` via `flutter pub add`.
- Define an immutable `SaveData` value type with fields:
  - `bool soundEnabled` (default true)
  - `bool hapticsEnabled` (default true)
  - `int matchesCompleted` (default 0; needed later for ad gating, harmless to ship now)
- Define a `SaveService` with:
  - `Future<SaveData> load()`
  - `Future<void> save(SaveData data)`
  - A version key so future ticket changes can migrate safely.
- Tolerate missing keys; never throw on first install. Return defaults instead.
- Round-trip must be lossless: `save → load` returns the same `SaveData`.
- Make the service constructable with an injected `SharedPreferences` for testing (use `SharedPreferences.setMockInitialValues({})` in tests).
- Provide a Riverpod provider that exposes `SaveData` and a small notifier with `setSoundEnabled` / `setHapticsEnabled` / `recordMatchCompleted` methods. The notifier persists on every change.

## Design Notes

- Do not introduce JSON file storage, secure storage, or remote sync. `shared_preferences` is the spec-mandated MVP storage.
- Do not couple to `MatchState` or any in-game type. This service is a pure preferences store.
- The `matchesCompleted` field exists only so `P3` ad gating can consume it without a schema migration; do not add UI for it now.

## Verification

```bash
cd dink_rivals
flutter pub get
flutter analyze
flutter test
```

Required tests (in `save_service_test.dart`):

- Defaults when nothing is persisted.
- Round-trip preserves `soundEnabled`, `hapticsEnabled`, and `matchesCompleted`.
- Notifier `setSoundEnabled(false)` reflects in `load()` after restart (simulated by constructing a fresh service over the same mocked prefs).
- `recordMatchCompleted` increments by exactly one.

## Acceptance Criteria

- New service and tests are added and pass.
- No UI, screen, or gameplay file is modified.
- No data is persisted beyond the three documented fields.
- `tickets/status.md` and this ticket metadata are updated.
