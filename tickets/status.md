# Ticket Status

Last updated: 2026-05-10

## Current Assessment

Phase 0 is implemented and has been iterated through ten tuning/control passes. The codebase already includes a playable gray-box court, visible swing controls, full racket-segment hitbox, ball/shadow, pseudo-3D physics, opponent AI, debug overlay, reset point, deterministic tests, and Android install/run notes in `dink_rivals/PHASE_NOTES.md`.

Phase 0 remains in `review` until final human playtest confirms the latest swing-control/tuning questions in `PHASE_NOTES.md`. Phase 1 implementation is now present: match state, scoring, rules, point flow, expanded contact classifications, AI classification choices, score display, and rally feedback are implemented. Final Phase 1 manual Android QA is still pending.

Phase 2 tickets (`P2-001..P2-007`) are drafted and `todo`. Phase 2 wraps gameplay in a real app shell: GoRouter + Riverpod foundation, save service, main menu, roster placeholder, settings with persisted sound/haptics toggles, pause/resume, end-match summary, and Android verification. No phase-2 implementation work has started.

## Dashboard

| ID | Phase | Status | Priority | Parallel | Depends on | Summary |
| --- | --- | --- | --- | --- | --- | --- |
| P0-001 | 0 | review | high | legacy | [] | Original blank court rally loop ticket; implementation exists. |
| P0-002 | 0 | review | high | closeout | [] | Close Phase 0 with final QA, notes, and handoff cleanup. |
| P1-001 | 1 | done | high | A | [] | Add match state and scoring system. |
| P1-002 | 1 | done | high | B | [] | Add rules system for bounds, bounce, and kitchen faults. |
| P1-003 | 1 | done | high | C | [P1-001, P1-002] | Integrate point, serve, score, and match flow into the game loop. |
| P1-004 | 1 | done | high | D | [] | Expand shot types and hit/target logic for lob and smash. |
| P1-005 | 1 | done | medium | E | [P1-004] | Improve opponent AI for beginner rallies under Phase 1 shots/rules. |
| P1-006 | 1 | done | medium | F | [P1-001, P1-003, P1-004] | Add scoreboard and rally feedback text. |
| P1-007 | 1 | review | high | final | [P1-003, P1-005, P1-006] | Phase 1 verification, Android QA checklist, and notes. |
| P2-001 | 2 | todo | high | A | [] | App shell: GoRouter + Riverpod, route scaffolding for menu/game/settings/roster. |
| P2-002 | 2 | todo | high | B | [] | Save service backed by `shared_preferences` for sound/haptics/matches-completed. |
| P2-003 | 2 | todo | high | C | [P2-001] | Main menu with Quick Match / Roster / Settings, plus roster placeholder listing the four MVP characters. |
| P2-004 | 2 | todo | high | D | [P2-001, P2-002] | Settings screen with persisted Sound and Haptics toggles. |
| P2-005 | 2 | todo | high | E | [P2-001] | Game screen wrapper, Pause button, Pause overlay, and pause-aware `update(dt)`. |
| P2-006 | 2 | todo | high | F | [P2-001, P2-005] | End-match summary screen with Rematch / Return to Menu and `matchesCompleted` increment. |
| P2-007 | 2 | todo | high | final | [P2-002, P2-003, P2-004, P2-005, P2-006] | Phase 2 verification, Android QA checklist, and notes. |

## Open Coordination Notes

- Existing worktree has local changes from prior Phase 0 tuning. Do not revert them.
- `dink_rivals/PHASE_NOTES.md` is the authoritative playtest history.
- Phase 1 should preserve the current visible movement joystick, swing-stick racket control, automatic racket contact, full racket-segment hitbox, and enlarged play area unless a ticket explicitly changes them.
- Shot names are contact classifications, not UI commands. Do not add dink/drive/lob/smash buttons while completing current tickets.
- Scoring and rules should be testable outside Flame components.
- Avoid adding menus, ads, art, persistence, audio, or progression while Phase 1 is active.
- During Phase 2 work, preserve the Phase 0/Phase 1 control contract and all existing gameplay/AI/physics behavior. Only the wrapping app shell and persistence surfaces are in scope. No ads, no real audio/haptics, no art pass — those phases come later.
- Phase 2 must not break the "no forced ad before first gameplay" rule; ad logic does not exist yet and should not be introduced ahead of Phase 3.
