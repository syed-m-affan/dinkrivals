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

Run from `dink_rivals/`:

```bash
flutter build apk --release
```

Production closeout still requires a real upload keystore, a Play Console-ready
application id, and a signed artifact verification pass.
