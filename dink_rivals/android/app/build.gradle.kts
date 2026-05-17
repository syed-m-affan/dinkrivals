import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun signingValue(propertyName: String, environmentName: String): String? {
    return (keystoreProperties[propertyName] as String?) ?: System.getenv(environmentName)
}

val releaseStoreFilePath = signingValue("storeFile", "DINK_RIVALS_UPLOAD_STORE_FILE")
val releaseStorePassword = signingValue("storePassword", "DINK_RIVALS_UPLOAD_STORE_PASSWORD")
val releaseKeyAlias = signingValue("keyAlias", "DINK_RIVALS_UPLOAD_KEY_ALIAS")
val releaseKeyPassword = signingValue("keyPassword", "DINK_RIVALS_UPLOAD_KEY_PASSWORD")
val releaseStoreFile = releaseStoreFilePath?.let { rootProject.file(it) }
val hasReleaseSigning = releaseStoreFile?.exists() == true &&
    !releaseStorePassword.isNullOrBlank() &&
    !releaseKeyAlias.isNullOrBlank() &&
    !releaseKeyPassword.isNullOrBlank()

val googleTestAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
val adMobApplicationIdOverride = (
    (project.findProperty("DINK_RIVALS_ADMOB_APP_ID") as String?)
        ?: System.getenv("DINK_RIVALS_ADMOB_APP_ID")
).orEmpty().trim()
val adMobApplicationId = adMobApplicationIdOverride.ifEmpty {
    googleTestAdMobAppId
}
val defaultApplicationId = "com.example.dink_rivals"
val applicationIdOverride = (
    (project.findProperty("DINK_RIVALS_APPLICATION_ID") as String?)
        ?: System.getenv("DINK_RIVALS_APPLICATION_ID")
).orEmpty().trim()
val androidApplicationId = applicationIdOverride.ifEmpty {
    defaultApplicationId
}

android {
    namespace = "com.example.dink_rivals"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // The source namespace/R class stays fixed; applicationId is the install/Play identity.
        applicationId = androidApplicationId
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["adMobApplicationId"] = adMobApplicationId
    }

    signingConfigs {
        create("release") {
            storeFile = releaseStoreFile
            storePassword = releaseStorePassword
            keyAlias = releaseKeyAlias
            keyPassword = releaseKeyPassword
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigning) "release" else "debug"
            )
        }
    }
}

flutter {
    source = "../.."
}
