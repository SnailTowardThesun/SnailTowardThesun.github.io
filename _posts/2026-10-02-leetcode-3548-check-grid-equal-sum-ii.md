---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3548: 矩阵分割判断II"
categories: LeetCode
---

> 分割成两部分使和相等，允许从其中一部分移除至多一个元素。关键公式：不删时 `2s = total`，删元素 x 时 `2s - total = x`，用哈希集合 O(1) 查找。

## 题目

LeetCode 3548. Check if Grid Can Be Cut Into Sections With Equal Sum II（矩阵分割判断II）

Difficulty: **Hard**

给你一个由正整数组成的 `m × n` 矩阵 `grid`。判断是否可以通过一条水平或垂直分割线将矩阵分成两部分，使得：
- 两部分非空
- 两部分元素和相等，或者从其中一部分移除至多一个单元格后相等
- 移除单元格后剩余部分保持连通

### 示例

```
示例 1：
输入：grid = [[5, 5, 6, 2, 2, 2]]
输出：true
解释：在第1列后垂直分割，右半部分移除第一个 2，和变为 6，与左半部分 5+5=... 相等。

示例 2：
输入：grid = [[1, 1], [1, 1]]
输出：true
解释：水平或垂直分割，两部分和相等（无需移除）。
```

## 解题思路

### 总和公式 + 哈希集合

设总和为 `total`，第一部分和为 `s`：
- 不删元素：`s = total - s` → `2s - total = 0`
- 从第一部分删元素 `x`：`s - x = total - s` → `2s - total = x`

遍历第一部分时，用哈希集合记录已遍历的元素值（预加 0 覆盖不删的情况）。对每个分割点计算 `x = 2s - total`，若 `x` 在集合中则可行。

需要考虑四种情况：水平分割从上/下半删、垂直分割从左/右半删。每种情况遍历方向不同。

**连通性约束**：单行或单列时只能删除端点；多行多列时任意位置都可删除（删除后仍连通）。

### 复杂度分析

- **时间复杂度**：O(m × n)，四种情况各遍历一次矩阵。
- **空间复杂度**：O(m × n)，哈希集合。

## 代码实现

```cpp
class Solution {
   public:
    bool canPartitionGrid(vector<vector<int>>& grid) {
        int rows = grid.size();
        int cols = grid[0].size();

        long long total = 0;
        for (int i = 0; i < rows; i++)
            for (int j = 0; j < cols; j++)
                total += grid[i][j];

        // 水平分割，从上半部分删
        auto check_horizontal = [&]() {
            unordered_set<long long> s;
            s.insert(0);
            long long sum = 0;
            for (int i = 0; i < rows - 1; i++) {
                for (int j = 0; j < cols; j++) {
                    sum += grid[i][j];
                    s.insert(grid[i][j]);
                }
                long long x = 2 * sum - total;
                if (s.count(x)) {
                    int r = i + 1, c = cols;
                    if (x == 0) return true;
                    if (r == 1 && c > 1) {
                        if (grid[0][0] == x || grid[0][c-1] == x) return true;
                    } else if (c == 1 && r > 1) {
                        if (grid[0][0] == x || grid[i][0] == x) return true;
                    } else {
                        return true;
                    }
                }
            }
            return false;
        };

        // 同理实现 check_vertical、check_horizontal_lower、check_vertical_right
        // ...（完整代码见源文件）

        if (check_horizontal()) return true;
        // ... 其他三种情况
        return false;
    }
};
```

### 代码解析

- `x = 2 * sum - total`：不删时 `x=0`（预加入集合），删元素时 `x` 等于被删元素值。
- 连通性：单行/单列只能删端点，多行多列任意删。
- 四种遍历方向覆盖所有分割+删除组合。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3548) {
    Solution s;
    auto eg = vector<vector<int>>{{5, 5, 6, 2, 2, 2}};
    EXPECT_EQ(true, s.canPartitionGrid(eg));
}
```
{% endraw %}

## 总结

本题的核心是将「分割+删一个元素」转化为代数方程：

1. 不删：`2s = total`；删 x：`2s - total = x`；
2. 哈希集合记录已遍历元素，O(1) 判断 `x` 是否存在；
3. 四种分割方向 + 单行/单列的连通性端点约束。
