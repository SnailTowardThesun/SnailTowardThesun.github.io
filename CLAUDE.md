# For Good Future - 博客网站

技术博客网站，专注于分享算法、编程和技术相关内容，基于Jekyll构建并部署在GitHub Pages上。

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Jekyll | ~> 4.3 | 静态站点生成器 |
| Minima | ~> 2.5 | 默认主题 |
| Ruby | 3.4 | 运行环境 |
| Sass | - | CSS预处理器 |
| Docker | - | 容器化环境 |
| GitHub Pages | - | 部署平台 |

## 关键目录

| 目录 | 用途 |
|------|------|
| `_posts/` | 博客文章（Markdown格式） |
| `_layouts/` | 页面布局模板 |
| `_sass/` | Sass样式文件 |
| `assets/` | 静态资源（图片、CSS等） |
| `docker/` | Docker相关配置 |

## 重要命令

```bash
# 本地开发服务器
bundle exec jekyll serve

# 构建静态站点
bundle exec jekyll build

# Docker构建
docker build -f Dockerfile.local -t blog .

# Docker运行
docker run -p 4000:4000 blog
```

## 编码规范

- **博客文章**：使用Markdown格式，文件名格式为 `YYYY-MM-DD-title.md`
- **LeetCode文章**：标题格式为 `LeetCode刷题的日子--No.<序号>: <题目名称>`，例如 `LeetCode刷题的日子--No.2078: Two Furthest Houses With Different Colors`
- **代码块**：使用Markdown代码围栏，指定语言以获得语法高亮
- **图片**：存放在 `assets/` 目录下，按年份/主题组织
- **链接**：使用相对路径或完整URL，确保可访问性

## 部署信息

- **部署平台**：GitHub Pages
- **域名**：https://SnailTowardThesun.github.io
- **构建方式**：GitHub Actions自动构建
- **分支**：主分支自动部署

## 特殊说明

- 遵循 `AGENTS.md` 中的协作协议，采用"Vibe Coding, Logical Execution"原则
- 内容主题主要涵盖算法、C++、AI等技术领域
- 保持代码示例的准确性和可执行性
- 定期更新依赖以确保安全性和性能

## 开发流程

1. **本地开发**：使用 `bundle exec jekyll serve` 启动本地服务器
2. **内容创作**：在 `_posts/` 目录创建新的博客文章
3. **构建测试**：运行 `bundle exec jekyll build` 确保构建成功
4. **部署**：推送到GitHub主分支，自动部署到GitHub Pages