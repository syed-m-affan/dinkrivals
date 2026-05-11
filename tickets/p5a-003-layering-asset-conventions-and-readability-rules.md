---
id: P5A-003
phase: 5A
status: done
priority: high
parallel_group: C
depends_on: [P5A-002]
blocks: [P5B-002, P5C-002, P5D-002, P5E-002, P5F-002]
owner: unassigned
last_updated: 2026-05-11
---

# P5A-003 - Layering, Asset Conventions, and Readability Rules

## Goal

Define concrete folder, naming, draw-order, and occlusion rules before adding environment and VFX assets.

## Build Spec Coverage

Phase 5A - Concept Frame and Art Direction Lock:

- Target asset folders.
- Target draw-order map for court, environment, props, players, ball, shadows, VFX, HUD, and controls.
- Safe-area layout notes for tall Android phones.

## Suggested File Ownership

- `docs/art/visual-direction.md`
- `docs/art/render-layer-map.md` (new)
- `dink_rivals/assets/images/environment/classic/.gitkeep` (new)
- `dink_rivals/assets/images/environment/shared/.gitkeep` (new)
- `dink_rivals/assets/images/vfx/.gitkeep` (new)
- `dink_rivals/assets/images/ui/hud/.gitkeep` (new)
- `dink_rivals/pubspec.yaml`
- `tickets/status.md`

Do not add actual production art in this ticket beyond `.gitkeep` placeholders.

## Requirements

- Create target asset folders:
  - `assets/images/environment/classic/`
  - `assets/images/environment/shared/`
  - `assets/images/vfx/`
  - `assets/images/ui/hud/`
- Register the folders in `pubspec.yaml`.
- Create `docs/art/render-layer-map.md` documenting intended order for:
  - background/environment
  - off-court props
  - court surface
  - court markings/kitchen/net shadow
  - player/opponent shadows
  - player/opponent/paddles
  - ball shadow/ball
  - contact VFX
  - HUD/controls/feedback
- Document occlusion rules: decorative props must not cover active court lines, ball shadow, controls, score, pause, or feedback text.
- Document SafeArea expectations for tall Android phones.

## Non-Goals

- No environment component implementation.
- No VFX implementation.
- No UI restyle.
- No changes to `CourtProjection` or `CourtLayoutSystem`.

## Verification

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
```

## Acceptance Criteria

- Asset folders exist and are declared.
- Render-layer and occlusion rules are documented.
- Later implementation tickets can avoid draw-order conflicts.

## Implementation Notes

- Added `docs/art/render-layer-map.md` with draw order, occlusion rules, SafeArea rules, folder conventions, and naming conventions.
- Added the Phase 5A target asset folders and registered them in `pubspec.yaml`.
