# Dink Rivals Visual Overhaul Spec

## 1. Purpose

This spec defines an agent-friendly plan to raise the visual quality of Dink Rivals until the in-game experience feels close to the approved concept screenshot in `docs/art/concepts/concept-screenshot.png`, while keeping the game readable and playable on Android.

The plan is intentionally AI-first. New visual assets should default to generated bitmap images, then be normalized, integrated, and verified through repeatable agent tasks. Manual drawing should be reserved for masks, layout guides, debug overlays, and tiny code-native primitives where an image asset would make gameplay less clear.

## 2. Reference Materials

Primary target:

- `docs/art/concepts/concept-screenshot.png`
- `docs/art/concepts/concept-sheet.png`

Current visual evidence:

- `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png`
- `docs/art/phase-5.2/phase-5.2-emulator-smoke.png`
- `docs/art/phase-5/phase-5-screenshot.png`
- `docs/art/phase-5/phase-5g-menu.png`

Existing planning and direction:

- `docs/specs/build-spec.md`
- `docs/art/phase-5/visual-direction.md`
- `docs/art/phase-5/visual-gap-inventory.md`
- `docs/art/phase-5.2/phase-5.2-delta-inventory.md`
- `docs/art/phase-5.2/phase-5.2-art-direction.md`
- `docs/art/phase-5.2/phase-5.2-comparison.md`
- `docs/art/phase-5/render-layer-map.md`

Runtime code inspected:

- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/components/net_component.dart`
- `dink_rivals/lib/game/components/vfx/vfx_layer_component.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/lib/game/config/character_visuals.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`

Asset manifests inspected:

- `dink_rivals/assets/images/environment/classic/README.md`
- `dink_rivals/assets/images/sprites/README.md`
- `dink_rivals/assets/images/vfx/README.md`
- `dink_rivals/assets/images/ui/court_cards/README.md`

## 3. Product Visual Goal

Dink Rivals should look like a polished mobile arcade pickleball game set in a lively park court. The first gameplay screen should immediately communicate:

- Bright 3/4 arcade sports composition.
- A real park setting with depth, court-side objects, signs, trees, lamps, fencing, and ground transitions.
- Characterful players with readable silhouettes, paddles, shot poses, and point reactions.
- A tactile court surface with worn paint, scuffs, net shadow, ball contact marks, and consistent lighting.
- High-clarity ball, trail, hit sparks, bounce rings, lob/smash effects, and move indicators.
- A HUD and control layer that feels designed as part of the same arcade world rather than debug UI.

The concept screenshot is the quality bar. The current implementation has useful systems and Phase 5.2 improvements, but it still reads as a functional prototype: simple generated environment, sparse props, flat characters, procedural court details, and oversized gameplay controls that do not yet match the richness of the target.

## 4. Non-Negotiables

- Gameplay readability wins over art density. Ball, player feet, paddle state, service status, and score must remain clear on a physical Pixel device.
- Maintain the 3/4 mobile portrait court layout. Do not change pickleball rules or core controls as part of art work unless a gameplay ticket explicitly asks for it.
- New art assets should be generated bitmap images first. Avoid manually drawn placeholder art unless the asset is a debug overlay, collision/hitbox guide, tiny icon, or temporary acceptance marker.
- Store visual decisions in data/config where possible. Do not scatter magic colors, positions, or asset paths through components.
- `VisualPalette` remains the source of truth for runtime colors that are still code-rendered.
- Existing player-control affordances must remain visible and reachable inside Android safe areas.
- The game must still run smoothly on Android. Visual upgrades need performance budgets and device checks.
- All shipped assets must be original, non-trademarked, and safe for distribution.
- Every phase must produce evidence: screenshots, contact sheets, asset manifests, and automated checks where possible.

## 5. Current-State Inventory

### 5.1 Runtime Visual Architecture

The game currently renders a hybrid scene:

- Environment layer: `ClassicEnvironmentComponent` draws a generated park background when `environment/classic/park_background_generated.png` is available. When that background is drawn, the component returns early after fence anchor and court shadow rendering, so many configured props in `EnvironmentLayout.classicProps` are bypassed.
- Court layer: `CourtComponent` renders the court procedurally using `VisualPalette`, court projection, line wear, panel colors, service zones, scuffs, and pixel texture.
- Net layer: `NetComponent` renders a procedural net with posts, rail, mesh, and shadow.
- Actor layer: player and opponent sprites are driven by generated sprite strips and `CharacterVisualDefinition`.
- Ball/VFX layer: `VfxLayerComponent` renders trails, bounce rings, hit sparks, smash flashes, and point bursts from small bitmap assets.
- HUD/control layer: scoreboard, feedback, controls, serve prompts, and overlays are mostly code-rendered UI surfaces.

This structure is a good base for incremental visual upgrades. The main architectural issue is that the generated background is too monolithic: it provides atmosphere but prevents layered prop composition and does not let the court integrate with foreground/midground objects like the concept screenshot.

### 5.2 Current Asset Footprints

Important existing slots:

- `environment/classic/park_background_generated.png`: 941x1672.
- `environment/classic/court_classic.png`: 880x1920.
- Classic props: mostly 96, 128, 160, and 192 pixel slots.
- Ball sprite: 24x24.
- Character idle strips: 64x48.
- Character run strips: 128x48.
- Character swing strips: 96x48.
- Ready, hit-confirm, point-win, point-loss strips: 64x48.
- Paddle sprites: 24x40.
- Character portraits: 128x128.
- Logo: 512x192.
- Court cards: 320x192.
- VFX slots: hit spark 48x48, bounce ring 56x40, trail segment 48x24, smash flash 64x64, point burst 72x72.

The current footprints are small and efficient, but some are too constrained for the visual target. Character gameplay sprites especially need either larger source art normalized into the current frame footprint, or a planned footprint increase with projection and hitbox review.

### 5.3 Current Strengths

- The game already has a layered component model that can support a richer art pass.
- Court projection and render order are isolated enough to revise without rewriting gameplay.
- `VisualPalette` centralizes many runtime colors.
- The asset directories already include READMEs and placeholder manifest language.
- Phase 5.2 created a useful first pass at environment, court, net, UI, and VFX improvements.
- Recent gameplay work added visible swing hitbox concepts, which can become stylized shot indicators.

### 5.4 Current Gaps

- The environment still reads as a flat backdrop rather than a dense park court.
- The generated background has a different scale and texture language from the gameplay sprites.
- Court material is readable but still procedural and geometric compared with the concept's tactile painted surface.
- Net is functional but not yet a strong visual anchor with convincing mesh, posts, and cast shadow.
- Player sprites are too simple and small to carry personality.
- Shot animations and move-state indicators need stronger pixel-art expression.
- Ball physics/VFX readability needs more visual weight without making the ball harder to track.
- HUD and controls are serviceable but do not match the concept's integrated arcade UI.
- Menus and end-match screens do not yet share the richer world identity.
- There is no final visual art bible with prompt packets, acceptance criteria, and asset provenance.

## 6. Visual North Star

The target style is polished pixel-art arcade sports, not realistic simulation. The screenshot should feel like a dense, hand-directed scene:

- Warm daylight with consistent upper-left lighting and grounded lower-right shadows.
- Saturated but controlled colors: green park, blue/teal court accents, warm UI panels, high-contrast ball.
- Clear depth bands: far trees/signs, fence and benches, court apron, court playfield, players, ball, HUD.
- Chunky pixel forms with crisp edges, small internal highlights, and no blurry scaling.
- Players should look like stylized athletes, not simple token shapes.
- The court should have worn paint, subtle scuffs, net shadow, and surface texture that supports ball visibility.
- Shot VFX should be short, readable, and informative: dink, drive, lob, smash, miss, fault, serve, point.
- UI should feel arcade-premium while staying compact enough for play.

## 7. AI-First Production Model

### 7.1 Agent Roles

Each visual phase should be broken into small agent tasks:

- Art Direction Agent: defines the target reference crop, prompt packet, constraints, and acceptance checklist.
- Asset Generation Agent: generates bitmap candidates from prompt packets and creates contact sheets.
- Asset Normalization Agent: crops, cleans transparency, rescales, aligns pivots, checks dimensions, and updates manifests.
- Runtime Integration Agent: wires assets into config/components without changing unrelated gameplay.
- Visual QA Agent: captures emulator and physical Pixel screenshots and compares them against the target checklist.
- Performance QA Agent: checks frame pacing, texture memory, APK size, and Android rendering behavior.
- Closeout Agent: updates docs, evidence screenshots, ticket status, and unresolved gaps.

Agents should work from explicit file ownership. For example, an environment task owns `assets/images/environment/classic/`, `EnvironmentLayout`, and `ClassicEnvironmentComponent`; a character task owns `assets/images/sprites/`, `CharacterVisualDefinition`, and animation state mapping.

### 7.2 Asset Loop

Each new visual package should follow this loop:

1. Create or update a prompt packet in docs.
2. Generate 4 to 8 bitmap candidates.
3. Build a contact sheet and choose one approved direction.
4. Normalize selected art into runtime dimensions and pivots.
5. Add or update the asset manifest.
6. Integrate through config and existing components.
7. Capture before/after screenshots.
8. Run automated checks.
9. Record acceptance and unresolved gaps.

### 7.3 Source And Evidence Folders

Recommended folders:

- `docs/art/visual-overhaul/prompts/`: prompt packets and negative prompts.
- `docs/art/visual-overhaul/contact-sheets/`: generated candidate sheets.
- `docs/art/visual-overhaul/evidence/`: screenshots, comparisons, and QA notes.
- `dink_rivals/assets/images/source/`: optional source exports that are safe to keep in repo.

Do not overwrite prior generated art without preserving enough evidence to compare direction changes.

### 7.4 Generated Image Rules

Prompts must specify:

- Pixel-art arcade sports style.
- Transparent background when the asset is a sprite, prop, VFX element, or UI ornament.
- No logos, brands, celebrity likenesses, or trademarked uniforms.
- Consistent upper-left key light and lower-right shadow.
- Crisp hard edges, no antialias haze, no painterly blur for runtime sprites.
- Shape language aligned with the concept screenshot.
- Exact target dimensions or a larger clean source that can be cropped.
- Safe margins for animation frames and pivots.

Negative prompts should reject:

- Photorealism.
- Watercolor blur.
- Vector-flat icon style.
- Tiny unreadable details.
- Random text or fake logos.
- Perspective mismatches.
- Black or transparent halos.
- Overly dark backgrounds behind the ball.

## 8. Target Runtime Architecture

### 8.1 Environment

Move from one monolithic generated background toward layered generated bitmap assets:

- Far sky and tree band.
- Fence/signage band.
- Midground benches, lamps, banners, shrubs, planters.
- Court apron and ground transitions.
- Foreground edge dressing that never overlaps controls.

`ClassicEnvironmentComponent` should render these as independent layers so composition can match the concept without blocking configured props. The full-screen generated background can remain as a fallback or temporary base, but the final target should use layered assets with data-driven placement.

### 8.2 Court

Keep court readability but increase material quality:

- Use generated court surface texture or texture overlays for worn paint and scuffs.
- Keep line rendering precise and high contrast.
- Add richer apron texture and ground blending.
- Make net shadow and player shadows agree with the same light direction.
- Preserve deterministic court bounds for gameplay logic.

### 8.3 Net

Upgrade net from a procedural object to an art-directed hybrid:

- Generated pixel-art posts and caps.
- Generated mesh or mesh texture tile.
- Runtime line/mesh fallback for clarity.
- Strong but subtle cast shadow.
- Better depth handling at the center strap and posts.

### 8.4 Characters And Animation

Characters need the largest perceived-quality lift:

- Generate larger source sprites with clear 3/4 athletic poses.
- Preserve consistent frame pivots and feet positions.
- Add state-specific animations for idle, ready, run, dink, drive, lob, smash, miss, hit-confirm, point-win, and point-loss.
- Make player and opponent silhouettes different from each other at gameplay scale.
- Keep rackets/paddles visibly connected to swing motion.
- Add shot anticipation frames so swipe moves feel intentional.

If current 64x48/96x48 footprints cannot carry enough quality, plan a controlled footprint increase and update projection, collision visualization, and tests together.

### 8.5 Shot Indicators And Hitboxes

The current swing-hitbox feature should be styled into final move indicators:

- Dink: small paddle contact shimmer near the paddle.
- Drive: horizontal pixel-art arc or slash in front of the player, aligned with swipe direction.
- Lob: upward scoop arc with a short rising trail.
- Smash: vertical downward impact band above/in front of the player.
- Miss: brief whiff arc with low brightness and no contact burst.

Visual indicators must reflect the actual active hit zone. If the hitbox is a horizontal line/arc, the player should see a matching horizontal line/arc. If the hitbox is vertical, the indicator must be vertical. These indicators should be generated bitmap VFX where possible, with runtime transform/rotation/scale used only to align them to the swipe and court projection.

### 8.6 Ball And VFX

The ball should remain the highest-readability gameplay object:

- Strong outline and highlight.
- Trail length tied to velocity and shot type.
- Bounce ring placed at court contact point.
- Hit spark tied to shot type and contact quality.
- Lob arc hint that reads as height, not floatiness.
- Smash flash that is dramatic but short.
- Fault/out/point callouts that do not obscure the next playable moment.

### 8.7 HUD And Controls

Align the HUD with the concept:

- Score cluster near the top-left or a compact anchored position that leaves the playfield clear.
- Pause/settings affordance top-right.
- Shot feedback near top-center with arcade plaque styling.
- Controls should use polished pads/buttons and subdued transparency, not debug-like circles.
- Keep controls large enough for thumb play, but reduce visual dominance.
- Remove obsolete swing-power language from visual surfaces where gameplay no longer uses it.

### 8.8 Menus And Out-of-Match Screens

The menu, roster, court select, settings, and end-match screens should share the same art direction:

- Generated hero background based on the park court world.
- Character portraits that match gameplay sprites.
- Court cards that show real visual differences.
- Buttons and panels that use the same arcade UI material as gameplay HUD.
- No generic dark placeholder screens.

## 9. Phase Plan

### Phase VO-0: Baseline Capture And Art Bible

Goal: lock the evidence base and visual rules before changing assets.

Tasks:

- Capture current emulator gameplay, menu, roster, settings, and end-match screenshots.
- Capture physical Pixel screenshots before the overhaul starts.
- Build a one-page concept breakdown from `concept-screenshot.png`.
- Document color, density, camera, depth bands, HUD placement, character scale, and VFX notes.
- Create prompt packet templates for environment, court, character, VFX, and UI.

Acceptance:

- `docs/art/visual-overhaul/evidence/baseline-*` screenshots exist.
- `docs/art/visual-overhaul/prompts/prompt-template.md` exists.
- Art bible notes include explicit do/don't rules for generated images.

### Phase VO-1: Environment Layer Rebuild

Goal: replace the flat backdrop feeling with a layered park court that resembles the concept.

Tasks:

- Generate far tree/sky band candidates.
- Generate fence and signage candidates.
- Generate bench, lamp, shrub, planter, and gear props as transparent pixel assets.
- Normalize props into existing slot sizes where possible.
- Update `EnvironmentLayout` with depth-aware placements.
- Update `ClassicEnvironmentComponent` so generated background does not bypass all props.
- Ensure foreground dressing does not overlap controls or court-critical areas.

Acceptance:

- Gameplay screenshot shows clear far, mid, court, and foreground depth bands.
- At least 8 distinct environment prop instances are visible without cluttering the ball path.
- No prop covers active player, opponent, score, controls, or ball.
- Generated bitmap art replaces manual placeholder-like environment pieces.

### Phase VO-2: Court Surface And Net Polish

Goal: make the court feel tactile and grounded while preserving exact gameplay clarity.

Tasks:

- Generate court texture overlays for worn painted surface, service panels, apron, and line wear.
- Integrate overlays with `CourtComponent` or a dedicated court asset layer.
- Generate net post/cap/strap/mesh assets.
- Keep procedural fallback for exact line and mesh clarity.
- Tune court, net, player, and ball shadows to share one light direction.

Acceptance:

- Court still clearly shows kitchen, service boxes, baselines, sideline, and net.
- Surface has visible texture at Pixel scale without causing ball camouflage.
- Net is a visual anchor and not just thin lines.
- Automated tests covering court geometry still pass.

### Phase VO-3: Character Sprite Upgrade

Goal: make players feel like characterful arcade athletes.

Tasks:

- Generate updated source sheets for Rookie, Rally Queen, Veteran, and Showman.
- Produce gameplay strips for idle, ready, run, dink, drive, lob, smash, miss, hit-confirm, point-win, and point-loss.
- Normalize frame pivots and feet positions.
- Update `CharacterVisualDefinition` with any new assets and metadata.
- Review hitbox alignment after any footprint change.
- Keep player and opponent animation states responsive to serve, move, swing, and point state.

Acceptance:

- Player and opponent are visually distinct at gameplay scale.
- Serving player and opponent both animate when moving.
- Each shot type has a recognizable animation.
- Animation frames do not slide feet unintentionally unless movement is expected.
- Hitbox visuals still align with actual swing zones.

### Phase VO-4: Shot VFX And Move Indicators

Goal: make dink, drive, lob, smash, miss, serve, and point outcomes visible and satisfying.

Tasks:

- Generate VFX sprites for drive arc, lob scoop, smash band, dink sparkle, miss whiff, serve glint, bounce ring, and point burst.
- Map VFX to actual move state and contact result.
- Ensure drive aim follows swipe direction visually.
- Ensure lob and smash indicators show vertical intent.
- Remove or replace obsolete swing power bar visuals.
- Add debug-only toggle for active swing hitbox overlays if needed.

Acceptance:

- Each move can be identified from a screenshot or short clip.
- Swing miss shows a miss and does not silently become a dink.
- Contact VFX and active hitbox indicator agree spatially.
- Ball remains readable through VFX.

### Phase VO-5: HUD, Controls, And Feedback

Goal: replace prototype-looking surfaces with cohesive arcade UI.

Tasks:

- Generate compact score panel assets or UI skins.
- Generate feedback plaque and point result treatments.
- Generate control pad/button skins that preserve touch target size.
- Reposition HUD toward concept-like anchors.
- Review safe areas on Pixel and emulator.
- Remove swing-power affordance from user-facing visuals unless gameplay adds it back.

Acceptance:

- HUD reads as part of the same visual world as gameplay.
- Controls are clear but no longer dominate the screen visually.
- No text overlaps on Pixel.
- Serve, fault, score, and point feedback are readable within one second.

### Phase VO-6: Menu And Screen Cohesion

Goal: bring out-of-match screens up to the same quality bar.

Tasks:

- Generate a menu background from the park court visual identity.
- Generate or update logo and title treatment if needed.
- Generate character portraits that match gameplay sprites.
- Update court cards to match actual court art.
- Apply shared panel/button/token styling to roster, court select, settings, pause, and end-match screens.

Acceptance:

- Main menu no longer reads as a generic dark placeholder.
- Character selection uses art that matches in-game characters.
- Court cards preview actual visual themes.
- End-match screen feels connected to the match presentation.

### Phase VO-7: Android QA, Performance, And Closeout

Goal: verify the overhaul on the target device class.

Tasks:

- Run Flutter analyze and tests.
- Build a debug APK.
- Install and launch on emulator.
- Install and launch on physical Pixel.
- Capture gameplay and menu screenshots from both.
- Check frame pacing during serve, drive rallies, lob, smash, point result, and menu transitions.
- Update comparison docs and unresolved gap inventory.

Acceptance:

- `flutter analyze` passes.
- `flutter test` passes.
- Debug APK builds.
- Emulator smoke screenshot exists.
- Physical Pixel screenshot exists.
- No obvious jank during normal play.
- Visual comparison doc states which target gaps remain.

## 10. Asset Work Packages

### 10.1 Environment Package

Owned paths:

- `dink_rivals/assets/images/environment/classic/`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/lib/game/components/classic_environment_component.dart`

