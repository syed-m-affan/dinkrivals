# Dink Rivals — Agent Build Spec

## 1. Product Summary

**Working title:** Dink Rivals
**Genre:** Retro arcade pickleball game
**Target:** Mobile-first, Android first, iOS later
**Stack:** Flutter + Flame + Dart
**Business model:** Free / ad-supported
**Core camera:** 3/4 top-down court view, not side-view
**MVP mode:** 1v1 singles arcade pickleball vs AI

Dink Rivals should feel like a simple, fast, charming arcade sports game. It should borrow the spirit of Retro Bowl: readable visuals, short sessions, simple controls, quick matches, and enough structure to make people want one more game.

The game should **not** become a generic free-to-play grind. Ads are allowed, but the game should avoid annoying freemium mechanics.

---

## 2. Non-Negotiable Product Rules

1. **No energy timers.** The player must never be prevented from playing because they ran out of stamina, tickets, hearts, or energy.
2. **No premium gems.** Do not add gem currency, gacha, loot boxes, or purchasable power.
3. **No pay-to-win.** Any future purchases must be remove-ads or cosmetics only.
4. **No ads during rallies.** Ads may only appear at natural breaks.
5. **No forced ad before first gameplay.** First-time user should get into a match quickly.
6. **3/4 court perspective only.** The kitchen/non-volley zone must be visible and meaningful.
7. **Gameplay feel comes first.** Do not build menus, monetization, or progression before Phase 0 proves that rallies feel good.
8. **Every phase must run on a local Android device.** No phase is complete until it is playable on a real Android phone.

---

## 3. Core Game Pitch

A fast retro arcade pickleball game where players move around a 3/4 court, dink near the kitchen, drive deep shots, lob over aggressive opponents, smash high balls, and compete through quick matches and simple tournaments.

The player should understand the game in 30 seconds:

* Move with left thumb.
* Aim with right thumb.
* The right stick moves a small red aim indicator through the old paddle arc.
* The aim indicator is visual-only and has no hitbox.
* Dinks use the player body hitbox plus current aim direction.
* Drive, lob, and smash use committed swing hitboxes.
* Win rallies.
* Win matches.
* Unlock rivals/courts through achievements.

Current control direction is locked around aim-assisted contact, not a visible gameplay paddle. Do not restore player/opponent paddle rendering or add separate dink, drive, lob, or smash buttons unless a future ticket explicitly reverses this decision after playtest evidence.

---

## 4. Tech Stack

### 4.1 Required Stack

| Area                  | Choice                                        | Reason                                                     |
| --------------------- | --------------------------------------------- | ---------------------------------------------------------- |
| App framework         | Flutter                                       | One codebase for Android/iOS, great app UI, fast iteration |
| Game framework        | Flame                                         | Lightweight 2D game framework inside Flutter               |
| Language              | Dart                                          | Native Flutter/Flame language                              |
| Rendering             | Flame components                              | Court, players, ball, HUD, effects                         |
| Navigation            | GoRouter                                      | Simple screen routing                                      |
| State management      | Riverpod or ChangeNotifier                    | App/menu/game state separation                             |
| Local storage         | SharedPreferences first                       | Save unlocks, settings, ad counters, stats                 |
| Audio                 | Flame Audio or audioplayers                   | SFX/music                                                  |
| Ads                   | google_mobile_ads                             | AdMob rewarded/interstitial/banner support                 |
| IAP later             | in_app_purchase or RevenueCat                 | Optional Remove Ads purchase post-MVP                      |
| Analytics later       | Firebase Analytics, PostHog, or GameAnalytics | Retention and event tracking after core game works         |
| Crash reporting later | Sentry or Firebase Crashlytics                | Stability after MVP                                        |
| Testing               | flutter_test + Dart unit tests                | Scoring/rules/unlocks/ad frequency tests                   |

### 4.2 Suggested Dependencies

Agents should install current stable versions using `flutter pub add`, not by copying fake version numbers.

```bash
flutter pub add flame
flutter pub add flame_audio
flutter pub add go_router
flutter pub add flutter_riverpod
flutter pub add shared_preferences
flutter pub add google_mobile_ads
flutter pub add audioplayers
flutter pub add in_app_purchase
```

Do **not** add real AdMob, IAP, Firebase, Sentry, or analytics in Phase 0.

---

## 5. Local Android Testing Requirement

Every phase must produce a build that can run on a physical Android device.

### 5.1 Required Local Setup

Developer should have:

* Flutter SDK
* Android Studio
* Android SDK / platform tools
* Physical Android phone
* Developer Options enabled
* USB Debugging enabled
* USB cable or wireless debugging
* Optional local Android emulator for agent smoke tests

### 5.2 Standard Commands

```bash
flutter doctor
flutter pub get
flutter devices
flutter analyze
flutter test
flutter run -d <ANDROID_DEVICE_ID>
```

If the local QA emulator exists, start it from any directory:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd dink_rivals_qa
```

Then use:

```bash
flutter devices
flutter run -d emulator-5554
```

### 5.3 Build APK Locally

Debug APK:

```bash
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
flutter install -d emulator-5554 --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

Release APK for local testing:

```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

On Windows, if `adb` is not on `PATH`, use:

```powershell
$adb = "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1
& $adb -s emulator-5554 shell screencap -p /sdcard/dink_rivals_qa.png
& $adb -s emulator-5554 pull /sdcard/dink_rivals_qa.png ..\dink_rivals_qa.png
```

The emulator is acceptable for fast launch, screenshot, and basic gameplay smoke checks. It does not replace required physical-device QA for phase closeout.

### 5.4 Per-Phase Definition of Done

A phase is not done until:

* `flutter analyze` passes or documented warnings are accepted.
* `flutter test` passes.
* App installs on local Android phone.
* App launches without crash.
* Phase label/debug version is visible.
* App runs for at least 5 minutes of normal testing.
* Manual QA checklist for that phase is completed.
* Known issues are written to `PHASE_NOTES.md`.

---

## 6. Repository Structure

```text
dink_rivals/
  pubspec.yaml
  pubspec.lock
  analysis_options.yaml
  README.md
  PHASE_NOTES.md

  assets/
    images/
      sprites/
      courts/
      ui/
      logos/
    audio/
      sfx/
      music/
    fonts/

  lib/
    main.dart

    app/
      app.dart
      router.dart
      app_theme.dart
      app_config.dart

    screens/
      main_menu_screen.dart
      game_screen.dart
      tournament_screen.dart
      roster_screen.dart
      trophy_room_screen.dart
      settings_screen.dart
      remove_ads_screen.dart

    game/
      dink_rivals_game.dart
      game_bootstrap.dart

      config/
        game_constants.dart
        court_constants.dart
        tuning_constants.dart
        debug_flags.dart

      components/
        court_component.dart
        net_component.dart
        kitchen_zone_component.dart
        player_component.dart
        opponent_component.dart
        ball_component.dart
        shadow_component.dart
        aim_arc_component.dart
        hud_component.dart
        score_component.dart
        rally_feedback_component.dart
        debug_overlay_component.dart

      systems/
        input_system.dart
        movement_system.dart
        shot_system.dart
        ball_physics_system.dart
        opponent_ai_system.dart
        scoring_system.dart
        match_rules_system.dart
        power_meter_system.dart
        tournament_system.dart
        unlock_system.dart
        ad_placement_system.dart

      models/
        shot_type.dart
        player_side.dart
        player_stats.dart
        character_def.dart
        court_def.dart
        ball_state.dart
        player_state.dart
        match_state.dart
        tournament_state.dart
        unlock_condition.dart
        save_data.dart

      data/
        characters.dart
        courts.dart
        tournaments.dart
        unlock_conditions.dart

    services/
      save_service.dart
      ad_service.dart
      purchase_service.dart
      audio_service.dart
      haptics_service.dart
      analytics_service.dart

  test/
    game/
      scoring_system_test.dart
      match_rules_system_test.dart
      ball_physics_system_test.dart
      unlock_system_test.dart
      tournament_system_test.dart
      ad_placement_system_test.dart
