---
title: "基于 Docker 部署 Mattermost"
date: 2024-01-06
draft: false
description: "基于 Docker 部署 Mattermost."
slug: "Mattermost"
tags: ["Mattermost", "Docker"]
---

本文记录如何使用 Docker 私有化部署可于生产环境中使用的Mattermost的方法.

## Mattermost 介绍

[Mattermost](https://mattermost.com/) 是一个灵活的开源、可自行架设的[在线聊天服务](https://zh.wikipedia.org/wiki/网络聊天)，有分享文件、搜索与集成其他服务等功能。可用于内网聊天, 自建聊天服务等. 客户端支持全平台终端, 方便且易于使用.

![1](featured.png)

## 安装 Docker 及 Docker compose

我使用 Debian, 故以下内容将基于 Debian, 如果您使用其他系统, 请自行查询如何安装. 

### 安装 Docker

1. 更新软件包索引

   ```shell
   sudo apt update
   ```

2. 安装所需的包以允许 `apt` 通过 HTTPS 使用仓库

   ```bash
   sudo apt install apt-transport-https ca-certificates curl software-properties-common
   ```

3. 添加 Docker 官方 GPG 密钥

   ```bash
   curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
   ```

4. 设置 Docker 仓库

   ```bash
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
   ```

5. 再次更新软件包索引

   ```bash
   sudo apt update
   ```

6. 安装 Docker CE

   ```bash
   sudo apt install docker-ce
   ```

7. 验证 Docker 安装是否成功

   ```bash
   sudo systemctl status docker
   ```

   如果出现以下内容, 则表示安装成功

   ```
   ➜  ~ systemctl status docker
   ● docker.service - Docker Application Container Engine
        Loaded: loaded (/lib/systemd/system/docker.service; enabled; preset: enabled)
        Active: active (running) since Fri 2024-01-05 14:32:54 UTC; 6min ago
   TriggeredBy: ● docker.socket
          Docs: https://docs.docker.com
      Main PID: 6403 (dockerd)
         Tasks: 8
        Memory: 37.4M
           CPU: 351ms
        CGroup: /system.slice/docker.service
                └─6403 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
   ```



### 安装 Docker Compose

1. 下载 Docker Compose 的当前稳定版本

   ```bash
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   ```

   {{< alert >}}

   注意: 本文撰写时最新稳定版本为 v2.23.3, 建议检查 [Docker compose github](https://github.com/docker/compose/releases) 页面以获取最新版本

   {{< /alert >}}

2. 赋予二进制文件可执行权限

   ```bash
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. 测试安装

   ```bash
   docker-compose --version
   ```

   如出现以下内容, 则表示安装成功

   ```
   Docker Compose version v2.23.3
   ```

   

## 部署 Mattermost

1. Clone 官方的仓库 & 进入目录

   ```bash
   git clone https://github.com/mattermost/docker
   cd docker
   ```

2. 创建 `.env` 文件

   在 `docer` 目录下, 存在于一个默认文件, 名字为 `env.example`, 将其 copy 为我们的 `.env` 文件

   ```bash
   cp env.example .env
   ```

3. 修改 `.env` 文件

   {{< alert >}}

   注意: 本文撰写时Mattermost最新的版本号为 9.3.0

   {{< /alert >}}

   1. 如果你有域名, 可以将 `DOMAIN=mm.example.com` 中的域名修改为你的域名

   2. 由于默认使用的是企业版, 如果需要使用社区版请将变量 ` MATTERMOST_IMAGE` 修改为 `mattermost-team-edition` , 即

      ```bash
      # 将 mattermost-enterprise-edition
      MATTERMOST_IMAGE=mattermost-enterprise-edition
      
      # 修改为
      MATTERMOST_IMAGE=mattermost-team-edition
      ```

   3. 修改需要部署的版本

      将变量 `MATTERMOST_IMAGE_TAG` 后的版本号修改为所需要安装的版本号, 例如:

      ```bash
      MATTERMOST_IMAGE_TAG=9.3.0
      ```

      

4. 创建所需的目录并设置其权限

   ```bash
   mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes}\
   
   sudo chown -R 2000:2000 ./volumes/app/mattermost
   ```

5. 部署 Mattermost

   ```bash
   sudo docker compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d
   ```

现在应该可以使用 `http://<你的IP>:8065` 来访问你的Mattermost了.



### 配置反向代理

1. 安装 Nginx

   ```bash
   sudo apt intsall nginx
   ```

2. 在目录 `/etc/nginx/conf.d` 中创建文件 `mm.conf`

   ```bash
   sudo touch /etc/nginx/conf.d/mm.conf
   ```

3. 在 `mm.conf` 中写入配置内容, 例如:

   ```nginx
   server {
       listen 443 ssl; # 如果有其他进程在运行导致443被占用可以修改为任意其他端口, 但记住将防火墙中对应端口打开
       server_name your.domain.com; # 填入DNS解析好的域名
   
       ssl_certificate /your/cert/path; # ssl证书公钥路径
       ssl_certificate_key /your/key/path; # ssl证书密钥路径
   
       # 请求体的最大大小, 适用于大文件上传
       client_max_body_size 100M;
   
       # 设置较长的超时时间，对于文件上传
       proxy_read_timeout 300s;
       proxy_connect_timeout 300s;
   
       # 调整缓冲区大小
       proxy_buffers 16 16k;
       proxy_buffer_size 32k;
       
       location / {
           proxy_pass http://127.0.0.1:8065;
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

4. 加载配置

   ```bash
   sudo systemctl reload nginx
   ```

5. 启动 nginx 服务

   ```bash
   # 启动 nginx
   sudo systemctl start nginx
   
   # 或 重启 nginx
   sudo systemctl restart nginx
   ```

   

