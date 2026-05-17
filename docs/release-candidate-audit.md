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
  - `flutter test`: 259 tests passed.
  - `flutter build apk --debug`: built `build/app/outputs/flutter-apk/app-debug.apk`.
  - `flutter build apk --release`: built `build/app/outputs/flutter-apk/app-release.apk`.
  - `flutter install -d emulator-5554 --use-application-binary=build\app\outputs\flutter-apk\app-debug.apk`: installed.
  - `adb shell monkey -p com.example.dink_rivals -c android.intent.category.LAUNCHER 1`: launched, process id `16695`.
- Device state: `adb devices -l` lists only `emulator-5554`; the physical Pixel is not visible.
- Working tree after push: clean except pre-existing untracked `.idea/`.

## Checklist

| Requirement | Evidence | Status |
| --- | --- | --- |
| Main menu | `MainMenuScreen`, `AppRoutes.menu`, menu tests/goldens | Implemented |
| Quick Match | Main menu Quick Match navigates to `AppRoutes.game`; default route starts playable game | Implemented |
| 4-player tournament | `TournamentState`, `TournamentSystem`, `TournamentScreen`, `tournament_*` tests | Implemented |
| 4 characters | Rookie, Rally Queen, Veteran, Showman roster definitions and portraits | Implemented for roster/meta |
| 2 courts | `CourtSelectScreen`; Classic Park and projection-training court selection | Implemented |
| Achievement unlocks | character unlock IDs, Classic Cup trophy, challenge/tournament unlock flow | Implemented |
| Local save | `SaveData`, `SaveService`, notifier tests cover stars, settings, unlocks, tutorial, selected court/character | Implemented |
| Trophy room | `TrophyRoomScreen`, `AppRoutes.trophyRoom`, progression screen tests | Implemented |
| Settings | persisted sound/haptics settings and tests | Implemented |
| Rewarded ads | post-match reward and tournament retry flows, fake default, native AdMob opt-in | Implemented |
| Respectful interstitials | `AdPlacementSystem` gates, end-match/tournament-exit natural breaks, regression tests | Implemented |
| Optional banners outside gameplay | `AdBannerSlot` mounted on menu/settings/roster/trophy only, hidden before first completed match | Implemented |
| Real AdMob test path | `google_mobile_ads`, `AdMobAdService`, test IDs, native banner/fullscreen plumbing | Implemented |
| Production AdMob plumbing | `AdMobConfig`, Gradle app ID placeholder, production unit dart-defines, UMP consent gate, `NoAdsService` fallback | Implemented; actual IDs external |
| SFX/music | `AudioService` and sound setting wiring from Phase 5 | Implemented at current MVP level |
| Basic tutorial overlay | first-game quick-start overlay with persisted `tutorialSeen` | Implemented |
| Android release build | release APK builds locally | Implemented |
| Release signing scaffolding | `android/key.properties` / `DINK_RIVALS_UPLOAD_*` support | Implemented; real credentials external |
| Final application ID plumbing | `DINK_RIVALS_APPLICATION_ID` override with stable QA default | Implemented; final value external |
| No energy/gems/gacha/pay-to-win | No implementation evidence for those mechanics; monetization remains ads/cosmetic-style only | Implemented by omission |
| No forced ad before first gameplay | banners hidden before first completed match; interstitial gates require completed matches/time; rewarded ads user-initiated | Implemented |
| No ads during active gameplay | banner slots are not mounted on game/debug/tournament match/end-match reward flow; interstitial calls occur only at natural breaks | Implemented |
| Offline gameplay | 900-second offline emulator QA harness run previously recorded without crash/ANR | Verified on emulator |
| Physical Pixel install/QA | Current ADB output lists only emulator | Blocked |
| Human feel/visual signoff | Requires human/device review | Blocked |
| Per-character runtime sprite sheets | Current gameplay still uses accepted player/opponent sheets; user rejected casual regeneration path | Blocked on approved art workflow/signoff |
| Actual AdMob production verification | Requires AdMob app ID, ad unit IDs, and configured UMP message | Blocked on account setup |
| Real signing verification | Requires upload keystore/passwords and final package ID value | Blocked on credentials/account setup |

## Decision

The remaining known release-candidate gaps are not implementable in this
session without external account values, approved production art, a visible
physical Pixel, or human subjective signoff. The active goal should not be
marked complete because the physical Pixel install/QA and external release
values remain unresolved.
