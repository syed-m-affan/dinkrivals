---
id: P1-009
phase: 1
status: in_progress
priority: medium
parallel_group: A
depends_on: []
blocks: [P1-007]
owner: claude
last_updated: 2026-05-10
---

# P1-009 - Lob and Smash Rarely Trigger

## Problem

In the 2026-05-10 playtest the player never saw lob or smash classifications. The thresholds are set so high that no naturally-occurring ball state satisfies them.

## Findings

- `smashMinBallHeight = 64`. Peak `z` of any in-play ball is roughly `vz^2 / (2 * gravity * arcGravityScale)`. With `lobInitialZ = 86` and `lobArcGravityScale = 0.54`, the lob peak is ~15 units — far below 64. So smashes are essentially unreachable.
- `lobAngleThreshold = 0.86` on `|face.x|` requires the racket to be at ~60° off-axis, which the player has no natural reason to do.
- AI lob probability is gated on both players being near the kitchen, so it rarely picks lob either.

## Fix

- Make lobs actually go high:
  - `lobInitialZ`: 86 → 130
  - `lobArcGravityScale`: 0.54 → 0.40 (peak ~52 units)
- Make smash reachable when a lob is returned:
  - `smashMinBallHeight`: 64 → 28
  - `opponentSmashMinBallHeight`: 80 → 30
- Make player-driven lob slightly more discoverable:
  - `lobAngleThreshold`: 0.86 → 0.65 (~40° off-axis)
- Give the AI more reason to lob:
  - `opponentLobProbability`: 0.18 → 0.32
- Better speed contrast for smash now that drive is slower (see P0-005):
  - covered by P0-005 tuning of `smashSpeedXY`.

## Verification

- Existing smash height test still passes (it uses `smashMinBallHeight ± 5`, so the assertion is relative to the constant).
- Existing lob test still passes (uses `lobAngleThreshold` indirectly via direction `(0.9, -0.4)`).
- On device: AI throws occasional lobs; returning a lob produces a smash classification.

## Acceptance Criteria

- Lob and smash classifications visibly trigger in normal play.
- AI uses lobs at reasonable frequency.
- Smash threshold is achievable from a returned lob.
