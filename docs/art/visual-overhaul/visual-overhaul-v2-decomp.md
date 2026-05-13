# Visual Overhaul v2 Concept Decomposition

Owner: Art Direction Agent for VO2-0

Primary reference: `docs/art/concepts/concept-screenshot.png` at 852x1846.
Runtime layer target: 941x1672 source canvas for classic court environment layers.

## Composition Targets

The concept is a 3/4 portrait arcade sports view with the court as the main read, a branded venue band behind the far baseline, and compact HUD plaques over the top third. v2 should preserve the current game camera and gameplay math while raising the asset quality to match this composition.

| Element | Concept read | v2 target |
|---|---:|---:|
| Near player height | 11-12% of screen height, about 205-220 px in concept | 11-12% of Pixel screenshot height at near baseline; source sprite remains 48x72, runtime logical footprint 33x49.5 court units |
| Far opponent height | 8-9% of screen height, about 145-165 px in concept | 7.5-9% of screenshot height after depth scaling; still shows cap, face block, torso, legs, paddle |
| Ball diameter | 1.3-1.7% of screen height in concept, about 24-31 px depending on depth and trail glow | 12-16 px visible core on a 1920-tall Pixel capture; never smaller than 10 px at far court |
| Score block | 28-30% of screen width, about 245 px wide in concept | 26-30% of screen width; two adjacent panels with 2 px gap |
| Single score panel | 12-14% of screen width, about 105-120 px wide | 84-100 px wide on a 360 dp layout, scaled by device density |
| Feedback plaque | 31-33% of screen width and 5-6% of screen height | top-center plaque about 30-34% width, two lines, no overlap with score or pause |
| Rally strip | 29-33% of screen width, left anchored below score | two-line text strip, no border, aligned under score block |
| Main banner | 38-44% of screen width in venue band | `DINK RIVALS` banner centered on fence, clear at gameplay distance |
| Secondary sign | 23-28% of screen width in venue band | `PICKLEBALL LEGENDS` sign on right fence, framed and readable |
| Touch controls | bottom 18-20% of screen height | keep existing hit regions >=48 dp; visual rings may be lighter and quieter |

## Depth Bands

Use these bands for generation and integration. They are visual bands only; they do not change court projection.

1. Sky and far tree canopy: top 0-13% of source canvas. Darkest greens frame the HUD but do not fight text.
2. Fence and signage: 13-26%. Chain-link fence, banner, side sign, lamps, benches, bags, planters.
3. Far apron and opponent staging: 26-36%. Muted green paving, soft shadows, far player silhouette.
4. Court playfield: 36-74%. Deep blue court, bright worn white lines, net crossing near the mid-lower third.
5. Near apron and player staging: 74-83%. Quiet green floor so the near player and ball shadow read clearly.
6. Controls: 83-100%. Low-detail ground under translucent control affordances.

## Character Scale and Pose

The near player is the scale anchor. The concept player reads because the cap, head, torso, shorts, shoes, paddle, and shadow are separated by value and outline. The v2 sprite sheets must preserve that read at 48x72 source resolution.

- Player identity: blue cap, white shirt with red trim, navy shorts, white shoes, dark paddle in right hand.
- Opponent identity: red cap or red upper kit, contrasting white/navy support colors, dark paddle, distinct stance from player.
- Foot pivot: y=70 inside each 48x72 frame, leaving 2 px foot padding.
- Outline: 1 px hard dark outline at source scale, with selective 2 px accents only on the outer silhouette where needed for phone readability.
- Internal detail budget: cap brim, face block, shirt block, shorts, socks/shoes, paddle hand. Avoid tiny facial features that disappear.
- Shadow: short lower-right cast shadow. It must not be baked into transparent gameplay sprites unless the runtime package explicitly asks for it.

## Ball Arc and Trail

The concept ball is readable because the ball core is bright yellow, the trail is translucent warm yellow-green, and the shadow is separated on the court below.

- Ball core: bright yellow with cream highlight and warm rim.
- Trail: tapered arc, 6-10 samples visually, strongest near the current ball, fading toward the previous position.
- Trail width: about 45-60% of ball diameter at the head, tapering to 15-25% at the tail.
- Arc colors: yellow-white core, warm yellow body, optional muted teal edge only when it improves contrast over blue court.
- Shadow: small dark blue/navy oval on court plane, offset lower-right from the ball path at altitude.
- Reject trails that look like smoke, ribbon fabric, magic spells, or soft airbrush strokes.

## Backdrop Signage Placement

The venue band is the main v2 environmental upgrade.

- Main banner: centered behind far baseline on the fence, horizontal rectangle, navy canvas, cream `DINK` and warm red/orange `RIVALS`, optional pickleball icon. Keep text large and blocky. Do not use real logos.
- Secondary sign: right fence panel, smaller framed rectangle with `PICKLEBALL LEGENDS`, trophy/shield icon allowed if original and simple.
- Left dressing: bench, backpack, planter, lamp or fence post, all lower contrast than signage.
- Right dressing: bench, planter, lamp, sign support, all lower contrast than ball and active players.
- Fence mesh: visible but low contrast. It should frame signage, not create noise behind HUD text.

## HUD Anchors

HUD must look like the concept but remain safe on Android devices.

- Score block: top-left safe area, two adjacent plaques. Blue `YOU` panel on left, red `RIVAL` panel on right. Use cream/white numerals and chunky border.
- Pause button: top-right safe area, square plaque, same border language as score panels.
- Feedback plaque: top-center below top safe area, two lines. Example: `DINK!` over `NICE SHOT`.
- Rally strip: left aligned below score block, text-only, two lines. Example: `RALLY: 6`, `LAST SHOT: DINK`.
- Controls: bottom-left movement ring and bottom-right swing ring. Visuals may be translucent; hit targets must remain >=48 dp.
- Serve button: bottom-center only when serving; small visual footprint but same >=48 dp touch target.

## Palette Pulls

Use the shared palette card in `prompts/vo2-shared-style-rules.md`. The concept target is saturated but controlled:

- Deep blue court field: `courtSurface` #2B76AA, shaded by #225E90 and highlighted by #3894C9.
- Cream lines and HUD text: `courtLineWhite` #F4F7E8.
- Venue greens: `environmentTreeLineBack` #0C1B12, `environmentTreeLineMid` #284523, `environmentGround` #4F6241.
- Sign navy: `environmentSignPanel` #102946.
- Player blue: `playerPrimary` #3C86FF with navy support from `courtApronNavy` #163B57.
- Opponent red: `opponentPrimary` #FF5F5F and `scoreboardOpponent` #A83E3E.
- Ball and hit accent: `ballPrimary` #FFE24A, `uiAccent` #FFCB47.
- Dark outline/shadow: `uiBackground` #10151B and `projectedShadow` #061211.

## Lighting Direction

All v2 generated art uses one lighting model:

- Key light from upper-left.
- Grounded shadows cast lower-right.
- Top-left edges may receive small cream/blue highlights.
- Lower-right edges use navy, dark green, or warm red shadow ramps.
- No alternate per-asset lighting, no rim lighting from the right, no centered drop shadows.

## Acceptance Notes for Later Agents

- Style coherence is a gate, not polish. A good isolated asset still fails if it does not share palette, line weight, lighting, and pixel density with the rest of v2.
- Generated text must be checked manually. Signage and HUD text with malformed letters must be regenerated or hand-authored inside the allowed runtime/UI workflow.
- Character and ball readability should be judged from paused full-screen Pixel captures, not zoomed contact sheets.
