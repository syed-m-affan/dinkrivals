# Dink Rivals Visual Overhaul v2 Spec

## 1. Purpose

v1 of the visual overhaul (`docs/specs/visual-overhaul-spec.md`, closed out through phase 5.2 and the 5h micro-polish set) succeeded at *environmental* readability: `park_background_overhaul.png` now paints a recognizable park court, `ClassicEnvironmentComponent` correctly layers 18 props on top of it, the net renders cleanly via background-crop trick, and the VFX system is mature (8 wired effects, capped buffer, no per-frame allocations). The current emulator capture (`phase-5.2-gameplay-emulator-smoke.png`) is broadly playable and readable.

What v1 did **not** close is the perceived-quality gap against `docs/art/concepts/concept-screenshot.png`. v2 exists to close it.

The five residual gaps v2 must close:

1. **Characters read as chunky pixel blobs, not athletes.** Concept characters are clearly drawn pixel-art athletes with caps, faces, paddles, and mid-action poses. Current sprites are silhouette-only at a 32×48 source frame and ~22×33 court-unit logical footprint — too small to carry concept-level detail.
2. **Character and ball scale relative to the court is wrong.** In the concept, the near player reads at ~12% of screen height with clear feet/torso/cap segmentation; current player is ~7–8% and reads as a small token.
3. **Backdrop is missing the concept's arcade-venue identity.** Concept shows a prominent "DINK RIVALS" banner and a "PICKLEBALL LEGENDS" sign framed behind the far court. Current bg bakes small signage but does not read as a venue.
4. **HUD/feedback plaques are flat code-rendered surfaces** that don't match the concept's chunky bordered arcade plaques ("DINK! / NICE SHOT", "YOU 05 / RIVAL 03", "RALLY: 6 / LAST SHOT: DINK").
5. **Environment is locked into a single monolithic painted image,** which prevents art-direction iteration (alt venues, denser dressing, swappable signage).

v2 is AI-first like v1: new assets default to generated bitmap images normalized to a locked style, then integrated and verified through repeatable agent tasks. Hand-drawn placeholder primitives are reserved for masks, debug overlays, and tiny code-native UI elements.

## 2. Reference Materials

Quality target:

- `docs/art/concepts/concept-screenshot.png` — single source of truth for the v2 quality bar
- `docs/art/concepts/concept-sheet.png` — secondary art-direction reference

Current-state evidence v2 must beat:

- `docs/art/phase-5.2/phase-5.2-gameplay-emulator-smoke.png` — current gameplay smoke
- `docs/art/phase-5.2/phase-5.2-final-rally.png`, `phase-5.2-final-serve.png` — v1 closeout captures
- `phase5_current.png` (repo root) — older baseline for "how far we've come" comparison

Prior planning to honor (extend, do not re-litigate):

- `docs/specs/visual-overhaul-spec.md` — v1 canon
- `docs/art/phase-5/visual-direction.md`, `visual-gap-inventory.md`, `phase-5.2-art-direction.md`, `phase-5.2-delta-inventory.md`
- `docs/art/phase-5/render-layer-map.md` — layer order canon
- `docs/specs/build-spec.md` — product non-negotiables (3/4 perspective, no IAP, etc.)
- `docs/art/visual-overhaul/prompts/character-sprite-generated-atlas.md` — v1 prompt packet

Runtime code inspected for this spec:

- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/components/racket_component.dart`
- `dink_rivals/lib/game/components/ball_component.dart`
- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/components/net_component.dart`
- `dink_rivals/lib/game/components/court_component.dart`
- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/game/components/vfx/vfx_layer_component.dart`
- `dink_rivals/lib/game/config/character_visuals.dart`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/lib/game/config/tuning_constants.dart`
- `dink_rivals/lib/game/systems/court_layout_system.dart`
- `dink_rivals/lib/game/util/court_projection.dart`

## 3. Product Visual Goal

v2 should make the in-game match screen look like the same game as the concept screenshot. Concretely:

- The near player and far opponent both read as clearly drawn pixel-art athletes — visible cap, visible paddle, visible mid-action pose — at gameplay distance on a Pixel-class phone.
- Character and ball scale relative to the court is coherent across the full perspective depth range.
- The backdrop reads as an arcade pickleball *venue*, not a generic park — branded banner, framed sign, fence, trees, court-side dressing.
- HUD plaques are chunky, bordered, two-line where the concept is two-line, and tucked into the same screen anchors the concept uses.
- Menu/roster/end-match screens share the same arcade language so the player never crosses a visual boundary between menu and match.

Gameplay readability still wins over art density (see §4).

## 4. Non-Negotiables

Inherited from v1 and the build spec, restated here so v2 tickets can quote them directly:

