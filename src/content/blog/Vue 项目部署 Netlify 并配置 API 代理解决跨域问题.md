---
title: "Vue 项目部署 Netlify 并配置 API 代理解决跨域问题"
description: "介绍如何在 Netlify 上部署 Vue 项目，并通过 netlify.toml 配置 API 代理转发，轻松解决前端开发中的跨域问题。"
publishDate: 2025-03-16
tags: ["vue", "netlify", "deploy", "proxy", "cors", "frontend", "toml"]
---

## 前言

在 Vue 项目开发中，前端应用通常需要调用后端 API。当项目部署到 Netlify 后，如果后端 API 位于不同的域名下，就会遇到**跨域（CORS）**问题。本文介绍如何通过 `netlify.toml` 配置文件，在 Netlify 上实现无缝的 API 代理转发。

## 配置示例

```toml
[build]
  command = "npm run build"
  publish = "dist"

[[redirects]]
  from = "/farm_server/*"
  to = "https://pre.shuxitech.com/farm_server/:splat"
  status = 200
  force = true
```

## 配置项详解

### [build] 区块

| 配置项 | 说明 |
|--------|------|
| `command` | 构建命令，执行 `npm run build` 生成生产环境代码 |
| `publish` | 指定构建输出目录，Vue 项目默认输出到 `dist` 文件夹 |

### [[redirects]] 区块

| 配置项 | 说明 |
|--------|------|
| `from` | 匹配的路径模式，`/farm_server/*` 表示匹配所有以 `/farm_server/` 开头的请求 |
| `to` | 目标地址，`:splat` 表示将通配符匹配的内容原样传递到目标 URL |
| `status` | HTTP 状态码，`200` 表示 rewrite（重写），而非 redirect（重定向） |
| `force` | 强制应用此规则，即使目标路径存在静态文件也优先匹配 |

## 解决了什么问题？

### 1. 跨域问题（CORS）

浏览器同源策略会阻止前端直接请求不同域名的 API。通过 Netlify 代理，前端代码只需请求同域名的 `/farm_server/xxx`，Netlify 服务器会自动转发到目标 API 服务器，从而**绕过浏览器跨域限制**。

### 2. 环境统一

本地开发时使用 `vite.config.ts` 配置代理，生产环境使用 `netlify.toml` 配置代理，保持代码一致性，无需修改 API 调用逻辑。

### 3. 隐藏真实 API 地址

对外暴露的是 `/farm_server/` 路径，真实后端地址不会直接暴露给客户端。

## 使用场景

- ✅ Vue/React/Angular 等前端项目部署到 Netlify
- ✅ 需要调用第三方或独立部署的后端 API
- ✅ 希望前后端分离部署但避免跨域问题
- ✅ 需要统一本地开发和生产环境的 API 调用方式

## 注意事项

1. `:splat` 是 Netlify 的通配符占位符，会将 `from` 中 `*` 匹配的内容原样附加到 `to` 地址
2. `status = 200` 表示 rewrite，浏览器地址栏不会发生变化
3. 如需多条代理规则，可添加多个 `[[redirects]]` 区块

## 总结

通过简单的 `netlify.toml` 配置，即可在 Netlify 上实现 Vue 项目的自动化构建部署和 API 代理转发，是解决前端跨域问题的优雅方案。