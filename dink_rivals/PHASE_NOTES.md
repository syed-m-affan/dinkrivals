# Phase 0 - Notes

## Build info
- Flutter version: 3.41.9 stable
- Flame version: 1.37.0
- Tested device: Pixel 10 Pro XL
- Build date: 2026-05-10

## What works
- `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --debug` pass.
- Phase 0 scene boots directly from `main.dart`.
- Gray-box court, kitchen zones, net, player, opponent, ball, shadow, debug overlay, and reset button are implemented.
- App builds, installs, launches directly into gameplay, and shows the PHASE 0 label.
- Right-side shot input triggers; reset/install/run stability looked fine during first playtest.
- Ball visibility and court/kitchen/net markings are clear enough.
- Second-pass build adds visible left joystick control, visible right shot button, and hold-charge feedback.
- Second-pass build softens dink tuning and increases movement responsiveness.
- Second-pass build makes AI recover toward a ready position unless the ball is threatening its side.
- Second-pass build uses a depth-scaled trapezoid court projection with stronger ball height displacement.
- Regression coverage now includes reset-ball inert behavior and serve-position point start.
- Third-pass build responds to feedback that the rhombus perspective still felt top-down/2D, movement was still too slow, dinks were too high, and drives lacked feel beyond distance.
- Fourth-pass build responds to feedback that the ball was too fast to volley, AI was too good/robotic, play area should be bigger, and player needs aim steering.
- Fourth-pass build adds a right-side AIM joystick above the hit button and aim indicators on both players.
- Fourth-pass build slows dink/drive ball travel, increases hit window, makes AI less perfect, and adds idle opponent sway.
- Fifth-pass build responds to feedback that idle AI was too jittery, ball was still too fast, players were too slow, AI should be slower, play area should be bigger, and players should be slightly smaller.
- Fifth-pass build slows ball again, speeds up player, slows AI, smooths/reduces idle sway, enlarges court scale, and shrinks player/opponent circles.
- Sixth-pass build changes the AIM joystick from shot steering to racket placement.
- Sixth-pass build restricts movement input to the visible movement joystick, restricts hit input to the visible hit button, uses the racket as the hitbox, and auto-steers successful dink/drive shots back toward midcourt.
- Seventh-pass build responds to feedback that hitbox still felt player-centered, AI became too stupid, ball got stuck out of bounds after a few hits, and ball still needed to be slower.
- Seventh-pass build extends racket reach, tightens racket hit radius, slows ball again, makes AI more successful than the previous pass, and adds soft boundary rebounds so the ball does not pin to court edges.

## What doesn't feel right
- First playtest: movement was a Phase 0 blocker. Drag/swipe movement felt like quicksand, too slow, and had no clear on-screen affordance.
- Preferred movement scheme: visible left-side virtual control stick where pushing/holding a direction moves continuously.
- Dink and drive both trigger, but they do not feel different enough. Dink is too strong.
- Right-side shot area needs a visible button/affordance, plus an indication that drive is charging while held.
- AI feels too stupid/robotic. It beelines for the ball even when the ball is not meaningfully on its side, then shoots.
- Sustained rallies are currently impossible mainly because movement feels bad.
- Ball visibility is good, but height does not feel like it affects gameplay enough.
- Perspective feels too top-down/2D, closer to Pong with dink/drive buttons than 2.5D/isometric pickleball.
- Second playtest: perspective still felt wrong, like a top-down rhombus court rather than meaningful 2.5D.
- Second playtest: movement remained too slow to keep up with the ball and friction felt weird.
- Second playtest: AI felt better.
- Second playtest: dinks went way too high, and drives only felt like they went farther.
- Third playtest: ball moved too fast to meaningfully get a volley going.
- Third playtest: AI was a bit too good and still somewhat robotic; idle movement would make it feel more human.
- Third playtest: play area should be bigger.
- Third playtest: add a steering joystick above hit button to determine the next dink/drive angle, with visual indicators on each player.
- Fourth playtest: AI idle movement was too jittery/robotic.
- Fourth playtest: ball was still a bit too fast and players a bit too slow.
- Fourth playtest: AI should be a bit slower too.
- Fourth playtest: hard to get volley going when opponent sends the ball deep because player is too slow to get there.
- Fourth playtest: play area should be bigger and players slightly smaller.
- Fifth feedback request: steering control should change where the player holds the racket, and the racket should be the hitbox.
- Fifth feedback request: shots should auto-steer toward the middle if the racket touches the ball when player dinks or drives.
- Fifth feedback request: movement should only start from the movement joystick and hitting should only start from the hit button.
- Sixth playtest: hitbox still felt like it was on the player rather than the racket.
- Sixth playtest: AI was too stupid after the previous tuning.
- Sixth playtest: rallies ended after a few hits because the ball went out of bounds and got stuck there.
- Sixth playtest: ball needs to be slower.

## Bugs found
- No crash/stutter/black-screen issue reported in first playtest.
- Seventh-pass implementation verified with `flutter analyze`, `flutter test` (11/11), and `flutter build apk --debug` on 2026-05-10.