- 3/4 mobile portrait perspective is fixed. No camera angle changes.
- Gameplay readability wins over art density. Ball, player feet, paddle state, service status, and score must remain clear on a Pixel-class device at all times.
- Court geometry and hitbox math stay deterministic. Visual changes do not alter rally outcomes.
- New visual assets default to generated bitmap images. Hand-drawn placeholders only for debug overlays, masks, hitbox guides, and tiny code-native UI primitives.
- Store visual decisions in `lib/game/config/` (visual palette, tuning, environment layout, character visuals). No magic numbers in components.
- All generated assets must be original — no logos, no celebrity likenesses, no trademarked uniforms.
- Every phase produces evidence (PNGs in `docs/art/visual-overhaul/evidence/vo2-*`).
- `flutter analyze` zero warnings and `flutter test` green at every phase boundary.
- Physical Pixel install verified at the v2 closeout phase (VO2-8).
- Player-control affordances stay inside Android safe areas with ≥48 dp hit targets.

**v2-specific non-negotiable: locked shared style across all generated art.** Environment layers, character sprites, signage, HUD plaques, portraits, court cards must all share one locked style — same palette, same line weight, same lighting direction, same pixel density. The Art Direction Agent owns and publishes `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md` before any generation begins; every prompt packet inherits from it by reference; the Asset Normalization Agent enforces it as a gate before integration. Any candidate that style-breaks against existing v1 props or earlier-landed v2 assets goes back to generation, not into the repo.

## 5. Locked Decisions

The following were decided at spec time and are not open for re-litigation inside phase tickets.

- **Source sprite footprint:** 48×72 px per frame (1.5× the v1 32×48). Frame-count divisor in `player_component.dart:245` and `opponent_component.dart:246` updates from `/32` to `/48`. Logical sprite size constants (`player_component.dart:47-49`, `opponent_component.dart:47-49`) go from 22×33 court-units to 33×49.5 court-units.
- **Roster sprite coverage:** Only the player and opponent on-court archetypes get full new 11-state sprite sheets. Rookie/Rally Queen/Veteran/Showman portraits get a style-matched refresh, but no full-sheet generation for the unused archetypes.
- **Environment layering:** Split `park_background_overhaul.png` into separate generated bitmap layers (sky_trees, fence_signage, court_base, net). Court projection control points in `court_layout_system.dart:15-32` are preserved — only the painted content is split.

## 6. v2 North Star (style rules)

Same direction as v1, tightened:

- Polished pixel-art arcade sports, not realistic simulation.
- Warm daylight, consistent upper-left key light, grounded lower-right shadows.
- Saturated but controlled palette: deep blue court paint, white lines, teal banner/sign accents, warm yellow highlights, red opponent identity, navy player identity.
- Clear depth bands: sky+far trees → fence+signage band → court apron → court playfield → players → ball → HUD.
- Chunky pixel forms with crisp 1-px outlines and small internal highlights. No painterly blur, no antialias haze for runtime sprites.
- Players are stylized athletes: cap, face, paddle, action pose — readable at gameplay scale.
- Shot VFX is short, readable, and informative: dink, drive, lob, smash, miss, fault, serve, point.
- UI is arcade-premium and compact, not debug-like.

## 7. AI-First Production Model

### 7.1 Agent Roles

| Role | Phases | Owned scope |
|---|---|---|
| Art Direction Agent | VO2-0 | Decomp doc, shared style rules, prompt packets, palette pulls |
| Asset Generation Agent | VO2-1, VO2-3, VO2-4, VO2-7 | Candidate PNGs, contact sheets |
| Asset Normalization Agent | VO2-3, VO2-4, VO2-7 | Crop/align/pivot/dimension fix; manifest updates; style-rules gate |
| Runtime Integration Agent | VO2-1, VO2-2, VO2-5, VO2-6, VO2-7 | Dart code edits; config/tuning changes; component wiring |
| Visual QA Agent | VO2-1, VO2-3, VO2-4, VO2-5, VO2-6, VO2-8 | Emulator + Pixel captures; concept comparison |
| Performance QA Agent | VO2-2, VO2-5, VO2-8 | Frame pace, APK size, texture memory |
| Closeout Agent | VO2-8 | Comparison doc, residual ticket file-out, PHASE_NOTES.md update |

Agents work from explicit file ownership. For example, the character package owns `assets/images/sprites/`, `lib/game/config/character_visuals.dart`, and the animation-state mapping in `player_component.dart` / `opponent_component.dart`.

### 7.2 Asset Loop (per package)

1. Pull from `vo2-shared-style-rules.md`.
2. Generate 4–8 bitmap candidates from the packet.
3. Build a contact sheet; choose one approved direction.
4. Normalize to runtime dimensions and pivots.
5. Run the style-rules checklist gate (Normalization Agent rejects, returns to generation if it fails).
6. Update the asset manifest README in the owning folder.
7. Integrate through config and existing components.
8. Capture before/after screenshots in `docs/art/visual-overhaul/evidence/vo2-*`.
9. Run `flutter analyze` + `flutter test`.
10. Record acceptance and any unresolved gaps.

