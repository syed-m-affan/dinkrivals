# Sprite Cell Size Decision

Decision: move the runtime character sheets to native 64x64 chibi cells.

Why this changed:
- The user explicitly preferred the chibi direction that better matches the concept.
- 64x64 is the installed character-sprite skill's default for readable chibi game sprites.
- Square cells give enough room for a large head, compact limbs, paddle cue, and clean frame margins without clipping.
- The renderer now computes frame count from 64px cells and samples integer source rectangles.

Risk accepted:
- This intentionally changes the character silhouette from tall athlete to compact chibi.
- Runtime display dimensions were retuned so gameplay scale stays readable without changing hitboxes or movement.