## Tuning suggestions
- Increase movement responsiveness and speed after converting to joystick control.
- Soften dink: lower `dinkSpeedXY`, lower/adjust `dinkInitialZ`, and make it drop shorter into the kitchen.
- Keep drive clearly stronger/deeper, with visible hold charge feedback.
- Improve AI behavior: recover to ready position when ball is not threatening, predict/intercept when ball is coming to opponent side, and avoid always chasing current ball position.
- Make projection more 2.5D/isometric and increase visible separation between ball and shadow so height matters.
- Third-pass tuning changed movement to direct joystick velocity, raised player speed, replaced rhombus skew with depth-scaled trapezoid projection, capped shot flight times, lowered dink arc, and made drives flatter/faster.
- Fourth-pass tuning lowered ball speeds, lowered opponent speed, increased opponent reaction delay/miss chance, increased hit window, enlarged the on-screen court scale, and added aim steering.
- Fifth-pass tuning raised `playerMaxSpeed` to 285, lowered `opponentMaxSpeed` to 82, lowered dink/drive speeds to 98/178, increased opponent reaction delay/miss chance to 0.44/0.34, enlarged court scale, shrank players to radius 8, reduced idle sway amplitude/frequency, and made opponent deep shots less deep.
- Sixth-pass control change adds `racketReach` and `racketHitRadius`, draws racket/hitbox indicators, removes manual shot-angle steering, and adds regression coverage for racket-hitbox shot validation.
- Seventh-pass tuning sets `racketReach` to 42, `racketHitRadius` to 12, lowers dink/drive speeds to 82/142, lowers AI miss chance to 0.22, routes AI hit attempts through the same racket hitbox path, and adds boundary rebound test coverage.
- Eighth-pass control rework removes the dink/drive button entirely.
- Eighth-pass control rework changes the right-side control into a swing stick that rotates the racket through a front 180-degree arc.
- Eighth-pass control rework makes player hits automatic on racket-ball contact, with outgoing ball speed based on racket swing speed, incoming ball speed, and racket angle.
- Eighth-pass control rework fixes the first-hit bug by removing the body-hit shortcut; reset/start hits now use the same racket hitbox as in-play hits.
- Eighth-pass tuning slightly enlarges the visible court scale, lowers player/opponent movement speeds, lowers AI dink/drive speeds, and caps player contact power lower than the previous button-driven shots.
- Eighth-pass verification passed `flutter analyze`, `flutter test` (13/13), and `flutter build apk --debug` on 2026-05-10.
- Ninth-pass tuning responds to feedback that the ball felt stiff/like a lead brick and was hard to serve.
- Ninth-pass tuning lowers the contact threshold, increases racket swing sensitivity, raises soft/firm contact output, adds more lift, lowers gravity/drag, and increases bounce damping while keeping a rest cutoff to avoid micro-hop jitter.
- Ninth-pass verification passed `flutter analyze`, `flutter test` (14/14), and `flutter build apk --debug` on 2026-05-10.
- Ninth-pass install attempt failed because the Pixel 10 Pro XL was no longer visible to Flutter; reconnect/unlock the phone and rerun install.
- Tenth-pass control update responds to feedback that the racket hitbox should include the full racket shaft from player to tip and that the shaded endpoint circle was confusing.
- Tenth-pass control update changes racket contact to a capsule along the player-to-racket segment and removes the translucent endpoint hitbox indicator from rendering.
- Tenth-pass verification passed `flutter analyze`, `flutter test` (15/15), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992` on 2026-05-10.

## Resume notes
- Tenth feedback pass has been implemented, rebuilt, and installed on Pixel 10 Pro XL; physical Android playtest is pending.
- Phase 1 implementation pass adds match state, rally scoring to 7, pure rule evaluation, point reset flow, expanded contact classifications (`dink`, `drive`, `lob`, `smash`), basic AI use of expanded classifications, score display, and transient shot/fault feedback.
- Phase 1 automated verification passed `flutter analyze`, `flutter test` (27/27), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992` on 2026-05-10.
- Phase 1 follow-up wires opponent kitchen volley detection into the game loop, then passed `flutter analyze`, `flutter test` (27/27), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992` on 2026-05-10.
- Latest Android launch smoke test passed on Pixel 10 Pro XL via `adb shell am start -W -n com.example.dink_rivals/.MainActivity`, with status `ok` and wait time 3053ms on 2026-05-10.
- Follow-up `dumpsys window` showed `mFocusedApp=ActivityRecord ... com.example.dink_rivals/.MainActivity`, but `mCurrentFocus=NotificationShade` because the phone was locked, so visual gameplay QA remains unverified.
- After unlocking, a device screenshot verified the gameplay scene renders with the PHASE 0 debug label, score display, court/kitchen/net, player/opponent, ball/shadow, reset button, movement stick, swing stick, and no separate dink/drive button.
- A limited `adb shell input swipe` on the swing control visibly changed gameplay state, but this is not a substitute for human playtesting because it does not verify feel, fair misses, 10+ crossing rallies, or full-match flow.
- Phase 1 manual QA is still pending:
  - Play 3 full matches.
  - Force out-of-bounds.
  - Force double bounce.
  - Try kitchen volley.
  - Produce dink, drive, lob, and smash contact classifications.
  - Confirm match ends at 7.
  - Confirm score updates correctly.
  - Confirm feedback text appears for shots and faults.
  - Confirm opponent can sustain beginner rallies.
  - Play for 5 minutes without crash.
- Next concrete task is installing/playtesting the latest debug APK:
  - Is joystick movement responsive and understandable?
  - Does removing the dink/drive button make hitting more intuitive?
  - Does the right swing stick feel like a 180-degree racket swing rather than 360-degree aiming?
  - Does automatic racket contact feel fair and predictable?
  - Does first-hit/reset contact clearly come from the racket, not the player body?
  - Do softer/firmer swings produce understandable soft/firm returns?
  - Does AI feel less like it is blindly chasing the ball?
  - Does opponent idle sway feel smoother and less robotic?
  - Does the trapezoid projection feel closer to 2.5D/isometric?
  - Is the swing-stick/racket visual clear without clutter?
  - Does the hitbox clearly depend on racket placement and swing timing?
  - Are racket/hitbox indicators useful without clutter?
  - Does restricting movement/hit starts to the visible controls feel better?
  - Is the slightly enlarged play area better?
  - Are smaller player circles still readable?
  - Are 10+ crossing rallies achievable?
  - Does the ball avoid getting stuck at the court edges?

---

# Phase 2 - Notes

## Build info
- Build date: 2026-05-10
- Dependencies added: go_router, flutter_riverpod (3.3.1), shared_preferences

## What landed (P2-001..P2-006)
- App shell: `ProviderScope` + `MaterialApp.router` via GoRouter (routes `/`, `/game`, `/settings`, `/roster`, `/end-match`).
- Save service: `SaveService` over `shared_preferences` for `soundEnabled`, `hapticsEnabled`, `matchesCompleted`. Riverpod `Notifier`/`NotifierProvider` (3.x API).
- Main menu screen: Quick Match / Roster / Settings buttons, placeholder DR logo, phase label.
- Roster screen: read-only list of the four MVP characters (Rookie, Rally Queen, Veteran, Showman).
- Settings screen: Sound + Haptics `SwitchListTile`s wired to the save provider, persisted on toggle.
- Game screen wrapper: `GameWidget<DinkRivalsGame>` in a `Stack` with a pause IconButton; tapping pauses, hardware back also pauses (PopScope). Pause overlay shows Resume / Return to Menu.
- DinkRivalsGame additions: `paused` flag (update(dt) early-returns), `resetMatch()` method, `matchOverNotifier` (ValueNotifier<bool>) that flips true when `_awardPoint` sees `matchOver`.
- End-match screen: detects `matchOverNotifier` from the game screen, navigates to `/end-match`, increments `matchesCompleted` once, shows winner banner + final score + rally stats, Rematch / Return to Menu buttons.

## Verification done
- `flutter analyze` clean, zero warnings.
- `flutter test` passes 47/47 (added: save service tests, save data notifier tests, settings widget tests, end-match screen widget tests, pause flag unit tests; existing 30 still green).
- `flutter build apk --debug` succeeds.
- Android install on Pixel 10 Pro XL was pending at end of session (device disconnected before final install).

## Known caveats
- Riverpod 3.x uses `Notifier`/`NotifierProvider`; legacy `StateNotifier` was abandoned during implementation.
- DinkRivalsGame is constructed once via `dinkRivalsGameProvider` and persists across navigation. `resetMatch()` is the canonical "fresh match" entry point for Rematch / Menu return.
- `recordMatchCompleted` fires when the end-match screen listener triggers — exactly once per completed match. Increment happens in `_handleMatchOver`, not on every `matchOver` write.
- Sound / Haptics toggles persist but have no observable effect; real audio + haptics belong to Phase 5.
- Pause currently overlays the swing/movement controls without clearing the bottom-left/right joystick zones. On device, pointer cleanup (`clearMovement`, `_movementPointerId = null`) prevents stuck sticks on resume.

## Manual Android QA still required (P2-007)
- Launch app boots into main menu (not directly into gameplay).
- Quick Match starts a match.
- Pause mid-rally freezes physics/AI/input.
- Resume continues without snapping.
- Return-to-Menu from pause resets state.
- Match plays to 7; end-match summary shows correct winner and score.
- Rematch starts a fresh 0-0 match.
- Settings toggles persist after app kill/relaunch.
- Roster shows four characters.
- Hardware back from `/game` opens pause (not silent quit).
- Five minutes uptime, no crash.

---

# Playtest 2026-05-10 (post-Phase 2)

## Findings
- Movement joystick stopped tracking after a point reset until finger lifted and re-pressed.
- Serving felt off — bumping a static ball with the racket was inconsistent.
- Swing speed had no felt impact on outgoing ball speed (saturation at the clamp).
- Out-of-bounds fault never triggered — the ball always rebounded off the soft boundary.
- Lob and smash classifications never observed in play; dink vs drive only distinguishable by feedback text.
- Top of the game canvas overlaps the device notch / notification shade on Pixel 10 Pro XL.
- Pause / hardware back / settings persistence were not tested this pass.

## Implementation pass (2026-05-10)
- **P0-003**: `DinkRivalsGame.resetPoint()` no longer clears `_movementPointerId`, `_swingPointerId`, or `inputSystem.clearMovement()`. Drag pointers survive a point reset so a held joystick keeps reading; cleanup happens naturally via Flame's drag/tap-end events.
- **P0-004**: New serve flow. While `!ball.isInPlay`, the ball is glued to the player's racket tip each frame and a bottom-center SERVE button is rendered. Tap launches the ball along racket direction at `serveMinOutputSpeed` + `serveMinLift` via the new `ShotSystem.serve(...)`. Swing-stick auto-contact is suppressed during serve state so the serve is deliberate.
- **P0-005**: `racketSwingRadiansPerPixel` 0.016 → 0.005, `swingPowerScale` 0.62 → 0.50, `firmContactSpeed` 176 → 150, `driveSpeedXY` 132 → 116, `smashSpeedXY` 170 → 150, `driveContactThreshold` 124 → 118, `driveArcGravityScale` 0.42 → 0.36, `dinkArcGravityScale` 0.75 → 0.92. Slower swings now stay near the soft clamp; fast swings reach the firm clamp; ball top-speed lowered overall.
- **P1-008**: Removed the unconditional soft boundary rebound from `BallPhysicsSystem.update`. In-play balls now fly past the court rectangle and produce `landedOutOfBounds = true` on ground contact, triggering the OOB fault.
- **P1-009**: `lobInitialZ` 86 → 130, `lobArcGravityScale` 0.54 → 0.40 (lob peak ~52 units), `smashMinBallHeight` 64 → 28, `opponentSmashMinBallHeight` 80 → 30, `lobAngleThreshold` 0.86 → 0.65, `opponentLobProbability` 0.18 → 0.32. Lobs go visibly higher; returning a lob is now within smash threshold.
- **P2-008**: `GameScreen` wraps the `GameWidget` and pause-button stack in `SafeArea` so the gameplay canvas no longer extends under the notch / notification bar.

## Automated verification (2026-05-10)
- `flutter analyze`: zero issues.
- `flutter test`: 49/49 (added: in-play OOB landing test, two `serve()` tests).
- `flutter build apk --debug`: pending in this session.

## Perspective implementation pass (2026-05-11)
- **P0-006**: Retuned the gray-box court projection to a taller 3/4 view with stronger near/far width scaling, stronger z displacement, explicit top/bottom framing reserves, and a compressed one-line debug overlay. Added projection tests for near/far width ratio, portrait-friendly aspect, and depth scaling.
- **P0-007**: Added gray-box depth cues: raised net with posts/mesh, projected player/opponent body shapes, smooth ball altitude scale, stronger altitude-sensitive ball shadow, depth-scaled racket visuals, and y-based component priority for more coherent net/entity ordering.
- Verification passed on 2026-05-11: `flutter analyze`, `flutter test` (52/52), `flutter build apk --debug`, `flutter install -d 58011FDCQ00992 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`.
- Pixel 10 Pro XL Quick Match screenshot spot-check confirmed the view is materially less top-down than `docs/art/phase-2/phase-2-screenshot.png`; the court is taller, the raised net reads as an obstacle, player/opponent bodies have vertical presence, and bottom controls no longer cover the court baseline.

## Serve control update (2026-05-11)
- Serve state now locks the player in place until launch. Movement-stick input is ignored while waiting to serve, but the swing stick remains active for aiming.
- SERVE changed from tap-to-launch fixed speed to press-and-hold charge: press starts charging, release launches along the current racket direction, and the serve button shows a charge ring plus percentage / HOLD label.
- `ShotSystem.serve(...)` now accepts normalized power and maps it between `serveMinOutputSpeed` / `serveMaxOutputSpeed` and `serveMinLift` / `serveMaxLift`.
- Verification passed on 2026-05-11: `flutter analyze`, `flutter test` (60/60), and `flutter build apk --debug`.

## Phase 3 fake ad framework (2026-05-11)
- Added fake-only ad stack: `AdService`, `FakeAdService`, Riverpod provider wiring, and initialized fake service in `main.dart`. No real AdMob dependency, production ad IDs, banners, IAP, or remove-ads logic were added.
- Added `AdPlacementSystem` with in-memory session counters and deterministic elapsed-time advancement. Interstitial eligibility requires a natural break, 3 completed matches this session, 3 matches since the last interstitial, and 4 minutes since the last interstitial.
- End-match screen now has optional `WATCH AD: 2X REWARD` fake rewarded action. It is one-shot per screen visit, user-initiated, and only changes a placeholder reward label.
- Fake interstitials are checked only when tapping Return to Menu from the end-match screen. Eligible interstitials show a dismissible fake dialog before deferred navigation to `/`; Rematch and active gameplay do not trigger interstitials.
- Added post-match debug text for ad eligibility: session matches, matches until eligible, time until eligible, and natural-break state.
- Verification passed on 2026-05-11: `flutter analyze`, `flutter test` (73/73), `flutter build apk --debug`, and `flutter install -d 58011FDCQ00992 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`.
- Android launch command returned `Status: ok` for `com.example.dink_rivals/.MainActivity`, but screenshot capture showed the physical device lock screen. Manual Phase 3 fake-ad QA remains required for P3-006.

## Manual QA still required (combined P0-002 / P1-007 / P2-007)
Re-run the previous QA checklists with attention to:
- Hold the movement joystick across a point loss — player keeps moving.
- Serve: ball sits on racket tip, swing stick aims, SERVE button launches in aim direction.
- Soft swing vs hard swing — visibly different outgoing speeds and arcs.
- Hit the ball into a side wall — FAULT: OUT fires instead of a rebound.
- Force a lob (sideways racket angle + soft swing); AI should also throw the occasional lob.
- After AI lob, drive it down — should classify as SMASH.
- Confirm top of game canvas no longer overlaps notch / notification shade.
- Untested in last pass — pause mid-rally freeze, resume without snapping, return-to-menu reset, hardware back → pause, settings persistence across kill+relaunch.

## Phase 5 implementation pass (2026-05-11)
- **P5-001**: Added Phase 5 asset folders, centralized `VisualPalette`, calmer pixel-style court rendering, palette-driven court/kitchen/net/debug overlay colors, and Phase 5 debug label.
- **P5-002**: Generated placeholder pixel sprite sheets for player/opponent idle, run, and swing states. `PlayerComponent` and `OpponentComponent` now render sprites by default, keep primitive fallback through `DebugFlags.useSprites`, preserve y-priority sorting, and switch animation from `PlayerState`.
- **P5-003**: Generated ball and player/opponent paddle sprites. `BallComponent` preserves the prior height/depth visual radius curve while rendering the sprite; `RacketComponent` renders rotated paddle sprites at racket tips. `ShadowComponent`, ball physics, and shot classification were not changed.
- **P5-004**: Applied Phase 5 theme to Material UI, main menu logo, roster portraits, end-match winner portrait, score plate, serving indicator, and per-shot feedback colors with a short pop animation.
- **P5-005**: Added `flame_audio`, `AudioService` / `FlameAudioService` / `FakeAudioService`, generated short placeholder WAV SFX, and wired hit, bounce, point, fault, and menu-click events to the existing `soundEnabled` flag.
- **P5-006**: Added `HapticsService` / `FlutterHapticsService` / `FakeHapticsService`. Player racket contact fires light haptics and player point wins fire medium haptics, gated by the existing `hapticsEnabled` flag.
- Verification passed on 2026-05-11: `flutter analyze`, `flutter test` (96/96), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992`.

