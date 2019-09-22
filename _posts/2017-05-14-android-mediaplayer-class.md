---
layout: article
author: SnailTowardThesun
title: android mediaplayer
categories: 流媒体相关
---

# Android MediaPlayer

之前做过一些关于android播放器的开发工作，当时懵懂无知，只知道一个ffmpeg，然后就费劲巴拉的用ndk把ffmpeg编译了，然后又自己封装了个库调用，那个过程可以看看[这篇文章](http://www.roman10.net/2013/08/18/how-to-build-ffmpeg-with-ndk-r9/)，然后我这里也有一个编译好的[库](http://download.csdn.net/detail/peter_hugh/8295383)，可以拿来用。

好了，历史就说到这里，下面开始说一些今天的正题了，MediaPlayer类。

## MediaPlayer 是什么

### MediapPlayer的简要说明
* MediaPlayer 是android默认提供的一套用于播放视频音频的库。
* 除了实现了播放、停止的功能外，MediaPlayer还能够提供pause，seek的功能。
* MediaPlayer不仅仅能够播放本地文件，还能够播放一些网络流。
    > 不过，对于网络流的支持还是比较有限的，远不如ffmpeg的支持好。

### MediaPlayer支持的网络格式
* RTSP(RTP,SDP)
* HTTP/HTTPS progressive streaming
* HTTP/HTTPS live streaming [draft protocol](https://tools.ietf.org/html/draft-pantos-http-live-streaming-22):
    * MPEG-2 TS media files only
    * Protocol version 3 (Android 4.0 and above)
    * Protocol version 2 (Android 3.x)
    * Not supported before Android 3.0
> Note: HTTPS is not supported before Android 3.1.

### 支持的编码器
见官方给出的[附录](https://developer.android.com/guide/topics/media/media-formats.html#core)

## MediaPlayer 的基本使用方式
1. 设置权限
    ```
    <uses-permission android:name="android.permission.INTERNET" /> 网络权限
    ```
1. 布局文件
    ```
    <?xml version="1.0" encoding="utf-8"?>
    <android.support.constraint.ConstraintLayout
        xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        tools:context="com.example.hankun.myapplication.MainActivity">
        <SurfaceView
            android:id="@+id/big_screen"
            android:layout_width="200dp"
            android:layout_height="200dp"
            android:layout_marginTop="8dp"
            app:layout_constraintTop_toBottomOf="@+id/btn_play"
            android:layout_marginLeft="8dp"
            app:layout_constraintLeft_toLeftOf="@+id/btn_play" />
    </android.support.constraint.ConstraintLayout>

    ```
1. 代码部分
    ```
    public class MainActivity extends AppCompatActivity {

        private String stream_url = "http://127.0.0.1:8080/live/livestream.m3u8";
        private SurfaceHolder sh;
        private SurfaceView sfv;
        private MediaPlayer player;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            sfv = (SurfaceView)findViewById(R.id.big_screen);
            player = new MediaPlayer();
            try {
                player.setDataSource(this, Uri.parse(stream_url));
                sh =sfv.getHolder();
                sh.addCallback(new MyCallBack());
                player.prepare();
                player.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mp) {
                        player.start();
                        player.setLooping(true);
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        private class MyCallBack implements SurfaceHolder.Callback {
            @Override
            public void surfaceCreated(SurfaceHolder holder) {
                player.setDisplay(holder);
            }

            @Override
            public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {

            }

            @Override
            public void surfaceDestroyed(SurfaceHolder holder) {

            }
        }
    }
    ```

    代码说明：
    * MediaPlayer 的基本使用
    
        播放一个网络流的基本流程如下:
        ```
        String url = "http://........"; // your URL here
        MediaPlayer mediaPlayer = new MediaPlayer();
        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
        mediaPlayer.setDataSource(url);
        mediaPlayer.prepare(); // might take long! (for buffering, etc)
        mediaPlayer.start();
        ```
        但是这种设置只能够播放音频，因为没有给MediaPlayer绑定view去显示图像。
    
    * 添加视频播放，主要是满足MediaPlayer.SetDisplay(SurfaceHolder sh)
        1. 创建一个SurfaceView用于显示。
        1. 实现SurfaceHolder.Callback，也就是MyCallBack。值得注意的是，在surfaceCreated的回调中调用SetDisplay，保证绑定成功。
        1. MediaPlayer.setOnPreparedListener的作用是用于自动播放，可以改为使用按钮触发。

> Tips:
> 1. 用于生成hls流的工具，可以使用开源工具[SRS](https://github.com/ossrs/srs)。
> 1. 使用android模拟器不能够显示视频，需要使用真机，也是让人挺不开心呢。

## MediaPlayer 与TextureView配合使用

像上文中提到的MediaPlayer的最简单用法，封装的十分严密，基本上不知道发生了啥。尤其是当我们想要拿到视频的某一幅画面的时候，就变得更加困难。因此我们就需要使用TextureView这个控件了。废话不多说，直接贴代码

1. 布局文件
    ```
    <?xml version="1.0" encoding="utf-8"?>
    <android.support.constraint.ConstraintLayout
        xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:tools="http://schemas.android.com/tools"
        xmlns:app="http://schemas.android.com/apk/res-auto"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        tools:context="com.example.hankun.myapplication.MainActivity">

        <TextureView
            android:id="@+id/text_screen"
            android:layout_width="380dp"
            android:layout_height="204dp"
            android:layout_weight="1"
            tools:layout_editor_absoluteY="0dp"
            tools:layout_editor_absoluteX="0dp" />
        <Button
            android:layout_width="200dp"
            android:layout_height="50dp"
            tools:layout_editor_absoluteX="0dp"
            android:id="@+id/button"
            android:layout_marginTop="8dp"
            app:layout_constraintTop_toBottomOf="@+id/text_screen" />
        <ImageView
            android:id="@+id/image_screen"
            android:layout_width="380dp"
            android:layout_height="250dp"
            app:layout_constraintRight_toRightOf="parent"
            android:layout_marginTop="8dp"
            app:layout_constraintTop_toBottomOf="@+id/button"
            android:layout_marginRight="0dp" />
    </android.support.constraint.ConstraintLayout>
    ```
    * 我们设定了一个TextureView用来显示和抓取图像
    * 添加一个按钮，每次点击按钮就抓图
    * 设立了一个ImageView，用于显示抓到的图片
1. 代码部分
    ```
    public class MainActivity extends AppCompatActivity {

        private MediaPlayer player;
        private TextureView ttv;

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            setContentView(R.layout.activity_main);

            player = new MediaPlayer();
            player.setVolume(0, 0);

            ttv = (TextureView) findViewById(R.id.text_screen);
            ttv.setVisibility(0);
            ttv.setSurfaceTextureListener(new TextureListen());
            try {
                String stream_url = "http://192.168.199.245:8080/live/livestream.m3u8";
                player.setDataSource(this, Uri.parse(stream_url));
                player.prepare();
                player.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    @Override
                    public void onPrepared(MediaPlayer mp) {
                        player.start();
                        player.setLooping(true);
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
            }

            Button btn_image = (Button)findViewById(R.id.button);
            btn_image.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    ImageView img = (ImageView) findViewById(R.id.image_screen);
                    img.setImageBitmap(ttv.getBitmap());
                }
            });

        }
        private class TextureListen implements TextureView.SurfaceTextureListener {

            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int i, int i1) {
                try {
                    player.setSurface(new Surface(surfaceTexture));
                } catch (Exception e) {
                    e.printStackTrace();;
                }
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int i, int i1) {

            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture) {
                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surfaceTexture) {
            }
        }
    }
    ```

    > 在使用TextureView的时候，不再调用MediaPlayer 的`setDisplay`函数，而是调用了`setSurface`函数。因为SurfaceTexture那里涉及到了很多OpenGL ES的东西，还没来得及看，就先略过不说了。

> Tips: 在不能够理OpenGL ES的时候，我们还想获取到一个视频中的画面，那么不妨使用这种形式：将TextureView置于最底层并使用控件遮住。然后开启独立线程去刷新（就是代码中按钮的操作），这样就能获取到Bitmap，然后进行操作。虽然会浪费一些性能，但是最起码可用。

## MediaPlayer 与SurfaceTexture配合使用

## MediaPlayer 的高阶使用方式
>我还没研究，待续吧

## 参考
[api 官方文档](https://developer.android.com/reference/android/media/MediaPlayer.html)

[官方使用说明](https://developer.android.com/guide/topics/media/mediaplayer.html)