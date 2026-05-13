# Classic Environment Placeholder Manifest

All files in this folder are original low-detail retro placeholder pixel assets generated for Phase 5B with ChatGPT image generation, then cropped, chroma-keyed, despilled, and resized locally into stable asset slots. They are safe to replace with final art as long as filenames or consuming manifests are updated together.

| File | Size | Intended use | Layer | Dominant hue | Value range | Safe zones | Phone readability note | Status |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `park_background_overhaul.png` | 979x1606 | Generated full-scene park court base used behind procedural court and layered props | Far/base | Park green and court blue | Bright-mid | Keep court corridor readable; props may layer over it | Closest current asset to the concept screenshot target | Overhaul pass |
| `layer_sky_trees.png` | 979x1606 | VO2 transparent sky and tree band split from the full-scene background | Far/base | Sky blue and foliage green | Bright-mid | Top band only | Keeps the top venue band independently replaceable | VO2 split |
| `layer_fence_signage.png` | 979x1606 | VO2 transparent fence/signage band split from the full-scene background | Far backdrop | Teal, yellow, red | Medium-bright | Behind far baseline | Carries readable venue identity behind play | VO2 split |
| `layer_court_base.png` | 979x1606 | VO2 transparent court/apron base split from the full-scene background | Court/base | Deep blue court | Medium | Projection anchor | Preserves measured painted court control points | VO2 split |
| `layer_net.png` | 979x1606 | VO2 transparent net layer drawn by `NetComponent` at net depth | Net | White/teal | High contrast | Net strip only | Lets far-side entities pass under a dedicated net layer | VO2 split |
| `off_court_ground_tile.png` | 192x128 | Repeating courtside grass/ground tile behind the court | Ground | Desaturated green | Medium-dark | Off-court only; keep quieter under controls | Avoid high-frequency repeats near translucent sticks | Placeholder |
| `far_fence_segment.png` | 192x160 | Far-background fence or low wall segment | Far backdrop | Blue-gray | Dark-mid | Behind far baseline only | Mesh should stay dimmer than net and ball | Placeholder |
| `tree_cluster.png` | 192x192 | Off-court tree mass placed behind active play | Far/side prop | Olive green | Dark-mid | Outside active lines and HUD | Chunky masses only; avoid saturated leaves near court edge | Placeholder |
| `shrub_cluster.png` | 192x128 | Low courtside foliage that must stay outside court lines | Side prop | Green | Medium | Off-court margins only | Keep below player/ball contrast | Placeholder |
| `bench.png` | 192x128 | Sideline bench prop outside the playable court | Side prop | Warm brown | Medium | Sidelines outside controls | Warm accent should not resemble ball/VFX yellow | Placeholder |
| `lamp_post.png` | 96x192 | Tall courtside light prop outside control and HUD regions | Far/side prop | Charcoal/yellow | Dark with tiny highlight | Outside upper HUD and bottom controls | Light glow must stay softer than ball | Placeholder |
| `banner_sign.png` | 192x128 | Fence-mounted sign or banner accent | Far backdrop | Warm yellow/red | Medium-bright | Behind far court, away from feedback text | Accent should not compete with score or serve power | Placeholder |
| `equipment_bag.png` | 160x128 | Small sideline equipment prop outside active court lines | Side prop | Blue | Medium | Sidelines outside controls | Small silhouette; never cover baselines | Placeholder |

Shared support asset:

| File | Size | Intended use | Layer | Dominant hue | Value range | Safe zones | Phone readability note | Status |
| --- | ---: | --- | --- | --- | --- | --- | --- | --- |
| `../shared/soft_shadow_patch.png` | 128x64 | Soft environmental shadow under props | Shadow | Black alpha | Low contrast | Under props only | Must not look like ball shadow or fault marker | Placeholder |

Generation approach: a low-detail ChatGPT image-generation source sheet was created under `.codex/generated_images`, then a local Pillow import pass cropped each prop, removed the flat chroma-key background, normalized purple-blue fringe toward the fence palette, and resized into the asset files above. The overhaul background was generated with the built-in image generation tool and copied from `C:\Users\saffa\.codex\generated_images\019e17dc-950d-7d92-a846-b0ee361d56e5\ig_0d1d334c34e07226016a022744fe188195909c178b3bf6f96e.png`. No third-party art was used.
