---
id: P52E-001
phase: 5.2D
status: todo
priority: high
parallel_group: D
depends_on: [P52A-002]
blocks: [P52K-001, P52M-001]
owner: unassigned
last_updated: 2026-05-11
---

# P52E-001 - Backdrop Fence and Signage Band

## Goal

Add a concept-like rear fence signage band with original Dink Rivals branding and a secondary park sign, without crowding the opponent, scoreboard, or top feedback banner.

## Build Spec Coverage

Phase 5.2D - Backdrop Signage:

- Rear fence signage band.
- "DINK RIVALS" banner.
- Original secondary park sign.
- Data-driven placement.

## Suggested File Ownership

- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/assets/images/environment/classic/`
- `docs/art/phase-5.2-signage-contact-sheet.png`
- `docs/art/phase-5.2-signage.png`
- `tickets/status.md`

Coordinate with P52K before changing shared environment layout data.

## Requirements

- Add rear fence/banner placement through environment config or data structures, not scattered pixel literals.
- Create or generate original sign assets:
  - one Dink Rivals banner
  - one secondary non-trademarked park sign such as "PARK COURTS" or "PICKLEBALL LEAGUE"
- Keep signage behind gameplay priority: lower contrast than players, ball, court lines, net, scoreboard, pause, and feedback.
- Include a contact sheet or screenshot proof under `docs/art/`.
- Preserve existing prop aspect-ratio handling from Phase 5.1.
- Ensure signs do not overlap opponent silhouette, scoreboard, pause, or feedback banner on tall phone captures.

## Non-Goals

- No dynamic billboards.
- No new brands, licensed logos, trademarked text, unlocks, court-selection flow, or monetization.
- No park depth props beyond signage; P52K owns that pass.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

## Acceptance Criteria

- Backdrop signage is visible and concept-like at gameplay scale.
- Sign assets are original and cohesive with Phase 5.2 art rules.
- Signs do not reduce opponent, ball, court, or HUD readability.
- Existing environment tests still pass.

## Planning Notes

- Claude flagged "Pickleball Legends" wording as a trademark/copy risk. Use original secondary sign text.
