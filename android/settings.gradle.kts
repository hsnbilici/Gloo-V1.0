pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    id("com.google.firebase.crashlytics") version("2.8.1") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")

// Fix old Flutter plugins for AGP 8+: namespace, compileSdk, JVM target alignment
gradle.afterProject {
    if (this.name == "app" || this.name == rootProject.name) return@afterProject
    try {
        val android = this.extensions.findByName("android")
            as? com.android.build.gradle.LibraryExtension ?: return@afterProject

        // Force namespace from AndroidManifest.xml if missing
        if (android.namespace.isNullOrEmpty()) {
            val manifest = file("${this.projectDir}/src/main/AndroidManifest.xml")
            if (manifest.exists()) {
                val pkg = Regex("""package="([^"]+)"""")
                    .find(manifest.readText())?.groupValues?.get(1)
                if (!pkg.isNullOrEmpty()) {
                    android.namespace = pkg
                }
            }
        }

        // Ensure compileSdk >= 35 and JVM 17 for Java/Kotlin
        if (android.compileSdk == null || android.compileSdk!! < 35) {
            android.compileSdk = 35
        }
        android.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    } catch (_: Exception) {
        // Not all subprojects are Android libraries
    }
}