## Manual Phase 5 QA still required (P5-007)
- Confirm new logo, themed buttons, roster portraits, player/opponent/ball/paddle sprites, court readability, kitchen readability, net readability, serving-side indicator, and distinct DINK/DRIVE/LOB/SMASH/FAULT feedback on a physical Android device.
- Toggle Sound off/on and confirm hit, bounce, point, fault, and menu-click SFX silence and return.
- Toggle Haptics off/on and confirm player hit light buzz and player point-win medium buzz silence and return.
- Play 3 full matches, confirm no frame drops, run 5+ minutes uptime, force-kill/relaunch to confirm Sound/Haptics persistence, and confirm notch/nav clearance.

## Phase 5A-5G visual expansion start (2026-05-11)
- **P5A-001..P5A-003**: Added Phase 5 baseline/gap docs, visual direction source of truth, render-layer map, SafeArea/occlusion rules, asset folder conventions, and pubspec asset declarations.
- **P5B-001**: Added original low-detail retro environment placeholder assets generated with ChatGPT image generation and locally cropped/despilled into `assets/images/environment/classic/` plus shared shadow support.
- **P5D-001**: Added data-driven character visual definitions for Rookie, Rally Queen, Veteran, and Showman; roster portrait lookup now uses config; tests cover unique visual entries and asset paths.
- **P5F-001 / P5F-004**: Added reusable arcade UI primitives/tokens and original low-detail retro court card placeholder assets without wiring court selection, unlocks, purchases, or navigation.
- Claude was retried for visual critique but was unavailable due usage limits. Codex subagent fallback critique reviewed the art direction and second-pass generated assets; the final imported assets use the simpler retro pass the user preferred, with no detected magenta-key pixels after cleanup.
- Verification passed on 2026-05-11: `flutter analyze`, `flutter test` (109/109), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992`.
- **P5B-002**: Added `ClassicEnvironmentComponent` and `EnvironmentLayout`; the Classic Court now has low-detail off-court ground, backdrop fence, trees, shrubs, bench, lamp, banner, bag, and prop shadows behind gameplay. Projected placement tests guard against HUD/control/court readability collisions.
- **P5C-001 / P5C-002**: Added projected court scuffs, reduced pixel texture density, subtle line wear, inset kitchen edge treatment, net cast shadow, post highlights, rail depth, and reduced mesh detail. Claude review drove adjustments away from kitchen-line clutter and overly busy net diagonals.
- **P5C-003**: Added a shared `ProjectedShadow` helper, centralized shadow offset/palette/toggle, and applied coherent directional shadows to the ball, player, opponent, Classic environment props, and paddle head. Claude review drove removal of the high-priority racket handle shadow so shadows do not paint over character feet.
- **P5D-002**: Added original low-detail ready, hit-confirm, point-win, and point-loss sprite sheets for player/opponent, plus event-driven pose timers that preserve swing/contact readability and do not touch hitboxes or gameplay tuning. Claude review drove the swing-first pose precedence and queued-hit cleanup.
- **P5D-003**: Refreshed the four roster portraits in the same hard-edge low-detail direction and added `docs/art/phase-5/phase-5d-character-check.png`. Claude review found no blockers; remaining notes are that Rally Queen reads more as yellow hair on pink than a distinct headband at portrait scale, and Veteran's mint accent is subtle against the gray kit.
- **P5E-001 / P5E-002**: Added low-detail VFX sprites and deterministic VFX layer; existing contact and bounce events now spawn brief hit/smash/bounce effects. Claude review drove smaller smash/bounce sizing and faster alpha falloff to reduce ball occlusion.
- **P5E-003**: Added capped high-ball trail effects and point-burst support tied to existing point-award timing. Claude review found no code blockers; Android VFX performance/readability smoke is still pending because no Android device was visible to Flutter.
- **P5F-002**: Restyled in-match HUD with separate player/opponent score panels, active-serve border, feedback backing panel, bordered pause button, and stronger movement/swing control rings. Claude review drove fixes for match-over chip overflow and serve-marker digit collision.
- **P5F-003**: Restyled the main menu, roster, settings, pause overlay, opponent-serve ready prompt, and end-match screen with the shared arcade panels/buttons while preserving Quick Match, fake ad surfaces, settings persistence, and existing route/test keys. Claude review drove fixes for text-fit, button width consistency, opponent-win layout, reward-ad label length, roster copy wrapping, and the raw opponent-serve READY button.
- **P5G-001**: Added repeatable Flutter golden coverage for menu, roster, settings, and end-match UI states, plus `docs/art/phase-5/phase-5g-comparison.md`. Gameplay screenshots for serve/rally/point/pause are blocker-documented because the widget golden harness renders the Flame canvas as black, web is not configured, and no Android device was visible.
- **P5G-003 prep**: Converted known non-device visual gaps into follow-up tickets P5H-001 through P5H-007: gameplay capture harness, optional web screenshot path, main-menu composition, Rally Queen portrait readability, Veteran accent readability, environment depth band, and character idle/ready micro-animation. Final closeout remains pending Android QA.
- **Completion audit**: Added `docs/art/phase-5/phase-5ag-completion-audit.md` mapping every Phase 5A-G ticket and prompt requirement to concrete evidence. Audit decision: do not mark the active goal complete until Android validation and final closeout are recorded.
- Latest verification passed on 2026-05-11 and was rerun after the completion audit: `flutter pub get`, `flutter analyze`, `flutter test` (127/127), and `flutter build apk --debug`. After the Pixel 10 Pro XL reconnected, `flutter install --debug -d 58011FDCQ00992 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk` succeeded; refreshed `dink_rivals-debug.apk` remains copied to the workspace root and is ignored.
- **Android QA still pending beyond install smoke**: `adb shell am start -W -n com.example.dink_rivals/.MainActivity` returned `Status: ok` with `WaitTime: 1741` on Pixel 10 Pro XL. P5B-003 remains in `review` pending environment screenshots/readability notes, P5E-003 remains in `review` pending VFX performance/readability smoke, and P5G-002 remains in `review` pending the full Android performance/readability checklist.
- **Phase 5 visual feedback pass**: Hid the debug overlay by default, strengthened net outline/highlight/shadow treatment, added a bright ball rim/highlight, increased the far-court opponent render scale for gameplay clarity, and enlarged the swing zone with a pressed pulse/halo. Claude reviewed the current code and found no blocker-level concerns. Verification passed with `flutter analyze`, `flutter test` (130/130), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`. The latest APK is installed and copied to `dink_rivals-debug.apk`; a fresh second-pass gameplay screenshot is still blocked because the device locked after install, so `docs/art/phase-5/phase-5-screenshot.png` contains the last valid post-fix on-device capture.
- **Phase 5 environment/model correction pass**: Reworked the Classic environment away from the wonky repeated grass tile into a continuous concept-style ground, wider paved apron, projected court drop shadow, subtle paving lines, and denser edge foliage; changed the court palette toward the blue concept art and slightly reduced court width scale so the environment has room to read. Pre-serve, hit-confirm, and point-result character poses now keep the same idle model silhouette instead of swapping into the mismatched placeholder sheets. Verification passed with `flutter analyze`, `flutter test` (131/131), `flutter build apk --debug`, and `flutter install --debug -d 58011FDCQ00992 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`; refreshed `dink_rivals-debug.apk`.
- **Phase 5.1 concept-fidelity implementation pass**: Implemented P51A-P51H corrections for the current concept gap. Added `docs/art/phase-5.1/phase-5.1-delta-inventory.md`, removed the high-priority racket-head shadow that read as black player artifacts, regenerated chunkier transparent player/opponent/paddle sprite sheets with consistent body baselines, aspect-preserved environment prop rendering, added a procedural dense tree/fence backdrop, added apron feather/contact shadow/court edge shade for grounding, tightened score-panel sizing, and separated smaller visual control radii from the preserved touch hit regions. Claude and a Codex subagent both reviewed the plan; both pointed to grounding, prop aspect preservation, and the high-priority racket shadow as the highest-value fixes. Verification passed with `flutter analyze`, `flutter test` (133/133), `flutter build apk --debug`, Android install/launch on Pixel 10 Pro XL (`58011FDCQ00992`), and Android screenshot capture for serve/rally/pause states. P51I remains in `review` because the full 5-minute Android smoke is incomplete: a long-running smoke was interrupted around 3 minutes and the Pixel disconnected from Flutter/ADB before a clean restart could finish. The refreshed APK is copied to `dink_rivals-debug.apk`.

