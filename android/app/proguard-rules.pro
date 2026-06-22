# Keep PDFium / pdfrx native bindings and plugin classes from being stripped.
-keep class io.scer.** { *; }
-keep class com.shockwave.** { *; }
-keep class * extends io.flutter.embedding.engine.plugins.FlutterPlugin { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# Keep annotation classes used by json_serializable / freezed generated code.
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
