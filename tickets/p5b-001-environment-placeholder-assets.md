---
id: P5B-001
phase: 5B
status: todo
priority: high
parallel_group: A
depends_on: [P5A-002, P5A-003]
blocks: [P5B-002, P5B-003]
owner: unassigned
last_updated: 2026-05-11
---

# P5B-001 - Classic Court Environment Placeholder Assets

## Goal

Generate consistent placeholder pixel assets for the Classic Court park environment, based on the visual direction notes.

## Build Spec Coverage

Phase 5B - Courtside Environment and Depth Dressing:

- Trees, shrub clusters, benches, lamp posts, signs, banners, bags, and courtside props.
- Off-court ground surface and soft environmental shadows.

## Suggested File Ownership

- `dink_rivals/assets/images/environment/classic/`
- `dink_rivals/assets/images/environment/shared/`
- `docs/art/visual-direction.md` (reference only)
- `tickets/status.md`

Avoid editing Dart code in this ticket.

## Requirements

- Add placeholder pixel assets for at least:
  - off-court ground tile
  - far fence or wall segment
  - tree cluster
  - shrub cluster
  - bench
  - lamp post
  - banner/sign
  - equipment bag
  - soft shadow patch
- Assets must be generated or hand-authored locally; do not use licensed art.
- Keep asset sizes and naming aligned with P5A-003 conventions.
- Add a short asset manifest in `assets/images/environment/classic/README.md` listing each asset, intended use, dimensions, and whether it is placeholder or final.

## Non-Goals

- No environment rendering code.
- No court texture or net changes.
- No gameplay or layout changes.

## Verification

- Confirm every asset referenced by the manifest exists.
- If image generation scripts are used, document the generation approach in the manifest.

## Acceptance Criteria

- Environment asset set is complete enough for P5B-002 to render a park setting.
- All assets are original placeholder art or explicitly license-safe.
- No runtime behavior changes.

