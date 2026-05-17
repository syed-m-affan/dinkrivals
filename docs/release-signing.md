# Android Release Signing

The Android release build now has signing scaffolding but does not include
production credentials. Secrets must stay out of git.

`dink_rivals/android/key.properties` is gitignored and can contain:

```properties
storeFile=app/upload-keystore.jks
storePassword=replace-with-store-password
keyAlias=upload
keyPassword=replace-with-key-password
```

The same values can be provided with environment variables:

```powershell
$env:DINK_RIVALS_UPLOAD_STORE_FILE="app/upload-keystore.jks"
$env:DINK_RIVALS_UPLOAD_STORE_PASSWORD="replace-with-store-password"
$env:DINK_RIVALS_UPLOAD_KEY_ALIAS="upload"
$env:DINK_RIVALS_UPLOAD_KEY_PASSWORD="replace-with-key-password"
```

When all four values are present and the keystore file exists, the release build
uses the `release` signing config. Otherwise it falls back to debug signing so
`flutter build apk --release` continues to work for local QA.

## Application ID

The default QA install identity remains `com.example.dink_rivals`. Production
builds can supply the final Play Console package name without editing Gradle:

```powershell
$env:DINK_RIVALS_APPLICATION_ID="com.yourstudio.dinkrivals"
```

or, when invoking Gradle directly from `dink_rivals/android/`:

```bash
./gradlew assembleRelease -PDINK_RIVALS_APPLICATION_ID=com.yourstudio.dinkrivals
```

The Android `namespace` intentionally remains `com.example.dink_rivals`; only
`applicationId` changes the install and Play Store identity.

Run from `dink_rivals/`:

```bash
flutter build apk --release
```

Production closeout still requires a real upload keystore, a Play Console-ready
application id supplied through this override, and a signed artifact
verification pass.
