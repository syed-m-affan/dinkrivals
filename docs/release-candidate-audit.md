# MVP Release Candidate Audit

Date: 2026-05-17

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
  - `flutter test`: 283 tests passed.
  - `flutter build apk --debug`: built `build/app/outputs/flutter-apk/app-debug.apk`.
  - `flutter build apk --release`: built `build/app/outputs/flutter-apk/app-release.apk`.
  - `flutter install -d emulator-5554 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`: installed.
  - `adb shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1`: launched, process id `16695`.
  - `.\tool\release_readiness.ps1`: mechanical release preflight passes with warnings for external production values and physical device availability.
  - `.\tool\release_readiness.ps1 -RunAnalyze -RunTests -BuildRelease`: analyzer, all tests, and release build pass; external production values still warn.
  - `.\tool\release_readiness.ps1 -RequireProductionSecrets -RequireProductionAdMode -RequirePhysicalDevice -RequireReleaseApk`: exits nonzero as expected for missing signing/app id/production AdMob/physical-device inputs.
  - Focused progression tests cover pure unlock rules, tournament loss/final
    champion screen paths, challenge win/loss paths, persisted rewarded stars,
    Dink Streak Paddle achievement persistence, release metadata/preflight
    switches, exact banner route placement, and non-sprite character identity
    accents.
- Device state: `adb devices -l` lists only `emulator-5554`; the physical Pixel is not visible.
- Working tree after push: clean except pre-existing untracked `.idea/`.

## Checklist

| Requirement | Evidence | Status |
| --- | --- | --- |
| Main menu | `MainMenuScreen`, `AppRoutes.menu`, menu tests/goldens | Implemented |
| Quick Match | Main menu Quick Match navigates to `AppRoutes.game`; default route starts playable game | Implemented |
| 4-player tournament | `TournamentState`, `TournamentSystem`, `TournamentScreen`, `tournament_*` tests | Implemented |
| 4 characters | Rookie, Rally Queen, Veteran, Showman roster definitions, portraits, AI profiles, and non-sprite on-court identity accents | Implemented for roster/meta/runtime accent |
| 2 courts | `CourtSelectScreen`; Classic Park and projection-training court selection | Implemented |
| Achievement unlocks | `UnlockSystem`, character unlock IDs, Classic Cup trophy, Dink Streak Paddle, challenge/tournament unlock flow | Implemented |
| Local save | `SaveData`, `SaveService`, notifier tests cover stars, settings, unlocks, tutorial, selected court/character, Dink Streak Paddle | Implemented |
| Trophy room | `TrophyRoomScreen`, `AppRoutes.trophyRoom`, progression screen tests including Dink Streak Paddle | Implemented |
| Settings | persisted sound/haptics settings and tests | Implemented |
| Rewarded ads | post-match reward and tournament retry flows, fake default, native AdMob opt-in | Implemented |
| Respectful interstitials | `AdPlacementSystem` gates, end-match/tournament-exit natural breaks, regression tests | Implemented |
| Optional banners outside gameplay | `AdBannerSlot`, `ad_banner_route_placement_test.dart`; mounted on menu/settings/roster/trophy only, hidden before first completed match | Implemented |
| Real AdMob test path | `google_mobile_ads`, `AdMobAdService`, test IDs, native banner/fullscreen plumbing | Implemented |
| Production AdMob plumbing | `AdMobConfig`, Gradle app ID placeholder, production unit dart-defines, UMP consent gate, `NoAdsService` fallback | Implemented; actual IDs external |
| SFX/music | `AudioService` and sound setting wiring from Phase 5; Claude recommended deferring placeholder music until an approved production asset exists | SFX implemented; music deferred |
| Basic tutorial overlay | first-game quick-start overlay with persisted `tutorialSeen` | Implemented |
| Android release build | release APK builds locally | Implemented |
| Release signing scaffolding | `android/key.properties` / `DINK_RIVALS_UPLOAD_*` support | Implemented; real credentials external |
| Final application ID plumbing | `DINK_RIVALS_APPLICATION_ID` override with stable QA default | Implemented; final value external |
| No energy/gems/gacha/pay-to-win | No implementation evidence for those mechanics; monetization remains ads/cosmetic-style only | Implemented by omission |
| No forced ad before first gameplay | banners hidden before first completed match; interstitial gates require completed matches/time; rewarded ads user-initiated | Implemented |
| No ads during active gameplay | route-level banner tests assert no banner slots on game/debug/tournament/courts/end-match; interstitial calls occur only at natural breaks | Implemented |
| Offline gameplay | 900-second offline emulator QA harness run previously recorded without crash/ANR | Verified on emulator |
| Visible release/debug label | `AppConfig.phaseLabel` is `MVP Release Candidate` and shown on main menu | Implemented |
| Release preflight gates | `release_readiness.ps1` has optional analyze/test/build and production-ad-mode checks | Implemented |
| Physical Pixel install/QA | Current ADB output lists only emulator | Blocked |
| Human feel/visual signoff | Requires human/device review | Blocked |
| Per-character runtime sprite sheets | Current gameplay keeps accepted player/opponent sheets byte-identical and adds separate color accents; user rejected casual regeneration path | Blocked on approved art workflow/signoff |
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

The remaining known release-candidate gaps are not implementable in this
session without external account values, approved production art/audio, a
visible physical Pixel, or human subjective signoff. The active goal should not
be marked complete because the physical Pixel install/QA and external release
values remain unresolved.
