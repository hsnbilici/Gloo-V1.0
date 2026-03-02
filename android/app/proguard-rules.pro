# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Supabase / OkHttp / Retrofit (used transitively)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class com.google.gson.** { *; }

# Google Play Services (Ads, IAP)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# FFmpeg Kit
-keep class com.arthenica.ffmpegkit.** { *; }

# Google Play Core (Flutter engine deferred components — optional dep)
-dontwarn com.google.android.play.core.**

# Keep native methods
-keepclasseswithmembernames class * { native <methods>; }
