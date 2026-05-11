# Character Sprite Generated Atlas

Built-in image generation source: `docs/art/visual-overhaul/contact-sheets/character-sprite-generated-atlas.png`

Prompt summary: generated a two-row, eight-column pixel-art pickleball character atlas on flat `#00ff00` chroma-key. Rows are player and opponent. Columns are idle, ready, run 1, run 2, dink, horizontal drive, upward lob, and overhead smash. The runtime sprites were chroma-keyed, cropped, normalized to the existing 32x48 frame footprint, and exported into `dink_rivals/assets/images/sprites/`.

The generated atlas is the source of truth for the replacement character sheets.
The first normalization pass removed the key background, aligned feet to the
existing anchor, and packed frames into the current Flame renderer format.

The checked-in runtime sheets then apply a moderate simplification pass:
each 32x48 frame is reduced to a coarser 24x36 grid, palette-reduced to 16
colors, and scaled back to 32x48 with nearest-neighbor sampling. This keeps the
generated silhouettes and shot-specific poses while reducing the over-detailed
illustrated look.
