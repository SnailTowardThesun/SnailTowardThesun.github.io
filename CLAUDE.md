# CLAUDE.md — SnailTowardThesun.github.io 博客

技术博客网站，专注于分享算法、编程和技术相关内容，基于 Jekyll（Chirpy 主题）构建并部署在 GitHub Pages 上。

## 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Jekyll | 4.4（随主题 gem 约束） | 静态站点生成器 |
| jekyll-theme-chirpy | ~> 7.6 | 站点主题（布局/样式由 gem 提供） |
| Ruby | 3.4（容器内） | 运行环境 |
| Podman | - | 容器化构建（本机无 docker） |
| GitHub Pages + Actions | - | 自动部署 |

## 关键目录

| 目录/文件 | 用途 |
|------|------|
| `_posts/` | 博客文章（`YYYY-MM-DD-title.md`） |
| `_data/` | 站点数据（导航、作者信息等） |
| `_plugins/` | Jekyll 插件脚本 |
| `_tabs/` | 顶部导航页面（归档/分类/关于等） |
| `assets/` | 静态资源（图片、CSS、JS） |
| `_config.yml` | Jekyll 站点配置 |
| `Gemfile` | Ruby 依赖（jekyll-theme-chirpy ~> 7.6） |
| `Dockerfile` | 本地镜像定义（`localhost/jekyll-blog`） |

> 仓库内没有 `_layouts/`、`_sass/` 目录——布局与样式由主题 gem 提供，定制走 `_config.yml` 和 `assets/` 自定义 SCSS。

## 重要命令（一律走 podman）

本机系统 ruby 过旧（2.6）跑不了 bundle，**禁止直接执行 `bundle exec jekyll ...`**；docker 未安装。

```bash
podman machine start 2>/dev/null || true   # 确保 podman 虚拟机在运行

# 构建验证（提交/推送前必做）
podman run --rm -v "$PWD:/app" -w /app localhost/jekyll-blog:latest bash -c "jekyll build"

# 本地预览（含 live reload）
podman run --rm -v "$PWD:/app" -w /app -p 4000:4000 \
  localhost/jekyll-blog:latest bash -c "jekyll serve --host 0.0.0.0 --port 4000"

# 仅当本地无镜像或 Gemfile 变更时才重建（需根目录 Dockerfile，层缓存会复用）
podman build -t localhost/jekyll-blog:latest .
```

成功标志：输出末尾 `done in N seconds` 且无 `Liquid Exception`。

## 编码规范

- **博客文章**：使用 Markdown 格式，文件名格式为 `YYYY-MM-DD-title.md`（小写字母、数字、连字符）
- **LeetCode 文章标题**：`LeetCode刷题的日子--No.<序号>: <题目名称>`，含冒号时 YAML 中用双引号包裹
- **YAML Front Matter**：`author` / `title` / `categories` / `tags`（Chirpy 自动推断 post 布局，无需写 layout）
- **小知识**：紧跟 YAML Front Matter 之后、正文之前，单行 `>` 引用块，不超过 100 字，无标题，内容与题目相关
- **图片**：存放在 `assets/` 目录下，按年份/主题组织，相对路径引用
- **链接**：使用相对路径或完整 URL，确保可访问性

## Jekyll/Liquid 模板注意事项 ⚠️

**重要**：Jekyll 使用 Liquid 模板引擎，会将 `{% raw %}{{% endraw %}` 解释为变量起始标记。

### 问题场景
当博客文章中包含 C++/Java 等使用双大括号 `{% raw %}{{% endraw %}}` 初始化语法的代码时（如 `{% raw %}vector<vector<int>> dirs = {{0, 1}, {0, -1}}{% endraw %}`），Jekyll 构建会报错：
```
Liquid Exception: Variable '{% raw %}{{0, 1}{% endraw %}' was not properly terminated with regexp: /\}\}/
```

### 解决方案
在包含 `{% raw %}{{% endraw %}` 的代码块前后使用 `{% raw %}` 和 `{% endraw %}` 标签：

```markdown
{% raw %}
```cpp
vector<vector<int>> dirs = {{0, 1}, {0, -1}};
```
{% endraw %}
```

### 需要注意的场景
- C++ STL 容器初始化：`{% raw %}vector<vector<int>>{{...}, {...}}{% endraw %}`
- Java Collections初始化
- 任何使用双大括号的代码示例
- 即使在行内代码中（反引号包裹）也会触发此错误

### 建议
编写完博客后，用 podman 方式 `jekyll build` 本地验证构建成功后再推送（见上方命令）。

## 部署信息

- **部署平台**：GitHub Pages
- **域名**：https://SnailTowardThesun.github.io
- **构建方式**：GitHub Actions 自动构建
- **分支**：主分支自动部署

## 开发流程

1. **环境准备**：`podman machine start`（如未运行）
2. **内容创作**：在 `_posts/` 目录创建新的博客文章（遵循上方规范）
3. **构建测试**：podman 方式运行 `jekyll build` 确保构建成功
4. **部署**：推送到 GitHub 主分支，自动部署到 GitHub Pages
