---
id: VO2-000
phase: visual-overhaul-v2
status: done
priority: critical
parallel_group: overview
depends_on: []
blocks: [VO2-001, VO2-002, VO2-003, VO2-004, VO2-005, VO2-006, VO2-007, VO2-008]
owner: Art Direction Agent
last_updated: 2026-05-11
---

# VO2-000 - Visual Overhaul v2 Overview and Baseline

## Goal

Lock the v2 comparison evidence, shared style rules, prompt packets, phase map, and agent ownership before runtime or asset work begins.

## Source Spec

Primary source: `docs/specs/visual-overhaul-v2-spec.md`.

Quality target:

- `docs/art/concepts/concept-screenshot.png`
- `docs/art/concepts/concept-sheet.png`

Current-state evidence to beat:

- `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png`
- `docs/art/phase-5.2/phase-5.2-final-rally.png`
- `docs/art/phase-5.2/phase-5.2-final-serve.png`
- `phase5_current.png`

## Non-Negotiables

- 3/4 mobile portrait perspective is fixed.
- Gameplay readability wins over art density.
- Court geometry and hitbox math stay deterministic.
- New visual assets default to generated bitmap images.
- Store visual decisions in `lib/game/config/`; no magic numbers in components.
- All generated assets must be original.
- Every phase produces PNG evidence under `docs/art/visual-overhaul/evidence/vo2-*`.
- `flutter analyze` zero warnings and `flutter test` green at every runtime phase boundary.
- Physical Pixel install verified at VO2-008.
- Player-control affordances stay inside Android safe areas with at least 48 dp hit targets.
- All generated art inherits from `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`.

## Agent Role Map

| Role | VO2 phases | Owned scope |
| --- | --- | --- |
| Art Direction Agent | VO2-000 | Decomp doc, shared style rules, prompt packets, palette pulls |
| Asset Generation Agent | VO2-001, VO2-003, VO2-004, VO2-007 | Candidate PNGs, contact sheets |
| Asset Normalization Agent | VO2-003, VO2-004, VO2-007 | Crop, align, pivot, dimension fixes, manifest updates, style-rules gate |
| Runtime Integration Agent | VO2-001, VO2-002, VO2-005, VO2-006, VO2-007 | Dart code edits, config/tuning changes, component wiring |
| Visual QA Agent | VO2-001, VO2-003, VO2-004, VO2-005, VO2-006, VO2-008 | Emulator + Pixel captures, concept comparison |
| Performance QA Agent | VO2-002, VO2-005, VO2-008 | Frame pace, APK size, texture memory |
| Closeout Agent | VO2-008 | Comparison doc, residual ticket file-out, `PHASE_NOTES.md` update |

## Phase Index and Parallelism

Recommended order:

- Start with `VO2-000`.
- After shared style rules exist, `VO2-001` and `VO2-002` can run in parallel.
- `VO2-003` depends on `VO2-002`.
- `VO2-004` depends on `VO2-002` and can run after or alongside late player normalization if owned files are coordinated.
- `VO2-005` depends on character scale/art landing from `VO2-003` and `VO2-004`.
- `VO2-006` can run after `VO2-001` because HUD placement depends on the new venue composition.
- `VO2-007` depends on the sprite/environment/HUD visual language from `VO2-001`, `VO2-003`, `VO2-004`, and `VO2-006`.
- `VO2-008` closes the full chain.

## Owned Files

- `docs/art/visual-overhaul/visual-overhaul-v2-decomp.md`
- `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`
- `docs/art/visual-overhaul/prompts/vo2-character-player.md`
- `docs/art/visual-overhaul/prompts/vo2-character-opponent.md`
- `docs/art/visual-overhaul/prompts/vo2-environment-layers.md`
- `docs/art/visual-overhaul/prompts/vo2-signage.md`
- `docs/art/visual-overhaul/prompts/vo2-hud.md`
- `docs/art/visual-overhaul/prompts/vo2-portraits.md`
- `docs/art/visual-overhaul/evidence/vo2-baseline-*.png`
- `tickets/status.md`

## Tasks

- Capture fresh emulator screenshots: menu, roster, serve, rally, dink, drive, lob, smash, point-win, pause.
- Capture physical Pixel screenshots for the same set.
- Produce `docs/art/visual-overhaul/visual-overhaul-v2-decomp.md` covering character scale fractions, ball arc/trail spec, backdrop signage placement, HUD anchors, color palette pulls, and lighting direction.
- Publish `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md`.
- Publish the v2 prompt packets for character, environment-layer, signage, HUD, ball-trail, and portraits.
- Ensure every v2 prompt packet explicitly says it inherits from `vo2-shared-style-rules.md`.

## Acceptance Criteria

- At least 10 baseline PNGs under `vo2-baseline-*` exist for emulator and physical Pixel.
- `visual-overhaul-v2-decomp.md` lists explicit pixel/percentage targets for character height, ball diameter, score panel width, and plaque size.
- `vo2-shared-style-rules.md` exists and is referenced by every v2 prompt packet.
- All required prompt packets exist and include target dimensions, frame counts where applicable, pivot rules, palette pulls, lighting note, and reject checklist.

## Verification

Doc-only phase. Confirm referenced files exist. Flutter checks are skipped for this ticket unless implementation files are touched.
