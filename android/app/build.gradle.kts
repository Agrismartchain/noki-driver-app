import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing
//
// Real credentials are never committed. They are read from `android/key.properties`
// (gitignored, external to the repo) or from environment variables, so a
// release build can be signed on a dev machine or CI without touching git.
//
// android/key.properties:
//   storeFile=/absolute/path/to/noki-driver-release.jks
//   storePassword=...
//   keyAlias=...
//   keyPassword=...
//
// Equivalent environment variables (used when key.properties is absent):
//   NOKI_DRIVER_RELEASE_STORE_FILE
//   NOKI_DRIVER_RELEASE_STORE_PASSWORD
//   NOKI_DRIVER_RELEASE_KEY_ALIAS
//   NOKI_DRIVER_RELEASE_KEY_PASSWORD
// ---------------------------------------------------------------------------
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

fun releaseSigningValue(propertyKey: String, envKey: String): String? =
    (keystoreProperties[propertyKey] as String?)?.takeIf { it.isNotBlank() }
        ?: System.getenv(envKey)?.takeIf { it.isNotBlank() }

val releaseStoreFilePath = releaseSigningValue("storeFile", "NOKI_DRIVER_RELEASE_STORE_FILE")
val releaseStorePassword = releaseSigningValue("storePassword", "NOKI_DRIVER_RELEASE_STORE_PASSWORD")
val releaseKeyAlias = releaseSigningValue("keyAlias", "NOKI_DRIVER_RELEASE_KEY_ALIAS")
val releaseKeyPassword = releaseSigningValue("keyPassword", "NOKI_DRIVER_RELEASE_KEY_PASSWORD")

val hasReleaseSigningCredentials =
    !releaseStoreFilePath.isNullOrBlank() &&
        !releaseStorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank() &&
        rootProject.file(releaseStoreFilePath).exists()

// Explicit, opt-in-only escape hatch for local/CI compile-proof builds where no
// real release keystore exists yet. Never enabled by default, never silent: it
// prints a loud warning and the resulting APK must never be distributed as an
// RC or field artifact.
val allowDebugReleaseSigning =
    (project.findProperty("nokiAllowDebugReleaseSigning") as String?)?.toBoolean() == true ||
        System.getenv("NOKI_ALLOW_DEBUG_RELEASE_SIGNING") == "true"

android {
    namespace = "com.agrismartchain.noki.noki_driver_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.agrismartchain.noki.noki_driver_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigningCredentials) {
            create("release") {
                storeFile = rootProject.file(releaseStoreFilePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = when {
                hasReleaseSigningCredentials -> signingConfigs.getByName("release")
                allowDebugReleaseSigning -> {
                    logger.warn(
                        "NOKI: release build is signed with the DEBUG key because " +
                            "NOKI_ALLOW_DEBUG_RELEASE_SIGNING/-PnokiAllowDebugReleaseSigning " +
                            "was set explicitly. This is for local compile-proof builds ONLY " +
                            "and must never be used for a distributable RC or field artifact."
                    )
                    signingConfigs.getByName("debug")
                }
                else -> throw GradleException(
                    "NOKI release signing is not configured for noki-driver-app.\n" +
                        "Provide ONE of:\n" +
                        "  1) android/key.properties (gitignored) with storeFile, storePassword, keyAlias, keyPassword\n" +
                        "  2) NOKI_DRIVER_RELEASE_STORE_FILE / _STORE_PASSWORD / _KEY_ALIAS / _KEY_PASSWORD env vars\n" +
                        "To prove compilation only (NEVER for distribution), pass " +
                        "-PnokiAllowDebugReleaseSigning=true or set NOKI_ALLOW_DEBUG_RELEASE_SIGNING=true."
                )
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