## Phase 5.2 concept composition and identity pass (2026-05-11)
- Implemented P52A-001 through P52M-001 for non-human scope. Added `docs/art/phase-5.2/phase-5.2-delta-inventory.md`, `docs/art/phase-5.2/phase-5.2-art-direction.md`, `docs/art/phase-5.2/phase-5.2-generated-asset-contact-sheet.png`, and `docs/art/phase-5.2/phase-5.2-comparison.md`.
- Retuned the 3/4 projection and court layout for stronger near/far perspective while preserving deterministic projection tests and gameplay coordinate semantics.
- Added Phase 5.2 palette tokens, court apron/playing-surface/kitchen zoning, stronger line contrast, rebuilt net geometry, integrated scoreboard serving indicator, rally count, and last-shot readout.
- Generated new raster assets for player/opponent sprite sheets, roster portraits, signs, planters, and VFX. Claude reviewed the asset sheet, flagged Rally Queen label occlusion, and gave final no-blocker signoff after the portrait fix.
- Added rear sign/lamp/planter park depth, fixed-buffer ball trail rendering, refreshed contact/bounce VFX, top-center feedback banner, and serve-charge/control polish without changing touch hit regions.
- The original serve-state opponent animation bug is covered by `player_component_test.dart`: opponent velocity selects the `run` pose even while the point is not in progress.
- Verification passed: `flutter analyze`, `flutter test` (145/145), `flutter build apk --debug`, `flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk`, emulator launch, menu screenshot, and Quick Match serve-state screenshot. Physical-device human playtest and subjective concept signoff remain outside this automated closeout.
- Follow-up visual indicator pass: fixed generated character sheet frame slicing,
  movement-direction sprite reflection, player point-result visibility after
  point end, idle shot-chip highlighting, active `LOB`/`SMASH` chip labels, and
  full-diameter committed swing hitbox lanes. Verification passed with
  `flutter analyze`, `flutter test`, `flutter build apk --debug`, emulator
  install, and Pixel 10 Pro XL install. Latest Pixel screenshot recapture was
  discarded because the device remained on the lockscreen bouncer while the app
  was focused behind keyguard.

