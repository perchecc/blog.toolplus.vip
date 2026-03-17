---
title: 'Mac M3 用 Chrome DevTools 调试安卓真机网页'
description: '最简四步教程：Mac 连接安卓手机，用 Chrome DevTools 实时调试手机上的网页样式'
publishDate: '2026-03-17'
tags: ['调试', 'Chrome DevTools', 'Android', 'Mac', 'ADB']
---

## 1. 手机开启开发者选项

打开「设置 → 关于手机」，狂点**版本号 7 下**，开启「开发者选项」。

进入开发者选项，打开：

- **USB 调试**
- **USB 调试（安全设置）**（有的话也打开）

## 2. Mac 安装 ADB 工具

终端运行一行命令：

```bash
brew install android-platform-tools
```

> 没装 Homebrew？访问 https://brew.sh 先装一下。

## 3. 连接手机

1. 用数据线连接手机和 Mac
2. 手机弹出「允许这台电脑调试」→ 点**允许**
3. 终端验证连接：

```bash
adb devices
```

出现类似 `XXXXXXXX device` 就成功了。

![image-20260317161544781](https://imgs.shuxitech.com/image-20260317161544781.png)



## 4. Chrome 开始调试

电脑 Chrome 打开：

```
chrome://inspect
```

你手机上打开的网页会直接显示出来，点 **inspect** → 弹出的面板就是真机的真实样式面板。

---

完事，四步搞定真机调试。
