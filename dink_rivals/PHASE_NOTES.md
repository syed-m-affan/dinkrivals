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