## Perspective overhaul (2026-05-11)
- Implemented PERSP-000 through PERSP-010 for non-human scope. The projection now maps gameplay coordinates to the painted court in `park_background_overhaul.png` using measured image-space court corners plus the painted net boundary, and `CourtLayoutSystem` uses the same cover-fit transform as the background renderer.
- The synthetic court and kitchen overlays are disabled so they no longer clash with the painted court. The net remains a thin projected foreground rail overlay at `Court.netY`, restoring visual occlusion for far-side ball/opponent movement while preserving near-side draw order.
- Player, opponent, ball, shadows, and swing lanes now derive visual scale and z lift from the painted-court projection. Gameplay constants, scoring, AI, shot classification, and physics semantics remain unchanged.
- Verification for this pass includes `flutter analyze`, `flutter test`, `flutter build apk --debug`, Pixel 10 Pro XL install for `docs/art/perspective-overhaul/perspective-after-screenshot.png`, and latest `emulator-5554` install/smoke for `docs/art/perspective-overhaul/perspective-gameplay-net-smoke-emulator.png` while Pixel was not visible. PERSP-010 remains in `review` for the human 5-minute rally and subjective concept signoff gate.

## Visual Overhaul v2 implementation (2026-05-12)
- Created the VO2 ticket track (`tickets/visual-overhaul-v2/vo2-000..vo2-008`) plus follow-up validation tickets VO3-001 and VO3-002 for physical Pixel/human signoff.
- Added VO2 decomp and prompt packets under `docs/art/visual-overhaul/`, including `vo2-shared-style-rules.md`.
- Split the current painted venue into `layer_sky_trees.png`, `layer_fence_signage.png`, `layer_court_base.png`, and `layer_net.png`; runtime now draws environment layers in order and `NetComponent` draws the dedicated net layer.
- Upgraded player/opponent runtime support to 48x72 frame sheets with 33x49.5 court-unit logical footprint, regenerated all 22 state sheets, refreshed roster portraits and the classic court card, and archived VO2 player/opponent contact sheets. The first crude procedural character pass was rejected during review and replaced by the prior generated athlete style normalized to the new VO2 frame footprint.
- Centralized ball radius constants, lightly retuned contact radii for the larger characters, enlarged paddle draw size, extracted the rally/last-shot readout into `RallyStripComponent`, tightened controls, removed the `AIM` label, and gated debug HUD behind `DebugFlags.showHud`.
- Updated shared arcade panel/button chrome to a 3px outer border plus 2px inner highlight and refreshed affected UI goldens.
- Initial closeout evidence under `docs/art/visual-overhaul/evidence/vo2-final-*` was rejected during art QA because some gameplay captures were invalid duplicates and the visual result did not satisfy the concept target.
- Recovery pass: kept the stronger generated-athlete sprite direction, expanded player/opponent run sheets to 8 frames, hardened sprite alpha, filled enclosed transparent holes, and verified all 22 runtime sheets have no partial-alpha pixels or enclosed transparent holes.
- Recovery pass: removed projected fence/sign props from `EnvironmentLayout.classicProps`; fence/signage now belongs to the background layer instead of the court plane.
- Recovery pass: removed the rejected chain-link-mounted `DINK RIVALS` and `PICKLEBALL LEGENDS` text boards from `layer_fence_signage.png`; this removes the bad signage but does not yet provide final replacement signage.
- Recovery pass: net rendering now crops the measured net strip and uses a lighter overlay so near-net ball/opponent visibility is improved.
- Recovery pass: main menu no longer uses the gameplay court background; shared panels/buttons, scoreboard, controls, and feedback banner colors were retuned toward the painted park palette.
- Verification passed after recovery: `flutter analyze`, `flutter test` (177/177), sprite alpha/hole validation, `flutter build apk --debug`, `flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk`, and fresh emulator menu/serve/rally captures under `docs/art/visual-overhaul/evidence/vo2-recovery-emulator/`.
- VO2 remains in `review`, not final closeout. Open gates: concept-matched replacement signage, shot-specific fresh captures, physical Pixel validation, and human concept-quality signoff.

