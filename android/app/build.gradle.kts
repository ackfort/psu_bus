plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.psu_bus"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // ✅ 1. เปิดใช้งาน Desugaring (สำหรับ flutter_local_notifications)
        isCoreLibraryDesugaringEnabled = true 
        
        // ใช้ Java 11 ตามที่คุณกำหนด (Workmanager/Local Notifications มักจะต้องการแค่ 1.8)
        sourceCompatibility = JavaVersion.VERSION_11 
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.psu_bus"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
    // ✅ 2. เพิ่ม Desugaring Library dependency
    // ใช้เวอร์ชันล่าสุดที่เสถียร (2.0.4)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4") 
}