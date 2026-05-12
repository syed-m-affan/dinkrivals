# Ticket System

This directory is the handoff surface for agents working on Dink Rivals.

Every implementation ticket should be a standalone Markdown file with the metadata block below at the top. Keep tickets small enough that one agent can finish one ticket without needing to coordinate with unrelated files.

```yaml
---
id: P1-001
phase: 1
status: todo
priority: high
parallel_group: A
depends_on: []
blocks: [P1-003]
owner: unassigned
last_updated: 2026-05-10
---
```

## Directory Layout

Tickets are grouped by numeric phase folder. Letter suffixes belong to the numeric phase that precedes them. Examples:

- `phase-0/` through `phase-5/` contain the main phase tickets.
- `P5A-*` through `P5H-*` tickets live in `phase-5/`.
- `P51A-*` through `P51I-*` tickets live in `phase-5.1/`.
- `P52A-*` through `P52M-*` tickets live in `phase-5.2/`.
- `perspective-overhaul/` contains the PERSP ticket track.

Keep `README.md` and `status.md` at the root of `tickets/`.

## Status Values

- `todo`: ready to pick up.
- `in-progress`: an agent is actively working it.
- `blocked`: cannot proceed until a listed dependency or decision is resolved.
- `review`: implementation is done, but tests, QA, or human playtest confirmation is pending.
- `done`: acceptance criteria and verification steps are complete.

## Agent Workflow

1. Read `AGENTS.md`, `docs/specs/build-spec.md`, `dink_rivals/PHASE_NOTES.md`, `tickets/status.md`, and the ticket file.
2. Before editing code, set the ticket status to `in-progress`, set `owner`, update `last_updated`, and add a short note in `tickets/status.md`.
3. Respect `depends_on`, `parallel_group`, and `Suggested file ownership`.
4. Keep implementation scoped to the ticket. If you need to edit outside the suggested files, record why in the ticket under `Implementation notes`.
5. Run the verification listed in the ticket. At minimum for Phase 1 code changes, run:

```bash
cd dink_rivals
flutter analyze
flutter test
```

For emulator smoke checks, use the local `dink_rivals_qa` AVD when available:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd dink_rivals_qa
```

Then from `dink_rivals/`:

```bash
flutter devices
flutter run -d emulator-5554
```

Or install a built APK:

```bash
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

Emulator screenshots and launch checks are useful for ticket review notes, but physical Android QA is still required when the ticket or build spec says a phase cannot be marked done without it.

6. When finished, update the ticket with verification results, known issues, and any follow-up tickets needed.
7. Move the ticket to `review` if Android device QA or human playtest remains. Move it to `done` only when all ticket acceptance criteria are met.
8. Update `tickets/status.md` in the same change.

## Current Control Contract

All current and future Phase 0/Phase 1 tickets inherit this contract unless a new accepted playtest ticket explicitly changes it:

- Left virtual stick moves the player.
- Right virtual stick swings the racket through the front 180-degree arc.
- The right stick controls racket angle and swing velocity only; it does not select shot type.
- The full racket segment from player body to racket tip is the player hitbox.
- Hits are automatic when ball/racket contact occurs at hittable height with enough relative speed.
- `dink`, `drive`, `lob`, `smash`, `block`, and `serve` are contact classifications for physics, AI, feedback, stats, and tests. They are not player-facing shot buttons.
- Do not add dink/drive/lob/smash buttons or resurrect tap/hold shot-button input while completing current tickets.

## Parallel Work Rules

Tickets in different parallel groups can usually be worked in parallel. Tickets in the same group may touch the same files and should be serialized unless agents explicitly coordinate.

Use the `Suggested file ownership` section in each ticket as the first conflict-avoidance rule. Do not rewrite unrelated systems while completing a ticket.

## Phase Gates

Phase 0 can be marked done only after `P0-002` is complete.

Phase 1 can be marked done only after every `P1-*` ticket is done and `P1-007` confirms Android QA.