### 7.3 Source and Evidence Folders

- `docs/art/visual-overhaul/prompts/` — v1 packets stay; v2 packets prefixed `vo2-`. The shared style rules live here as `vo2-shared-style-rules.md`.
- `docs/art/visual-overhaul/contact-sheets/` — generated candidate sheets. v2 sheets prefixed `vo2-`.
- `docs/art/visual-overhaul/evidence/` — screenshots, comparisons, QA notes. v2 captures prefixed `vo2-`.
- `dink_rivals/assets/images/source/` — optional source exports.

Do not overwrite v1 evidence. Compare against it.

### 7.4 Generated Image Rules (v2 additions)

Every v2 prompt packet must include by reference the contents of `vo2-shared-style-rules.md`, which locks:

- Palette card (≤16 colors pulled from `lib/game/config/visual_palette.dart`).
- Line weight (1-px hard outline).
- Lighting (upper-left key, lower-right grounded shadow).
- Pixel density (target 1 source-px ≈ 1 screen-px at near-baseline depth).
- "Reject if": painterly shading, watercolor, vector-flat icon style, antialias haze, unlisted palette colors, alternate lighting direction, isometric-mismatch perspective, fake text/logos, black halos, transparent fringes.

Negative prompts inherit from v1.

## 8. Target Runtime Architecture

### 8.1 Environment

Move from one monolithic painted background to layered generated bitmaps sharing the 941×1672 canvas:

- `layer_sky_trees.png` — back band: sky gradient, distant tree silhouettes; transparent below the tree line.
- `layer_fence_signage.png` — mid band: chain-link fence, "DINK RIVALS" banner, "PICKLEBALL LEGENDS" framed sign; transparent elsewhere.
- `layer_court_base.png` — court paint, apron, ground transitions, white lines, kitchen. This is the projection anchor.
- `layer_net.png` — net mesh, posts, rail; transparent everywhere else.

`ClassicEnvironmentComponent` draws layers in order: sky_trees → fence_signage → court_base → cast shadows → existing props (from `EnvironmentLayout.classicProps`). `NetComponent` switches from the current crop-from-bg trick (`net_component.dart:17-62`) to drawing `layer_net.png` directly at the same priority.

Perspective control points in `court_layout_system.dart:15-32` are preserved against the new `layer_court_base.png` (same pixel coordinates, same canvas size).

### 8.2 Court

`CourtComponent` remains a no-op placeholder. All court paint moves into `layer_court_base.png`. Lines, kitchen, service boxes, and surface texture all live in the layer asset, generated in the locked style.

### 8.3 Net

Net upgrades from cropped background to dedicated layer asset. The Flame component priority continues to follow `Court.netY` for depth sorting (per `docs/art/phase-5/render-layer-map.md` §8).

### 8.4 Characters and Animation

Source frames bump to 48×72 px (from 32×48). Logical sprite size bumps to 33×49.5 court-units (from 22×33). Frame counts per state are unchanged:

| State | Frames | FPS |
|---|---|---|
| idle | 2 | 2 |
| ready | 3 | 3 |
| run | 6 | 5.5–14 (dynamic via `_runFpsForSpeed`) |
| dink | 2 | 14 |
| drive | 3 | 18 |
| lob | 3 | 12 |
| smash | 3 | 22 |
| miss | 2 | 18 |
| hitConfirm | 2 | 12 |
| pointWin | 3 | 4 |
| pointLoss | 2 | 3 |

Feet pivot at y=70 (2-px foot padding). Frame-to-frame foot stability is required except during `run`.

### 8.5 Paddles and Hitboxes

Paddle sprite (`racket_component.dart:171-172`) bumps from 10×18 to 14×25 court-units to stay proportional. Hitbox radii in `tuning_constants.dart` (`racketHitRadius`, `cleanContactRadius`, `forgivenContactRadius`, `emergencyBodyContactRadius`, `verticalHitRadius`) scale by ~1.0–1.15× — characters are 1.5× larger but hit feel should slightly favor player reach rather than scale strictly. Document final values in a comment block.

### 8.6 Ball

Ball radius formula in `ball_component.dart:86-89` re-tunes and promotes its constants to `tuning_constants.dart` as `Tuning.ballRadiusBase` and `Tuning.ballRadiusAltitudeBoost`. Target: ball reads ~14 px on a 1920-tall canvas at near-baseline, larger than the racket contact point but never obscures the paddle.

`court_projection.dart:71-75` `depthScale` range (currently 0.40 far → 1.15 near) is re-verified with the new character size. If the near player reads too large at depthScale=1.15, clamp the near edge to ~1.05 or raise the far edge to ~0.50 to compress the dynamic range. Tune empirically; record final values.

### 8.7 VFX

