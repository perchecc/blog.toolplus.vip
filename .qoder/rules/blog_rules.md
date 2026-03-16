---
trigger: always_on
---

# Astro 博客项目规范

## 项目概述

- 基于 **Astro 5** 框架的博客站点，主题包为 `astro-pure 1.4.0`
- 部署平台：**Vercel**（`@astrojs/vercel` 适配器，`output: 'server'`）
- 站点地址：`https://blog.toolplus.vip`

## 技术栈

| 类别 | 技术 |
| --- | --- |
| 框架 | Astro 5.16.6 |
| 语言 | TypeScript 5.9.3（strict 模式） |
| 样式 | UnoCSS（presetMini + presetTypography），CSS 变量主题色 |
| 内容 | Astro Content Collections（glob loader），Markdown / MDX |
| Markdown 扩展 | remark-math + rehype-katex（数学公式），自定义 Shiki 代码高亮 |
| 搜索 | Pagefind（需 prerender 启用） |
| 评论 | Waline |
| 包管理 | bun（workspace 模式，`packages/*`） |
| 代码格式化 | Prettier + prettier-plugin-astro + @ianvs/prettier-plugin-sort-imports |
| Lint | ESLint + eslint-plugin-astro |

## 项目结构

```
src/
  assets/styles/     # 全局样式（global.css、app.css）
  components/        # 业务组件（按功能分目录：home/、links/、waline/ 等）
  content/blog/      # 博客文章（Markdown/MDX）
  layouts/           # 布局组件（BaseLayout、BlogPost、ContentLayout 等）
  pages/             # 页面路由（Astro 文件路由）
  plugins/           # 本地 Rehype/Shiki 插件
  content.config.ts  # 内容集合定义
  site.config.ts     # 站点配置（主题、集成、页面数据）
packages/pure/       # astro-pure 主题包（workspace 子包）
```

## 路径别名

在 `tsconfig.json` 中定义，代码中必须使用这些别名：

| 别名 | 路径 |
| --- | --- |
| `@/assets/*` | `src/assets/*` |
| `@/components/*` | `src/components/*` |
| `@/layouts/*` | `src/layouts/*` |
| `@/utils` | `src/utils/index.ts` |
| `@/plugins/*` | `src/plugins/*` |
| `@/pages/*` | `src/pages/*` |
| `@/types` | `src/types/index.ts` |
| `@/site-config` | `src/site.config.ts` |

主题包组件通过 `astro-pure/*` 导入：
- `astro-pure/components/basic` — Header, Footer, ThemeProvider
- `astro-pure/components/pages` — PostPreview, TOC, Hero, Copyright 等
- `astro-pure/user` — Button, Card, Icon, Label 等用户组件
- `astro-pure/advanced` — Quote, MediumZoom, GithubCard 等
- `astro-pure/server` — getBlogCollection, sortMDByDate 等服务端工具
- `astro-pure/utils` — cn, clsx 等工具函数
- `astro-pure/types` — 类型定义

## 导入排序（Prettier 自动处理）

顺序：astro 核心 → @astrojs → 第三方 → astro-pure → @/ 别名 → 相对路径

## 命名规范

- 文件名：`kebab-case`（如 `rehype-auto-link-headings.ts`）
- Astro 组件：`PascalCase`（如 `BlogPost.astro`、`PostPreview.astro`）
- 变量名：`camelCase`
- 常量名：`UPPER_SNAKE_CASE`
- 类名/接口名：`PascalCase`

## 代码格式化规则

- 无分号（`semi: false`）
- 单引号（`singleQuote: true`）
- 缩进 2 空格
- 行宽 100 字符
- 无尾逗号（`trailingComma: 'none'`）
- 箭头函数总是加括号（`arrowParens: 'always'`）
- 换行符 `lf`

## Astro 组件编写规范

- 使用 `---` 围栏块编写 frontmatter（服务端逻辑、导入、Props 定义）
- Props 使用 `interface Props` 定义类型
- 模板中使用 UnoCSS 类名，配合 `cn()` 工具合并类名
- 动画使用 `animate` 类（全局 `fade-in-up` 动画）

```astro
---
import { cn } from 'astro-pure/utils'

interface Props {
  title: string
  class?: string
}

const { title, class: className } = Astro.props
---

<div class={cn('animate', className)}>
  <h1>{title}</h1>
</div>
```

## 内容集合

- 博客文章放在 `src/content/blog/`，文件名格式：`YYYY-MM-DD-标题.md`
- 使用 `glob` loader 加载，schema 通过 Zod 定义
- 必填字段：`title`（≤60）、`description`（≤160）、`publishDate`
- 可选字段：`updatedDate`、`heroImage`、`tags`、`language`、`draft`、`comment`

## 常用命令

| 命令 | 说明 |
| --- | --- |
| `bun dev` | 启动开发服务器 |
| `bun run build` | 构建（含 astro-pure check + astro check） |
| `bun run preview` | 预览构建结果 |
| `bun run format` | Prettier 格式化 |
| `bun run lint` | ESLint 检查 |
| `bun run sync` | 同步 Astro 类型 |

## 注释规范

### 函数注释

- 使用 JSDoc 风格，包含功能描述、参数说明及返回值类型
- 示例：

```ts
/**
 * 计算商品总价
 * @param price 单价
 * @param quantity 数量
 * @returns 总价
 */
const calculateTotal = (price: number, quantity: number): number => {
  return price * quantity
}
```

### 临时禁用标记

- 注释掉的功能代码需添加 `[临时禁用]` 标记并说明原因
- 禁止直接删除暂时不需要的功能代码，应注释保留

## AI 回答规范

- 直接给出解决方案，不添加总结性话语和客套话
- 回答简洁明了，重点突出
- 生成的代码应立即可用，包含必要的类型定义和导入
- 遵循项目既定的代码规范
- 不添加"以上代码实现了..."之类的解释
