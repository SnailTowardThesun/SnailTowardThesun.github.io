---
layout: article
title: vim 退格键不可用
categories: vim tool
---
# vim 退格键不可用
两个步骤：

1. 去掉讨厌的有关vi一致性模式，避免以前版本的一些bug和局限
    ```
    set nocompatible
    ```
1. backspace有几种工作方式，默认是vi兼容的。对新手来说很不习惯。对老vi 不那么熟悉的人也都挺困扰的。可以用
    ```
    set backspace=indent,eol,start
    ```
 
* indent: 如果用了 `:set indent` , `:set ai` 等自动缩进，想用退格键将字段缩进的删掉，必须设置这个选项。否则不响应。
* eol:如果插入模式下在行开头，想通过退格键合并两行，需要设置eol。
* start：要想删除此次插入前的输入，需设置这个。


 将以上两个命令加到vim的系统配置文件里就可以了。通过vim命令:ver可以看到系统配置文件的位置，一般在/etc/vimrc