Assets:

- Far tree/sky strip.
- Fence strip with transparent gaps if needed.
- Court-side sign set.
- Bench set.
- Lamp posts.
- Shrub clusters.
- Planters.
- Bags/towels/water bottles.
- Ground transition tiles.
- Foreground edge dressing.

Acceptance notes:

- Use generated bitmap props.
- Preserve transparent backgrounds.
- Do not add unreadable text to signs.
- Keep prop pivots documented.

### 10.2 Court And Net Package

Owned paths:

- `dink_rivals/assets/images/environment/classic/`
- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/components/net_component.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`

Assets:

- Court surface overlay.
- Apron texture.
- Line wear mask.
- Net mesh tile.
- Net posts/caps.
- Net center strap.
- Court shadow overlays.

Acceptance notes:

- Court geometry remains deterministic.
- Texture never hides lines or ball.
- Net render order follows `docs/art/phase-5/render-layer-map.md`.

### 10.3 Character Package

Owned paths:

- `dink_rivals/assets/images/sprites/`
- `dink_rivals/assets/images/paddles/`
- `dink_rivals/assets/images/ui/portraits/`
- `dink_rivals/lib/game/config/character_visuals.dart`

Assets per character:

- Idle sheet.
- Ready sheet.
- Run sheet.
- Dink sheet.
- Drive sheet.
- Lob sheet.
- Smash sheet.
- Miss sheet.
- Hit-confirm sheet.
- Point-win sheet.
- Point-loss sheet.
- Portrait.
- Paddle.

Acceptance notes:

- Keep pivots and feet stable.
- Use consistent scale across characters.
- Make paddle contact point visible.
- Use generated art, then normalize to runtime.

### 10.4 VFX Package

Owned paths:

- `dink_rivals/assets/images/vfx/`
- `dink_rivals/lib/game/components/vfx/vfx_layer_component.dart`
- Shot systems that emit VFX events.

Assets:

- Dink sparkle.
- Drive arc.
- Lob scoop.
- Smash band.
- Miss whiff.
- Bounce ring.
- Trail segment.
- Hit spark.
- Point burst.
- Fault marker.

Acceptance notes:

- Short-lived, high-clarity effects.
- Directional indicators should match swipe/shot direction.
- Hitbox indicator and gameplay hit zone must agree.

### 10.5 UI Package

Owned paths:

- `dink_rivals/assets/images/ui/`
- HUD, controls, menu, roster, settings, pause, and result screen code.

Assets:

- Score panel skin.
- Feedback plaque.
- Pause/settings buttons.
- Control pad/button skins.
- Menu background.
- Logo update if needed.
- Court cards.
- Result plaques.

Acceptance notes:

- Use the same visual language across gameplay and menus.
- Avoid oversized cards in gameplay.
- Keep mobile text legible and non-overlapping.

## 11. Prompt Packets

### 11.1 Environment Prompt Packet

Use for far background, props, and ground dressing.

Prompt:

```text
Pixel-art mobile arcade pickleball park environment, bright daytime, 3/4 court perspective, dense but readable background like a polished sports game screenshot, trees behind a chain-link fence, benches, lamps, court-side signs, shrubs, bags, warm sunlight from upper left, grounded shadows lower right, saturated greens and teal court accents, crisp hard pixel edges, clean transparent background for props, original non-branded details, no readable logos, no random text, no blur.
```

Negative prompt:

```text
photorealistic, watercolor, vector icon, blurry, dark void, trademark logo, fake brand text, noisy tiny details, wrong perspective, black halo, transparent fringe, low contrast ball area
```

### 11.2 Court Prompt Packet

Prompt:

```text
Pixel-art pickleball court surface texture for a polished mobile arcade game, 3/4 portrait perspective, worn painted acrylic, crisp white court lines, subtle scuffs, small dust marks, visible kitchen and service boxes, teal and blue-green panels, warm sunlit highlights, soft grounded net shadow, high contrast for a bright yellow ball, clean game asset texture, no logos.
```

Negative prompt:

```text
photorealistic, blurry lines, warped geometry, unreadable court markings, dark ball-camouflage patches, logos, text, extreme grunge, noisy high-frequency pattern
```

### 11.3 Character Prompt Packet

Prompt:

```text
Pixel-art arcade pickleball athlete sprite sheet, 3/4 top-down mobile sports game perspective, expressive but readable at small size, crisp outline, upper-left light, lower-right shadow, athletic stance, visible paddle, clean frame spacing, transparent background, original character design, no logos, no text. Poses: idle, ready, run, dink, horizontal drive swing, upward lob scoop, overhead smash, missed swing, hit confirm, point win, point loss.
```

Negative prompt:

```text
photorealistic, anime portrait proportions, blurry antialias haze, inconsistent character between frames, missing paddle, unreadable limbs, random text, brand logos, huge head, feet sliding, different camera angle
```

### 11.4 Shot VFX Prompt Packet

Prompt:

```text
Pixel-art arcade sports impact VFX sprite set, transparent background, crisp hard edges, short-lived readable effects for pickleball shots: small dink sparkle, horizontal drive slash arc, upward lob scoop arc, vertical overhead smash impact band, miss whiff arc, bounce ring, fast ball trail, point burst. Bright but controlled colors, upper-left light, no text, no logos, clean alpha edges.
```

Negative prompt:

```text
large explosion, blurry glow, smoky realistic particles, text labels, logos, full-screen effect, low contrast, black halo, noisy spark clutter
```

### 11.5 UI Prompt Packet

Prompt:

```text
Pixel-art arcade sports mobile UI assets for a pickleball game, compact score panel, feedback plaque, pause button, touch control skins, result plaque, polished but readable, warm yellow accents, teal court colors, crisp outlines, subtle bevels, transparent background, no logos, no random text, designed for portrait gameplay HUD.
```

Negative prompt:

```text
generic fantasy UI, sci-fi hologram, blurry gradients, unreadable tiny text, huge decorative frame, brand logos, random letters, photorealistic material
```

## 12. Verification Commands

Run from `dink_rivals/` unless noted:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter devices
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d emulator-5554
```

