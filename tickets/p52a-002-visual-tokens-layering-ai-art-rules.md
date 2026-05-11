---
id: P52A-002
phase: 5.2A
status: done
priority: high
parallel_group: A
depends_on: [P52A-001]
blocks: [P52B-001, P52C-001, P52D-001, P52E-001, P52F-001, P52G-001, P52H-001, P52I-001, P52J-001, P52K-001, P52L-001]
owner: codex
last_updated: 2026-05-11
---

# P52A-002 - Visual Tokens, Layering, and AI Art Rules

## Goal

Create the shared Phase 5.2 visual foundation so parallel agents can generate and implement cohesive art without hardcoded colors, inconsistent sprite styles, or layering conflicts.

## Build Spec Coverage

Phase 5.2A2 - Visual Tokens, Layering, and AI Art Rules:

- `VisualPalette` extension.
- Render-layer and safe-area notes.
- AI prompt/export rules for high-quality cohesive assets.
- Contact-sheet expectations for asset tickets.

## Suggested File Ownership

- `dink_rivals/lib/game/config/visual_palette.dart`
- `docs/art/render-layer-map.md`
- `docs/art/visual-direction.md`
- `docs/art/phase-5.2-art-direction.md`
- `tickets/status.md`

Avoid editing feature components beyond token references needed to keep analyzer/tests green.

## Requirements

- Add or document shared palette tokens for:
  - court apron
  - kitchen tint
  - signage/banner surfaces
  - feedback banner background and border
  - rally/last-shot labels
  - serve meter fill/empty states
  - any new Phase 5.2 environment accents
- Update render-layer notes for backdrop signage, rear fence, net mesh/rail/shadow, ball trail, feedback banner, scoreboard, and controls.
- Add safe-area guidance: scoreboard, pause, and top-center feedback banner must not overlap; feedback sits below the top HUD row on notched/tall devices.
- Create reusable AI art prompt packets for sprites, portraits, signage, environment props, and VFX.
- Define asset export rules:
  - transparent PNG where needed
  - no black matte halos
  - no premultiplied-alpha fringe
  - consistent outline weight and lighting direction
  - stable gameplay-scale dimensions and foot baselines
  - contact-sheet proof under `docs/art/`
- Record that backdrop sign text must be original; avoid trademarked or copied text.

## Non-Goals

- No gameplay feature work.
- No final character, court, VFX, HUD, or environment implementation.
- No licensed or image-search-derived production assets.

## Verification

Run from `dink_rivals/` if code tokens change:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Phase 5.2 implementation tickets can reference concrete token names and layer rules.
- Asset-producing tickets have prompt/export/contact-sheet requirements.
- No new hardcoded color literals are required for Phase 5.2 visuals.

## Planning Notes

- Claude specifically identified token drift and AI asset inconsistency as high risks. Codex subagents agreed this foundation ticket should block parallel implementation.

## Implementation Notes

- Implemented: extended `VisualPalette`, updated `docs/art/render-layer-map.md`, and added `docs/art/phase-5.2-art-direction.md` with generated-asset constraints.
- Verification: `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator install/launch on `emulator-5554`, and `docs/art/phase-5.2-gameplay-emulator-smoke.png`.
