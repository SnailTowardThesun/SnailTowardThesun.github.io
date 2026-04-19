# SnailTowardThesun.github.io

程序员的刷题笔记与技术文档博客。

## 使用 Docker 运行开发环境

由于本机 Ruby 环境可能与 GitHub Pages 不兼容，推荐使用 Docker 进行本地开发调试。

### 快速启动

```bash
docker run --rm -v "$PWD:/app" -w /app -p 4000:4000 ruby:3.4 /bin/bash -c "bundle install && bundle exec jekyll serve --host 0.0.0.0 --port 4000"
```

### 首次运行

首次运行时需要安装依赖，后续可以直接启动：

```bash
# 创建 Gemfile.lock
docker run --rm -v "$PWD:/app" -w /app ruby:3.4 bash -c "bundle lock"

# 安装依赖
docker run --rm -v "$PWD:/app" -w /app ruby:3.4 /bin/bash -c "bundle install"

# 启动服务
docker run --rm -v "$PWD:/app" -w /app -p 4000:4000 ruby:3.4 /bin/bash -c "bundle exec jekyll serve --host 0.0.0.0 --port 4000"
```

### 访问

启动后访问 http://localhost:4000

### 常用命令

```bash
# 构建静态文件
docker run --rm -v "$PWD:/app" -w /app ruby:3.4 /bin/bash -c "bundle exec jekyll build"

# 启用 live reload
docker run --rm -v "$PWD:/app" -w /app -p 4000:4000 -p 35729:35729 ruby:3.4 /bin/bash -c "bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload"
```

## 技术栈

- Jekyll 4.3
- GitHub Pages
- Bootstrap 3
- SCSS
