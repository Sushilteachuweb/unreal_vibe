# Flutter Video Player ProGuard Rules
# Keep video player classes
-keep class io.flutter.plugins.videoplayer.** { *; }
-keep class io.flutter.plugin.common.** { *; }

# Keep ExoPlayer classes (used by video_player)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep media classes
-keep class android.media.** { *; }
-keep class androidx.media.** { *; }

# Keep video codec classes
-keep class android.media.MediaCodec { *; }
-keep class android.media.MediaFormat { *; }
-keep class android.media.MediaExtractor { *; }

# Keep surface view classes
-keep class android.view.SurfaceView { *; }
-keep class android.view.TextureView { *; }

# Keep hardware acceleration classes
-keep class android.view.HardwareRenderer { *; }
-keep class android.opengl.** { *; }

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Prevent obfuscation of native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep asset loading classes
-keep class android.content.res.AssetManager { *; }
-keep class android.content.res.Resources { *; }

# Google Play Core classes (required by Flutter)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Specifically keep the missing classes identified by R8
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep Flutter Play Store split application
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }