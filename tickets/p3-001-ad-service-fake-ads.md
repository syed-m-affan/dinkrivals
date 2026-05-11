---
id: P3-001
phase: 3
status: done
priority: high
parallel_group: A
depends_on: []
blocks: [P3-003, P3-004, P3-005, P3-006]
owner: codex
last_updated: 2026-05-11
revised_by: claude-2026-05-11
---

# P3-001 - Ad Service and Fake Ads

## Goal

Create the Phase 3 ad service abstraction and a fake implementation that can simulate rewarded and interstitial ads without adding real AdMob or any external ad SDK.

## Build Spec Coverage

Phase 3 tasks:

- Create `AdService` interface.
- Create `FakeAdService`.

## Suggested File Ownership

- `dink_rivals/lib/services/ad_service.dart`.
- `dink_rivals/lib/app/ad_provider.dart` (new) — Riverpod provider exposing the active `AdService`. Follow the `saveServiceProvider` pattern in `dink_rivals/lib/services/save_service.dart`.
- `dink_rivals/lib/main.dart` — call `AdService.initialize()` during bootstrap (analogous to `SaveService.load()`).
- `dink_rivals/test/ad_service_test.dart`.

Avoid editing screens in this ticket; UI wiring belongs to `P3-003`, `P3-004`, and `P3-005`.

## Requirements

- Define an `AdService` interface matching the build spec:
  - `Future<void> initialize()`
  - `Future<bool> isRewardedAdReady()`
  - `Future<bool> showRewardedAd({required String placement})`
  - `Future<bool> isInterstitialReady()`
  - `Future<bool> maybeShowInterstitial({required String placement})`
  - `bool get adsRemoved`
- Implement `FakeAdService` with deterministic behavior suitable for tests.
- Fake rewarded ads should complete only when explicitly requested by the caller.
- Fake interstitial calls should return whether an interstitial would have shown; actual frequency decisions belong to `P3-002`.
- `adsRemoved` always returns `false` in Phase 3. Phase 3 does not add any UI to flip it (no IAP, no remove-ads button); the field is a stub for Phase 4+ to satisfy the interface.
- Expose the active `AdService` via a Riverpod provider in `lib/app/`. Same shape as `saveServiceProvider` / `saveDataProvider` so screens and `AdPlacementSystem` can read it.
- Call `AdService.initialize()` from `main.dart` before `runApp(...)`, alongside `SaveService.load()`. Override the provider in `ProviderScope` with the initialized instance.
- No production ad IDs, AdMob dependency, Android manifest changes, banners, IAP, remove-ads UI, or real network behavior.

## Verification

Run from `dink_rivals/`:

```bash
flutter analyze
flutter test
```

Required tests:

- Fake service initializes without side effects.
- Rewarded readiness can be queried.
- `showRewardedAd(...)` returns success for ready fake ads.
- Interstitial readiness can be queried.
- `adsRemoved` is always `false` in `FakeAdService` (no Phase 3 way to flip it).
- Riverpod provider returns the initialized fake service.

## Acceptance Criteria

- `AdService` and `FakeAdService` exist and are testable outside Flutter widgets.
- No real ad SDK is introduced.
- No gameplay, routing, or screen UI is changed.
- `flutter analyze` and `flutter test` pass.

## Implementation Notes

Completed on 2026-05-11:

- Added `AdService` and deterministic `FakeAdService`.
- Added `adServiceProvider` and `lib/app/ad_provider.dart` export surface.
- Initialized `FakeAdService` in `main.dart` and overrode the provider at app bootstrap.
- Added `ad_service_test.dart` coverage for initialization, readiness, show calls, `adsRemoved`, and provider override.

## Verification

- `flutter analyze`: passed with no issues.
- `flutter test`: passed 73/73.
- `flutter build apk --debug`: passed.
