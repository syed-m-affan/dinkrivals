# Character Sprite Generated Atlas

Built-in image generation source: `docs/art/visual-overhaul/contact-sheets/character-sprite-generated-atlas.png`

Prompt summary: generated a two-row, eight-column pixel-art pickleball character atlas on flat `#00ff00` chroma-key. Rows are player and opponent. Columns are idle, ready, run 1, run 2, dink, horizontal drive, upward lob, and overhead smash. The runtime sprites were chroma-keyed, cropped, normalized to the existing 32x48 frame footprint, and exported into `dink_rivals/assets/images/sprites/`.

The generated atlas is the visual source of truth for the replacement character sheets; normalization only removes the key background, aligns feet to the existing anchor, and packs frames into the current Flame renderer format.
