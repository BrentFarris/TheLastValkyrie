For those of you who don't know, I have been a (Visual Studio)[https://visualstudio.microsoft.com/vs/community/] user for a long time now, amoung other forms of IDEs I've used Visual Studio the most. Something else I also love to use is the C programming language (I wish VS was more up to date for C but it's good enough). One of the things you can do is develop for Android using NDK and Visual Studio which works fairly well, even though it is using Ant instead of Gradle, I find that it has suited all of my needs so far. That being said, I'm going to drop some tips here on how to make the development process a bit more friendly to be able to interact via JNI and native code.

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
Notice the commented out line `System.loadLibrary`. You can call this as many times as needed, but all you need to do is replace `"other_lib"` with the name of your library, like `System.loadLibrary("fmod");` or something similar. At this point you should be able to build without any issues

## Custom JAR files
Now that we've setup our activity to better interact with JNI and load other libraries, we are going to look at how to add our own `.jar` files and access the types within them from native code.

*Though this is not a tutorial on creating .jar files, I will say to make sure and compile your code with `-source 1.7 -target 1.7` so that it is matching Ant's versions we setup earlier.*

TBD
