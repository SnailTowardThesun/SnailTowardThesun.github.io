# AGENTS.md — SnailTowardThesun.github.io（技术博客）

本仓库只包含**技术博客**一个项目：基于 Jekyll（Chirpy 主题）的刷题笔记与技术文档，部署在 GitHub Pages。与算法题解仓库（LeetCode_MyAns）的联动发布流程见上层工作区 `AGENTS.md` 及 `.agents/skills/` 技能。

---

## 核心原则

- **Logic over Tokens** — 优先生成逻辑严密的短代码，而非冗长的 AI 生成片段
- **最小变更** — 只修改必要文件，不引入无关改动
- **注释即文档** — 博客文章必须包含 "小知识" 板块
- **本地验证** — 提交/推送前必须通过 `jekyll build` 验证

---

## 项目结构

```
SnailTowardThesun.github.io/
├── _posts/                       # 博客文章（YYYY-MM-DD-title.md）
├── _data/                        # 站点数据（导航、作者信息等）
├── _plugins/                     # Jekyll 插件脚本
├── _tabs/                        # 顶部导航页面（归档/分类/关于等）
├── assets/                       # 静态资源（图片、CSS、JS）
├── category/                     # 分类归档页
├── tools/                        # 主题自带工具脚本
├── _config.yml                   # Jekyll 站点配置
├── Gemfile / Gemfile.lock        # Ruby 依赖
├── Dockerfile                    # 本地镜像定义（构建 localhost/jekyll-blog）
├── index.html                    # 首页
└── README.md
```

> 布局与样式由 `jekyll-theme-chirpy` gem 提供，仓库内**没有** `_layouts/`、`_sass/` 目录；定制通过 `_config.yml` 与 `assets/` 下自定义 SCSS 实现。

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Jekyll | 4.4（随主题 gem 约束） | 静态站点生成器 |
| jekyll-theme-chirpy | ~> 7.6 | 站点主题 |
| Ruby | 3.4（容器内） | 运行环境 |
| Podman | - | 容器化构建（本机无 docker） |
| GitHub Pages + Actions | - | 自动部署 |

---

## 构建与本地开发（一律走 podman）

本机系统 ruby 过旧跑不了 bundle，**禁止直接执行 `bundle exec jekyll ...`**；docker 未安装，容器工具是 podman。完整流程见技能 `jekyll-build-verify`。

```bash
podman machine start 2>/dev/null || true   # 确保 podman 虚拟机在运行

# 构建验证（新增/修改任何文件后、commit 前必做）
podman run --rm -v "$PWD:/app" -w /app localhost/jekyll-blog:latest bash -c "jekyll build"

# 本地预览（含 live reload）
podman run --rm -v "$PWD:/app" -w /app -p 4000:4000 \
  localhost/jekyll-blog:latest bash -c "jekyll serve --host 0.0.0.0 --port 4000"

# 仅当本地无该镜像或 Gemfile 变更时才重建（层缓存会复用，需根目录 Dockerfile）
podman build -t localhost/jekyll-blog:latest .
```

成功标志：输出末尾 `done in N seconds` 且无 `Liquid Exception`。

---

## 博客文章规范

**文件名格式**: `YYYY-MM-DD-title.md`（如 `2026-05-05-leetcode-61-rotate-list.md`），小写字母、数字、连字符。

**YAML Front Matter**（Chirpy 自动推断 post 布局，无需写 layout）:
```yaml
---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.61: 旋转链表"
categories: LeetCode
tags: [简单, 链表]
---
```

**文章结构**（按顺序，每篇必须遵循）:
1. **小知识** — YAML Front Matter 之后、正文之前，以 Markdown 引用块（`>`）形式呈现，不超过 100 字，无标题，内容与题目相关（应用场景、趣味知识、历史背景等）
2. `## 题目` — 题目名称、难度、题目描述
3. `### 示例` — 输入输出示例
4. `## 解题思路` — 算法思路、步骤详解、复杂度分析
5. `## 代码实现` — 代码块
6. （可选）扩展讨论

**小知识格式示例**:
```markdown
---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.61: 旋转链表"
categories: LeetCode
tags: [简单, 链表]
---

> 链表旋转操作在轮询调度、循环队列等场景中经常使用，可以用来实现资源的循环分配。

## 题目

...
```

**小知识要求**:
- 以 `>` 引用块格式出现，不超过 100 个中文字符
- 位置固定：YAML Front Matter 之后、第一个正文标题之前
- 内容必须与题目相关；非 LeetCode 技术文章同样适用

**标题格式**: `LeetCode刷题的日子--No.<序号>: <题目名称>`；含冒号时 YAML 中用双引号包裹。

### ⚠️ Jekyll/Liquid 模板兼容（必须）

Jekyll 会把 `{{` 解释为 Liquid 变量起始。包含双大括号的代码（C++ STL 初始化、Java Collections 等，行内反引号也触发）必须用 raw 标签包裹：

```markdown
{% raw %}
```cpp
vector<vector<int>> dirs = {{0, 1}, {0, -1}};
```
{% endraw %}
```

---

## 新文章发布 Checklist

- [ ] YAML Front Matter 格式正确（冒号用双引号包裹，含 author/title/categories/tags）
- [ ] 文件名符合 `YYYY-MM-DD-title.md` 格式
- [ ] 小知识在 Front Matter 之后以 `>` 引用块出现，不超过 100 字
- [ ] 代码块中双大括号已用 raw 标签包裹
- [ ] 构建验证通过（podman 方式 `jekyll build`，见上）
- [ ] 图片存放在 `assets/` 目录，使用相对路径引用
- [ ] 确认 `_site/` 未被加入提交（已被 gitignore，`git status` 复核）

---

## 提交规范

- **提交信息**: `[blog] Post LeetCode No.61 solution` 风格前缀
- **分支策略**: 直接在主分支提交（个人仓库）
- **文件命名**: 只使用 `README.md`（大写），不使用 `readme.md`

---

*博客仓库 Agent 指南。跨项目（算法题解→博客发布）协作见上层工作区 AGENTS.md。*
