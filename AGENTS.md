# AGENTS.md — 单仓库双项目协作指南

本仓库是一个 **Monorepo**，包含两个独立项目。AI Agent 在操作前必须先确认当前工作目录属于哪个项目，并遵循对应规范。

---

## 项目概览

| 项目 | 路径 | 类型 | 语言/技术 | 用途 |
|------|------|------|-----------|------|
| **LeetCode_MyAns** | `LeetCode_MyAns/` | 算法题解 | C++17, Rust | LeetCode 题目解答与测试 |
| **SnailTowardThesun.github.io** | `SnailTowardThesun.github.io/` | 技术博客 | Jekyll, Markdown, SCSS | 刷题笔记与技术文档 |

---

## 核心原则

- **Logic over Tokens** — 优先生成逻辑严密的短代码，而非冗长的 AI 生成片段
- **精确操作** — 修改文件前先确认路径归属哪个项目，避免跨项目污染
- **注释即文档** — 新题和博客必须包含完整注释/说明，缺一不可
- **本地验证** — 推送前必须通过构建和测试验证

---

## 项目一：LeetCode_MyAns（算法题解）

### 项目结构

```
LeetCode_MyAns/
├── cplusplus/                    # C++ 题解（CMake + Google Test）
│   ├── questions/                # 每日一题（按编号命名，如 1.cpp）
│   ├── top150/                   # 面试经典 150 题
│   │   ├── array/                # 数组类题目
│   │   ├── double_pointer/       # 双指针类题目（如有）
│   │   └── string/               # 字符串类题目
│   ├── CMakeLists.txt            # CMake 构建配置
│   └── README.md
├── rust/                         # Rust 题解（Cargo Workspace）
│   ├── ans/                      # 主答案模块
│   │   └── questions/            # 按题号命名的 .rs 文件
│   ├── baseAlgorithm/            # 基础算法练习
│   │   └── src/main.rs           # 排序等基础算法
│   └── Cargo.toml                # Workspace 配置
├── .clang-format                 # C++ 格式化配置
├── package.json                  # Turborepo 根配置
├── turbo.json                    # Turbo 任务定义
└── README.md
```

### 构建与测试命令

```bash
# === Turborepo 顶层命令（在 LeetCode_MyAns/ 下执行）===
npm install                          # 安装依赖
npm run build                       # 构建所有子项目
npm run test                        # 运行所有测试
npm run lint                        # 运行所有格式化

# === C++ 项目（在 cplusplus/ 下执行）===
mkdir -p build && cd build
cmake ..
make
./tests                            # 运行测试
ctest --verbose                    # 详细测试输出
clang-format -i questions/*.cpp    # 格式化代码

# === Rust 项目（在 rust/ 下执行）===
cargo build                        # 构建
cargo test                         # 运行测试
cargo test test_two_sum            # 运行指定测试
cargo fmt                          # 格式化代码
cargo clippy                       # 代码检查
```

### C++ 编码规范

- **标准**: C++17，编译标志 `-g -std=c++17 -Wall`
- **CMake**: 最低版本 3.28，通过 FetchContent 自动下载 Google Test
- **缩进**: 4 空格，不使用 Tab（遵循 `.clang-format` 的 Google 风格）
- **行宽**: 120 字符
- **命名**:
  - 类名: `PascalCase`（如 `Solution`）
  - 函数/变量: `snake_case`（如 `two_sum`, `max_length`）
- **文件命名**:
  - 每日一题: `题号.cpp`（如 `1.cpp`, `3643.cpp`）
  - Top150: `top150_题号.cpp`（如 `top150_no121_best_time_to_buy_sell_stock.cpp`）
- **注释要求**（文件头部，中文）:
  - `@题目描述`: 完整题目内容
  - `@示例`: 输入输出示例
  - `@解题思路`: 算法思路、步骤、复杂度分析
- **测试**: 使用 `TEST(Daily, 题号)` 格式，包含基本和边界用例

### C++ 避免事项

- 不要在头文件中使用 `using namespace std;`
- 避免裸指针，优先使用智能指针
- 不要提交编译产物（`.gitignore` 已配置）
- 避免硬编码魔法数字
- 不要使用已废弃的 C++ 特性

### Rust 编码规范

- **标准**: 最新稳定版 Rust
- **缩进**: 4 空格
- **命名**:
  - 函数/变量: `snake_case`
  - 结构体/枚举: `PascalCase`
  - 常量: `SCREAMING_SNAKE_CASE`
- **文件组织**: 按题号命名 `.rs` 文件（如 `2389.rs`），放在 `ans/questions/`
- **测试**: 使用 `#[test]` 属性，测试函数与源码放在同一文件
- **文档**: 使用 `///` 为公共 API 添加文档注释
- **Workspace**: `ans` 和 `baseAlgorithm` 两个成员

### 新题提交 Checklist

- [ ] 代码注释完整（题目描述 + 解题思路 + 示例，中文）
- [ ] 测试用例包含基本场景和边界条件
- [ ] C++ 代码通过 `clang-format` 格式化
- [ ] Rust 代码通过 `cargo fmt` 和 `cargo clippy` 检查
- [ ] 构建通过且测试全部通过
- [ ] 文档文件命名为 `README.md`（不是 `readme.md`）

---

## 项目二：SnailTowardThesun.github.io（技术博客）

### 项目结构