Existing 8-effect set (dinkSpark, driveArc, lobArc, smashBand, missWhiff, bounceRing, trailSegment, pointBurst) keeps its plumbing. Emit sizes review ~1.2× scale, configurable from `tuning_constants.dart`. Ball shadow contrast on the court bumps so the arc apex is readable at every altitude.

### 8.8 HUD and Controls

`score_component.dart` shrinks to a top-left two-panel block. "YOU 05" (yellow accent) + "RIVAL 03" (red accent), 2-px gap, no central divider chip. The rally/last-shot readout currently in this component moves to a new dedicated component.

New `lib/game/components/rally_strip_component.dart`: left-anchored two-line strip showing `RALLY: 6` and `LAST SHOT: DINK`, monospace, drop shadow, no border. Reads `game.matchState.rallyCount` and `game.lastShotType`.

`rally_feedback_component.dart` rebuilds to a two-line bordered plaque ("DINK!" / "NICE SHOT") top-center. Pop-on 0.15s, hold 0.6s, fade 0.25s. Existing triggers unchanged.

`touch_controls_component.dart` tightens the move stick and swing knob, removes the AIM label text, repositions the SERVE button to bottom-center (small, only visible during own-serve). Hit-target size stays ≥48 dp.

Debug overlay (`Phase 5 FPS 120 …`) gates behind `DebugFlags.showHud` and is off in gameplay builds.

### 8.9 Menus and Out-of-Match Screens

Flutter widgets stay (they share `VisualPalette`). `ArcadeButton` and `ArcadePanel` re-token to the new palette and gain a chunkier 3-px outer border + 2-px inner highlight to match the in-game plaques. Menu hero background regenerates from the same prompt family as the new environment layers. Roster portraits regenerate to match the new player and opponent sprite identities. Court card regenerates to match the new layered env.

## 9. Phase Plan

### Phase VO2-0 — Baseline Capture and Concept Decomposition

**Owner:** Art Direction Agent
**Goal:** Lock the comparison evidence and produce a one-page concept breakdown before any asset work.

**Tasks:**
- Capture fresh emulator screenshots: menu, roster, serve, rally, dink, drive, lob, smash, point-win, pause. Store as `docs/art/visual-overhaul/evidence/vo2-baseline-*.png`.
- Capture physical Pixel screenshots for the same set.
- Produce `docs/art/visual-overhaul/visual-overhaul-v2-decomp.md`: annotated concept-screenshot breakdown covering (a) character scale fractions, (b) ball arc + trail spec, (c) backdrop signage placement, (d) HUD anchor positions, (e) color palette pulls, (f) lighting direction.
- Publish `docs/art/visual-overhaul/prompts/vo2-shared-style-rules.md` (the locked palette card, line-weight reference, lighting note, "reject if" checklist).
- Update `docs/art/visual-overhaul/prompts/` with five new v2 prompt packets: character, environment-layer, signage, HUD, ball-trail. Each inherits from `vo2-shared-style-rules.md`.

**Acceptance:**
- ≥10 baseline PNGs under `vo2-baseline-*` exist on emulator and Pixel.
- `visual-overhaul-v2-decomp.md` lists explicit pixel/percentage targets for character height, ball diameter, score panel width, plaque size.
- `vo2-shared-style-rules.md` exists and is referenced by every v2 prompt packet.
- Five v2 prompt packets exist.

### Phase VO2-1 — Environment Layer Split

**Owner:** Asset Generation Agent + Runtime Integration Agent
**Goal:** Replace monolithic `park_background_overhaul.png` with separately authored, layer-aligned generated assets — without breaking court projection, and without introducing a style break against the rest of the game.

**Tasks:**
- Generate four layered PNGs on the 941×1672 canvas: `layer_sky_trees.png`, `layer_fence_signage.png`, `layer_court_base.png`, `layer_net.png`. All inherit from `vo2-shared-style-rules.md`.
- Update `lib/game/config/environment_layout.dart` `generatedBackgroundAsset` from a single path to a typed list of `EnvironmentBackgroundLayer`.
- Rewrite `lib/game/components/classic_environment_component.dart:64-117` to draw layers in order: sky_trees → fence_signage → court_base → cast shadows → existing props.
- Update `lib/game/components/net_component.dart:17-62` to draw `layer_net.png` directly instead of cropping the monolithic bg.
- Preserve `court_layout_system.dart:15-32` perspective trapezoid control points; re-verify by overlaying gameplay logical bounds on the new `layer_court_base.png`.

**Acceptance:**
- Court projection unchanged: ball serve start, player baseline, opponent baseline, net line all land on the painted court within 2 px on emulator.
- Backdrop reads as an arcade pickleball venue. "DINK RIVALS" banner and "PICKLEBALL LEGENDS" sign are visible and legible.
- All four layers pass the style-rules gate against `vo2-shared-style-rules.md`.
- `flutter analyze` clean; `flutter test` green.
- Evidence: `vo2-env-split-rally.png`, `vo2-env-split-serve.png`.

