---
title: Android NDK, JAR files, JNI, and Visual Studio
description: How to call custom class and functions from .jar files in Visual Studio NDK with Ant and JNI
tags: ndk android java jar custom-class jni visual-studio
---

For those of you who don't know, I have been a [Visual Studio](https://visualstudio.microsoft.com/vs/community/) user for a long time now, amoung other forms of IDEs I've used Visual Studio the most. Something else I also love to use is the C programming language (I wish VS was more up to date for C but it's good enough). One of the things you can do is develop for Android using NDK and Visual Studio which works fairly well, even though it is using Ant instead of Gradle, I find that it has suited all of my needs so far. That being said, I'm going to drop some tips here on how to make the development process a bit more friendly to be able to interact via JNI and native code.

***Note:  I am assuming you've setup Visual Studio and installed native android development***

## Update Ant
If you've installed Android native development through Visual Studio, you should have everything you need (NDK & SDK) inside of the `C:/Microsoft` folder. Something we need to do is tell the Ant build system to use a more modern version of JDK (OpenJDK) for building java code. To do this, open the `C:/Microsoft/AndroidSDK/25/tools/ant/build.xml` file in a text editor and locate the line that starts with `<property name="java.target"`. Change the value of this to **1.7**. Do the same thing for `<property name="java.source"`. At this point you should see something like the following:
```xml
<!-- compilation options -->
<property name="java.encoding" value="UTF-8" />
<property name="java.target" value="1.7" />
<property name="java.source" value="1.7" />
<property name="java.compilerargs" value="" />
<property name="java.compiler.classpath" value="" />
```

## project.properties
My project properties file in the `.sln` looks like the following:
```
# Project target
target=$(androidapilevel)
# Provide path to the directory where prebuilt external jar files are by setting jar.libs.dir=
jar.libs.dir=libs
```

## AndroidManifest.xlm
Since we are going to be writing `.jar` files and possibly loading in external libraries at runtime, we will need to setup our project to have our own custom native activity code. Inside the `AndroidManifest.xlm` file you will need to find the `android:hasCode=""` value in the `<application>` tag and set it's value to `true`. It should look similar to the following:
```xml
<application android:label="@string/app_name" android:hasCode="true">
	<!-- ... -->
</application>
```
Next we will want to set the `<activity android:name=""` value to our package and activity name that we will be creating. So if your activity class name is going to be `FancyActivity` then you should have something similar to the following:
```xml
 <activity android:name="com.PackageName.FancyActivity" android:label="@string/app_name">
	<!-- ... -->
</activity>
```

## Creating our custom activity
Since our full class path will be `com.PackageName.FancyActivity` we will need to create a few folders inside of our `*.Packaging` project in Visual studio. Create a folder path named `src/com/PackageName/`. Next create a file inside of the `PackageName` folder named `FancyActivity.java`. Below is the code you should have inside of `FancyActivity.java`:
```java
package com.PackageName;

import android.app.NativeActivity;

public class FancyActivity extends NativeActivity
{
	static
	{
		//System.loadLibrary("other_lib");
	}
}
```
Notice the commented out line `System.loadLibrary`. You can call this as many times as needed, but all you need to do is replace `"other_lib"` with the name of your library, like `System.loadLibrary("fmod");` or something similar. At this point you should be able to build without any issues.

**Pro tip:** You should always add `System.loadLibrary("ProjectName");` where **ProjectName** is the name of the `.so` file that is generated for your NDK project build. This will allow you to call native functions from within your Java code (great for callbacks and the like).

## Custom JAR files
Now that we've setup our activity to better interact with JNI and load other libraries, we are going to look at how to add our own `.jar` files and access the types within them from native code.

### Building .jar files
Make sure and compile your code with `-source 1.7 -target 1.7` so that it is matching Ant's versions we setup earlier. After you've built your `.class` files, ensure your folder structure is correct as it relates to the package path. If your package path for your class(es) is `package com.PackageName;` then you should have the .class file within a folder structure `com/PackageName/*.class`. When you build your `.jar` file it should be for the whole folder structure.

### Including .jar files in project
Now that you have your `.jar` file, you should create a folder named `libs` in your `*.Packaging` project. Place your `.jar` file into this folder and make sure to right click it and select `Include In Project`.

## Accessing your code inside the .jar file
Lets assume for this part you've created a class named `Dummy` with a function that has the signature `void SayHi(string name)` which will print out "Hello, %s!" (%s = `name` input string of function). We will use JNI to access your code and invoke your method. Below is the code we will use to call our function. You can place it directly inside of your `void android_main(struct android_app* state)` function:
```c
JNIEnv* env = NULL;
const ANativeActivity* activity = state->activity;
(*activity->vm)->AttachCurrentThread(activity->vm, &env, 0);

jobject jobj = activity->clazz;
jclass clazz = (*env)->GetObjectClass(env, jobj);
jmethodID getClassLoader = (*env)->GetMethodID(env, clazz, "getClassLoader", "()Ljava/lang/ClassLoader;");
jobject cls = (*env)->CallObjectMethod(env, jobj, getClassLoader);
jclass classLoader = (*env)->FindClass(env, "java/lang/ClassLoader");
jmethodID findClass = (*env)->GetMethodID(env, classLoader, "loadClass", "(Ljava/lang/String;)Ljava/lang/Class;");
jstring strClassName = (*env)->NewStringUTF(env, "com.PackageName.Dummy");
jclass fancyActivityClass = (jclass)((*env)->CallObjectMethod(env, cls, findClass, strClassName));
(*env)->DeleteLocalRef(env, strClassName);
jmethodID sayHi = (*env)->GetStaticMethodID(env, fancyActivityClass, "SayHi", "(Ljava/lang/String;)V");
jstring words = (*env)->NewStringUTF(env, "Brent");
(*env)->CallStaticVoidMethod(env, fancyActivityClass, sayHi, words);
(*env)->DeleteLocalRef(env, words);
```

Now those who have had a little exposure with JNI might say "Can't we just use the `(*env)->FindClass` method? While this may be true for normal Android built in classes, it is not true for our own custom class. The reasoning is that JNI can only look through what is currently on the stack, and believe it or not, even though our `FancyActivity` is running our code, it isn't on the stack so we can't even find it. So what we need to do is get the current activity, then find a method on it called `getClassLoader`. Once we have this function, we are free to load any class from anywhere that is loaded, even inside our `.jar` code.

Hope this helps people who are having trouble. It tooke me a full day to figure out all of this stuff because there isn't anything straight forward on the internet, I had to dig really deep to find all the pieces to put this together!
