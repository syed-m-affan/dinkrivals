# AdMob Release Configuration

The default build path uses Google's Android test AdMob app ID and test ad unit
IDs. Production IDs must come from the AdMob account for the final Play package
name and should not be committed to git.

## Default Test Ads

Run from `dink_rivals/`:

```bash
flutter build apk --debug --dart-define=DINK_RIVALS_USE_ADMOB=true
```

This keeps the manifest placeholder on Google's test app ID and uses test
banner, rewarded, and interstitial unit IDs.

## Production App ID

The Android manifest reads the app ID through the Gradle placeholder
`adMobApplicationId`. Provide it with either a Gradle property or environment
variable:

```powershell
$env:DINK_RIVALS_ADMOB_APP_ID="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"
```

or:

```bash
cd dink_rivals/android
./gradlew assembleRelease -PDINK_RIVALS_ADMOB_APP_ID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

## Production Unit IDs

Pass the ad unit IDs through Dart defines:

```bash
flutter build apk --release \
  --dart-define=DINK_RIVALS_USE_ADMOB=true \
  --dart-define=DINK_RIVALS_USE_PRODUCTION_ADMOB_IDS=true \
  --dart-define=DINK_RIVALS_ADMOB_BANNER_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/bbbbbbbbbb \
  --dart-define=DINK_RIVALS_ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/rrrrrrrrrr \
  --dart-define=DINK_RIVALS_ADMOB_INTERSTITIAL_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/iiiiiiiiii
```

If `DINK_RIVALS_USE_PRODUCTION_ADMOB_IDS=true` is set but any unit ID is
missing, the app uses `NoAdsService` instead of falling back to fake ads.

## Consent Flow

When native AdMob is enabled, `DINK_RIVALS_REQUEST_AD_CONSENT` defaults to
`true`. The app requests UMP consent before initializing Mobile Ads or loading
native ads. If consent cannot establish that ads may be requested, production-ID
mode serves no ads.

For consent testing, use:

```bash
--dart-define=DINK_RIVALS_AD_CONSENT_DEBUG_GEOGRAPHY=eea
--dart-define=DINK_RIVALS_AD_CONSENT_DEBUG_DEVICE_IDS=device_id_1,device_id_2
--dart-define=DINK_RIVALS_RESET_AD_CONSENT=true
```

Valid debug geographies are `eea`, `regulated_us`, and `other`.

End-to-end production ad QA still requires the real AdMob app ID, production
unit IDs, a configured UMP message in AdMob, the final Play package name, and a
physical Android device.
