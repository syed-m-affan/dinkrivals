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
- Pixel 10 Pro XL Quick Match screenshot spot-check confirmed the view is materially less top-down than `docs/art/phase-2-screenshot.png`; the court is taller, the raised net reads as an obstacle, player/opponent bodies have vertical presence, and bottom controls no longer cover the court baseline.

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