### Phase VO2-2 — Character Footprint Bump (Code + Hitbox Alignment)

**Owner:** Runtime Integration Agent
**Goal:** Make the codebase ready for 48×72 frames at the new logical size *before* generating new art, so generation has a stable target.

**Tasks:**
- `lib/game/components/player_component.dart:47-49`: `_spriteWidth = 33`, `_spriteHeight = 49.5`, recompute `_spriteFootPadding = _spriteHeight * (2 / 72)`.
- `lib/game/components/player_component.dart:245`: change `_frameCountFor` divisor from `/32` to `/48`.
- `lib/game/components/opponent_component.dart`: mirror the same edits on lines 47–49 and 246.
- `lib/game/config/tuning_constants.dart`: review `racketHitRadius`, `cleanContactRadius`, `forgivenContactRadius`, `emergencyBodyContactRadius`, `verticalHitRadius`. Scale by ~1.0–1.15×. Document final values in a comment block.
- `lib/game/components/racket_component.dart:171-172`: bump paddle from 10×18 to 14×25 court-units.
- Author 22 placeholder 48×72 sprite sheets (solid-color silhouettes — 11 player + 11 opponent) so the game runs through this ticket before real art lands. Name them clearly so future deletion is trivial.
- Run `flutter analyze` (zero warnings) and `flutter test` (green).
- Capture emulator screenshot: player+opponent at new logical size with placeholder silhouettes; confirm feet stick to court and racket sprite endpoint meets `game.playerRacketPosition()`.

**Acceptance:**
- `flutter analyze` zero warnings; `flutter test` green.
- Player and opponent silhouettes visibly larger on emulator; feet do not float or sink.
- Ball contact during a standard rally still triggers `hitConfirm` consistently.
- Racket sprite endpoint visually meets the ball at contact.

### Phase VO2-3 — Player Sprite Generation and Integration

**Owner:** Asset Generation Agent → Asset Normalization Agent → Runtime Integration Agent
**Goal:** Replace the 11 player sheets with concept-quality 48×72 pixel-art frames.

**Tasks:**
- Generate using the v2 character prompt packet (blue cap, white shirt with red trim, navy shorts, visible paddle in right hand, athletic stance, 3/4 mobile perspective, locked palette and lighting). Per-state frame counts: idle 2 / ready 3 / run 6 / dink 2 / drive 3 / lob 3 / smash 3 / miss 2 / hitConfirm 2 / pointWin 3 / pointLoss 2.
- Normalize: each frame 48×72, feet anchored at y=70 (2-px foot padding), pivot stable frame-to-frame (no horizontal foot drift outside `run`). Save as `assets/images/sprites/player_<state>.png`, replacing the v1 files.
- No code changes needed (VO2-2 landed the runtime support).
- Capture in-game contact sheet `docs/art/visual-overhaul/contact-sheets/vo2-player-ingame.png`.

**Acceptance:**
- All 11 player sheets are 48×72 per frame, transparent background, no halo.
- All 11 sheets pass the style-rules gate.
- Player reads as a clearly drawn athlete with cap + paddle visible at Pixel gameplay distance.
- Animation transitions (idle ↔ run ↔ swing) play without frame snap; feet stable.
- Hitbox alignment unchanged.

### Phase VO2-4 — Opponent Sprite Generation and Integration

**Owner:** Asset Generation Agent → Asset Normalization Agent → Runtime Integration Agent
**Goal:** Distinct, concept-matched opponent (red cap, contrasting kit) with full 11-state coverage.

**Tasks:**
- Generate, normalize, integrate 48×72 frames for `opponent_<state>.png` × 11 states using a sibling prompt packet. Silhouette must be distinguishable from player at gameplay scale (different cap shape + kit color).
- Capture in-game contact sheet `vo2-opponent-ingame.png`.
- Run a 5-minute rally smoke on emulator; confirm `OpponentAISystem` is unaffected (sprites are visual-only).

**Acceptance:**
- Player and opponent are silhouette-distinct in a Pixel-distance screenshot.
- Opponent animates correctly through serve, rally, dink, drive, lob, smash, miss, point states.
- All 11 sheets pass the style-rules gate.
- No analyze/test regressions.

### Phase VO2-5 — Ball + Perspective Scaling Pass

**Owner:** Runtime Integration Agent + Visual QA Agent
**Goal:** Re-tune ball size, trail, and perspective so the arc reads as 3D motion against the new larger characters.

