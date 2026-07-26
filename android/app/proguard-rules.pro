# flutter_local_notifications persists scheduled alarms as JSON via Gson.
# R8 must keep generic signatures and TypeToken subclasses, or release
# builds crash with "java.lang.RuntimeException: Missing type parameter"
# whenever the plugin reads its notification cache.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

-keep class com.dexterous.flutterlocalnotifications.** { *; }

-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
