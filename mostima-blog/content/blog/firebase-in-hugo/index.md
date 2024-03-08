---
title: "Hugo 博客中配置 Firebase 的方法"
date: "2024-01-14"
draft: false
description: "firebase in hugo blog"
slug: "firebase-hugo-blog"
tags: ["Firebase", "Blog", "Hugo"]
series: ["Hugo 博客搭建"]
series_order: 2
showHero: true
heroStyle: "basic"
---

## 简介

Blowfish 添加了对 Firebase 的支持以在网站上使用动态数据.

## 配置方法

1. 在 [Firebase 官网](https://firebase.google.com/)免费注册一个账号

2. 选择「添加项目」，输入项目名

   ![](firebase1.png)

   ![](firebase2.png)

3. 开启「为此项目启用 Google Analytics」

   ![](firebase3.png)

4. 选择默认账号即可

   ![](firebase4.png)

5. 进入项目主页后选择 <kbd></></kbd>

   ![](firebase6.png)

6. 输入你的应用名

   ![](firebase7.png)

7. 选择「使用 `<script>` 标记」， 并记录下 config 数据，如黄框所示

   ![](firebase8.png)

8. 在 `config/_default/params.toml` 文件中将上一步中的配置变量覆盖原配置

   ```toml
   # 实例，请替换为自己的数据
   [firebase]
     apiKey: "AIzaSyB5tqlqDky77Vb4Tc4apiHV4hRZI18KGiY",
     authDomain: "blowfish-21fff.firebaseapp.com",
     projectId: "blowfish-21fff",
     storageBucket: "blowfish-21fff.appspot.com",
     messagingSenderId: "60108104191",
     appId: "1:60108104191:web:039842ebe1370698b487ca",
     measurementId: "G-PEDMYR1V0K"
   ```

9. 配置 Authentication

   1. 在「项目首页」或「侧边栏」中选择 Authentication

      ![](firebase9.png)

   2. 选择 <kbd>开始</kbd>

      ![](firebase10.png)

   3. 选择 「匿名」

      ![](firebase11.png)

   4. 启用匿名，并保存

      ![](firebase12.png)

   5. 点击侧边栏， 选择「Firestore Database」，并点击<kbd>创建数据库</kbd>

      ![](firebase13.png)

   6. 选择距离你为止较近的「位置」

      ![](firebase14.png)

   7. 选择「以生产模式开始」，并点击<kbd>创建</kbd>

      ![](firebase15.png)

   8. 完成后，修改规则， 将以下内容粘贴进输入框中

      ```json
      rules_version = '2';
      service cloud.firestore {
        match /databases/{database}/documents {
          match /{document=**} {
            allow read, write: if request.auth != null;
          }
        }
      }
      ```

   如果你之前已经将 `showViews` 和 `showLikes` 设置为 `true` 的话, 现在阅读量和点赞量应该可以正常显示了.
