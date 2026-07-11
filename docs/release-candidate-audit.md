# MVP Release Candidate Audit

Date: 2026-05-17; RC completion update: 2026-07-10

## 2026-07-10 RC Completion Update

- Replaced the legacy menu stack with the arcade hub: one-tap Quick Match,
  featured Classic Cup/Showman reward, and compact Roster, Courts, Trophies,
  and Settings tiles. QA labels/routes and fake-ad UI are build-gated and are
  absent from the RC.
- Added immutable match sessions across quick match, direct challenge, Cup,
  result, and rematch flows. Opponent character identity is no longer inferred
  from mutable AI state; roster challenges now preserve the selected rival's
  AI, sprites, name, portrait, result identity, and rematch target.
- Classic Cup now awards Showman atomically with the Cup win and trophy.
  Rally Queen and Veteran remain direct-challenge unlocks; locked Showman has
  no direct challenge path. Revisited/retried results cannot duplicate rewards.
- Integrated native 64x64 north/south runtime packs for Rookie, Rally Queen,
  Veteran, and Showman. The accepted Rookie south pack is retained. All 64
  strips pass fixed-cell validation and motion audit; the accepted run,
  manifest, prompts, previews, contact sheets, and review record are under
  `docs/art/visual-overhaul/skill-runs/release-candidate-characters-2026-07-10/`.
- Player maximum speed is 225 court units/second; acceleration remains 1350.
- Android launch icon/splash are branded. Version is `0.2.0+2`.
- RC preflight passed with Google test AdMob IDs, real AdMob plumbing enabled,
  fake placeholders disabled, QA UI disabled, analyzer clean, 308 tests green,
  and `build/app/outputs/flutter-apk/app-release.apk` produced (67.7 MB).
- The release APK installed/launched on `emulator-5554`. Quick Match, the
  Rally Queen roster challenge, and Classic Cup semifinal setup were visually
  smoke-tested; a 60-second offline monitor completed with no crash or ANR.
- Remaining external gates are physical-device gameplay/readability QA and
  human visual signoff. Public-store signing, final application ID, production
  AdMob IDs/UMP account setup, store assets, and Play submission remain outside
  this internal RC.

## Objective

Implement as much of the Dink Rivals build spec as possible without human
intervention, use Claude for decisions where useful, periodically commit/push,
and install on the connected Pixel when finished.

## Evidence Snapshot

- Release plumbing commits pushed before this audit:
  - `c5931c1 allow release application id override`
  - `3ab6194 add admob production consent plumbing`
- Verification on the current tree:
  - `flutter analyze`: no issues.
  - `flutter test`: 294 tests passed.
  - `flutter build apk --release`: built `build/app/outputs/flutter-apk/app-release.apk`.
  - `flutter install -d 58011FDCQ00992 --use-application-binary=build\app\outputs\flutter-apk\app-release.apk`: installed the current release APK on Pixel 10 Pro XL when the device was visible.
  - `adb -s 58011FDCQ00992 shell am start -W -n com.example.dink_rivals/.MainActivity`: launched the current release APK on Pixel 10 Pro XL with `Status: ok`, cold launch `TotalTime: 783`, `WaitTime: 786`, pid `20597`, and focused `com.example.dink_rivals/.MainActivity`.
  - `.\tool\release_readiness.ps1 -RequireProductionSecrets -RequireProductionAdMode -RequirePhysicalDevice -RequireReleaseApk`: exits nonzero as expected for missing signing/app id/production AdMob/ad-mode inputs; the latest post-launch ADB check also reported no Android devices visible, so this strict gate still fails the physical-device check when the Pixel is disconnected.
- Historical emulator evidence retained for stability:
  - `flutter build apk --debug`: built `build/app/outputs/flutter-apk/app-debug.apk`.
  - `flutter install -d emulator-5554 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`: installed.
  - `flutter install -d emulator-5554 --use-application-binary=build\app\outputs\flutter-apk\app-release.apk`: installed current release APK.
  - `.\tool\android_qa.ps1 -DeviceId emulator-5554 -ApkPath build\app\outputs\flutter-apk\app-release.apk -Offline -DurationSeconds 900`: completed without crash or ANR signatures.
  - `adb shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1`: launched the current release APK on `emulator-5554`.
  - Current release emulator launch check: `pidof com.example.dink_rivals` returned `18064`, and `dumpsys window` focused `com.example.dink_rivals/.MainActivity`.
  - `.\tool\release_readiness.ps1 -RunAnalyze -RunTests -BuildRelease`: completed on the 293-test tree before the global error-handler slice; the latest tree has equivalent standalone analyzer/test/release-build verification instead of a completed wrapper pass.
  - Focused progression tests cover pure unlock rules, tournament loss/final
    champion screen paths, challenge win/loss paths, persisted rewarded stars,
    Dink Streak Paddle achievement persistence, selectable Dink Streak Accent
    persistence/equip UI, release metadata/preflight switches, exact banner
    route placement, first-match/no-pre-game-ad flow, and non-sprite character
    identity accents.
  - Product-rule guard tests scan app source/config for forbidden energy,
    gems, gacha, loot box, premium-currency, heart-gate, and pay-to-win
    mechanics.
  - Asset-manifest guard tests verify pubspec asset declarations, checked-in
    asset reachability, and the approved runtime sprite PNG set.
  - Global error-handler tests verify Flutter and platform uncaught errors are
    reported through the release bootstrap hooks.
- Device state: Pixel 10 Pro XL `58011FDCQ00992` was visible long enough for release install/launch evidence, then a later ADB/Flutter device check listed no Android devices. Extended physical-device gameplay/visual QA still needs a stable connection.

## Checklist

| Requirement | Evidence | Status |
| --- | --- | --- |
| Main menu | `MainMenuScreen`, `AppRoutes.menu`, menu tests/goldens | Implemented |
| Quick Match | Main menu Quick Match navigates to `AppRoutes.game`; default route starts playable game | Implemented |
| 4-player tournament | `TournamentState`, `TournamentSystem`, `TournamentScreen`, `tournament_*` tests | Implemented |
| 4 characters | Rookie, Rally Queen, Veteran, Showman roster definitions, portraits, AI profiles, and non-sprite on-court identity accents | Implemented for roster/meta/runtime accent |
| 2 courts | `CourtSelectScreen`; Classic Park and projection-training court selection | Implemented |
| Achievement unlocks | `UnlockSystem`, character unlock IDs, Classic Cup trophy, Dink Streak Paddle, challenge/tournament unlock flow | Implemented |
| Local save | `SaveData`, `SaveService`, notifier tests cover stars, settings, unlocks, tutorial, selected court/character, Dink Streak Accent selection | Implemented |
| Trophy room | `TrophyRoomScreen`, `AppRoutes.trophyRoom`, progression screen tests including Dink Streak Accent equip/unequip | Implemented |
| Settings | persisted sound/haptics settings and tests | Implemented |
| Rewarded ads | post-match reward and tournament retry flows; explicit fake-ad flag; native AdMob test path in RC | Implemented |
| Respectful interstitials | `AdPlacementSystem` gates, end-match/tournament-exit natural breaks, regression tests | Implemented |
| Optional banners outside gameplay | `AdBannerSlot`, `ad_banner_route_placement_test.dart`; mounted on menu/settings/roster/trophy only, hidden before first completed match | Implemented |
| Real AdMob test path | `google_mobile_ads`, `AdMobAdService`, test IDs, native banner/fullscreen plumbing | Implemented |
| Production AdMob plumbing | `AdMobConfig`, Gradle app ID placeholder, production unit dart-defines, UMP consent gate, `NoAdsService` fallback | Implemented; actual IDs external |
| SFX/music | `AudioService` and sound setting wiring from Phase 5; Claude recommended deferring placeholder music until an approved production asset exists | SFX implemented; music deferred |
| Basic tutorial overlay | first-game quick-start overlay with persisted `tutorialSeen` | Implemented |
| Android release build | release APK builds locally | Implemented |
| Release signing scaffolding | `android/key.properties` / `DINK_RIVALS_UPLOAD_*` support | Implemented; real credentials external |
| Final application ID plumbing | `DINK_RIVALS_APPLICATION_ID` override with stable QA default | Implemented; final value external |
| No energy/gems/gacha/pay-to-win | `product_rules_guard_test.dart` scans app source/config for forbidden energy, gems, gacha, loot box, premium-currency, heart-gate, and pay-to-win mechanics | Implemented |
| Asset manifest integrity | `asset_manifest_guard_test.dart` verifies declared assets exist, checked-in assets are reachable from pubspec, and the approved runtime sprite PNG set has not drifted accidentally | Implemented |
| No forced ad before first gameplay | `main_menu_flow_test.dart` asserts first Quick Match/tutorial path shows no banner/interstitial/rewarded ad; banners hidden before first completed match; interstitial gates require completed matches/time; rewarded ads user-initiated | Implemented |
| No ads during active gameplay | route-level banner tests assert no banner slots on game/debug/tournament/courts/end-match; interstitial calls occur only at natural breaks | Implemented |
| Offline gameplay | 900-second offline emulator QA harness runs recorded without crash/ANR for debug APK and current release APK | Verified on emulator |
| Visible release/debug label | Phase/debug labels are hidden in normal RC UI and available only with `DINK_RIVALS_SHOW_QA_UI=true` | Implemented |
| Release preflight gates | `release_readiness.ps1` has optional analyze/test/build and production-ad-mode checks | Implemented |
| Global uncaught error hooks | `main.dart` installs zoned, Flutter, and platform error handlers; `main_error_handlers_test.dart` covers reporting behavior | Implemented |
| Physical Pixel install | Current release APK installed and launched on Pixel 10 Pro XL `58011FDCQ00992` with `Status: ok` | Implemented |
| Physical Pixel extended QA | Current ADB/Flutter device check later listed no Android devices; human gameplay/readability pass still pending | Blocked |
| Human feel/visual signoff | Requires human/device review | Blocked |
| Per-character runtime sprite sheets | Four character identities, north/south directions, eight native 64x64 action sheets each; validated imagegen workflow with accepted Rookie south retained | Implemented; human signoff pending |
| Approved music asset | Placeholder music was rejected by Claude as a polish regression | Blocked on approved audio asset |
| Actual AdMob production verification | Requires AdMob app ID, ad unit IDs, and configured UMP message | Blocked on account setup |
| Real signing verification | Requires upload keystore/passwords and final package ID value | Blocked on credentials/account setup |

## Mechanical Preflight

Run from `dink_rivals/`:

```powershell
.\tool\release_readiness.ps1
```

The default mode reports warnings for missing production-only values. To run
mechanical checks and require production secrets, production-safe ad mode, and a
physical Android device, run:

```powershell
.\tool\release_readiness.ps1 -RunAnalyze -RunTests -BuildRelease -RequireProductionSecrets -RequireProductionAdMode -RequirePhysicalDevice -RequireReleaseApk
```

## Decision

The internal Android RC implementation is complete and mechanically verified.
It must not be promoted to a public-store release until the explicitly external
physical-device, human-signoff, signing, final-package, production-AdMob/UMP,
privacy/store-listing, and Play submission gates are completed.
