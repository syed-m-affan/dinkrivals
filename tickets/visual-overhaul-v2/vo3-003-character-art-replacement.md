---
id: VO3-003
phase: visual-overhaul-v3
status: review
priority: critical
parallel_group: character-art
depends_on: [VO2-003, VO2-004]
owner: Asset Generation Agent + Asset Normalization Agent + Visual QA Agent
last_updated: 2026-05-12
---

# VO3-003 - Character Art Replacement

## Goal

Replace the failed VO2 player and opponent character art with concept-quality gameplay sprites that read as distinct athletes at phone gameplay distance.

## Scope

- Replace player sheets that failed art QA.
- Replace opponent sheets that failed art QA.
- Preserve the VO2 48x72 frame footprint and existing runtime filenames.
- Preserve gameplay behavior, hitboxes, scoring, physics, AI, and controls.
- Keep player and opponent silhouette, kit color, cap, paddle, and pose language distinct.

## Acceptance Criteria

- Player reads as the intended blue/white athlete with visible cap, torso, legs, and paddle in serve and rally screenshots.
- Opponent reads as a distinct red-identity rival in serve and rally screenshots.
- Neither character has halos, matte fringes, malformed limbs, unreadable face/torso separation, or style drift against the concept target.
- Gameplay-scale contact sheet and in-game screenshots are archived.
- Art-direction review explicitly accepts the replacement sheets before this ticket is marked `done`.

## Verification

Run from `dink_rivals/` after implementation:

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Capture serve/rally screenshots on emulator at minimum, and physical Pixel screenshots when hardware is visible.

## Recovery Notes

- 2026-05-12: User accepted the revised sprite direction but reported sprite artifacting.
- Runtime player/opponent sheets remain on the stronger generated-athlete source, normalized to the VO2 48x72 frame footprint.
- 2026-05-12: Player sheets were retuned into a blue version of the concept competitor, and opponent sheets were retuned toward the original red competitor rival while preserving the existing frame geometry.
- Deterministic cleanup hardened sprite alpha and filled enclosed transparent holes; no AI regeneration was used for this minor edit.
- Verification script reports no partial-alpha pixels and no enclosed transparent holes across all 22 player/opponent runtime sheets.
- 2026-05-12: User rejected the tall athlete sheets and requested the chibi direction. Runtime character sheets were moved to native 64x64 chibi cells using the installed `game-character-sprites` workflow as the acceptance model.
- Decision: move to 64x64 for the character runtime sheets. This is now worth it because the desired target is chibi, and 64x64 gives the larger head/compact body enough margin without clipping.
- Latest sprite audit reports 0 errors and 0 warnings.
- 2026-05-12: User rejected the first 64x64 chibi pass as much uglier despite smoother animation. Reworked the generator around the concept screenshot's shape language: player is now a blue-cap/white-shirt back-view competitor, opponent is a red-shirt/white-cap front-view rival, paddle is dark, and the old yellow-ring placeholder treatment is gone.
- The latest contact sheets remain technically clean, but this ticket stays in review until human art-direction signoff accepts the new look in-game.
- 2026-05-12: User rejected the manual redraw and requested the external `character-animation-creator-skill` workflow. Started a new skill-based run under `docs/art/visual-overhaul/skill-runs/character-animation-creator-2026-05-12/`.
- Skill-generated/imagegen-backed player/opponent ready and run strips were imported, chroma-key cleaned, validated, and integrated into runtime `idle`, `ready`, and `run` assets. This deliberately does not close the ticket yet: dink/drive/lob/smash/swing/hit-confirm/point-result rows still need skill-generated replacements before the character set is coherent.
- 2026-05-12: Completed the skill-generated runtime consistency pass for drive/serve, swing, dink, lob, smash, and hit-confirm. Point win/loss now reuse each character's generated ready sheet at runtime so point transitions no longer flash back to the rejected manual model.
- Removed the unused separate point-result sprite PNGs from `assets/images/sprites/`.
- 2026-05-12: Normalized runtime character sprite frames to a stable 56 px visible silhouette height with feet anchored at the bottom of each 64 px cell. This fixes generated action frames that visually shrank during lob/smash/drive/hit-confirm animations.
- 2026-05-12: Regenerated the remaining problem rows with the imagegen-backed sprite skill workflow: `player_drive.png`, `player_swing.png`, `player_smash.png`, `opponent_smash.png`, and derived `player_hit_confirm.png` from the regenerated drive. Rejected the first regenerated smash attempt because overhead frames still size-popped, then used grounded smash strips and widened narrow contact frames. Latest audit reports no clipping, no partial alpha, no green chroma residue, and stable frame heights.
- Added repo workflow documentation for future agents at `docs/art/visual-overhaul/sprite-generator-skill-workflow.md` and updated `AGENTS.md` plus the sprite asset README to block accidental use of the legacy procedural generator.
- New evidence:
  - `docs/art/visual-overhaul/skill-runs/character-animation-creator-2026-05-12/run-manifest.json`
  - `docs/art/visual-overhaul/contact-sheets/vo3-player-skill-runtime-sheets.png`
  - `docs/art/visual-overhaul/contact-sheets/vo3-opponent-skill-runtime-sheets.png`
  - `docs/art/visual-overhaul/contact-sheets/vo3-new-action-skill-sheets.png`
  - `docs/art/visual-overhaul/evidence/vo3-skill-sprite-audit.json`
- Evidence:
  - `docs/art/visual-overhaul/contact-sheets/vo2-player-normalized-runtime-sheets.png`
  - `docs/art/visual-overhaul/contact-sheets/vo2-opponent-normalized-runtime-sheets.png`
  - `docs/art/visual-overhaul/contact-sheets/vo2-player-competitor-runtime-sheets.png`
  - `docs/art/visual-overhaul/contact-sheets/vo2-opponent-competitor-runtime-sheets.png`
  - `docs/art/visual-overhaul/evidence/vo2-competitor-sprite-audit.txt`
  - `docs/art/visual-overhaul/evidence/vo2-competitor-sprite-audit.json`
  - `docs/art/visual-overhaul/sprite-overhaul-run/run-manifest.json`
  - `docs/art/visual-overhaul/sprite-overhaul-run/sprite-cell-size-decision.md`
  - `docs/art/visual-overhaul/evidence/vo2-sprite-alpha-diagnostic-after.png`
  - `docs/art/visual-overhaul/evidence/sprite-overhaul-emulator/chibi64_gameplay.png`
  - `docs/art/visual-overhaul/evidence/sprite-overhaul-emulator/gameplay_after_tap2.png`
  - `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/competitor_sprite_serve.png`
  - `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/serve_ui_latest.png`
  - `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/rally_ui_latest.png`
