---
id: P5C-003
phase: 5C
status: todo
priority: medium
parallel_group: C
depends_on: [P5C-001, P5C-002]
blocks: [P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5C-003 - Shared Shadows and Lighting Pass

## Goal

Add coherent directional shadows and subtle lighting/tint support for gameplay and environment objects without muddying court readability.

## Build Spec Coverage

Phase 5C - Court Material, Net, Lighting, and Shadows:

- Directional player, ball, paddle, and prop shadows.
- Optional time-of-day tint if it improves depth.
- Shared shadow helpers/components where useful.

## Suggested File Ownership

- `dink_rivals/lib/game/components/shadow_component.dart`
- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/components/racket_component.dart`
- `dink_rivals/lib/game/components/classic_environment_component.dart` (if present)
- `dink_rivals/lib/game/util/` or `lib/game/components/` for a shared shadow helper
- `dink_rivals/lib/game/config/visual_palette.dart`
- `tickets/status.md`

Do not alter entity positions, physics, hitboxes, or court projection math.

## Requirements

- Define a shared approach for shadow color, direction, opacity, and depth scale.
- Keep the existing ball-shadow height behavior or improve it without changing ball state.
- Add or refine player/opponent/paddle/prop shadows where the result helps depth.
- If a global tint is added, keep it configurable and subtle.
- Verify shadows do not obscure court lines, kitchen, ball, or ball shadow.

## Non-Goals

- No new VFX.
- No animation changes.
- No gameplay changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Shadows consistently reinforce depth.
- Court lines, kitchen, and ball remain readable.
- Existing physics, scoring, AI, and shot tests remain green.

