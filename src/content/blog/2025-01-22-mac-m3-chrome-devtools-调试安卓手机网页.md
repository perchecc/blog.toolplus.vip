---
title: 'Mac M3 用 Chrome DevTools 调试安卓真机网页'
description: '最简四步教程：Mac 连接安卓手机，用 Chrome DevTools 实时调试手机上的网页样式'
publishDate: 2025-01-22
tags: ['调试', 'Chrome DevTools', 'Android', 'Mac']
---

## 1. 手机开启 USB 调试

打开「设置 → 关于手机」，狂点版本号 **7 下**，开启「开发者选项」。

进入开发者选项，打开：

- **USB 调试**
- **USB 调试（安全设置）**（有的话也打开）

## 2. Mac 安装 adb 工具

终端执行：

```bash
brew install android-platform-tools
```

> 没装 Homebrew？先跑这行：`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

## 3. 数据线连接

用数据线连接手机和 Mac，手机会弹窗询问「允许这台电脑调试」→ 点 **允许**。

终端验证连接：

```bash
adb devices
```

出现类似 `XXXXXXXX device` 就成功了。

## 4. Chrome 调试

电脑 Chrome 地址栏输入：

```
chrome://inspect
```

手机上打开的网页会显示在列表里，点 **inspect** → 弹出的面板就是真机的 DevTools，实时查看和修改样式。