## Current visual-overhaul reset (2026-05-13)
- Player/opponent sprites and gameplay animations are done for the current visual pass. Accepted character work uses the documented sprite generation workflow in `docs/art/visual-overhaul/sprite-generator-skill-workflow.md` with the run under `docs/art/visual-overhaul/skill-runs/character-animation-creator-2026-05-12/`.
- Ball rendering and VFX are mostly done for now; revisit them only if projection or future environment art creates a readability regression.
- Runtime environment graphics are intentionally reset to a flat gray background. `ClassicEnvironmentComponent` draws the gray backdrop, `CourtComponent` draws projected gameplay boundaries, and `NetComponent` draws a procedural graybox net.
- The painted court/environment/signage path from earlier VO2 notes is historical, not the current closeout target. Current source of truth: `docs/art/visual-overhaul/current-visual-overhaul-state.md`.
- Next sequence: finalize perspective/projection; finalize how gameplay boundaries read visually; then rebuild the environment graphics from scratch around the locked projection and boundary guide.

## Phase 6 tournament MVP implementation start (2026-05-17)
- Added a minimal Classic Cup loop: main menu entry, tournament route/screen,
  4-player single-elimination bracket, semifinal/final progression, and return
  from completed tournament matches back to the bracket screen.
- Added `TournamentState`, `TournamentSystem`, and a Riverpod tournament
  provider. The bracket uses Rookie as the semifinal rival and Showman as the
  final rival, with Veteran represented in the simulated opposite semifinal.
