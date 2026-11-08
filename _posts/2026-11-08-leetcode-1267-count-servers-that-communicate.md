---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1267: 统计参与通信的服务器"
categories: LeetCode
tags: [中等, 数组, 矩阵, 计数]
---

> 许多矩阵问题不必上 DFS：当「连通」只由同行同列定义时，两个一维计数数组就能判别一切——把二维判定压成一维统计，是矩阵题的常用降维手段。

## 题目

LeetCode 1267. Count Servers that Communicate（统计参与通信的服务器）

Difficulty: **Medium**

给你一个 `m x n` 的整数矩阵 `grid` 表示一个服务器中心的数据分布图：

- `grid[i][j] = 1` 表示单元格 `(i, j)` 处有一台服务器；
- `grid[i][j] = 0` 表示该单元格没有服务器。

两台服务器位于**同一行或同一列**，就说它们可以通信。统计并返回能够与至少一台其他服务器通信的服务器数目。

约束：

- `1 <= m, n <= 250`
- `grid[i][j]` 为 0 或 1

### 示例

```text
输入：grid = [[1,0],[0,1]]
输出：0
解释：没有服务器可以与其他服务器通信。
```

```text
输入：grid = [[1,0],[1,1]]
输出：3
解释：三台服务器都能与至少一台其他服务器通信。
```

```text
输入：grid = [[1,1,0,0],[0,0,1,0],[0,0,1,0],[0,0,0,1]]
输出：4
解释：第一行的两台服务器互相通信；第三列的两台服务器互相通信；
右下角的服务器与谁都不在同一行列，不计入。
```

## 解题思路

### 关键观察：连通性退化成行列统计

「通信」的定义是同一行或同一列——这意味着一台服务器能否通信，**只取决于它所在的行、列里是否还有别的服务器**，与连通块的形状、大小无关。第一反应的「求连通分量」（DFS/BFS/并查集，分量大小 ≥ 2 即全计入）能做，但纯属杀鸡用牛刀：两个一维计数数组就能判别一切。

### 两遍线性扫描

1. 第一遍扫描：统计每行的服务器数 `row_cnt` 和每列的服务器数 `col_cnt`；
2. 第二遍扫描：对每个 `grid[i][j] == 1` 的格子，若 `row_cnt[i] > 1` 或 `col_cnt[j] > 1`，说明同行或同列至少还有另一台服务器，计入答案；
3. 返回计数。

为什么不用 DFS 还有一层实际原因：`m`、`n` 达 250，蛇形连通块可长达 6 万格，朴素递归 DFS 的深度会随之失控（Python 默认递归上限才 1000）。计数法全程无递归，从根上规避。

### 复杂度分析

- 时间复杂度：`O(m * n)`（两遍线性扫描）
- 空间复杂度：`O(m + n)`（行列计数表）

## 代码实现

C++ 与 Python 的行列计数一一对应（变量命名一致），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt1267-cpp" name="lt1267" checked>
  <input type="radio" id="lt1267-py" name="lt1267">
  <div class="lang-tab-nav">
    <label for="lt1267-cpp">C++</label>
    <label for="lt1267-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int countServers(vector<vector<int>>& grid) {
        int ret = 0;
        int m = grid.size();
        int n = grid[0].size();

        vector<int> row_cnt(m, 0);
        vector<int> col_cnt(n, 0);
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                if (grid[i][j] == 1) {
                    row_cnt[i] += 1;
                    col_cnt[j] += 1;
                }
            }
        }

        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                if (grid[i][j] == 1) {
                    if (row_cnt[i] > 1 || col_cnt[j] > 1) {
                        ret += 1;
                    }
                }
            }
        }
        return ret;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def countServers(self, grid: list[list[int]]) -> int:
        m, n = len(grid), len(grid[0])

        row_cnt = [0] * m
        col_cnt = [0] * n
        for i in range(m):
            for j in range(n):
                if grid[i][j] == 1:
                    row_cnt[i] += 1
                    col_cnt[j] += 1

        ret = 0
        for i in range(m):
            for j in range(n):
                if grid[i][j] == 1 and (row_cnt[i] > 1 or col_cnt[j] > 1):
                    ret += 1

        return ret
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 两个计数数组把「同行/同列有无其他服务器」这个二维判定拆成两个一维统计——第二遍扫描时每个格子只做两次数组下标访问；
- 判定条件是「或」而不是「且」：行列任一方还有别的服务器即可通信，无需真的找到那台服务器；
- 单独一台服务器 `row_cnt == col_cnt == 1`，两个条件都不满足，自然被排除；
- 全 1 矩阵是上界用例：所有行列计数都 ≥ 2，答案即服务器总数。

## 测试用例

覆盖三个官方示例与典型边界（单台、整行、整列、对角线全孤立、四角互通中心孤立）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：无同行同列，全部孤立 ----
    assert solution.countServers([[1, 0], [0, 1]]) == 0

    # ---- 官方示例 2：三台全部互通 ----
    assert solution.countServers([[1, 0], [1, 1]]) == 3

    # ---- 官方示例 3：两组互通 + 一个孤立 ----
    assert solution.countServers([[1, 1, 0, 0], [0, 0, 1, 0], [0, 0, 1, 0], [0, 0, 0, 1]]) == 4

    # ---- 最小规模：单台服务器无法通信 ----
    assert solution.countServers([[1]]) == 0

    # ---- 同一行 / 同一列多台：全部计入 ----
    assert solution.countServers([[1, 1, 1]]) == 3
    assert solution.countServers([[1], [1], [1]]) == 3

    # ---- 对角线摆放：不同行不同列，全部孤立 ----
    assert solution.countServers([[1, 0, 0], [0, 1, 0], [0, 0, 1]]) == 0

    # ---- 四角互通、中心孤立：只数四角 ----
    assert solution.countServers([[1, 0, 1], [0, 1, 0], [1, 0, 1]]) == 4
```

C++ 侧在 `TEST(Daily, 1267)` 里用同样的 9 组用例断言，`./tests --gtest_filter='Daily.1267'` 通过。

## 总结

- 「同行同列即可通信」的连通性定义天然支持降维：行列两个一维计数数组就是全部状态，无需 DFS/并查集；
- 两遍扫描——先统计、后判定——把每个格子的判定压缩成两次数组访问，O(m·n) 时间、O(m+n) 空间；
- 递归类解法在 250×250 的蛇形连通块面前有栈深风险，选择计数法顺带规避。
