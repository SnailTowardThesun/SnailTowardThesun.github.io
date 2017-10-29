---
layout: article
title: angular4 + flv.js + srs 搭建一个简单的基于html5的直播平台
categories: media streaming
---
## 简要说明
直播的风头基本都已经过去了，写这个文章的目的就是为了记录，所以废话少说，开始正题。
首先介绍下这几个工具：
1. [angular4](https://angular.io/), [google](www.google.com)开源的前端框架，最新的angular4使用了ts作为主力语言。
1. [flv.js](https://github.com/Bilibili/flv.js), [B站](www.bilibili.com)开源的html5播放器，简单来讲就是通过获取http-flv的直播流，然后利用[MSE](https://www.w3.org/TR/media-source/)来播放。
1. [srs](https://github.com/ossrs/srs), 作者[winlin](https://github.com/winlinvip)，国内比较认可的一款开源的流媒体服务器

## 具体步骤
1. 创建videoPlayer工程
    `ng new videoPlayer`
1. 添加flv.js
```
$cd videoPlayer
$npm install --save flv.js
$cd node_modules/flv.js
$npm install
$npm install -g gulp
$gulp release
```
1. 将flv.js添加到videoPlayer的工程中
     1. 修改`/path/videoPlayer/tsconfigure.json`，添加`"allowJs": true`
     1. 修改`/path/videoPlayer/.angular-cli.json`，添加` "scripts": ["../node_modules/flv.js/dist/flv.min.js"],`
      
1. 创建播放器
      1. 修改`/path/videoPlayer/src/app/app.component.html`
      ```
        <!--The content below is only a placeholder and can be replaced.-->
        <div style="text-align:center">
          <h1>
            html5 http-flv player
            <video id="videoElement"></video>
          </h1>
        </div>
      ```
     2. 修改`/path/videoPlayer/app/src/app.component.ts`:
      ```
      import { Component, OnInit } from '@angular/core';
      import 'flv.js';
      
      @Component({
        selector: 'app-root',
        templateUrl: './app.component.html',
        styleUrls: ['./app.component.css']
      })
      export class AppComponent implements OnInit {
        title = 'app';

        ngOnInit(): void {
          if (flvjs.isSupported()) {
            const videoElement =    <HTMLAudioElement>document.getElementById('videoElement');
            const flvPlayer = flvjs.createPlayer({
              type: 'flv',
              url: 'http://127.0.0.1:8080/live/livestream.flv'
            });
            flvPlayer.attachMediaElement(videoElement);
            flvPlayer.load();
            flvPlayer.play();
          }
        }
      }
      ```
1. 启动SRS
    ```
    $git clone https://github.com/ossrs/srs.git
    $cd srs/trunk
    $./configure
    $make
    $./objs/srs -c conf/http.flv.live.conf
    ```
    srs相关内容可以去看相关wiki，极为全面

1. 使用obs或者其他软件推流

1. 确认播放地址正确，启动angular，访问页面就能够看到了。

 注意：
srs的配置文件中，需要添加跨域配置
```
http_api {
    crossdomain on;
}
```

videoPlayer的代码：https://github.com/SnailTowardThesun/videoPlayer