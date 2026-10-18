# SnailTowardThesun.github.io

程序员的刷题笔记与技术文档博客，基于 [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) 主题（chirpy-starter 结构）。

## 部署

推送到 `master` 后由 GitHub Actions 自动构建并发布到 GitHub Pages（`.github/workflows/pages-deploy.yml`）。
需要将仓库 Settings → Pages → Build and deployment → Source 设置为 **GitHub Actions**。

## 本地开发

需要 Ruby 3.1+（3.4 与 CI 一致）：

```bash
bundle install
bundle exec jekyll serve   # http://localhost:4000
```

或使用官方 Docker 镜像：

```bash
docker run --rm -v "$PWD:/srv/jekyll" -p 4000:4000 amirpourmand/alpine-chirpy
```

## 结构约定

- `_posts/`：文章，文件名 `YYYY-MM-DD-title.md`；难度标签（简单/中等/困难）写在 front matter `tags`
- 旧站文章 URL 已完整保留：`permalink: /:categories/:year/:month/:day/:title.html`
- `/category/` 已重定向到 `/categories/`
- 头像与 favicon 位于 `assets/img/`，替换为个人图片即可

## 写新文章

```bash
bundle exec jekyll compose "leetcode-xx-title"  # 需要 jekyll-compose，或直接新建文件
```

front matter 模板：

```yaml
---
title: "LeetCode刷题的日子--No.XX: 题目名"
categories: LeetCode
tags: 中等   # 简单 / 中等 / 困难
---
```

注意：正文代码中如有 `{{ }}`（C++ 花括号初始化等），Jekyll 会原样保留，无需处理；真正的 Liquid 输出请用 `{% raw %}` 包裹。
