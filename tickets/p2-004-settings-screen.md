---
id: P2-004
phase: 2
status: todo
priority: high
parallel_group: D
depends_on: [P2-001, P2-002]
blocks: [P2-007]
owner: unassigned
last_updated: 2026-05-10
---

# P2-004 - Settings Screen with Persisted Toggles

## Goal

Implement the Settings screen with Sound and Haptics toggles backed by `P2-002`'s `SaveService`. The toggles must persist across app restarts. There is no audio or haptics implementation in Phase 2 — toggles only need to read and write the preference value.

## Build Spec Coverage

Phase 2 tasks:

- Create settings screen.
- Save sound/haptics settings.

## Suggested File Ownership

- `dink_rivals/lib/screens/settings_screen.dart`.
- `dink_rivals/test/settings_screen_test.dart` (widget test).
- Riverpod consumer wiring as needed in `lib/screens/settings_screen.dart` only.

Do not modify `SaveService`, `SaveData`, the router, the main menu, the game screen, or any `lib/game/**` file.

## Requirements

- Two toggle rows: **Sound** and **Haptics**. Both default to the on state on a fresh install.
- Each toggle reads the current value from the Riverpod save provider and persists the change immediately.
- A back-to-menu affordance returns to `/`.
- A clearly labeled "Phase 2 — gray-box settings" header so users and QA know they are on the Phase 2 placeholder, not a final settings screen.
- No additional settings rows in this ticket. Specifically: do not add language, controller layout, difficulty, music vs sfx split, account, restore purchases, remove ads, or "watch ad to double rewards". Those belong to later phases.

## Design Notes

- Phase 5 will add real SFX and haptics. In Phase 2 the toggles only persist values; they have no observable in-game effect yet. Acceptance does not require sound or haptics to actually trigger.
- The settings screen is the first non-trivial Riverpod consumer; keep it small and declarative.

## Verification

```bash
cd dink_rivals
flutter analyze
flutter test
flutter build apk --debug
```

Required tests:

- Widget test: toggling Sound updates the displayed switch state and calls the notifier's `setSoundEnabled`.
- Widget test: toggling Haptics calls `setHapticsEnabled`.
- Optional integration check: reading back from a freshly constructed `SaveService` reflects the persisted value.

Manual smoke:

- Open Settings from menu.
- Toggle Sound off, return to menu, reopen Settings — toggle reflects off.
- Kill and relaunch the app, reopen Settings — toggle still reflects off.

## Acceptance Criteria

- Sound and Haptics toggles persist across app restart.
- No regression on existing tests.
- No audio or haptics dependency added (Phase 5 owns that).
- No extra settings rows ship in this ticket.
- `tickets/status.md` and this ticket metadata are updated.
