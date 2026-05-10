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
* Swing the racket with right thumb.
* Racket contact, not shot buttons, creates returns.
* Soft, angled contact creates dinks/blocks.
* Fast, clean contact creates drives/smashes.
* Win rallies.
* Win matches.
* Unlock rivals/courts through achievements.

Current control direction is locked around physical racket contact. Do not add separate dink, drive, lob, or smash buttons unless a future ticket explicitly reverses this decision after playtest evidence.

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

### 5.2 Standard Commands

```bash
flutter doctor
flutter pub get
flutter devices
flutter analyze
flutter test
flutter run -d <ANDROID_DEVICE_ID>
```

### 5.3 Build APK Locally

Debug APK:

```bash
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

Release APK for local testing:

```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

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
| Dink  | Soft racket contact with open/short angle | Low/soft |      Slow |    Low | Drop into kitchen  |
| Drive | Fast racket contact through the ball      |   Medium |      Fast | Medium | Push opponent deep |
| Lob   | Upward/high-angle racket contact          |     High |      Slow | Medium | Beat net pressure  |
| Smash | High ball + fast downward contact         | Downward | Very fast |   High | Finish point       |
| Block | Low-swing-speed defensive contact         |      Low |      Slow |    Low | Emergency reset    |
| Serve | First racket contact of point             |   Medium |    Medium |    Low | Begin rally        |

### 8.3 Racket Contact Window

Use generous early contact windows. Mobile users should not feel robbed. The player racket is represented as a capsule from the player body to the racket tip, not as a tiny endpoint. A hit occurs automatically when the ball intersects this capsule at a hittable height and the racket or incoming ball has enough relative speed.

Initial tuning values:

```dart
hitWindowRadius = 42.0
perfectHitWindowRadius = 22.0
maxAimAssistDegrees = 12.0
racketReach = 42.0
racketHitRadius = 13.0
```

### 8.4 Targeting

Start with physical contact rather than explicit target buttons:

* Racket angle changes the outgoing left/center/right direction.
* Swing speed changes soft vs firm contact.
* Incoming ball speed and angle affect the return.
* Shot names are classifications of the contact result, not player-selected commands.

Do not add separate shot buttons. If future playtesting rejects swing-contact controls, create a new ticket that explicitly changes this control contract before changing implementation.

---

## 9. Controls

### 9.1 Phase 0 Controls

* Left virtual stick: move player.
* Right virtual stick: swing racket left/right through the front 180-degree arc.
* The right stick controls racket angle and swing velocity only; it does not select shot type.
* Racket-ball contact automatically hits the ball.
* Soft contact is classified as dink/block; firm contact is classified as drive.
* Debug reset button: reset point.
* No separate dink or drive buttons.

### 9.2 MVP Controls

Default:

* Left thumb stick = movement.
* Right thumb stick = racket swing.
* Racket angle and swing speed determine dink, drive, lob, block, or smash.
* Smash happens when the ball is high and the player makes fast downward/forward contact.
* UI must preserve screen space around the swing stick so touch input does not conflict with the reset button, score display, or feedback text.

### 9.3 Control Feel Acceptance

Controls must feel good within the first 30 seconds.

Requirements:

* Movement responsive but not twitchy.
* Racket contact forgiving.
* Soft and firm contacts clearly different.
* The hitbox feels like the full racket, not the player body or a confusing endpoint marker.
* First/reset contact uses the same racket segment hitbox as rally contact.
* Player understands why they won/lost point.
* Misses should feel fair, not random.

---

## 10. Rules

### 10.1 MVP Rules

Use arcade-friendly simplified pickleball:

* Rally scoring.
* First to 7.
* Win by 1 for MVP.
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
* Real side-out scoring.
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
* Right-stick racket swing.
* Automatic racket contact hits.
* Soft/firm contact classification for debug dink/drive labels.
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
12. Implement right-stick racket swing through a front 180-degree arc.
13. Implement automatic racket-contact hits.
14. Implement basic ball pseudo-3D physics.
15. Implement simple bot return logic.
16. Add debug overlay.
17. Add reset point button.

## Acceptance Criteria

* Runs on local Android phone.
* Player can move on bottom side of court.
* Player hits by swinging the racket, without separate dink or drive buttons.
* Ball can cross net.
* Opponent can return some shots.
* Rally can last at least 10 seconds.
* Soft and firm racket contacts feel different.
* First/reset hit uses the racket hitbox, not the player body.
* Ball height is visually readable.
* Kitchen zones are visible.
* No crash after 5 minutes.

## Android QA Checklist

* Install debug APK.
* Launch app.
* Confirm Phase 0 label appears.
* Move player.
* Swing racket with right stick.
* Confirm no dink/drive shot buttons appear.
* Confirm soft and firm contacts are understandable.
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
* Racket-contact classification for dink, drive, lob, smash.
* Feedback text: DINK, DRIVE, LOB, SMASH, FAULT.
* Centralized tuning constants.

## Implementation Tasks

1. Add `MatchState`.
2. Add `ScoringSystem`.
3. Add `MatchRulesSystem`.
4. Add `ShotType` enum.
5. Add racket-contact shot classification.
6. Add contact window logic.
7. Add kitchen volley rule.
8. Add serve sequence.
9. Add match-over state.
10. Add unit tests for scoring/rules.

## Acceptance Criteria

* Full match can be played to 7.
* Score updates correctly.
* Out-of-bounds awards point.
* Double bounce awards point.
* Kitchen volley fault works.
* Dink, drive, lob, smash are produced by racket contact and feedback.
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

Replace gray-box visuals with early production-style retro art.

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

  static const int quickMatchWinningScore = 7;
  static const int tournamentWinningScore = 7;

  static const int minMatchesBeforeInterstitial = 3;
  static const int minMinutesBetweenInterstitials = 4;
}
```

---

## 15. Testing Plan

### 15.1 Required Unit Tests

* Scoring system.
* Match-over detection.
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

> Create a Flutter + Flame project that launches directly into a gray-box 3/4 pickleball court with a movable player, simple AI opponent, ball/shadow, left-stick movement, right-stick racket swing, automatic racket-contact hits, and debug overlay. It must run on a local Android device.

Do not build menus, ads, art, unlocks, or tournament mode yet.

---

## 18. Build Philosophy

Build in this order:

1. Feel.
2. Rules.
3. App shell.
4. Fake ads.
5. Real test ads.
6. Art.
7. Tournament.
8. MVP polish.

A fun ugly prototype is valuable. A beautiful monetized game that does not feel good is worthless.
