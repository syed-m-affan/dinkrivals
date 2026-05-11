# VFX Asset Manifest

Runtime VFX now use generated pixel-art sprites cropped from
`docs/art/visual-overhaul/contact-sheets/shot-vfx-generated-sheet.png`.
The source sheet was generated with the built-in image generation tool on a
flat magenta chroma-key background, then split and alpha-keyed locally.

| File | Size | Intended use | Status |
| --- | ---: | --- | --- |
| `dink_spark_generated.png` | 231x169 | Dink/block contact sparkle | Generated |
| `drive_arc_generated.png` | 304x207 | Drive/serve contact arc, rotated by shot velocity | Generated |
| `lob_arc_generated.png` | 244x353 | Lob scoop contact arc | Generated |
| `smash_band_generated.png` | 238x426 | Smash impact band | Generated |
| `miss_whiff_generated.png` | 223x256 | Missed swing whiff at committed hitbox line | Generated |
| `bounce_ring_generated.png` | 308x171 | Ground-contact bounce ring | Generated |
| `trail_segment_generated.png` | 278x123 | Ball trail segment | Generated |
| `point_burst_generated.png` | 275x305 | Point-ending burst | Generated |
| `hit_spark.png` | 48x48 | Legacy contact spark | Legacy placeholder |
| `bounce_ring.png` | 56x40 | Legacy bounce ring | Legacy placeholder |
| `trail_segment.png` | 48x24 | Legacy ball trail segment | Legacy placeholder |
| `smash_flash.png` | 64x64 | Legacy smash flash | Legacy placeholder |
| `point_burst.png` | 72x72 | Legacy point burst | Legacy placeholder |

Runtime owner: `VfxLayerComponent`.