**Tasks:**
- `lib/game/components/ball_component.dart:86-89`: re-tune the radius formula. Concept ball reads ~14 px on a 1920-tall canvas (~0.7%). Promote constants to `tuning_constants.dart` as `Tuning.ballRadiusBase` and `Tuning.ballRadiusAltitudeBoost`. Ball must remain larger than the racket contact point but never obscure the paddle.
- Re-verify `court_projection.dart:71-75` `depthScale` range (0.40 far → 1.15 near). Sweep near/mid/far baseline positions. If near reads too large, clamp near edge to ~1.05 or raise far edge to ~0.50. Record final values.
- `lib/game/components/vfx/vfx_layer_component.dart`: confirm trail/bounce-ring/contact-burst sizes still feel proportional. Bump emit sizes ~1.2× if needed, configurable from `tuning_constants.dart`.
- Verify court ball shadow contrast at arc apex. Bump if needed.

**Acceptance:**
- Ball readable at every altitude across a full rally on Pixel.
- Trail clearly conveys arc; lob shows tall arc, drive shows flat trajectory.
- Scale chain reads coherently: at the same y, ball < racket < player.
- Ball/VFX tuning constants centralized; no magic numbers in `ball_component.dart`.

### Phase VO2-6 — HUD and Feedback Plaque Refit

**Owner:** Runtime Integration Agent
**Goal:** Replace procedural HUD surfaces with concept-matched arcade plaques. Still code-painted via `Canvas.drawRRect` + text — no new tech.

**Tasks:**
- `lib/game/components/score_component.dart`: shrink to a top-left anchored two-panel block ("YOU 05" yellow / "RIVAL 03" red, 2-px gap, no central chip). Move rally/last-shot readout out of this component.
- New `lib/game/components/rally_strip_component.dart`: left-anchored two-line strip (`RALLY: 6`, `LAST SHOT: DINK`). Monospace, drop shadow, no border. Reads `game.matchState.rallyCount` and `game.lastShotType`.
- `lib/game/components/rally_feedback_component.dart`: rebuild to two-line bordered plaque ("DINK!" / "NICE SHOT"). Pop-on 0.15s, hold 0.6s, fade 0.25s.
- `lib/game/components/touch_controls_component.dart`: tighten move stick + swing knob, remove AIM label text, reposition SERVE button to bottom-center (small, own-serve only). Hit targets stay ≥48 dp.
- Gate debug overlay behind `DebugFlags.showHud`. Off by default in gameplay builds.

**Acceptance:**
- Top-left score block matches concept proportions on Pixel.
- Feedback plaque triggers on every shot type with correct two-line text.
- Rally strip updates live during rallies.
- Controls pass the 48 dp thumb-target audit and don't overlap court surface paint.
- No text overlap or safe-area violations on Pixel.

### Phase VO2-7 — Out-of-Match Screen Cohesion

**Owner:** Runtime Integration Agent + Asset Generation Agent
**Goal:** Carry the new arcade language into menu, roster, settings, pause, end-match without rebuilding them in Flame.

**Tasks:**
- `lib/widgets/arcade_button.dart`, `arcade_panel.dart`: re-token to the new palette. Add chunkier 3-px outer border + 2-px inner highlight.
- `lib/screens/main_menu_screen.dart`: regenerate menu hero background using the same prompt family as v2 environment layers (park venue, lower density, room for logo).
- `lib/screens/roster_screen.dart`: regenerate `ui/portrait_*.png` × 4. Player + opponent portraits must visibly resemble their new 48×72 sprite identities. Veteran + Showman portraits get a style-pass-only refresh.
- `lib/screens/end_match_screen.dart`: result plaque uses the same plaque chrome as the in-game feedback plaque.
- `assets/images/ui/court_cards/classic_court_card.png`: regenerate to match the layered env.

**Acceptance:**
- Menu → roster → match → pause → end-match reads as one coherent visual world.
- Roster portraits look like the same characters as the gameplay sprites.
- All regenerated assets pass the style-rules gate.
- No text overlap or safe-area violations on Pixel.

### Phase VO2-8 — Android QA, Performance, and Closeout

**Owner:** Performance QA Agent + Closeout Agent
**Goal:** Verify on physical hardware and document the result.

**Tasks:**
- From `dink_rivals/`: `flutter pub get && dart format . && flutter analyze && flutter test && flutter build apk --debug`.
- Install on emulator and physical Pixel. Capture evidence set (menu, roster, settings, serve, dink, drive, lob, smash, point-win, pause, end-match) under `docs/art/visual-overhaul/evidence/vo2-final-*`.
- Frame-pace audit: serve sequence, full rally with shot VFX, point-burst, menu transition. No sustained <55 fps on Pixel.
- APK size check: report delta from v1. Flag if >+8 MB.
- Update `docs/art/visual-overhaul/visual-overhaul-v2-comparison.md` with concept vs vo2-final side-by-side. Convert residual gaps to `vo3-` follow-up tickets.
- Update `dink_rivals/PHASE_NOTES.md` with v2 closeout summary.

**Acceptance:**
- All evidence PNGs archived.
- `flutter analyze` clean, `flutter test` green, APK builds.
- 5-minute Pixel smoke: no crash, no jank spike.
- v2 comparison doc lists remaining gaps explicitly.

