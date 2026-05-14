---
id: VO3-006
phase: visual-overhaul-v3
status: review
priority: critical
parallel_group: environment-art
depends_on: [VO2-001, VO2-005]
owner: Runtime Integration Agent + Visual QA Agent
last_updated: 2026-05-14
---

# VO3-006 - Net and Visibility Correction

## Goal

Correct the VO2 net and near-net visibility issues so the net, ball, player, opponent, and court lines remain readable during serves, rallies, and net-adjacent shots.

## Scope

- Fix net art/layering that obscures or confuses gameplay objects.
- Preserve deterministic court projection and logical net position.
- Keep ball depth, shadows, and VFX readable around the net.
- Keep player/opponent occlusion rules clear when crossing or standing near the net.
- Do not alter scoring/rules, ball physics, AI, input, or shot classification.

## Acceptance Criteria

- Ball remains visible when crossing the net and during near-net contacts.
- Player and opponent remain readable on both sides of the net.
- Net reads as a pickleball net, not a visual wall or unrelated stripe.
- Court lines and kitchen boundaries remain legible behind/around the net.
- Serve, rally, dink, lob, and smash screenshots pass visual QA.

## Verification

Run from `dink_rivals/` after implementation:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Capture evidence for at least serve, rally, dink, lob, and smash states.

## Recovery Notes

- 2026-05-14: Net treatment has moved out of graybox styling. `NetComponent`
  remains procedural and sorted at `Court.netY`, but now uses the current
  palette rail/mesh/post colors over the projection-locked environment asset.
  Emulator game/debug-rally evidence under
  `docs/art/visual-overhaul/evidence/projection-environment-v1/` shows the net,
  ball, player, opponent, court lines, and kitchen highlight remain readable.
  Additional debug drive/lob/smash gesture captures and point/shot-feedback
  captures exist in the same folder. Review remains open for physical-device
  evidence, human visual signoff, and any missing live-flow shot states such as
  dink if final QA requires the full shot matrix.
- 2026-05-13: Current-state update. The current runtime uses a procedural
  graybox net instead of the previous painted `layer_net.png` path. Net
  visibility should be judged with projection and boundary readability during
  the graybox pass first; final net art belongs to the later fresh environment
  rebuild.
- 2026-05-12: `NetComponent` now crops the measured net strip from `layer_net.png` instead of drawing the full source layer over the playfield.
- `layer_net.png` was rebuilt so pixels outside the net strip are transparent and the net overlay alpha is reduced.
- Latest emulator serve/rally evidence shows the opponent and ball remain visible around the net:
  - `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/serve_ui_latest.png`
  - `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/rally_ui_latest.png`
- Remaining review item: serve/rally is covered, but dink/lob/smash-specific fresh captures are not yet reliable enough to claim final closeout.