- Added simple tournament rival AI profile differences for speed, whiff rate,
  lob probability, and smash probability without changing quick-match defaults.
- Added persisted `classicCupWins` save data. Winning the final unlocks the
  Classic Cup trophy and survives reload through `SaveService`.
- Automated verification added for tournament progression, provider/trophy
  persistence, tournament screen behavior, save migration/defaults, and
  `GameScreen` tournament-match advancement. Physical Android tournament QA,
  richer results presentation, optional tournament retry ads, and broader
  unlock/court-selection surfaces remain follow-up work.

## Phase 7 progression slice (2026-05-17)
- Added persistent reward currency (`stars`), tutorial completion, and selected
  cosmetic court ID to `SaveData` / `SaveService`.
- Post-match rewarded fake ads now persist the bonus 100 stars instead of only
  changing local screen text. Completed matches grant the base 100 stars through
  the existing match-completion path.
- Added a first-game quick-start overlay that pauses the match until dismissed,
  then persists `tutorialSeen` so it does not keep interrupting returning
  players.
- Added `CourtSelectScreen` and `TrophyRoomScreen`, both reachable from the
  main menu. Court selection currently offers the current Classic Park visual
  environment plus the gray projection-training court as cosmetic options.
- The Classic Cup trophy remains the first achievement unlock; trophy room
  displays the trophy state, stars, court availability, and tutorial state.
- Real AdMob, optional banners, character-specific unlock flows, tournament
  retry ads, release signing, and physical Pixel QA remain open Phase 7 work.
- `flutter build apk --release` succeeds and produced
  `build/app/outputs/flutter-apk/app-release.apk` (62.7 MB) on 2026-05-17.
  The Gradle release config still uses the debug signing config, so production
  signing remains a release-candidate follow-up.
- Added persistent character unlock IDs with Rookie and Rally Queen unlocked by
  default. Defeating a tournament rival now unlocks that rival ID, and the
  roster screen displays locked/unlocked state without changing gameplay
  character rendering or stats. The current tournament path can unlock Showman;
  direct Rally Queen/Veteran challenge flows remain future Phase 7 work.
- Added fake rewarded tournament retry: after an eliminated Classic Cup match,
  the tournament screen offers a user-initiated `RETRY AD` button. A successful
  fake rewarded ad restores the failed bracket match by removing only the loss
  record; no real AdMob SDK or in-gameplay ad placement was added.
