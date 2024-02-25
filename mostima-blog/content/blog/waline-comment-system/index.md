---
title: "Hugo 博客添加 Waline 评论系统"
date: "2024-02-24"
draft: false
descrition: "waline comment system"
slug: "waline-comment-system"
tags: ["Waline", "Hugo"]
---

Waline 是一款简洁，安全的评论系统。它支持完整的 Markdown 语法，同时包含表情，数学公式， HTML嵌入等。

在允许匿名评论的基础上支持账号登录，可以有效保持身份。并且允许使用 Vercel 免费，且简洁方便的部署。

## 配置方式

### LeanCLoud 设置（数据库）

1. {{< button href="https://console.leancloud.app/login" target="_blank" >}}&nbsp;登录{{< /button >}}&nbsp;或&nbsp;{{< button href="https://console.leancloud.app/register" target="_blank" >}}注册&nbsp;{{< /button >}}

2. 点击左上角 [创建应用](https://console.leancloud.app/apps) 并起一个名字 (选择免费的**开发版**）

   ![](waline1.png)

3. 进入刚刚创建的应用，点击左下角的 `设置`，然后选择 `应用凭证`，此时你会看到你的 `AppID`, `AppKey` 以及 `MasterKey`. 请妥善记录他们，后续将会使用。

   ![](waline2.png)

{{< alert >}}

**注意**： 如果你正在使用 Leancloud 国内版 ([leancloud.cn](https://leancloud.cn/))，推荐你切换到国际版 ([leancloud.app](https://leancloud.app/))。否则，你需要为应用绑定**已备案**的域名

{{< /alert >}}

---

{{< alert icon="fire" cardColor="#e63946" iconColor="#1d3557" textColor="#f1faee" >}}
未完待续
{{< /alert >}}