```

---

## 7. Core Gameplay Model

### 7.1 Camera / Court Perspective

Use a **3/4 top-down court**.

Player side is bottom. Opponent side is top. The camera should show:

* Full court
* Net
* Kitchen/non-volley zone
* Sidelines
* Baselines
* Player and opponent positions
* Ball and ball shadow

Do not use pure side-view.

### 7.2 Court Coordinates

Use logical court coordinates separate from screen pixels.

```dart
class CourtBounds {
  final double left;
  final double right;
  final double top;
  final double bottom;
  final double netY;
  final double playerKitchenTopY;
  final double playerKitchenBottomY;
  final double opponentKitchenTopY;
  final double opponentKitchenBottomY;
}
```

Create a projection helper:

```dart
Vector2 courtToScreen(Vector2 courtPosition) {
  // Converts logical court coordinates to 3/4 screen coordinates.
}
```

### 7.3 Ball Model

Use pseudo-3D ball physics.

```dart
class BallState {
  double x;
  double y;
  double z;
  double vx;
  double vy;
  double vz;
  PlayerSide lastHitBy;
  bool hasBouncedThisSide;
  bool isVolleyable;
}
```

Rendering rule:

* Ball shadow draws at projected `(x, y)`.
* Ball draws above shadow based on `z`.
* Ball can scale slightly larger when high.
* Bounce occurs when `z <= 0`.

### 7.4 Player Model

```dart
class PlayerState {
  Vector2 position;
  Vector2 velocity;
  PlayerSide side;
  CharacterDef character;
  double racketAngle;
  double racketAngularVelocity;
  bool isInKitchen;
  bool canHit;
  bool isSwinging;
}
```

### 7.5 Match Model

```dart
class MatchState {
  int playerScore;
  int opponentScore;
  PlayerSide servingSide;
  bool pointInProgress;
  bool matchOver;
  int rallyCount;
  int playerDinkContactsThisMatch;
  int playerSmashContactsThisMatch;
  int longestRally;
}
```

---

## 8. Shot System

### 8.1 Shot Types

```dart
enum ShotType {
  dink,
  drive,
  lob,
  smash,
  block,
  serve,
}
```

### 8.2 Shot Table

| Shot  | Contact condition                         |      Arc |     Speed |   Risk | Purpose            |
| ----- | ----------------------------------------- | -------: | --------: | -----: | ------------------ |
| Dink  | Player body contact + aim indicator       | Low/soft |      Slow |    Low | Drop into kitchen  |
| Drive | Fast racket contact through the ball      |   Medium |      Fast | Medium | Push opponent deep |
| Lob   | Upward/high-angle racket contact          |     High |      Slow | Medium | Beat net pressure  |
| Smash | High ball + fast downward contact         | Downward | Very fast |   High | Finish point       |
| Block | Low-swing-speed defensive contact         |      Low |      Slow |    Low | Emergency reset    |
| Serve | First racket contact of point             |   Medium |    Medium |    Low | Begin rally        |

### 8.3 Aim and Contact Window

Use generous early contact windows. Mobile users should not feel robbed. The right stick moves a visual aim indicator through the old paddle arc; it does not collide with the ball. Dinks occur when the ball intersects the player body contact radius at a hittable height. Drive, lob, smash, block, and legacy racket-contact paths continue to use the committed swing or racket capsule hitboxes.

Initial tuning values:

```dart
hitWindowRadius = 42.0
perfectHitWindowRadius = 22.0
maxAimAssistDegrees = 12.0
racketReach = 42.0
racketHitRadius = 13.0
dinkBodyContactRadius = 34.0
```

### 8.4 Targeting

Start with aim-assisted contact rather than explicit target buttons:

* The right-stick aim indicator changes the outgoing dink direction.
* Swipe intent and swing speed determine drive, lob, smash, and block behavior.
* Incoming ball speed and angle affect the return.
* Shot names are classifications of the contact result, not separate shot buttons.

Do not add separate shot buttons. If future playtesting rejects swing-contact controls, create a new ticket that explicitly changes this control contract before changing implementation.

---

## 9. Controls

### 9.1 Phase 0 Controls

* Left virtual stick: move player.
* Right virtual stick: move the red aim indicator through the front 180-degree arc.
* The aim indicator has no hitbox.
* Dink contact uses the player body hitbox.
* Drive, lob, and smash use committed swing hitboxes.
* Debug reset button: reset point.
* No separate dink or drive buttons.

### 9.2 MVP Controls

Default:

* Left thumb stick = movement.
* Right thumb stick = aim indicator.
* Dink uses body contact and current aim direction.
* Swipe intent and swing speed determine drive, lob, block, or smash.
* Smash happens when the ball is high and the player makes fast downward/forward contact.
* UI must preserve screen space around the swing stick so touch input does not conflict with the reset button, score display, or feedback text.

### 9.3 Control Feel Acceptance

Controls must feel good within the first 30 seconds.

Requirements:

* Movement responsive but not twitchy.
* Dink body contact is forgiving without feeling like a whole-court magnet.
* The aim indicator is readable as direction feedback, not as a collision object.
* Drive, lob, and smash contact remains distinct from passive dink contact.
* First/reset dink contact uses the body hitbox; harder shots keep their committed swing hitboxes.
* Player understands why they won/lost point.
* Misses should feel fair, not random.

---

## 10. Rules

### 10.1 MVP Rules

Use singles pickleball rules from `docs/pickleball_rules.md`, with arcade input and presentation:

* Points are scored only by the serving side.
* A receiver rally win causes side out / loss of serve, not a point.
* Quick Match plays to 11 and must be won by 2.
* Only one serve attempt is allowed.
* Serve must land in the opposite diagonal service court.
* The two-bounce rule applies after the serve.
* Ball must land in bounds.
* One bounce allowed per side.
* Volley allowed outside kitchen.
* Volley inside kitchen is a fault.
* Dink favors kitchen target.
* Drive favors deep court target.
* Lob uses high arc.
* Smash requires ball height threshold.

### 10.2 Allowed Simplifications

Do not implement these in MVP unless everything else is complete:

* Doubles.
* Detailed serve rotation.
* Online multiplayer.
* Spin.
* Wind.
* Fatigue.

---

## 11. Ad Monetization Spec

### 11.1 Ad Philosophy

The game is free, but ads should be respectful. The player should feel like ads support the game, not that the game is designed to annoy them.

### 11.2 Rewarded Ads

Rewarded ads are preferred.

Allowed placements:

* Post-match: double earned stars/coins.
* Tournament loss: optional one-time retry.
* Cosmetic preview: use a locked paddle/court for one match.

Rules:

* Always optional.
* Must clearly show reward.
* Never required to progress.
* Never shown automatically.

### 11.3 Interstitial Ads

Allowed only at natural breaks.

Allowed placements:

* After every 3 completed matches.
* After exiting a tournament.
* After a match only if enough time has passed.

Forbidden placements:

* During rally.
* During point reset.
* Immediately after launch.
* Before first gameplay.
* After every match.
* After every point.

Initial frequency policy:

```text
No interstitial before user has completed 3 matches.
No interstitial more often than once every 3 completed matches.
No interstitial more often than once every 4 real minutes.
No interstitial during active gameplay.
```

### 11.4 Banner Ads

Avoid banners in gameplay.

Allowed:

* Main menu bottom area.
* Roster screen.
* Trophy room.
* Settings screen.

Forbidden:

* Active gameplay.
* Over controls.
* Anywhere likely to cause accidental taps.

### 11.5 Remove Ads

Post-MVP optional feature.

* One-time purchase.
* Removes interstitial and banner ads.
* Rewarded ads can remain optional.
* Must include restore purchases.

### 11.6 Ad Service Interface

```dart
abstract class AdService {
  Future<void> initialize();
  Future<bool> isRewardedAdReady();
  Future<bool> showRewardedAd({required String placement});
  Future<bool> isInterstitialReady();
  Future<bool> maybeShowInterstitial({required String placement});
  bool get adsRemoved;
}
```

Before real ads, implement:

```dart
class FakeAdService implements AdService {
  // Simulates rewarded/interstitial ads with debug modals.
}
```

---

## 12. Visual Direction

### 12.1 Overall Style

Retro arcade sports with chunky readable shapes. Inspired by Retro Bowl’s clarity and simplicity, but not a clone.

Requirements:

* Consistent pixel density.
* Big readable UI.
* Clear court lines.
* Clear kitchen zone.
* Players readable at small size.
* Ball always visible.
* Ball shadow always visible.

### 12.2 Characters

MVP roster: 4 characters.

| Character   | Role                     | Strength       | Weakness        |
| ----------- | ------------------------ | -------------- | --------------- |
| Rookie      | Default balanced player  | Easy control   | No specialty    |
| Rally Queen | Dink/control specialist  | Soft game      | Lower power     |
| Veteran     | Defensive placement      | Consistency    | Slower speed    |
| Showman     | Aggressive flashy player | Power/specials | Less consistent |

### 12.3 Courts

MVP courts:

1. Classic Court.
2. Park Court.

Post-MVP:

* Sunset Court.
* Rooftop Court.
* Rec Center Court.
* Desert Court.

### 12.4 Concept Art Target

The visual north star is `docs/art/concepts/concept-sheet.png` and `docs/art/concepts/concept-screenshot.png`. These files are reference targets, not immutable requirements, until the visual direction is explicitly locked in Phase 5A or a later design-lock ticket.

The game view should eventually read like a polished mobile arcade sports scene, not just a textured court:

* 3/4 court remains the primary readable object.
* Full court, kitchen, net, ball, players, ball shadow, score, pause, and controls remain visible on a phone.
* Classic Court is surrounded by park detail: fence, trees, benches, lamps, signs, banners, pavement/grass transitions, and soft environmental shadows.
* Court surface has pixel texture, line wear, and subtle color variation without hiding bounds or kitchen zones.
* Players have clear silhouettes, readable paddles, idle/run/swing poses, and character-specific personality.
* HUD uses chunky arcade panels similar to the concept scoreboard and feedback banners.
* Feedback callouts, point banners, ball trail, hit sparks, and bounce effects add juice without obscuring gameplay.
* Menus, roster cards, court cards, unlock panels, and settings use the same visual language as the in-match HUD.

Visual upgrades must never reduce gameplay clarity. If a prop, shadow, texture, particle, or UI treatment makes the ball, court lines, kitchen, net, or controls harder to read, revise or remove it.

The visual expansion runs in three escalating passes. Phase 5A-5G establishes the initial concept-art expansion. Phase 5.1 is the correction pass that cleans up artifacts and grounds the court without revising perspective or HUD structure. Phase 5.2 is the comprehensive composition and identity pass that may revise perspective strength, court zoning, scoreboard, feedback callouts, and ball/contact juice under screenshot-evidence gates. Concept gaps that survive Phase 5.2 belong to Phase 5.3 follow-up tickets, not silent scope creep.

Until the design is finalized:

* Treat newer concept art in `docs/art/` as a candidate update, not an automatic replacement for the current target.
* Keep a short concept-art changelog in `PHASE_NOTES.md` or a dedicated `docs/art/phase-5/visual-direction.md` file.
* Prefer configurable palettes, prop placement data, reusable UI widgets, and replaceable assets over one-off hardcoded art decisions.
* When concept art changes, first update the visual gap checklist and affected phase/ticket notes, then update assets or UI.
* Do not rewrite gameplay systems just to match a visual mockup unless a gameplay ticket explicitly approves that change.
* Once a design-lock ticket is complete, later concept changes require new follow-up tickets rather than silent scope creep.

---

## 13. Development Phases

Each phase must be testable on a local Android device.

---

# Phase 0 — Blank Court Gameplay Demo

## Goal

Prove the core rally loop before art, menus, ads, progression, or monetization.

## Build Contents

* Blank 3/4 pickleball court.
* Visible net.
* Visible kitchen zones.
* Player as circle/rectangle.
* Opponent as circle/rectangle.
* Ball as circle.
* Ball shadow.
* Basic movement.
* Right-stick aim indicator.
* Automatic dink contact from the player body hitbox.
* Committed swing contact for drive/lob/smash labels.
* Simple bot that moves toward the ball.
* Basic rally reset.
* Debug overlay: FPS, phase label, ball x/y/z, rally count.

## Not Included

* No real art.
* No logo.
* No main menu.
* No ads.
* No tournament.
* No character stats.
* No unlocks.
* No IAP.

## Implementation Tasks

1. Create Flutter project.
2. Add Flame.
3. Create `DinkRivalsGame`.
4. Create 3/4 court projection helper.
5. Create court component.
6. Create kitchen zone component.
7. Create player component.
8. Create opponent component.
9. Create ball component.
10. Create shadow component.
11. Implement left-stick movement.
12. Implement right-stick aim indicator through a front 180-degree arc.
13. Implement automatic dink body contact and committed swing hits.
14. Implement basic ball pseudo-3D physics.
15. Implement simple bot return logic.
16. Add debug overlay.
17. Add reset point button.

## Acceptance Criteria

* Runs on local Android phone.
* Player can move on bottom side of court.
* Player aims and returns the ball without separate dink or drive buttons.
* Ball can cross net.
* Opponent can return some shots.
* Rally can last at least 10 seconds.
* Dink and committed swing contacts feel different.
* First/reset dink hit uses the player body hitbox, not the aim marker.
* Ball height is visually readable.
* Kitchen zones are visible.
* No crash after 5 minutes.

## Android QA Checklist

* Install debug APK.
* Launch app.
* Confirm Phase 0 label appears.
* Move player.
* Move the aim indicator with right stick.
* Confirm no dink/drive shot buttons appear.
* Confirm dink body contact and committed swing contacts are understandable.
* Confirm ball shadow appears.
* Confirm ball crosses net.
* Confirm opponent moves.
* Play for 5 minutes.
* Record control/framerate issues in `PHASE_NOTES.md`.

---

# Phase 1 — Core Rally Feel and Rules

## Goal

Make the gray-box rally feel like arcade pickleball.

## Build Contents

* Improved movement.
* Improved bot AI.
* In/out detection.
* Bounce rules.
* Kitchen volley fault.
* Scorekeeping.
* First-to-7 match flow.
* Serve/start point flow.
* Aim/contact classification for dink, drive, lob, smash.
* Feedback text: DINK, DRIVE, LOB, SMASH, FAULT.
* Centralized tuning constants.

## Implementation Tasks

1. Add `MatchState`.
2. Add `ScoringSystem`.
3. Add `MatchRulesSystem`.
4. Add `ShotType` enum.
5. Add aim/contact shot classification.
6. Add contact window logic.
7. Add kitchen volley rule.
8. Add serve sequence.
9. Add match-over state.
10. Add unit tests for scoring/rules.

## Acceptance Criteria

* Full match can be played to 11, win by 2.
* Score updates correctly.
* Only the serving side can score.
* Receiver rally win switches serve without adding a point.
* Illegal serves cause loss of serve / side out.
* Two-bounce-rule violations are faults.
* Out-of-bounds faults resolve according to server-only scoring.
* Double-bounce faults resolve according to server-only scoring.
* Kitchen volley fault works.
* Dink, drive, lob, smash are produced by the aim/contact system and feedback.
* No explicit shot buttons are added for dink, drive, lob, or smash.
* Opponent can sustain beginner rallies.
* Runs on local Android phone.
* No crash after 5 minutes.

## Android QA Checklist

* Play 3 full matches.
* Force out-of-bounds.
* Force double bounce.
* Try kitchen volley.
* Produce soft, firm, high, and smash contacts.
* Confirm match ends at 7.
* Record tuning notes.

---

# Phase 2 — App Shell and Menus

## Goal

Wrap gameplay in a basic app shell.

## Build Contents

* Main menu.
* Quick Match button.
* Pause menu.
* End match screen.
* Settings screen.
* Basic local save.
* Sound/haptics toggles.
* Placeholder logo.
* Placeholder roster screen.

## Implementation Tasks

1. Add GoRouter.
2. Create main menu screen.
3. Create game screen wrapper.
4. Create settings screen.
5. Create roster placeholder.
6. Create save service.
7. Save sound/haptics settings.
8. Add end-match summary.
9. Add pause/resume.
10. Add return-to-menu flow.

## Acceptance Criteria

* App launches to main menu.
* Quick Match starts gameplay.
* Match can pause/resume.
* Match can end and show summary.
* Settings persist after restart.
* Runs on local Android phone.

## Android QA Checklist

* Launch app.
* Start Quick Match.
* Pause/resume.
* Finish match.
* Return to menu.
* Change setting.
* Kill/reopen app.
* Confirm setting persisted.

---

# Phase 3 — Fake Ad Framework

## Goal

Design respectful ad placements before real AdMob integration.

## Build Contents

* `AdService` abstraction.
* `FakeAdService`.
* Ad frequency rules.
* Rewarded ad simulation on post-match screen.
* Interstitial simulation only after natural breaks.
* Debug overlay for ad eligibility.

## Implementation Tasks

1. Create `AdService` interface.
2. Create `FakeAdService`.
3. Create `AdPlacementSystem`.
4. Track completed matches this session.
5. Track time since last interstitial.
6. Add post-match “watch ad to double stars” fake button.
7. Add fake interstitial modal.
8. Add unit tests for ad frequency.

## Acceptance Criteria

* Fake rewarded ad only appears after user taps button.
* Fake rewarded ad grants reward.
* Fake interstitial appears only after allowed match break.
* No fake ad appears during gameplay.
* No interstitial during first 3 matches.
* Frequency cap works.
* Runs on local Android phone.

## Android QA Checklist

* Fresh install.
* Play first 3 matches.
* Confirm no interstitial.
* Tap rewarded ad button.
* Confirm reward doubles.
* Play enough matches for fake interstitial.
* Confirm it only appears after match.

---

# Phase 4 — Real AdMob Test Ads

## Goal

Integrate real ad SDK using test ads only.

## Build Contents

* `google_mobile_ads` integration.
* AdMob initialization.
* Test rewarded ad.
* Test interstitial ad.
* Optional test banner on menu only.
* Fallback behavior when ads fail.

## Implementation Tasks

1. Add `google_mobile_ads`.
2. Configure Android manifest as required.
3. Implement `AdMobAdService`.
4. Use official test ad unit IDs only.
5. Load rewarded ad in background.
6. Load interstitial in background.
7. Gracefully handle no fill/offline.
8. Add debug toggle fake ads vs test ads.

## Acceptance Criteria

* Test rewarded ad shows on Android phone.
* Test interstitial shows only when eligible.
* App works offline without blocking gameplay.
* No production ad IDs committed.
* No banner during gameplay.

## Android QA Checklist

* Install debug APK.
* Launch with internet.
* Trigger rewarded test ad.
* Trigger interstitial test ad.
* Disable internet.
* Relaunch.
* Confirm gameplay still works.

---

# Phase 5 — Visual Identity Pass

## Goal

Replace gray-box visuals with early production-style retro art. This phase establishes the asset pipeline, palette, sprites, themed UI, SFX, and haptics; it is not expected to reach the full concept-art richness by itself.

## Build Contents

* Pixel-style court art.
* Player sprites.
* Opponent sprites.
* Ball/paddle sprites.
* Character portraits.
* UI theme.
* Improved scoreboard.
* DINK/SMASH/FAULT feedback styling.
* Basic SFX.

## Implementation Tasks

1. Add asset folders.
2. Add court art.
3. Add sprite components.
4. Add basic sprite animations.
5. Add consistent palette.
6. Add scoreboard style.
7. Add SFX: hit, bounce, point, fault, menu click.
8. Add haptics for hit/point.

## Acceptance Criteria

* Game clearly reads as retro arcade sports.
* Kitchen zone remains visible.
* Ball remains visible.
* Characters match visual style.
* Score readable on phone.
* Sound can be toggled off.
* Runs on local Android phone.

## Android QA Checklist

* Play 3 matches.
* Confirm visual readability.
* Confirm UI not blocked by notch/nav bar.
* Toggle sound off.
* Confirm SFX stop.
* Watch for frame drops.

---

# Post-Phase-5 Visual Expansion Group

## Goal

Bring the game from the Phase 5 art-pass baseline toward the concept art in `docs/art/concepts/concept-sheet.png` and `docs/art/concepts/concept-screenshot.png`.

These phases are intentionally visual. They may be scheduled before Phase 6 if visual quality is the priority, or alongside later gameplay phases if file ownership is clean. They must not change scoring, physics, AI, ad placement, or the locked movement + swing-stick control contract.

The concept art may continue changing while this group is in progress. Each phase should build against the latest approved visual-direction note, and should leave assets/layouts replaceable enough that new concept art can be incorporated without resetting the entire visual pass.

## Starting Baseline After Phase 5

Phase 5 is expected to leave the project with:

* A centralized `VisualPalette`.
* A simple textured Classic Court asset, currently represented by `assets/images/court/court_classic.png`.
* Basic player, opponent, ball, and paddle sprites under `assets/images/sprites/`.
* Basic logo and roster portraits under `assets/images/ui/`.
* Basic SFX under `assets/audio/sfx/`.
* The existing 3/4 projection, court bounds, controls, rules, and match flow intact.

The gap to the concept art is mostly environment richness, character animation depth, in-match VFX, final HUD/menu presentation, and visual QA across real devices.

## Visual Expansion Non-Goals

* No shot buttons.
* No changes to scoring, match rules, ball physics, opponent AI, or ad frequency.
* No real AdMob, IAP, online multiplayer, energy systems, gems, gacha, or pay-to-win.
* No licensed or untracked third-party art.
* No `CourtProjection` or `CourtLayoutSystem` changes unless a visual QA ticket explicitly proves framing is blocking the concept target.
* No environment prop may cover active court lines, ball shadow, controls, score, pause, or rally feedback.

---

# Phase 5A — Concept Frame and Art Direction Lock

## Goal

Convert the current concept art into concrete in-engine visual rules before adding more assets, while leaving room for controlled concept updates until the design is finalized.

## Build Contents

* Screenshot comparison between current Phase 5 gameplay and `docs/art/concepts/concept-screenshot.png`.
* Target draw-order map for court, environment, props, players, ball, shadows, VFX, HUD, and controls.
* Pixel-density rules for world assets, sprites, UI panels, and icons.
* Safe-area layout notes for tall Android phones.
* Asset naming and folder conventions for environment and VFX assets.
* A visual-direction source-of-truth note that records approved concept references, open questions, and what is not locked yet.
* A design-lock checklist that says which parts are final, provisional, or intentionally deferred.

## Implementation Tasks

1. Capture a current Phase 5 Android screenshot and save it under `docs/art/`.
2. Add a short visual gap note under `docs/art/` or `PHASE_NOTES.md`.
3. Define target asset folders:
   * `assets/images/environment/classic/`
   * `assets/images/environment/shared/`
   * `assets/images/vfx/`
   * `assets/images/ui/hud/`
4. Document draw order and occlusion rules for the match scene.
5. Document the minimum readable sizes for ball, players, paddles, text, and court lines on phone.
6. Create or update `docs/art/phase-5/visual-direction.md` with:
   * Current approved concept references.
   * Revision date.
   * Locked decisions.
   * Provisional decisions.
   * Known gaps from current in-game visuals.
   * Rules for accepting future concept-art changes.

## Acceptance Criteria

* Future visual tickets can point to a concrete gap checklist.
* Target art direction is specific enough that multiple agents can produce compatible assets.
* Concept-art changes have a documented intake path until design lock.
* No gameplay behavior changes.
* Runs on local Android phone if any runtime layout code changes are made.

---

# Phase 5B — Courtside Environment and Depth Dressing

## Goal

Add the park setting around Classic Court so the match resembles the concept screenshot while preserving gameplay readability.

## Build Contents

* Off-court ground surface surrounding the playable court.
* Back fence or wall behind the opponent side.
* Trees, shrub clusters, benches, lamp posts, signs, banners, bags, and small courtside props.
* Near/far prop scaling that reinforces the existing 3/4 depth.
* Soft environmental shadows and edge shading.
* A render layer that keeps active gameplay objects above decorative background where needed.

## Implementation Tasks

1. Add environment asset folders and placeholder pixel assets.
2. Create an environment/background component for Classic Court.
3. Add prop placement data in config/data instead of hardcoding scattered screen pixels.
4. Render environment behind court lines and gameplay objects.
5. Add front-edge or side-edge depth dressing only where it does not cover controls or court bounds.
6. Add tests or debug assertions for environment layout bounds if practical.

## Acceptance Criteria

* Classic Court clearly reads as a park court, not a floating court on black.
* Full court, kitchen, net, and ball remain more readable than the background.
* Props do not overlap joystick, swing stick, serve button, score, pause, or feedback text.
* Frame rate remains acceptable on Android.

## Android QA Checklist

* Capture screenshots during serve, rally, and point feedback.
* Confirm player and opponent are never hidden by props.
* Confirm ball shadow remains visible over all court regions.
* Confirm the environment does not distract from in/out calls.

---

# Phase 5C — Court Material, Net, Lighting, and Shadows

## Goal

Polish the core match surface and depth cues so the court itself approaches the concept art quality.

## Build Contents

* More detailed court texture with subtle pixel noise, scuffs, and line wear.
* Clearer kitchen zone treatment that matches the art style.
* Net posts, net rail, mesh, and net shadow closer to the concept screenshot.
* Directional player, ball, paddle, and prop shadows.
* Optional time-of-day tint for Classic Court if it improves depth without reducing readability.

## Implementation Tasks

1. Replace the early court texture with a richer Classic Court texture.
2. Rework net drawing/assets to include posts, rail, mesh, and cast shadow.
3. Add shared shadow helpers or components where existing shadow code is too narrow.
4. Tune line thickness and contrast for phone readability.
5. Verify kitchen visibility after adding texture and shadows.

## Acceptance Criteria

* Court texture feels intentional and pixel-art, not flat bands.
* Net reads as a physical object with depth.
* Shadows help show height and position without muddying court lines.
* Kitchen zone remains obvious in active play.

---

# Phase 5D — Character Personality and Animation Polish

## Goal

Upgrade the basic Phase 5 sprites into characters that match the concept roster and remain readable at gameplay scale.

## Build Contents

* Player and opponent idle, run, ready, swing, hit-confirm, point-win, and point-loss poses.
* At least 4-frame run cycles where practical.
* Swing anticipation and follow-through frames.
* Character-specific colors and silhouettes for Rookie, Rally Queen, Veteran, and Showman.
* Portraits that match gameplay sprites.
* Paddle color/shape variants that do not imply pay-to-win.

## Implementation Tasks

1. Expand sprite sheets without changing movement or hit detection.
2. Drive animation state from existing `PlayerState` and match events.
3. Add character visual definitions in data/config rather than branching inside components.
4. Update roster portraits to match the in-game character designs.
5. Add screenshot or component tests where existing test patterns support sprite loading.

## Acceptance Criteria

* Characters are recognizable in both roster and gameplay views.
* Swing timing feels better visually without changing committed swing contact logic.
* Player and opponent remain distinct at small sizes.
* No animation hides the aim indicator or ball contact moment.

---

# Phase 5E — Ball Trail, Contact VFX, and Rally Juice

## Goal

Add arcade feedback similar to the concept screenshot without cluttering active play.

## Build Contents

* Ball arc/trail for lobs and high returns.
* Small hit spark or paddle flash on clean contact.
* Bounce dust or ring on court contact.
* Smash impact effect.
* Point-win burst/banner support.
* Optional screen shake only for point-ending smashes, disabled or very subtle by default.

## Implementation Tasks

1. Add VFX asset folder and lightweight effect components.
2. Trigger effects from existing shot classifications and ball bounce events.
3. Keep VFX lifetimes short and deterministic.
4. Respect sound/haptics settings where VFX are tied to feedback events.
5. Add debug toggles only if needed for performance testing.

## Acceptance Criteria

* Dink, drive, lob, smash, fault, bounce, and point events are easier to read.
* VFX never cover the ball for more than a brief moment.
* VFX do not change physics, scoring, or AI.
* No sustained frame drops on Android.

---

# Phase 5F — Concept HUD, Menus, and Court Cards

## Goal

Bring UI presentation closer to the concept sheet while keeping the first screen useful and fast.

## Build Contents

* Chunky blue/red scoreboard panels with serving indicator.
* Pause button treatment matching the concept screenshot.
* Top-center rally feedback and point banners.
* Refined joystick, swing-stick, and serve-button skins.
* Main menu background treatment and stronger logo presentation.
* Roster cards matching the concept layout.
* Court cards for Classic and Park Court, with locked-state art placeholders for later courts.
* Settings, pause, and end-match screens restyled to match the same UI system.

## Implementation Tasks

1. Move HUD colors, borders, shadows, and typography into shared theme/config where practical.
2. Replace generic buttons/cards with reusable arcade UI widgets.
3. Add court card assets for Classic and Park Court.
4. Confirm all text fits on small phones and large phones.
5. Preserve quick path to gameplay: new player can still start first match in under 3 taps.

## Acceptance Criteria

* In-match HUD resembles the concept art while staying notch/nav safe.
* Main menu, roster, settings, pause, and end-match screens feel like the same game.
* Button labels, scores, roster names, and settings copy do not clip.
* No menu, ad, or unlock work exceeds the current phase's feature scope.

---

# Phase 5G — Visual QA and Performance Gate

## Goal

Verify that the expanded visuals actually move the game toward the concept art and still run cleanly on Android.

## Build Contents

* Android screenshot set for menu, roster, settings, serve, rally, point banner, pause, and end match.
* Side-by-side comparison against `docs/art/concepts/concept-screenshot.png` and the latest Phase 5 screenshot.
* Performance check on a physical Android phone.
* Visual bug ticket list for any remaining concept gaps.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Android QA Checklist

* Fresh install on Android phone.
* Launch and start Quick Match in under 3 taps.
* Play at least 3 full matches.
* Keep the app running for at least 10 minutes.
* Capture screenshots at serve, rally, point, pause, and post-match.
* Confirm ball, ball shadow, court lines, kitchen, net, score, pause, and controls stay readable.
* Confirm no UI overlaps notch, gesture nav, joystick, swing stick, or serve button.
* Confirm SFX and haptics still respect settings.
* Record remaining visual gaps in `PHASE_NOTES.md` and/or follow-up tickets.

## Acceptance Criteria

* `flutter analyze` passes.
* `flutter test` passes.
* Debug APK installs and launches on Android.
* Expanded visuals are materially closer to the concept art.
* No gameplay, scoring, controls, ads, audio toggle, or haptics regressions.
* Known visual gaps are tracked instead of left implicit.

---

# Phase 5.1 — Concept Fidelity Correction Pass

## Goal

Bring the current Phase 5.1 gameplay screenshot materially closer to `docs/art/concepts/concept-screenshot.png` after the first Phase 5A-G visual expansion exposed specific quality gaps.

Phase 5.1 is a correction pass, not a new feature phase. It targets the visible mismatch between the current screenshot and the concept: black artifacts around player models, stretched-looking trees/fence assets, a basic environment, grass/background wonkiness, a floating-court read, and player model inconsistency before and after serve.

## Build Contents

* Current-vs-concept delta inventory for `docs/art/phase-5/phase-5-screenshot.png` or the latest `docs/art/phase-5.1/phase-5.1-screenshot.png`.
* Cleaner player/opponent silhouettes with no accidental black matte artifacts.
* Unified player/opponent proportions across pre-serve, rally, hit-confirm, and point-result states.
* De-stretched courtside fence, trees, shrubs, and props.
* Ground/apron/court-edge treatment that makes the court feel embedded in the park surface.
* Richer layered park depth: far trees, fence/wall, benches, lamps, planters, banners/signage, bags, and muted courtside details.
* Court surface, kitchen, net, and shadow polish closer to the concept screenshot.
* HUD/control proportion review only where the latest gameplay screenshot shows oversized or crowded elements.
* Android screenshot comparison and residual gap backlog.

## Visual Quality Targets

* The environment should read like one coherent park court, not repeated square tiles or isolated prop stickers.
* Fence and trees must keep believable proportions; avoid stretching small raster assets to fill large screen regions.
* The court must have visual contact with the ground through apron, edge wear, contact shadow, and/or pavement transition.
* Decorative environment detail must be lower contrast than court lines, ball, ball shadow, players, net, score, pause, and controls.
* Player and opponent sprites must use consistent outline weight, alpha handling, palette, proportions, and foot baseline across all gameplay states.
* The concept screenshot is the visual target, not a pixel-perfect contract. Gameplay clarity and the locked 3/4 perspective win any conflict.

## Implementation Tasks

1. Capture or preserve a current Phase 5.1 gameplay screenshot and produce a numbered delta inventory against `docs/art/concepts/concept-screenshot.png`.
2. Diagnose and remove black artifacts around player/opponent sprites and shadows.
3. Normalize character pose sheets so serve/rally/special states keep the same model identity.
4. Replace or revise stretched environment rendering with properly proportioned assets and data-driven placement.
5. Build a grounded court surround: apron, soft court shadow, grass/pavement transitions, and quiet control-area treatment.
6. Add layered park richness behind and beside the court without hiding gameplay.
7. Polish court surface color/texture, net contrast, kitchen visibility, and shadow cohesion.
8. Review HUD/control proportions against the concept and the latest phone screenshot.
9. Capture final Android screenshots, compare before/after/concept, and convert remaining gaps into follow-up tickets.

## Suggested Subphases

* **Phase 5.1A — Screenshot Baseline and Visual Triage**
  * Lock current screenshots, enumerate concept deltas, map overlapping P5H tickets, and update render-layer/acceptance-shot notes.
* **Phase 5.1B — Player Sprite Artifact Cleanup**
  * Remove black matte/fringe artifacts around player and opponent models without changing hit detection.
* **Phase 5.1C — Character Scale, Pose, and Direction Readability**
  * Make serve, rally, and special poses read as the same character model with consistent silhouette and readable paddle direction.
* **Phase 5.1D — Environment De-Stretch and Asset Placement**
  * Fix stretched-looking fence/trees and replace repeated tile bands with proportionate courtside elements.
* **Phase 5.1E — Grounding, Grass, and Court Integration**
  * Fix the floating-court read with believable ground transitions, apron/contact shadows, and quiet control-area ground.
* **Phase 5.1F — Park Depth and Background Richness**
  * Add layered concept-style park detail: far trees, fence, banners, benches, lamps, bags, planters, and side depth.
* **Phase 5.1G — Concept Court Surface and Net Polish**
  * Refine blue court material, kitchen treatment, court lines, net rail/mesh/posts, and cast shadows.
* **Phase 5.1H — HUD and Control Proportion Pass**
  * Tune score panels, pause, feedback, joystick, swing stick, and serve button only where they block concept fidelity or gameplay readability.
* **Phase 5.1I — Visual QA, Android Capture, and Closeout**
  * Capture the final screenshot set, write side-by-side comparison notes, verify Android performance/readability, and queue any Phase 5.2 gaps.

## Scope Exclusions

* No scoring, match rules, ball physics, AI, serve mechanics, contact hitboxes, shot classification, ad behavior, monetization, unlocks, tournament work, real AdMob, IAP, energy systems, gems, gacha, or pay-to-win.
* No new shot buttons.
* No animated crowd, weather, day/night system, seasonal courts, or dynamic billboard system.
* No menu/roster/settings redesign unless Phase 5.1A identifies a regression caused by gameplay-HUD changes.
* Avoid `CourtProjection` changes. `CourtLayoutSystem` framing changes require Phase 5.1A evidence that framing is blocking concept fidelity and must preserve phone readability.
* No untracked third-party art or licensed assets.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Android QA Checklist

* Fresh install on Android phone.
* Capture serve, post-serve/rally, point feedback, pause, and post-match screenshots.
* Compare concept / before / after for each Phase 5.1A delta.
* Confirm no black halos or accidental matte artifacts around player/opponent sprites.
* Confirm player model identity does not visibly change between waiting-to-serve, serve release, rally, hit-confirm, and point-result moments.
* Confirm fence, trees, shrubs, and props are not visibly stretched.
* Confirm court appears grounded in the environment.
* Confirm ball, ball shadow, court lines, kitchen, net, score, pause, joystick, swing stick, and serve button remain readable.
* Play at least 5 minutes and watch for frame drops or input lag.
* Record remaining gaps in `PHASE_NOTES.md`, `docs/art/phase-5.1/phase-5.1-comparison.md`, or follow-up tickets.

## Acceptance Criteria

* `docs/art/phase-5.1/phase-5.1-delta-inventory.md` identifies the target gaps.
* Final comparison shows each high-priority Phase 5.1 visual defect resolved, improved, or explicitly deferred.
* `flutter analyze` and `flutter test` pass.
* Debug APK builds, installs, and launches on Android.
* Environment reads closer to the concept screenshot without reducing gameplay clarity.
* Player/opponent sprites no longer show unintended black artifacts or model identity jumps.
* Remaining concept gaps are tracked instead of left implicit.

---

# Phase 5.2 — Concept Composition and Identity Pass

## Goal

Close the remaining structural gap between `docs/art/phase-5.1/phase-5.1-final-screenshot.png` and `docs/art/concepts/concept-screenshot.png`. Phase 5.1 cleaned up sprite artifacts, environment proportions, and court grounding, but the current screenshot still reads as a near-top-down arcade with a flat blue court, generic score boxes, sparse character detail, no rally feedback callout, no ball trail, and no backdrop signage. Phase 5.2 is the comprehensive composition and identity pass that brings perspective strength, court zoning, character readability, backdrop signage, rally feedback, and ball juice to concept parity while keeping the locked control contract, the 3/4 perspective non-negotiable, and the §2 product rules intact.

Phase 5.2 differs from Phase 5.1 in scope. Phase 5.1 was a cleanup pass that intentionally avoided `CourtProjection` and HUD restructuring. Phase 5.2 is a composition pass that is permitted to revise perspective strength, court zoning, scoreboard layout, and feedback systems — but must produce screenshot evidence before, during, and after each subphase, and must not change scoring, physics, AI, ad placement, or the control contract.

## Reference Inputs

* Concept screenshot: `docs/art/concepts/concept-screenshot.png`.
* Concept sheet: `docs/art/concepts/concept-sheet.png`.
* Phase 5.1 final captures: `docs/art/phase-5.1/phase-5.1-final-screenshot.png`, `docs/art/phase-5.1/phase-5.1-final-rally.png`, `docs/art/phase-5.1/phase-5.1-final-serve.png`, `docs/art/phase-5.1/phase-5.1-final-pause.png`.
* Phase 5.1 closeout notes: `docs/art/phase-5.1/phase-5.1-comparison.md`, `docs/art/phase-5.1/phase-5.1-delta-inventory.md`.
* Visual direction note: `docs/art/phase-5/visual-direction.md`.

## Phase Gate and Prior Ticket Handling

Phase 5.2 should start from `P51I-001`. If `P51I-001` is still in `review`, `P52A-001` must explicitly record which Phase 5.1 QA evidence is accepted as enough to begin 5.2 and which 5-minute Android smoke risk remains open.

Phase 5.2 absorbs or supersedes the older non-blocking `P5H-*` visual follow-ups where they overlap:

* `P5H-003` main-menu composition is handled by `P52M-001` comparison targets and any Phase 5.3 backlog.
* `P5H-004` and `P5H-005` portrait readability are handled by `P52F-001`.
* `P5H-006` far-background band is handled by `P52K-001`.
* `P5H-007` idle/ready micro-animation may be deferred to Phase 5.3 unless `P52F-001` can include it without risking sprite cohesion.

`P5E-003`, `P5G-002`, and `P5G-003` remain historical review gates. Phase 5.2 may absorb their unfinished Android visual smoke only if `P52A-001` records that decision and `P52M-001` includes the final Android performance/readability closeout.

## Concept Gap Summary

Phase 5.2 inherits the following concrete gaps from Phase 5.1 closeout:

1. **Perspective is too flat.** The current rally screenshot reads close to top-down; the concept reads as 3/4 with the player baseline visibly wider than the opponent baseline.
2. **Court surface has no zoning.** Current court is a single light blue rectangle; concept has a dark navy outer apron frame, a brighter blue playing surface, and a slightly muted kitchen tint.
3. **Net is a flat horizontal band with a stray indicator coin.** Concept net has angled rail, vertical mesh strands, posts at each end, and a coherent cast shadow.
4. **No backdrop signage.** Concept shows a "DINK RIVALS" banner and a "Pickleball Legends"-style sign on the rear fence; current build shows none.
5. **Characters lack identity at gameplay scale.** Concept characters have visible heads, baseball caps, outfits, and held paddles; current sprites read as low-detail chunky blobs and paddles are barely visible.
6. **Scoreboard does not match concept.** Current uses generic "04 00" boxes; concept uses "YOU" / "RIVAL" labelled panels with a serving-side indicator, plus a top-left "RALLY: N" and "LAST SHOT: …" readout.
7. **Rally feedback is wrong.** Current shows a floating mid-court rally number ("1"); concept shows a top-center "DINK! NICE SHOT" classification banner.
8. **No ball trail or contact juice.** Concept shows a green arcing ball trail; current draws no trail and contact effects are minimal.
9. **No power meter.** Concept sheet shows a lightning-style meter near the swing stick.
10. **Park depth is thin.** Concept shows a lamp post, planters, benches, and a deeper rear tree band; current has trees but limited courtside structure.
11. **HUD controls have minor proportion issues.** Concept move-ring shows D-pad chevrons; current move ring is plain and slightly oversized.

## Build Contents

* Visual token extension: add shared `VisualPalette` entries for court apron, kitchen tint, signage, feedback banner, last-shot label, power meter, and any new Phase 5.2 HUD accents before implementation tickets add new colors.
* Render-layer and AI-art rules: update render ordering, safe-area constraints, asset prompt packets, alpha-fringe checks, palette ramps, and contact-sheet requirements so AI-assisted assets stay cohesive.
* Reinforced 3/4 perspective: the player baseline reads visibly wider than the opponent baseline, with the court tilted toward camera in line with the concept screenshot, gated by readability checks on a real Android phone.
* Court surface zoning: dark navy outer apron framing the court rectangle, light blue main playing surface, and a slightly muted kitchen tint that distinguishes the non-volley zone without dimming court lines.
* Net upgrade: angled net rail aligned with the court perspective, vertical mesh strands, posts at each sideline end, and a coherent cast shadow that does not float across the kitchen. The stray rally-state indicator coin currently rendered over the net is relocated into the scoreboard serving indicator.
* Backdrop signage band: rear-fence component that hosts a "DINK RIVALS" banner and an original secondary park sign such as "PARK COURTS" or "PICKLEBALL LEAGUE", sized so it does not crowd the opponent silhouette or scoreboard.
* Character identity upgrade: visible head, cap, torso outfit, shorts/legs, shoes, and a hand/paddle cue readable from gameplay distance, with Rookie/Rally Queen/Veteran/Showman color identity matching the roster cards. The actual gameplay indicator is the visual-only aim marker in `RacketComponent`; do not bake a colliding gameplay paddle into character sprites.
* Scoreboard restyle: "YOU" / "RIVAL" vertical label panels with score numerals and a serving-side indicator dot, plus a top-left rally counter and last-shot readout ("RALLY: N" / "LAST SHOT: DINK").
* Rally feedback callout: top-center banner that displays shot classification ("DINK!", "DRIVE!", "LOB!", "SMASH!", "FAULT!", "NICE SHOT") for a short interval after the event, replacing the floating mid-court rally number.
* Ball trail and contact juice: short arcing trail behind the ball during flight, backed by a fixed-size sample buffer with no per-frame allocations, with refreshed hit spark on racket contact and bounce dust on ground contact, reusing or extending Phase 5E VFX components.
* Power meter element: lightning-style meter near the swing stick driven by read-only existing swing-speed or serve-charge signals. The meter is a visual readout of existing input, not a purchasable advantage, not an energy gate, and not a shot-buff toggle.
* Park depth pass two: lamp post on at least one sideline, a small back-row planter or bench cluster, and a slightly darker tree band behind the back fence to reinforce depth beyond what 5.1F delivered.
* HUD control polish: D-pad chevrons inside the move ring, refined "SWING" label above the swing knob, pause panel proportion check, and safe-area validation on tall and notched Android devices.
* Visual QA artifacts: Phase 5.2 baseline, intermediate, and final screenshot sets; a side-by-side comparison note; and a residual gap backlog.

## Visual Quality Targets

* The final Phase 5.2 rally screenshot must read at a glance as the same composition as `concept-screenshot.png`: a tilted court framed by park detail, with clear color zoning, visible backdrop signage, recognizable characters, a feedback callout, and a ball trail.
* Kitchen, sidelines, baselines, and center line must remain brighter than the surrounding court fill and brighter than every environmental element.
* Ball, ball shadow, and aim indicator must remain the highest-contrast small objects on screen.
* No new element may obstruct the joystick, swing stick, serve button, score panels, pause button, or feedback banner hit regions.
* Scoreboard, pause, and top-center feedback banner must share the safe-area band without overlap. The feedback banner sits below the scoreboard/pause row on notched and tall Android devices.
* The 3/4 perspective must remain a true 3/4 read: the kitchen on each side must remain visible and meaningful, and the camera must not slip toward pure side-view or pure top-down.
* No element may imply pay-to-win, energy, gem, or gacha mechanics. The power meter is a visual readout of existing swing speed only.
* Frame rate and input responsiveness must match or beat Phase 5.1 on the same Android device.
* Main-menu and end-match screenshots should inherit the new concept-HUD identity without becoming Phase 6 feature work: the logo should read in the upper composition, primary actions should remain immediately usable, and no new tournament/unlock navigation should be introduced.

## AI Visual Production Rules

Phase 5.2 is explicitly allowed to use AI-assisted visual generation, but tickets must constrain it so agents produce cohesive shippable assets instead of unrelated one-off images:

* `P52A-002` owns the reusable prompt packets, palette ramps, target sprite dimensions, outline weight, lighting direction, and export rules for all Phase 5.2 art.
* Generated sprites, portraits, signs, and props must be original, hard-edge, transparent where needed, and checked for black matte halos, premultiplied-alpha fringe, accidental background pixels, and inconsistent baseline alignment.
* Every asset-producing ticket must include a small contact sheet or screenshot proof under `docs/art/` before closeout.
* Prefer replacing whole cohesive sheets or manifests over mixing one-off frames from different styles.
* Avoid trademarked sign text, copied logos, licensed art, or image-search-derived production assets.
* If an AI asset reads worse than the current in-engine shape at gameplay scale, keep the current asset and record the failed attempt in the ticket notes rather than landing noisy art.

## Implementation Tasks

1. Capture a Phase 5.2 baseline screenshot set against the live Phase 5.1 build and produce `docs/art/phase-5.2/phase-5.2-delta-inventory.md` keyed to specific concept-screenshot regions.
2. Extend `VisualPalette`, update render-layer/safe-area rules, and publish AI art prompt/export rules before implementation tickets create new visual assets.
3. Strengthen 3/4 projection inside `CourtProjection` and `CourtLayoutSystem`, gated by before/after screenshot evidence, deterministic projection tests, and coordinate-stability checks. Preserve `Court` logical bounds and keep all gameplay systems coordinate-stable.
4. Introduce a court-zoning render pass that draws a dark apron frame, light playing surface, kitchen tint, and refreshed line treatment without changing logical court bounds.
5. Rebuild the net component to draw posts, an angled top rail, vertical mesh strands, and a single cohesive shadow under the rail; relocate the stray serve/indicator coin to the scoreboard.
6. Add a back-wall/signage component anchored behind the opponent baseline, with placement data in `config/` or `data/` rather than hardcoded pixels, and content for the "DINK RIVALS" banner plus an original secondary park sign.
7. Expand character sprite sheets so each roster member ships visible head/cap/outfit/hand cue at gameplay scale; update visual config and roster portraits where needed while keeping the visual-only aim indicator in `RacketComponent`.
8. Restyle the scoreboard into "YOU" / "RIVAL" panels with a serving indicator, and add a rally counter and last-shot label fed by existing match/shot state without modifying scoring or rules.
9. Move rally feedback into a top-center banner component that displays shot classification and fault/point callouts from existing events, and remove the floating mid-court rally number.
10. Add or extend a ball-trail component that samples ball positions into a fixed-size buffer for a short window, and refresh hit-spark and bounce-dust VFX hookups from Phase 5E without obscuring the ball.
11. Add a power-meter HUD component that visualizes existing swing velocity or serve charge via read-only getters; do not introduce new gameplay buffs, costs, cooldowns, or unlock gates.
12. Layer additional park depth (lamp post, planter, back tree band) using existing environment manifests; keep contrast lower than the court fill.
13. Polish controls: D-pad chevrons inside the move ring, refined "SWING" label, pause panel proportion check, and notch/gesture-area validation on tall Android devices.
14. Capture Phase 5.2 final Android screenshots (serve, rally, point feedback, pause, end-match, main menu) and produce `docs/art/phase-5.2/phase-5.2-comparison.md` side-by-side notes.
15. Convert remaining concept gaps into Phase 5.3 follow-up tickets if any defects fall outside the 5.2 scope.

## Suggested Subphases

* **Phase 5.2A — Composition Baseline and Concept Mapping.** Capture current rally/serve/pause/feedback/end-match screenshots, produce `phase-5.2-delta-inventory.md` keyed to specific concept regions, and confirm Phase 5.1 closeout state.
* **Phase 5.2A2 — Visual Tokens, Layering, and AI Art Rules.** Extend `VisualPalette`, update render-layer/safe-area rules, define prompt packets and contact-sheet expectations, and record prior-ticket supersession.
* **Phase 5.2B — 3/4 Perspective Reinforcement.** Tighten `CourtProjection` and `CourtLayoutSystem` so the court visibly tilts toward camera, gated by before/after screenshot evidence, deterministic projection tests, and gameplay-clarity acceptance checks.
* **Phase 5.2C — Court Surface Zoning.** Add the navy outer apron frame, light playing surface, kitchen tint, and updated line contrast inside the existing logical court bounds.
* **Phase 5.2D — Net Rebuild and Serving Indicator Relocation.** Rebuild the net component to concept fidelity and move the serving indicator into the scoreboard flow.
* **Phase 5.2D2 — Backdrop Signage Band.** Add a rear fence signage band hosting the game logo and an original secondary park sign.
* **Phase 5.2E — Character Identity Upgrade.** Expand sprite sheets so each roster member ships visible head/cap/outfit/paddle detail and matching roster portraits.
* **Phase 5.2F — Scoreboard, Rally Counter, and Last-Shot Readout.** Restyle the top scoreboard into YOU/RIVAL panels with a serving indicator, and add the rally and last-shot readouts.
* **Phase 5.2G — Top-Center Feedback Banner.** Replace the floating mid-court rally number with a top-center shot classification or fault callout driven by existing shot and rules events.
* **Phase 5.2H — Ball Trail and Contact Juice.** Add a ball trail component and rewire hit-spark and bounce-dust effects across the rally, point-win, and smash flows.
* **Phase 5.2I — Power Meter and Control Polish.** Add a swing-speed-driven visual meter near the swing stick and polish move-ring chevrons and the SWING label.
* **Phase 5.2I2 — HUD Safe-Area Polish.** Check scoreboard, pause, feedback banner, power meter, and controls together on tall/notched layouts.
* **Phase 5.2J — Park Depth Pass Two.** Add a lamp post, a planter or bench cluster, and a darker tree band behind the back fence using existing environment manifests.
* **Phase 5.2K — Visual QA, Android Capture, and Closeout.** Capture the final Phase 5.2 screenshot set, write the side-by-side comparison, complete the Android readability and performance smoke, and queue any Phase 5.3 gaps.

## Scope Exclusions

* No scoring, match rules, ball physics, AI, serve mechanics, committed swing hitboxes, shot classification, ad behavior, monetization, unlocks, tournament work, real AdMob, IAP, energy systems, gems, gacha, or pay-to-win.
* The power meter is a visual readout only. It must not gate, charge, cost, or boost shots in a way that changes scoring or physics outcomes.
* No new shot buttons; the locked left-stick movement + right-stick aim indicator + automatic contact contract remains.
* No animated crowd, weather, day/night system, seasonal courts, or dynamic billboards.
* No menu/roster/settings redesign beyond what is needed to reflect the new HUD theme. New courts, characters, or unlocks remain out of scope.
* No untracked third-party art, licensed assets, trademarked sign text, copied logos, or production assets derived from image search. New backdrop signage must use original or already-tracked art.
* Do not bake a gameplay paddle hitbox into player/opponent sprites. Character sheets may include a hand/paddle cue for identity, but the active directional visualization is the non-colliding aim indicator in `RacketComponent`.
* `CourtProjection` and `CourtLayoutSystem` changes are allowed in Phase 5.2B only when accompanied by before/after screenshot evidence and a readability check on a real Android phone.

## Verification Commands

Run from `dink_rivals/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter install -d <ANDROID_DEVICE_ID> --use-application-binary=build/app/outputs/flutter-apk/app-debug.apk
```

## Android QA Checklist

* Fresh install on a physical Android phone.
* Capture serve, rally, point-feedback, pause, end-match, and main-menu screenshots.
* Compare each Phase 5.2A delta concept / Phase 5.1 final / Phase 5.2 final.
* Confirm the court visibly tilts toward camera and the kitchen on both sides remains readable.
* Confirm court zoning (apron / playing surface / kitchen) reads without dimming court lines.
* Confirm net rail, posts, mesh, and cast shadow look like the concept net rather than a flat band.
* Confirm backdrop signage is present and does not crowd opponent or scoreboard.
* Confirm characters show head, cap, outfit, and paddle detail at gameplay distance.
* Confirm scoreboard panels show YOU/RIVAL labels and a serving indicator.
* Confirm the rally counter and last-shot readout are present and update correctly.
* Confirm the top-center feedback banner fires on dink/drive/lob/smash/fault/point and clears within a short interval.
* Confirm the ball trail draws during flight and clears on bounce or contact without obscuring the ball.
* Confirm the power meter responds to swing-speed input and does not affect physics or scoring.
* Confirm move-ring chevrons, the SWING label, and the pause panel preserve hit regions and safe areas.
* Play at least 5 minutes and verify frame rate parity with Phase 5.1.
* Record remaining gaps in `PHASE_NOTES.md`, `docs/art/phase-5.2/phase-5.2-comparison.md`, or Phase 5.3 follow-up tickets.

## Acceptance Criteria

* `docs/art/phase-5.2/phase-5.2-delta-inventory.md` identifies the target gaps relative to `phase-5.1-final-screenshot.png` and `concept-screenshot.png`.
* `docs/art/phase-5.2/phase-5.2-comparison.md` shows each Phase 5.2A high-priority delta resolved, improved, or explicitly deferred to Phase 5.3.
* `flutter analyze` and `flutter test` pass.
* Debug APK builds, installs, and launches on Android.
* The final rally screenshot reads at a glance as the concept composition: tilted court, zoned surface, dressed net, backdrop signage, recognizable characters, scoreboard restyle, feedback banner, and ball trail.
* No scoring, physics, AI, ad, audio, haptics, or control regressions.
* No element implies pay-to-win, energy, gems, gacha, or any mechanic forbidden by §2.
* Remaining concept gaps are tracked as Phase 5.3 tickets instead of left implicit.

---

# Phase 6 — Tournament MVP

## Goal

Add a simple meta-loop so Quick Match is not the whole game.

## Build Contents

* 4-player tournament bracket.
* Semifinal and final.
* Three AI rivals.
* Trophy unlock after tournament win.
* Tournament screen.
* Tournament results screen.
* Local save for trophies/unlocks.

## Implementation Tasks

1. Create `TournamentState`.
2. Create `TournamentSystem`.
3. Create tournament screen.
4. Define 4 MVP characters.
5. Implement simple opponent stat differences.
6. Implement bracket progression.
7. Save tournament wins.
8. Unlock trophy after win.
9. Add tests for tournament transitions.

## Acceptance Criteria

* User can start tournament.
* User can play semifinal.
* User can play final.
* Tournament win unlocks trophy.
* Trophy persists after restart.
* Rivals feel slightly different.
* Ads respect tournament flow.
* Runs on local Android phone.

## Android QA Checklist

* Start tournament.
* Win semifinal.
* Confirm bracket advances.
* Win final.
* Confirm trophy unlock.
* Restart app.
* Confirm trophy persists.
* Confirm ads do not interrupt match.

---

# Phase 7 — MVP Release Candidate

## Goal

Ship a small but complete free ad-supported game.

## MVP Contents

* Main menu.
* Quick Match.
* 4-player Tournament.
* 4 characters.
* 2 courts.
* Achievement-based unlocks.
* Local save.
* Trophy room.
* Settings.
* Rewarded ads.
* Respectful interstitial ads.
* Optional banner ads outside gameplay.
* SFX/music.
* Basic tutorial overlay.
* Android release build.

## MVP Unlock Examples

* Beat Rally Queen to unlock her.
* Beat Veteran to unlock him.
* Win Classic Cup to unlock Park Court.
* Score 5 dink-contact classifications in one match to unlock paddle skin.
* Win a tournament to unlock trophy.

## MVP Ad Placements

* Rewarded ad on post-match screen: double earned stars.
* Rewarded ad after failed tournament match: optional retry.
* Interstitial after every 3 completed matches, with time cap.
* Optional banner only on menu/settings/roster/trophy screens.

## Acceptance Criteria

* New player can start first match in under 3 taps.
* New player understands controls within 30 seconds.
* No forced ad before first gameplay.
* No ad during active gameplay.
* Player can complete tournament.
* Unlocks persist.
* Settings persist.
* Offline gameplay works.
* Android release APK builds.
* App does not crash after 15 minutes of testing.

## Current Implementation Note (2026-05-17)

The non-human Phase 7 progression slice now includes persistent stars,
tutorial dismissal, cosmetic court selection, character unlock IDs, selected
player character ID, Dink Streak Paddle achievement state, selected Dink
Streak Accent cosmetic state, a Trophy Room route, and a Courts route. The existing fake
rewarded post-match ad persists bonus stars, the first game visit shows a
dismissible quick-start overlay, defeated tournament rivals unlock in the
roster, unlocked characters can be selected from the roster, locked Veteran and
Showman roster cards can start direct challenge matches, Rally Queen can unlock
either through her direct challenge or the Classic Cup semifinal, and eliminated
tournament runs can use a fake rewarded retry ad to restore the failed match.
Unlock decisions for defeated rivals, Classic Cup trophy wins, and five-dink
paddle achievement completion now live in a pure `UnlockSystem` with focused
tests. The Classic Park court remains open by default because it is the
polished first-session environment; the gray court is a projection-training
variant, and a future earned-court reward should use a second polished court.
The five-dink reward can now be equipped from the Trophy Room as `Dink Streak
Accent`, which recolors the visual-only aim indicator and the player's separate
on-court accent arc without changing approved sprite pixels.
The Classic Cup now presents Rally Queen / Veteran / Showman as the three rival
profiles, includes a compact champion/eliminated result panel, and treats
user-initiated tournament exit as a natural-break interstitial placement behind
the existing completed-match/time gates.
The current player-character selection is cosmetic/persistent and updates
roster state, game state, player-win end-match portrait, and a separate
court-space identity accent under the selected player/opponent; gameplay still
uses the accepted player runtime sprite sheets until per-character sheets are
approved. A guarded fake banner placeholder is mounted only on the main menu,
settings, roster, and trophy room screens, stays hidden before the first
completed match, and is feature-flagged off with
`DINK_RIVALS_SHOW_AD_PLACEHOLDERS=false`; no banner is mounted on gameplay,
debug rally, court select, tournament match flow, or end-match/reward screens;
route-level widget tests now guard the exact allowed and blocked surfaces. A
first-match flow test also asserts Quick Match reaches the tutorial/game path
without any banner, interstitial, or rewarded ad call before gameplay. The
`google_mobile_ads` SDK is present behind `DINK_RIVALS_USE_ADMOB=true`; the
opt-in `AdMobAdService` uses Google's Android test app ID plus test
banner/rewarded/interstitial ad unit IDs by default and preserves
`FakeAdService` as the default non-AdMob path. Production AdMob release
plumbing now exists: the Android manifest app ID is supplied through a Gradle
placeholder, production unit IDs are supplied with dart-defines, UMP consent
gates native ad initialization/loading, and production-ID mode selects
`NoAdsService` instead of fake ads if IDs are incomplete or consent blocks ad
requests. The guarded non-gameplay `AdBannerSlot` placements render opt-in
native banners only when native ads are configured. Setup notes live in
`docs/admob-release.md`. New saves start with Rookie unlocked and selected;
Rally Queen is now a locked direct challenge rival with a soft-game AI profile,
and beating her or winning the Classic Cup semifinal unlocks `rally_queen`.
Actual AdMob account IDs/UMP message verification, per-character runtime
sprites, real signing credentials/application id validation, and physical Pixel
closeout remain open.
Android release-signing scaffolding reads a gitignored
`android/key.properties` file or
`DINK_RIVALS_UPLOAD_*` environment variables and falls back to debug signing
when credentials are absent; setup notes live in `docs/release-signing.md`. The
Android launcher label is `Dink Rivals`; the default package id/namespace
remain `com.example.dink_rivals` for QA installs, and release builds can
override `applicationId` with `DINK_RIVALS_APPLICATION_ID` once the final Play
Console package name is confirmed. A repeatable Android QA harness now lives at
`dink_rivals/tool/android_qa.ps1`; it can install/launch the debug APK, force
best-effort offline mode, and monitor logcat for crash/ANR signatures during
the 15-minute stability window. The harness completed a 900-second offline
emulator run on `emulator-5554` against the default debug APK without crash or
ANR signatures; physical Pixel closeout remains open.
`tool/release_readiness.ps1` can now also run analyze/tests/build and enforce a
production-safe ad mode for stricter release preflight checks.

## Android QA Checklist

* Fresh install.
* Launch app.
* Start Quick Match.
* Complete match.
* Try rewarded ad.
* Play enough matches for interstitial.
* Confirm interstitial timing is respectful.
* Start tournament.
* Complete tournament.
* Unlock one item.
* Restart app.
* Confirm unlock persists.
* Turn off internet.
* Confirm gameplay works offline.
* Play 15 minutes.

---

## 14. Tuning Constants

All tuning should live in `tuning_constants.dart`.

```dart
class Tuning {
  static const double playerMoveSpeed = 260;
  static const double rivalMoveSpeed = 235;
  static const double ballGravity = 980;

