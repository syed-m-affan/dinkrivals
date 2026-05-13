# Sprite Generator Skill Workflow

Use this workflow for character sprite work. The accepted runtime character art is based on the external skill at:

`https://github.com/tachikomared/character-animation-creator-skill/blob/main/SKILL.md`

The local checkout used for the current pass is:

`.codex_tmp/character-animation-creator-skill`

## Current Run

The current skill run lives at:

`docs/art/visual-overhaul/skill-runs/character-animation-creator-2026-05-12/`

Key outputs:

- `run-manifest.json`
- `source/*-imagegen.png`
- `64/generated/*.png`
- `64/final/*-sheet-clean.png`
- `64/qa/*-validation.json`
- `64/qa/previews/*`

Runtime sheets are checked into:

`dink_rivals/assets/images/sprites/`

## Required Rules

- Generate character action strips with image generation, not the old procedural sprite script.
- Use one horizontal strip per side/action/direction.
- Use native `64x64` cells.
- Use 6 frames for action strips unless the runtime state already requires a different count.
- Use pure `#00ff00` as the temporary chroma-key background.
- Copy every generated source image into the run folder under `source/`.
- Clean the imported strip before runtime integration.
- Validate every final strip and keep the validation JSON.
- Do not leave embedded balls, hit sparks, motion trails, or court props in character sheets. Runtime owns the ball and VFX layers.
- Do not integrate a sheet if any frame switches back to the rejected old/manual model.

## Import And Clean

From the repository root, import one generated strip:

```powershell
python .codex_tmp\character-animation-creator-skill\scripts\import_imagegen_contact_sheet.py `
  --input docs\art\visual-overhaul\skill-runs\<run>\source\player-drive-north-imagegen.png `
  --run-dir docs\art\visual-overhaul\skill-runs\<run> `
  --action drive `
  --direction north `
  --sizes 64 `
  --columns 6 `
  --key-color "#00ff00"
```

Clean it:

```powershell
python .codex_tmp\character-animation-creator-skill\scripts\pixel_snap.py `
  --input docs\art\visual-overhaul\skill-runs\<run>\64\generated\drive-north.png `
  --output docs\art\visual-overhaul\skill-runs\<run>\64\final\player-drive-north-sheet-clean.png `
  --cell 64 `
  --palette 64 `
  --alpha-threshold 24 `
  --chroma-key "#00ff00"
```

Validate it:

```powershell
python .codex_tmp\character-animation-creator-skill\scripts\validate_sheet.py `
  --input docs\art\visual-overhaul\skill-runs\<run>\64\final\player-drive-north-sheet-clean.png `
  --cell 64 `
  --columns 6 `
  --rows 1 `
  --json-out docs\art\visual-overhaul\skill-runs\<run>\64\qa\player-drive-north-validation.json `
  --contact-sheet docs\art\visual-overhaul\skill-runs\<run>\64\qa\player-drive-north-contact-sheet.png `
  --row-names player-drive-north
```

Export a preview when judging motion:

```powershell
python .codex_tmp\character-animation-creator-skill\scripts\export_animation_previews.py `
  --atlas docs\art\visual-overhaul\skill-runs\<run>\64\final\player-drive-north-sheet-clean.png `
  --out-dir docs\art\visual-overhaul\skill-runs\<run>\64\qa\previews `
  --rows 1 `
  --columns 6 `
  --cell 64 `
  --scale 4 `
  --duration 130 `
  --prefix player-drive-north `
  --row-names player-drive-north
```

## Runtime Integration

Player sheets are north/up-court/back-view. Opponent sheets are south/down-court/front-view.

Map generated strips into runtime assets like this:

- `drive` also backs `swing` and serve visuals.
- `hit_confirm` must be derived from a generated-model action strip, not from an old sheet.
- `point_win` and `point_loss` currently reuse the generated `ready` sheets at runtime. Do not add separate point-result PNGs unless expressive generated-model result poses are authored and wired deliberately.

After integration, update:

- `docs/art/visual-overhaul/skill-runs/<run>/run-manifest.json`
- `docs/art/visual-overhaul/contact-sheets/vo3-player-skill-runtime-sheets.png`
- `docs/art/visual-overhaul/contact-sheets/vo3-opponent-skill-runtime-sheets.png`
- `docs/art/visual-overhaul/evidence/vo3-skill-sprite-audit.json`

Then run:

```powershell
cd dink_rivals
flutter analyze
flutter test test\player_component_test.dart
```

Run broader visual tests or an emulator capture before closing a visual ticket.

## Legacy Generator

`dink_rivals/tool/generate_chibi_64_sprites.py` is legacy fallback tooling from the rejected manual pass. Do not use it to regenerate production character sprites for the current visual direction unless the user explicitly asks for a procedural fallback.
