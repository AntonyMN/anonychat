# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Pusher slf4j missing class (not needed at runtime on Android)
-dontwarn org.slf4j.**
-dontwarn org.slf4j.impl.**

# Pusher
-keep class com.pusher.** { *; }

# OkHttp (used by Pusher)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Play Core (Deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
