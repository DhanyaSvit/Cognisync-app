plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cognisync_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.cognisync.app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (Bill of Materials for version management)
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // Firebase Auth (no version needed because of BoM)
    implementation("com.google.firebase:firebase-auth")

    // Google Sign-In (required for Firebase Auth with Google)
    implementation("com.google.android.gms:play-services-auth:21.0.0")

    // MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
}

// Important: Apply the Google Services plugin after the dependencies
apply(plugin = "com.google.gms.google-services")