  static const double racketReach = 42;
  static const double racketHitRadius = 13;
  static const double maxRacketAngleRadians = 1.5708;
  static const double minRacketContactSpeed = 5;
  static const double softContactSpeed = 72;
  static const double firmContactSpeed = 138;
  static const double driveContactThreshold = 96;

  static const double hitWindowRadius = 42;
  static const double perfectHitWindowRadius = 22;
  static const double smashMinBallHeight = 80;

  static const int quickMatchWinningScore = 11;
  static const int quickMatchWinBy = 2;
  static const int tournamentWinningScore = 11;
  static const int tournamentWinBy = 2;

  static const int minMatchesBeforeInterstitial = 3;
  static const int minMinutesBetweenInterstitials = 4;
}
```

---

## 15. Testing Plan

### 15.1 Required Unit Tests

* Scoring system.
* Server-only scoring and side-out transitions.
* Match-over detection.
* Legal diagonal serve landing.
* Two-bounce rule after serve.
* Kitchen volley fault.
* Out-of-bounds detection.
* Double bounce rule.
* Unlock conditions.
* Tournament bracket progression.
* Ad placement frequency rules.

### 15.2 Required Manual Tests

At the end of every phase:

* Launch on Android phone.
* Play at least 5 minutes.
* Test pause/resume when available.
* Test settings persistence when available.
* Test ads not appearing during gameplay when available.
* Test offline behavior when ads are integrated.

### 15.3 Performance Targets

* 60 FPS target on modern Android.
* 30 FPS minimum on lower-end Android.
* No obvious input lag.
* App cold launch under 5 seconds.
* Match starts from menu in under 2 seconds.

---

## 16. Agent Work Rules

1. Complete one phase at a time.
2. Keep PRs small.
3. Do not add speculative systems.
4. Do not add real ads before fake ads are tested.
5. Do not add IAP before MVP is playable.
6. Do not add online multiplayer in MVP.
7. Do not add energy, gems, loot boxes, or purchasable advantages.
8. Keep game logic testable outside Flame components when possible.
9. Put tuning values in constants, not scattered through components.
10. Update `PHASE_NOTES.md` after each phase.

---

## 17. First Agent Task

The first coding agent should only build **Phase 0**.

Task:

> Create a Flutter + Flame project that launches directly into a gray-box 3/4 pickleball court with a movable player, simple AI opponent, ball/shadow, left-stick movement, right-stick aim indicator, automatic dink body contact, committed swing hits, and debug overlay. It must run on a local Android device.

Do not build menus, ads, art, unlocks, or tournament mode yet.

---

## 18. Build Philosophy

Build in this order:

1. Feel.
2. Rules.
3. App shell.
4. Fake ads.
5. Real test ads.
6. Initial art pass.
7. Concept-art visual expansion.
8. Concept fidelity correction pass.
9. Concept composition and identity pass.
10. Tournament.
11. MVP polish.

A fun ugly prototype is valuable. A beautiful monetized game that does not feel good is worthless.
