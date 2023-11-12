---
title: "使用Hideip-network搭建网页代理"
date: 2023-11-11
draft: false
description: "使用hideip network搭建在线网页代理方法."
slug: "hideip-network"
tags: ["proxy"]
series: ["Blog"]
series_order: 2
---

## 前言

本文使用的在线网页代理是匿名浏览网页工具，通过浏览器网页实现访问你需要的网站，而不用单独开启VPN，适用于禁止使用VPN，或不便留下痕迹的情况。



## 搭建需求

1. 一台境外的服务器

   可从[Vultr](www.vultr.com)，[DigitalOcean](www.digitalocean.com) 等云服务器商租用

2. 了解基本的终端命令行知识，例如：`cd`, `ls`, `systemctl` 等

   

## 环境需求 & 安装方式

我的服务器使用Arch Linux，故我将使用Arch Linux的包管理器安装。如果你使用的是别的Linux发行版（如Debian，Ubuntu）等，请自行查看包管理器安装命令。

- node

  ```bash
  sudo pacman -S nodejs
  ```

- npm

  ```bash
  sudo pacman -S npm
  ```

- nginx

  ```bash
  sudo pacman -S nginx
  ```

安装完成后, 使用以下命令查看是否有效,

{{< alert >}}

**注意:** node版本需要v16及以上, 如果apt 安装的版本低于v16, 建议手动安装

{{< /alert >}}

```bash
# 查看安装是否有效
node --version
npm --version
nginx -v

# 如果显示如下内容则表示有效
root@SF-Naive-1:~# node --version
v18.13.0
root@SF-Naive-1:~# npm --version
9.2.0
root@SF-Naive-1:~# nginx -v
nginx version: nginx/1.22.1
```



## 下载hnet文件 & 安装

详情可参考[hideip.network](https://official.hideip.network/) 官方网站 

1. 下载项目文件

   ```bash
   git clone -b v3 https://github.com/Hideipnetwork/hideipnetwork-web.git
   ```

2. 进入目录并安装项目

   ```bash
   # 进入目录
   cd hideipnetwork-web
   # 安装并初始化
   npm install
   ```



## 配置nginx

由于HNet项目规定仅允许通过https访问, 且项目默认使用本机等56559端口，所以需使用nginx将本机56559端口反代.

使用nginx, 让你的域名 abc.def.xyz 可以访问到本机的 127.0.0.1:56559 端口

1. 在目录`/etc/nginx/conf.d` 创建文件 `hnet.conf`

   ```bash
   #创建文件
   vim /etc/nginx/conf.d/hnet.conf
   ```

2. 将以下配置内容填入文件中

   ```nginx
   server {
       listen 443 ssl; # 如果有其他进程在运行导致443被占用可以修改为任意其他端口, 但记住将防火墙中对应端口打开
       server_name hide.anecho.link; # 填入DNS解析好的域名
   
       ssl_certificate /root/cert/anecho.link.cer; # ssl证书公钥路径
       ssl_certificate_key /root/cert/anecho.link.key; # ssl证书密钥路径
       location / {
           # proxy_busy_buffers_size  512k;
           # proxy_buffers  4 512k;
           # proxy_buffer_size  256k;
           proxy_pass http://127.0.0.1:56559;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'Upgrade';
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-Host $host:$server_port;
           proxy_set_header X-Forwarded-Server $host;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header Host $host;
       }
   }
   ```

   

3. 加载配置并启动nginx

   ```bash
   # 加载上方填入的配置
   sudo systemctl reload nginx
   # 启动nginx
   sudo systemctl start nginx
   # 或者
   sudo systemctl restart nginx
   ```



## 安装pm2配置后台运行

通过pm2管理hnet在后台运行

```bash
# 进入项目目录
cd /root/hideipnetwork-web

#安装pm2
npm i pm2 -g

#查看是否正常安装
pm2 --version

#启动hnet
pm2 start index.mjs --name HNet

# 查看是否正常启动
pm2 status

# 如果返回内容如下则表示正常启动
root@SF04:~/hideipnetwork-web# pm2 status
┌────┬────────────────────┬──────────┬──────┬───────────┬──────────┬──────────┐
│ id │ name               │ mode     │ ↺    │ status    │ cpu      │ memory   │
├────┼────────────────────┼──────────┼──────┼───────────┼──────────┼──────────┤
│ 0  │ HNet               │ fork     │ 0    │ online    │ 0%       │ 87.2mb   │
└────┴────────────────────┴──────────┴──────┴───────────┴──────────┴──────────┘

# 使用pm2设置开机自启
pm2 save
pm2 startup
```

至此应该可以通过 `https://你的域名` 来访问HNet了.

