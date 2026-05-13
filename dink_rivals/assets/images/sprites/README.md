Generated character sprite notes
================================

The current player and opponent runtime sheets are native 64x64 chibi cells
from the imagegen-backed sprite skill workflow, not from the old procedural
generator.

Workflow documentation:

- `docs/art/visual-overhaul/sprite-generator-skill-workflow.md`
- `docs/art/visual-overhaul/skill-runs/character-animation-creator-2026-05-12/run-manifest.json`

The checked-in set covers idle, ready, run, dink, drive, lob, smash, swing, and
hit-confirm for both player and opponent. Run uses 12 frames; action rows use 6
frames; hit-confirm uses 4 derived generated-model frames. Point win/loss poses
currently reuse each character's generated `ready` sheet at runtime, so there
are no separate point-result sprite PNGs.

The current style is concept-guided chibi pixel art: near-side player as a
blue-cap, white-shirt back-view competitor, and far-side opponent as the red
shirt / white-cap front-view rival. Sprite alpha is binary, cells are audited
for edge contact, and the paddle treatment is dark to match the concept sheet.
These assets are visual only; gameplay hit feel is controlled by
`lib/game/config/tuning_constants.dart`.

Do not run `tool/generate_chibi_64_sprites.py` over these assets unless the
user explicitly asks for a legacy procedural fallback. That script belongs to
the rejected manual pass and will overwrite the accepted skill-generated model.

Latest QA artifacts:

- `docs/art/visual-overhaul/contact-sheets/vo3-player-skill-runtime-sheets.png`
- `docs/art/visual-overhaul/contact-sheets/vo3-opponent-skill-runtime-sheets.png`
- `docs/art/visual-overhaul/evidence/vo3-skill-sprite-audit.json`
- `docs/art/visual-overhaul/skill-runs/character-animation-creator-2026-05-12/run-manifest.json`
