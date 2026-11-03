# SnailTowardThesun.github.io

程序员的刷题笔记与技术文档博客，基于 [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) 主题（chirpy-starter 结构）。

## 部署

推送到 `master` 后由 GitHub Actions 自动构建并发布到 GitHub Pages（`.github/workflows/pages-deploy.yml`）。
需要将仓库 Settings → Pages → Build and deployment → Source 设置为 **GitHub Actions**。

## 本地开发

本机使用 Podman 与仓库 Dockerfile 中的 Ruby 3.4 环境：

```bash
podman machine start  # 已运行时跳过
podman build -t localhost/jekyll-blog:latest .
podman run --rm -v "$PWD:/app" -w /app -p 4000:4000 \
  localhost/jekyll-blog:latest bundle exec jekyll serve --host 0.0.0.0
```

构建验证（与部署一致的 production 环境）：

```bash
podman run --rm -v "$PWD:/app" -w /app \
  localhost/jekyll-blog:latest bash -c 'JEKYLL_ENV=production bundle exec jekyll build'
```

## 结构约定

- `_posts/`：文章，文件名 `YYYY-MM-DD-title.md`；难度标签（简单/中等/困难）写在 front matter `tags`
- 旧站文章 URL 已完整保留：`permalink: /:categories/:year/:month/:day/:title.html`
- `/category/` 已重定向到 `/categories/`
- 头像与 favicon 位于 `assets/img/`，替换为个人图片即可

## 写新文章

在 `_posts/` 下新建 `YYYY-MM-DD-leetcode-xx-title.md`，使用以下模板。

front matter 模板：

```yaml
---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.XX: 题目名"
categories: LeetCode
tags: 中等   # 简单 / 中等 / 困难
---

> 小知识：在这里补充与题目相关的知识，不超过 100 字。

## 题目
```

注意：Jekyll 会在 Markdown 渲染前解析 Liquid，代码块和行内代码中的 `{{ }}`（如 C++ 花括号初始化）也会被解析。请将包含此类代码的区域用 `{% raw %}` 和 `{% endraw %}` 包裹，再运行构建验证。