## 10. Asset Work Packages

### 10.1 Environment Layer Package

Owned paths:

- `dink_rivals/assets/images/environment/classic/layer_*.png`
- `dink_rivals/lib/game/config/environment_layout.dart`
- `dink_rivals/lib/game/components/classic_environment_component.dart`
- `dink_rivals/lib/game/components/net_component.dart`

Assets: `layer_sky_trees.png`, `layer_fence_signage.png`, `layer_court_base.png`, `layer_net.png`.

Acceptance: pass style-rules gate; court projection within 2 px; signage legible.

### 10.2 Character Package

Owned paths:

- `dink_rivals/assets/images/sprites/player_*.png` × 11
- `dink_rivals/assets/images/sprites/opponent_*.png` × 11
- `dink_rivals/assets/images/sprites/paddle_player.png`, `paddle_opponent.png`
- `dink_rivals/lib/game/config/character_visuals.dart`
- `dink_rivals/lib/game/components/player_component.dart`
- `dink_rivals/lib/game/components/opponent_component.dart`
- `dink_rivals/lib/game/components/racket_component.dart`

Assets per side: 11 state sheets at 48×72 per frame + paddle at 14×25 court-units.

Acceptance: 11 stable-pivot frames per state; silhouette-distinct player vs opponent; style-rules gate pass; hitbox alignment retained.

### 10.3 Ball + VFX Package

Owned paths:

- `dink_rivals/lib/game/components/ball_component.dart`
- `dink_rivals/lib/game/components/vfx/vfx_layer_component.dart`
- `dink_rivals/lib/game/util/court_projection.dart`
- `dink_rivals/lib/game/config/tuning_constants.dart`

Tasks: re-tune ball radius formula, depthScale range, VFX emit sizes. Centralize constants in `tuning_constants.dart`.

Acceptance: ball readable across full arc; scale chain coherent.

### 10.4 HUD Package

Owned paths:

- `dink_rivals/lib/game/components/score_component.dart`
- `dink_rivals/lib/game/components/rally_feedback_component.dart`
- `dink_rivals/lib/game/components/rally_strip_component.dart` (new)
- `dink_rivals/lib/game/components/touch_controls_component.dart`
- `dink_rivals/lib/game/config/visual_palette.dart`
- `dink_rivals/lib/game/config/debug_flags.dart`

Tasks: score block restyle; rally strip extraction; two-line feedback plaque; control compaction; debug-overlay gating.

Acceptance: HUD anchors match concept; ≥48 dp hit targets preserved; no safe-area violations.

### 10.5 Menu and Out-of-Match Package

Owned paths:

- `dink_rivals/lib/widgets/arcade_button.dart`, `arcade_panel.dart`
- `dink_rivals/lib/screens/main_menu_screen.dart`, `roster_screen.dart`, `end_match_screen.dart`
- `dink_rivals/assets/images/ui/portrait_*.png` × 4
- `dink_rivals/assets/images/ui/court_cards/classic_court_card.png`
- Menu hero background asset (new)

Acceptance: shared arcade language across screens; portraits match gameplay sprites; style-rules gate pass.

## 11. Prompt Packets

All v2 packets live under `docs/art/visual-overhaul/prompts/` and inherit from `vo2-shared-style-rules.md` by reference. Author them in VO2-0.

- `vo2-shared-style-rules.md` — locked palette, line weight, lighting, "reject if" checklist.
- `vo2-character-player.md` — player 11-state sheet packet (blue cap identity).
- `vo2-character-opponent.md` — opponent 11-state sheet packet (red cap identity).
- `vo2-environment-layers.md` — sky_trees, fence_signage, court_base, net layer packet.
- `vo2-signage.md` — DINK RIVALS banner + PICKLEBALL LEGENDS sign packet.
- `vo2-hud.md` — score panel, feedback plaque, rally strip packet.
- `vo2-portraits.md` — 4-character portrait refresh packet.

Each packet states: target dimensions, frame counts (where applicable), pivot rules, palette pulls, lighting note, the "inherits from vo2-shared-style-rules.md" line, and the "reject if" checklist instance.

## 12. Verification Commands

Run from `dink_rivals/` at every phase boundary:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d emulator-5554
```

Physical Pixel at VO2-8:

```bash
flutter devices
flutter install -d <PIXEL_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter run -d <PIXEL_ID>
```

Screenshot helpers (Windows PowerShell):

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell screencap -p /sdcard/vo2.png
& $adb -s emulator-5554 pull /sdcard/vo2.png ..\dink_rivals\docs\art\visual-overhaul\evidence\vo2-<phase>-<state>.png
```

Doc-only phases (VO2-0) skip the Flutter checks; every runtime-touching phase must pass them.

## 13. Android Visual QA Checklist

