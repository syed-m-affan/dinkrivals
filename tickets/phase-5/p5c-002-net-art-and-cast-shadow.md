---
id: P5C-002
phase: 5C
status: done
priority: high
parallel_group: B
depends_on: [P5A-003]
blocks: [P5C-003, P5G-001]
owner: unassigned
last_updated: 2026-05-11
---

# P5C-002 - Net Art, Posts, Mesh, and Cast Shadow

## Goal

Upgrade the net from a simple drawn plane into a readable pixel-art object with posts, rail, mesh, and cast shadow.

## Build Spec Coverage

Phase 5C - Court Material, Net, Lighting, and Shadows:

- Net posts, net rail, mesh, and net shadow closer to concept screenshot.
- Net reads as a physical object with depth.

## Suggested File Ownership

- `dink_rivals/assets/images/court/net_*.png` (new, if using sprites)
- `dink_rivals/lib/game/components/net_component.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/test/` only if render helper behavior is added
- `tickets/status.md`

Do not edit ball physics, shot classification, court projection, or AI.

## Requirements

- Add or draw net posts, top rail, mesh, and subtle cast shadow.
- Preserve existing net y priority behavior and player/ball depth ordering.
- Ensure mesh does not hide the ball or paddles during contact moments.
- Use `VisualPalette` for colors and alpha values.
- Keep the net readable over the richer court texture from P5C-001.

## Non-Goals

- No court texture changes.
- No player/opponent sprites.
- No gameplay collision changes.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Acceptance Criteria

- Net reads as a physical object with depth.
- Ball and players remain readable when crossing or standing near the net.
- No scoring, physics, AI, or controls changes.

## Implementation Notes

- Upgraded drawn net with cast shadow, top-rail shadow, post highlights, vertical mesh, and reduced diagonal mesh.
- Claude review flagged mesh busyness and rail-shadow risks; diagonal mesh density/alpha and top-rail shadow width were reduced before verification.
