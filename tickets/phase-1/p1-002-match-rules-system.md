---
id: P1-002
phase: 1
status: done
priority: high
parallel_group: B
depends_on: []
blocks: [P1-003, P1-007]
owner: codex
last_updated: 2026-05-10
---

# P1-002 - Match Rules System

## Goal

Add pure rule evaluation for Phase 1 faults: out of bounds, double bounce, and kitchen volley fault.

## Build Spec Coverage

Phase 1 tasks:

- Add `MatchRulesSystem`.
- Add in/out detection.
- Add bounce rules.
- Add kitchen volley rule.
- Add unit tests for rules.

## Suggested File Ownership

- `dink_rivals/lib/game/systems/match_rules_system.dart`
- `dink_rivals/lib/game/models/rule_result.dart` if useful.
- `dink_rivals/test/match_rules_system_test.dart`
- `dink_rivals/lib/game/models/ball_state.dart` only if additional bounce metadata is required.

Avoid changing `BallPhysicsSystem` behavior in this ticket unless the rule system cannot observe enough state. If physics metadata is needed, keep it small and test it.

## Requirements

- Detect when the ball lands outside `Court.left/right/top/bottom`.
- Detect a second bounce on the same side.
- Detect volley inside the kitchen by the side that hit the ball.
- Return a clear result that identifies whether play continues, which side won the point, and why.
- Do not award points directly; scoring integration belongs to `P1-003`.
- Keep the API deterministic and testable without Flame rendering.

## Important Existing Behavior

Phase 0 currently rebounds the ball from court boundaries to keep rallies alive. Phase 1 needs real out-of-bounds detection. Handle this deliberately during integration:

- The rule system should be able to detect out before any optional rebound/clamp hides it.
- If changing physics is required, document it in this ticket and update ball physics tests.

## Verification

Run:

```bash
cd dink_rivals
flutter analyze
flutter test
```

Required tests:

- In-bounds ground contact continues play.
- Out-of-bounds landing awards the point to the other side.
- Double bounce awards the point to the other side.
- Player kitchen volley awards the point to opponent.
- Opponent kitchen volley awards the point to player.

## Acceptance Criteria

- Rules tests pass.
- Rules are pure and reusable by game loop integration.
- No UI or score display work is included.
- `tickets/status.md` and this ticket metadata are updated.
