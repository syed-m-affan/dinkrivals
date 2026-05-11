# Court Card Placeholder Manifest

These are original low-detail retro placeholder card images generated with ChatGPT image generation for future court-selection or court-preview UI. Phase 5F-004 only prepares assets; it does not add court selection, unlocks, purchases, or navigation.

| File | Size | Intended use | Status |
| --- | ---: | --- | --- |
| `classic_court_card.png` | 320x192 | Blue fenced starter-court preview card | Placeholder |
| `park_court_card.png` | 320x192 | Greener public-park preview with stronger grass identity | Placeholder |
| `locked_court_card.png` | 320x192 | Muted coming-soon placeholder; not premium/unlock monetization art | Placeholder |

Generation approach: a low-detail ChatGPT image-generation source sheet was created under `.codex/generated_images`, then a local Pillow import pass cropped each card, removed the flat chroma-key background outside the card art, despilled edges, and resized into the asset files above. No third-party art was used.