```
SnailTowardThesun.github.io/
├── _posts/                       # 博客文章（Markdown）
├── _layouts/                     # 页面布局模板
├── _sass/                        # Sass 样式
├── assets/                       # 静态资源（图片、CSS）
├── category/                     # 分类页面
├── docker/                       # Docker 配置
├── _config.yml                   # Jekyll 配置
├── Gemfile / Gemfile.lock        # Ruby 依赖
├── index.html                    # 首页
├── 404.html                      # 404 页面
├── Dockerfile.local              # 本地 Docker 镜像
├── .editorconfig                 # 编辑器配置
└── README.md
```

### 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Jekyll | ~> 4.3 | 静态站点生成器 |
| Minima | ~> 2.5 | 默认主题 |
| Ruby | 3.4 | 运行环境 |
| Sass | - | CSS 预处理器 |
| Docker/Podman | - | 容器化开发 |
| GitHub Pages | - | 自动部署 |

### 构建与部署命令

```bash
# === 本地开发（需 Ruby 环境）===
bundle exec jekyll serve           # 启动开发服务器（含 live reload）
bundle exec jekyll build           # 构建静态站点
bundle exec jekyll clean           # 清理构建产物

# === Docker 方式（推荐）===
docker run --rm -v "$PWD:/app" -w /app -p 4000:4000 \
  ruby:3.4 /bin/bash -c "bundle install && bundle exec jekyll serve --host 0.0.0.0 --port 4000"

# === 构建验证（推送前必做）===
docker run --rm -v "$PWD:/app" -w /app ruby:3.4 \
  /bin/bash -c "bundle exec jekyll build"

# === Podman 替代方案 ===
podman run --rm -v "$PWD:/app" -w /app -p 4000:4000 \
  ruby:3.4 /bin/bash -c "bundle install && bundle exec jekyll serve --host 0.0.0.0 --port 4000"
```

### 博客文章规范

**文件名格式**: `YYYY-MM-DD-title.md`（如 `2026-05-05-leetcode-61-rotate-list.md`）

**YAML Front Matter**:
```yaml
---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.61: 旋转链表"
categories: LeetCode
---
```

**文章结构**（按顺序，每篇必须遵循）:
1. **小知识** — YAML Front Matter 之后、正文之前，以 Markdown 引用块（`>`）形式呈现，不超过 100 字，内容与题目相关（应用场景、趣味知识、历史背景等）
2. `## 题目` — 题目名称、难度、题目描述
3. `### 示例` — 输入输出示例
4. `## 解题思路` — 算法思路、步骤详解、复杂度分析
5. `## 代码实现` — 代码块
6. （可选）扩展讨论

### 小知识格式示例

```markdown
---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.61: 旋转链表"
categories: LeetCode
---

> 链表旋转操作在轮询调度、循环队列等场景中经常使用，可以用来实现资源的循环分配。

## 题目

...
```

**小知识要求**:
- 以 `>` 引用块格式出现
- 不超过 100 个中文字符
- 内容必须与题目相关（应用场景、趣味知识、算法背景等）
- 位置：YAML Front Matter 之后、第一个正文标题之前
- 非 LeetCode 技术文章同样适用（如算法笔记、技术总结等）

**标题格式**: `LeetCode刷题的日子--No.<序号>: <题目名称>`
- 含冒号时，YAML 中需用双引号包裹：`title: "LeetCode刷题的日子--No.61: 旋转链表"`

### ⚠️ Jekyll/Liquid 模板兼容（必须）

Jekyll 使用 Liquid 模板引擎，会将左花括号解释为变量起始标记。包含双大括号的代码必须用特殊标签包裹：

**需包裹的场景**:
- C++ STL 容器初始化
- Java/C++ 匿名对象初始化
- 任何使用双大括号的代码（即使行内反引号也触发）

### 编辑器配置

`.editorconfig` 定义了全局格式规则:
- 编码: UTF-8，换行: LF
- 缩进: 2 空格
- Markdown 文件保留尾部空格（用于排版控制）

### 新文章发布 Checklist

- [ ] YAML Front Matter 格式正确（冒号用双引号包裹）
- [ ] 文件名符合 `YYYY-MM-DD-title.md` 格式
- [ ] 代码块中 `{{` 已用 `{% raw %}...{% endraw %}` 包裹
- [ ] 小知识在 YAML Front Matter 之后以 `>` 引用块格式出现，不超过 100 字
- [ ] 本地构建验证通过（`bundle exec jekyll build` 或 Docker）
- [ ] 图片存放在 `assets/` 目录，使用相对路径引用
- [ ] 链接使用相对路径或完整 URL

---

## 跨项目协作规范

### 代码与博客联动

当在 LeetCode_MyAns 中完成新题解答后，可选择在博客中发布对应的文章：
1. 先在 `LeetCode_MyAns/` 中完成代码编写和测试
2. 确保代码注释完整（题目描述 + 解题思路 + 复杂度分析）
3. 在博客中创建新文章，复用代码和思路
4. 博客代码注意 Liquid 模板兼容性

### 提交规范

- **提交信息**: 简洁明了，包含项目标识前缀
  - `[algo] Add solution for LeetCode 61` — 算法题解
  - `[blog] Post LeetCode No.61: Rotate List` — 博客文章
- **分支策略**: 直接在主分支提交（个人仓库）
- **文件命名**: 只使用 `README.md`（大写），不使用 `readme.md`

### Agent 操作指南

1. **确认路径**: 每次修改前先确认当前文件属于哪个项目
2. **遵循对应规范**: 严格按所属项目的编码规范执行
3. **最小变更**: 只修改必要文件，不引入无关改动
4. **验证先行**: 涉及代码变更时优先验证构建和测试
5. **不创建多余文件**: 不添加 LICENSE、版权头等已有或多余文件

---

*Generated for Monorepo Agent Collaboration. 遵循 "Vibe Coding, Logical Execution" 原则.*
