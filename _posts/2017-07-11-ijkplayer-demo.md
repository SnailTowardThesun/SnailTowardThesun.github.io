---
layout: article
title: ijkplayer demo
categories: android
---


# ijkplayer 播放器，android平台使用说明

[ijkplayer github 地址](https://github.com/Bilibili/ijkplayer)

## ijkplayer 编译
编译可以参考[官方说明](https://github.com/Bilibili/ijkplayer/blob/master/README.md)

简要步骤说明：
1. 将代码下载到本地
```
git clone https://github.com/Bilibili/ijkplayer
```

1. 设定ndk环境
    1. 下载对应平台的ndk工具包，[官网地址](https://developer.android.com/ndk/downloads/index.html)
    1. 设置ndk的编译环境，因为我使用的是mac，就直接
        ```
        export ANDROID_NDK=/ndk-path
        ```

1. 初始化ijkplayer为android编译环境
    ```
    ./init-android.sh
    ```

1. 编译ffmpeg之前准备
    因为ijkplayer还是依赖于ffmpeg的一些功能，所以在进行ijkplayer的编译之前，首先需要满足ffmpeg的编译条件。最主要的就是yasm的安装，以mac为例，安装yasm
    ```
    brew install yasm
    ```

1. 开始编译ffmpeg
    ```
    cd android/contrib
    ./compile-ffmpeg.sh clean
    ./compile-ffmpeg.sh all
    ```

1. 编译ijkplayer
    ```
    ./compile-ijk.sh all
    ```

## ijkplayer 的使用

### 使用前的说明
在完成上面的编译过程之后，可以在ijkplayer中发现一个android工程，简要的目录如下：

```
+---/path-to-ijkplayer/android/ijkplayer
    |
    +---ijkplayer-arm64
    |
    +---ijkplayer-armv5
    |
    +---ijkplayer-armv7a
    |
    +---ijkplayer-x86
    |
    +---ijkplayer-x86-64
    |
    +---ijkplayer-java
    |
    +---ijkplayer-exo
    |
    +---tools
```


如上目录为ijkplayer在android平台上需要用到的库，从命名上可以看出，以上modules中包含了这几类：
1. `ijkplayer-arm*`和`ijkplayer-x86*`，实现了不同平台下的so库。
1. `ijkplayer-java`和`ijkplayer-exo`, 为封装好的ijkplayer的java层api。
1. `tools`，编译需要用到的脚本程序

### 如何使用

1. 新建android工程，命名为：`ijkplayer-demo`。

1. 讲上文中表示出来的文件夹全部拷贝到新建的android工程目录下。

1. 修改新建工程中的`settings.gradle`:
    ```
    include ':ijkplayer-armv5', ':ijkplayer-x86_64'
    include ':ijkplayer-armv7a'
    include ':ijkplayer-arm64'
    include ':ijkplayer-x86'

    include ':ijkplayer-java'
    include ':ijkplayer-exo'

    include ':app'
    ```
1. 修改`/path-to-ijkplayer-demp/build.gradle`
    ```
    // Top-level build file where you can add configuration options common to all sub-projects/modules.

    buildscript {
        repositories {
            jcenter()
        }
        dependencies {
            classpath 'com.android.tools.build:gradle:2.3.3'

            // NOTE: Do not place your application dependencies here; they belong
            // in the individual module build.gradle files

        }
    }

    allprojects {
        repositories {
            jcenter()
        }
    }

    ext {
        compileSdkVersion = 23
        buildToolsVersion = "23.0.3"

        targetSdkVersion = 23

        versionCode = 800000
        versionName = "0.8.0"
    }

    task clean(type: Delete) {
        delete rootProject.buildDir
    }
    ```

1. 修改`/path-to-ijkplayer-demp/app/build.gradle`
    ```
    apply plugin: 'com.android.application'

    android {
        compileSdkVersion 25
        buildToolsVersion "25.0.1"
        defaultConfig {
            applicationId "com.test.ijkplayer.hankun.ijkplayer_test"
            minSdkVersion 21
            targetSdkVersion 25
            versionCode 1
            versionName "1.0"
            testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
        }
        buildTypes {
            release {
                minifyEnabled false
                proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
            }
        }
    }

    dependencies {
        compile fileTree(include: ['*.jar'], dir: 'libs')
        androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {
            exclude group: 'com.android.support', module: 'support-annotations'
        })
        compile 'com.android.support:appcompat-v7:25.1.1'
        compile 'com.android.support.constraint:constraint-layout:1.0.2'
        testCompile 'junit:junit:4.12'

        compile project(':ijkplayer-java')

        compile project(':ijkplayer-arm64')
        compile project(':ijkplayer-armv5')
        compile project(':ijkplayer-armv7a')
        compile project(':ijkplayer-x86')
        compile project(':ijkplayer-x86_64')
    }

    ```
1. 给app添加权限
    ```
    AndroidManifest.xml


    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    ```

1. app的布局文件
    ```
    <?xml version="1.0" encoding="utf-8"?>
    <android.support.constraint.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        xmlns:tools="http://schemas.android.com/tools"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        tools:context="com.test.ijkplayer.hankun.ijkplayer_test.MainActivity">
        <RelativeLayout
            android:layout_width="368dp"
            android:layout_height="495dp"
            tools:layout_editor_absoluteY="8dp"
            tools:layout_editor_absoluteX="8dp">

            <Button
                android:id="@+id/button_prepare"
                android:layout_width="wrap_content"
                android:layout_height="wrap_content"
                android:text="start"
                android:layout_alignParentTop="true"
                android:layout_alignParentStart="true" />

            <TextureView
                android:id="@+id/show_screen"
                android:layout_width="400dp"
                android:layout_height="200dp"
                android:layout_below="@+id/button_prepare"
                />
        </RelativeLayout>

    </android.support.constraint.ConstraintLayout>

    ```

1. MainActivity代码
    ```
    package com.test.ijkplayer.hankun.ijkplayer_test;

    import android.content.Context;
    import android.graphics.SurfaceTexture;
    import android.net.Uri;
    import android.support.v7.app.AppCompatActivity;
    import android.os.Bundle;
    import android.view.Surface;
    import android.view.TextureView;
    import android.view.View;
    import android.widget.Button;

    import tv.danmaku.ijk.media.player.IMediaPlayer;
    import tv.danmaku.ijk.media.player.IjkMediaPlayer;

    public class MainActivity extends AppCompatActivity {

        private String source_url = "rtsp://192.168.1.106:8554/test.mkv";
        private Context _ctx = this;
        public IjkMediaPlayer player = null;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            player = new IjkMediaPlayer();

            TextureView tv = (TextureView)findViewById(R.id.show_screen);
            tv.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
                @Override
                public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                    try {
                        player.setSurface(new Surface(surface));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

                }

                @Override
                public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                    return false;
                }

                @Override
                public void onSurfaceTextureUpdated(SurfaceTexture surface) {

                }
            });

            Button btn_prepare = (Button) findViewById(R.id.button_prepare);
            btn_prepare.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    // init player
                    IjkMediaPlayer.loadLibrariesOnce(null);
                    IjkMediaPlayer.native_profileBegin("libijkplayer.so");

                    player.setOnPreparedListener(mPreparedListener);
                    try {
                        player.setDataSource(_ctx, Uri.parse(source_url));
                        player.prepareAsync();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

        }

        IMediaPlayer.OnPreparedListener mPreparedListener = new IMediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(IMediaPlayer mp) {
                player.start();
            }
        };

    }
    ```

到这里，就完成了一个最简单的ijkplayer的demo。剩下的就是认真看ijkplayer的实现了。