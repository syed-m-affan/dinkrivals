---
id: PERSP-009
phase: perspective-overhaul
status: done
priority: high
parallel_group: audit
depends_on: [PERSP-003, PERSP-004, PERSP-005, PERSP-006, PERSP-007, PERSP-008]
blocks: [PERSP-010]
owner: unassigned
last_updated: 2026-05-11
---

# PERSP-009 - Gameplay Feel and Physics Audit Under the New Perspective

## Goal

Confirm that the gameplay still feels right after the perspective overhaul, and tune only the constants whose *perceptual* effect changes under the new projection. Logical-court physics is unchanged; what may need adjustment is the player's read of arc, height, and contact distance.

## Reference

- `docs/build-spec.md` non-negotiables, especially "gameplay feel before menus/monetization".
- `dink_rivals/lib/game/config/tuning_constants.dart` — the canonical tuning surface.

## Suggested file ownership

- `dink_rivals/lib/game/config/tuning_constants.dart` (only for narrow audit-driven changes; record each change in the ticket)
- `dink_rivals/test/ball_physics_system_test.dart`
- `dink_rivals/test/shot_system_test.dart`
- `dink_rivals/test/match_rules_system_test.dart`

Do not edit `BallPhysicsSystem`, `ShotSystem`, or `MatchRulesSystem` logic.

## What might break under the new perspective

1. **Ball altitude readability.** With a stronger trapezoid, a far-court lob now reads taller in screen pixels because of the new `zLiftForY`. The current `Tuning.lobInitialZ = 130` may now look excessive. **Test, do not pre-tune.**
2. **Smash window.** `Tuning.smashableBallMinZ = 48` is judged in court units; players will eyeball it. After the overhaul a ball at z=48 near the player looks higher than today (good — easier to read as smashable) and a ball at z=48 near the rival also looks higher. The eyeball judgment is now slightly more generous in both directions. No constant change is justified by the perspective alone — only by playtest evidence.
3. **Racket reach perception.** `racketReach = 42`, `committedSwingHorizontalHalfLength = 56` are in court units. They stay the same in court units; the visual swing lane therefore looks shorter near the far baseline (smaller depth scale) which is correct. The audit is to confirm the player does not feel cheated — re-balancing belongs to a future tuning ticket, not this one.
4. **AI aim.** `OpponentAISystem` aims at court coordinates and stays untouched. The perceived AI difficulty may shift slightly because the player's apparent court area changed; record any observation, do not retune AI in this ticket.
5. **Ball trail under perspective.** Trail samples may "ghost" if the projection changes mid-frame. Spot-check.
6. **Net collision.** The codebase currently does not collide the ball with the net mesh. Out of scope here; if the new perspective makes net pass-through more visible, file a follow-up rather than implementing collision.

## Required deliverables

- A short audit report appended to this ticket under `## Audit findings`:
  - Did any existing test in `ball_physics_system_test.dart`, `shot_system_test.dart`, or `match_rules_system_test.dart` change behavior? They should not — logical court coords are unchanged. If they did, find the regression.
  - Run 5 minutes of rally on `emulator-5554` or a physical Android device. Record (in writing) whether any of these felt wrong: serve power read, dink float, lob arc readability, smash window timing, drive trajectory readability.
  - For each item flagged, propose either: keep as-is, or open a follow-up ticket `PERSP-009-followup-*` outside this overhaul. Do **not** retune in-ticket unless a test fails.
- Add at least one new gameplay-feel test that uses the projection to assert a *perceptual* property without changing physics. Example:
  - `the projected screen distance from racket tip to a target at Court.netY exceeds X pixels` to guarantee the player can see the racket reach indicator.

## Verification

```bash
flutter analyze
flutter test
```

Manual: 5-minute rally on an Android device. Note frame-rate and crashes per `docs/build-spec.md` §5.4.

## Acceptance criteria

- Audit findings recorded.
- No physics or shot-system regressions in existing tests.
- At least one new perception-assertion test added.
- Any follow-ups filed as new tickets, not merged into this overhaul.

## Implementation notes

The overhaul keeps `Court.*` constants, `BallState` semantics, physics constants, shot classification, scoring, and opponent AI unchanged. New perception tests cover lob lift, baseline depth separation, racket reach readability, and z-lift depth ratio.

## Audit findings

- Existing physics/rules/shot tests remain green; logical gameplay coordinates did not change.
- Serve, dink, lob, smash, drive, and AI tuning were not retuned in this ticket. Any remaining subjective feel issue after human playtest should be filed as a follow-up tuning ticket.
- Ball-net collision remains out of scope. The renderer now restores visual net occlusion, but no gameplay collision is added.