Run on emulator and physical Pixel before closing v2:

- Launch: splash/menu without blank frames or stretched assets.
- Main menu: hero bg, logo, buttons, text — no overlap, safe-area clean.
- Roster: portraits match gameplay identities.
- Serve: server, receiver, ball, serve indicator, score, controls — all readable.
- Rally: player movement, opponent movement, ball trail, court lines — stay clear.
- Dink: small contact animation only on contact; "DINK!" plaque legible.
- Drive: horizontal swing arc visible; "DRIVE!" plaque legible.
- Lob: upward scoop + ball height cue read immediately.
- Smash: overhead band only in proper zone; "SMASH!" plaque legible.
- Miss: miss animation does not trigger contact VFX or accidental dink visuals.
- Fault/out: callout legible and clears quickly.
- Point result: animation does not hide the next serve setup.
- Pause/settings: panels styled consistently; fit safe areas.
- End match: result screen feels connected to the match world.
- Performance: no obvious stutter during shot VFX, point bursts, or menu transitions.
- Style coherence: pause-then-screenshot at any moment — does anything look like a different game?

## 14. Definition of Done

v2 is done when:

- A side-by-side capture of `concept-screenshot.png` and `vo2-final-rally.png` reads as the same game.
- Player and opponent are clearly drawn athletes with visible caps, paddles, and shot poses at gameplay scale on Pixel.
- Ball + character + court scale chain is coherent across the full depthScale range.
- Backdrop reads as an arcade pickleball venue (banner, sign, fence, trees).
- HUD plaques, rally strip, and feedback plaque match concept proportions.
- Menu/roster/end-match share the same arcade language.
- Every v2 generated asset passed the shared-style-rules gate at integration time.
- `flutter analyze` clean, `flutter test` green, APK builds.
- Physical Pixel runs 5+ minutes without crash or jank spike.
- `docs/art/visual-overhaul/visual-overhaul-v2-comparison.md` exists and converts residual gaps to `vo3-` tickets.

## 15. Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Hitbox alignment drifts after 48×72 bump | VO2-2 lands code + placeholder silhouettes before art generation, so hit-feel re-tunes independently of art quality |
| Layer split breaks court projection | VO2-1 preserves canvas size + perspective control points; only painted content splits |
| Generated layers style-break against characters/props | Mandatory `vo2-shared-style-rules.md` gate at integration; rejected candidates return to generation, not into repo |
| Larger characters obscure the ball | VO2-5 ball + perspective pass runs after sprites land, with explicit ball-vs-character contrast acceptance |
| 48×72 prompts produce inconsistent character across 11 states | Single seed family + locked palette across all states; Normalization Agent enforces pivot stability |
| Roster portraits diverge from gameplay sprites | VO2-7 explicitly requires portrait generation to use the same character-sheet seed/prompt family as gameplay sprites |
| Texture memory regression on low-end Android | VO2-8 reports APK size delta; cap at +8 MB or rework |
| Performance regression from more textures | Atlas related assets, keep dimensions modest, test on physical Pixel at VO2-8 |
| Touch ergonomics regress from tighter HUD | Preserve ≥48 dp hit targets while reducing visual weight; QA at VO2-6 |

## 16. Suggested Ticket Breakdown

One ticket per phase, filed under `tickets/vo2-NNN-<slug>.md`:

1. `vo2-000-overview.md` — pointer to this spec; phase index; agent role table
2. `vo2-001-environment-layer-split.md`
3. `vo2-002-character-footprint-bump.md`
4. `vo2-003-player-sprite-generation.md`
5. `vo2-004-opponent-sprite-generation.md`
6. `vo2-005-ball-and-perspective-scaling.md`
7. `vo2-006-hud-and-feedback-plaques.md`
8. `vo2-007-out-of-match-cohesion.md`
9. `vo2-008-android-qa-and-closeout.md`

(VO2-0 baseline capture is doc-only and can be a sub-task of the overview ticket.)

Each ticket includes: owning agent role, owned files, prompt packet path (if generating art), expected contact-sheet path, integration steps with exact line numbers from this spec, acceptance screenshot list, verification commands, known risks.

## 17. First Implementation Recommendation

Start with **VO2-0 (baseline + shared style rules) followed by VO2-2 (character footprint bump with placeholders) in parallel with VO2-1 (environment layer split)**. The footprint bump unblocks VO2-3 and VO2-4 (the big art-generation tickets) by giving them a stable 48×72 runtime target. The environment split unblocks the signage/venue identity work that the rest of the visual world keys off of. Both can land before any new character art generation begins.

Once VO2-1, VO2-2, and the style rules are in, the four art-heavy phases (VO2-3, VO2-4, VO2-5, VO2-6) can proceed in sequence with confidence that the runtime, projection, and style gate are all stable. VO2-7 picks up the menu cohesion afterward, and VO2-8 is the closeout.
