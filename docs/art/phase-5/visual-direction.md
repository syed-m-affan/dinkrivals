# Dink Rivals Visual Direction

Last updated: 2026-05-11

## Approved References

- `docs/art/concepts/concept-screenshot.png`: primary target for in-match composition, HUD density, court readability, and park atmosphere.
- `docs/art/concepts/concept-sheet.png`: character, logo, UI, and asset-language reference.
- `docs/art/phase-5/phase-5-current-serve.png`: current implementation baseline for gap comparisons.
- `docs/art/phase-5/visual-gap-inventory.md`: current list of known gaps.

## Locked Decisions

- The game remains a readable 3/4 mobile arcade sports view.
- Court, kitchen, net, ball, ball shadow, players, paddles, controls, score, pause, and feedback must remain visible on phone.
- The left movement stick and right swing stick are the control contract. Shot names remain contact classifications, not buttons.
- Classic Court visual target is a park court with fence, trees, benches, lamps, signs, banners, bags, and subtle shadows.
- `VisualPalette` is the color source of truth for runtime colors.
- Generated or hand-authored placeholder art is acceptable if it is original and consistent.
- New visual systems must be replaceable: data/config over scattered hardcoded screen pixels.

## Provisional Decisions

- Phase 5A-5G may use placeholder pixel assets as long as manifests mark them as placeholders.
- Environment props should be painted or rendered lower contrast than court lines and ball.
- Environment assets should bias toward desaturated olive/gray ground, darker fence values, simple tree masses, warm bench/sign accents, and very soft shadows.
- Court cards may exist as assets before a court-selection feature exists.
- Classic Court cards should read as the blue fenced starter court; Park Court cards should read as a greener public-park variant with stronger grass/tree identity.
- Locked court cards should be muted silhouettes or blueprint-style placeholders, not premium-looking locked art.
- Subtle screen shake is allowed only if disabled by default or limited to point-ending smash feedback.
- Time-of-day tint is allowed only if it improves depth without reducing readability.

## Deferred Decisions

- Final character art style and exact proportions remain provisional until P5D closeout.
- Final court-card interaction model belongs to a later feature ticket, not Phase 5F asset preparation.
- Park Court playability, tournament use, unlocks, trophies, and progression are out of scope.
- Real AdMob, IAP, online multiplayer, energy systems, gems, and gacha are out of scope.

## Pixel Density Rules

- Court/world textures should be authored at stable logical scales and projected in-engine, not baked to device pixels.
- Environment props should use chunky shapes and avoid one-pixel details that vanish on phone.
- Environment manifests should record layer, dominant hue, value range, safe zones, phone readability note, and placeholder/final status.
- Character gameplay sprites should prioritize silhouette over facial detail.
- Character definitions should preserve readable head/hat/hair shape, torso value, paddle contrast, outline contrast, and tiny-sprite readability.
- VFX sprites should be small, high contrast, and short-lived.
- UI panels should use thick borders, simple corners, and monospace/chunky typography.

## Contrast and Motion Rules

- Brightest whites are reserved for active court lines, score text, and essential UI text.
- Strongest yellows are reserved for the ball, serve power, and brief hit/point emphasis.
- Darkest accents are reserved for player outlines, net posts, and panel separation.
- Green environment details must not match the court's value at court edges.
- Trails, bursts, and swing effects must show direction without making the ball path ambiguous.
- Bottom control zones should sit over intentionally quiet ground or UI backing, never busy foliage.
- Top-third banners, fence signs, opponent silhouette, score, pause, and feedback must be checked together for collision.

## Minimum Readable Sizes

- Ball: never smaller than the current Phase 5 ground-state visual radius.
- Ball shadow: always visible on court, never darker than the ball's read.
- Player/opponent: body silhouette and paddle hand must be readable at far baseline scale.
- Paddles: must remain visible during swing/contact frames.
- Court lines: must stay brighter than court texture and environment.
- Score numerals: must be readable at a glance on a phone screenshot.
- Feedback text: must fit within top-center safe area and not cover the ball during rally.
- Controls: joystick/swing/serve controls must preserve their existing hit regions.

## Future Concept Intake

1. Add the new concept file under `docs/art/`.
2. Update this document's approved/provisional references.
3. Update `visual-gap-inventory.md` with concrete differences.
4. Create or update tickets for affected implementation areas.
5. Do not silently change gameplay systems to match a concept image.