Physical Pixel verification:

```bash
flutter devices
flutter install -d <PIXEL_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d <PIXEL_DEVICE_ID>
```

Windows screenshot helpers:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1
& $adb -s emulator-5554 shell screencap -p /sdcard/dink_rivals_visual.png
& $adb -s emulator-5554 pull /sdcard/dink_rivals_visual.png ..\dink_rivals_visual.png
```

Doc-only changes do not require Flutter tests, but any runtime visual integration phase does.

## 13. Android Visual QA Checklist

Run these checks on emulator and physical Pixel before closing the overhaul:

- Launch: splash/menu appears without blank frames or stretched assets.
- Main menu: background, logo, buttons, and text do not overlap.
- Character select: portraits match gameplay identity.
- Court select: court card art resembles actual match visuals.
- Serve: server, receiver, ball, serve indicator, score, and controls are readable.
- Rally: player movement, opponent movement, ball trail, and court lines stay clear.
- Dink: small contact animation appears only on contact.
- Drive: horizontal swing arc appears, and miss risk is visually clear.
- Lob: upward scoop and ball height cue read immediately.
- Smash: overhead indicator appears only when the ball is in the proper zone.
- Miss: miss animation does not trigger hit VFX or accidental dink visuals.
- Fault/out: callout is legible and clears quickly.
- Point result: result animation does not hide the next serve setup.
- Pause/settings: panels are styled consistently and fit safe areas.
- End match: result screen looks connected to the match world.
- Performance: no obvious stutter during shot VFX or menu transitions.

## 14. Definition Of Done

The visual overhaul is done when:

- Gameplay screenshots are recognizably closer to `concept-screenshot.png` in environment density, court material, player charm, HUD integration, and shot feedback.
- New core assets are generated bitmap art, not hand-drawn placeholder primitives.
- Current asset manifests document generated sources, dimensions, pivots, and runtime ownership.
- Every shot type has a distinct animation and matching VFX or indicator.
- Hitbox visual indicators match active gameplay hit zones.
- HUD and controls are polished, compact, and readable on Pixel.
- Menu and match result screens share the same visual identity as gameplay.
- `flutter analyze` passes.
- `flutter test` passes.
- Debug APK builds.
- Emulator and physical Pixel screenshots are captured and archived.
- Remaining gaps are documented with follow-up tickets instead of hidden in code comments.

## 15. Risks And Mitigations

Risk: generated art has inconsistent scale or style.

Mitigation: use prompt packets, contact sheets, and normalization passes before integration.

Risk: richer backgrounds reduce gameplay readability.

Mitigation: enforce ball/player contrast checks on screenshots and reserve clean visual corridors around the ball path.

Risk: larger sprites break hitboxes or projection.

Mitigation: change sprite footprint, projection, and hitbox tests together in a scoped character phase.

Risk: VFX hides the ball.

Mitigation: cap effect lifetime, opacity, and screen size; verify each shot on Pixel.

Risk: monolithic background prevents layered polish.

Mitigation: split environment into generated bitmap layers and let `EnvironmentLayout` place props.

Risk: UI polish regresses touch ergonomics.

Mitigation: preserve or increase hit targets while reducing visual weight.

Risk: performance cost rises from more textures.

Mitigation: atlas related assets, keep dimensions modest, avoid per-frame allocations, and test on physical Android.

## 16. Suggested Ticket Breakdown

1. Create visual overhaul baseline capture and prompt templates.
2. Replace monolithic park background with layered generated environment assets.
3. Upgrade court surface and net visuals.
4. Generate and integrate upgraded player/opponent animation sets.
5. Generate and integrate shot-specific VFX and swing-hitbox indicators.
6. Redesign gameplay HUD and touch controls.
7. Redesign menu, roster, court select, settings, pause, and result screens.
8. Run emulator and Pixel visual QA, update comparison docs, and file residual polish tickets.

Each ticket should include:

- Owned files.
- Prompt packet.
- Generated contact sheet.
- Selected assets and dimensions.
- Integration steps.
- Acceptance screenshots.
- Required commands.
- Known risks.

## 17. First Implementation Recommendation

Start with environment layering before characters. The environment is the largest perceived gap against the concept screenshot, and the current `ClassicEnvironmentComponent` already has a clear integration issue where the generated background bypasses configured props. Fixing that unlocks richer scene composition without touching gameplay physics.

After the environment reads correctly, move to character sprites and shot VFX together. Those two systems define moment-to-moment feel, and recent swing-hitbox work gives a strong foundation for visible move indicators.
