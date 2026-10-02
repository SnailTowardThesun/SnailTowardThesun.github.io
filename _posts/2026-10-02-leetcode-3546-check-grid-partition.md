---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3546: 矩阵分割判断"
categories: LeetCode
---

> 判断能否用一条水平或垂直分割线平分矩阵，核心是「前缀和 × 2 == 总和」，逐行逐列累加即可。

## 题目

LeetCode 3546. Check if Grid can be Partitioned（矩阵分割判断）

Difficulty: **Easy**

给你一个 m × n 整数矩阵 grid，判断能否通过一条水平或垂直、沿行列边界的分割线把矩阵分成两个非空部分，使两部分元素和相等。

### 示例

```
示例 1：
输入：grid = [[54756, 54756]]
输出：true
解释：垂直分割，两列和均为 54756。

示例 2：
输入：grid = [[1, 4], [2, 3]]
输出：true
解释：水平分割，两行和均为 5。
```

## 解题思路

### 总和 + 前缀和单次遍历

1. 计算整个矩阵总和 `total_sum`。
2. 水平方向：逐行累加前缀行和，若某位置 `prefix_row_sum × 2 == total_sum`，存在水平分割线。
3. 垂直方向：逐列累加前缀列和，同样判断。
4. 辅助函数版本还利用了奇偶性：总和为奇数不可能平分，提前返回。

源文件保留了三个演进版本：V1 前缀+后缀数组、V2 总和+单次遍历、最终版 O(1) 空间。

### 复杂度分析

- **时间复杂度**：O(m × n)。
- **空间复杂度**：O(1)，最终版只需累加变量。

## 代码实现

```cpp
class Solution {
   public:
    bool canPartitionGrid(vector<vector<int>>& grid) {
        int rows = grid.size();
        int cols = grid[0].size();

        int64_t total_sum = 0;
        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < cols; j++) total_sum += grid[i][j];
        }

        // 水平分割
        int64_t prefix_row_sum = 0;
        for (int i = 0; i < rows - 1; i++) {
            for (int j = 0; j < cols; j++) prefix_row_sum += grid[i][j];
            if (prefix_row_sum * 2 == total_sum) return true;
        }

        // 垂直分割
        int64_t prefix_col_sum = 0;
        for (int j = 0; j < cols - 1; j++) {
            for (int i = 0; i < rows; i++) prefix_col_sum += grid[i][j];
            if (prefix_col_sum * 2 == total_sum) return true;
        }

        return false;
    }
};
```

### 代码解析

- 用 `×2 == total` 避免计算后缀和，是去掉后缀数组的关键。
- 注意循环边界是 `rows - 1`、`cols - 1`，保证两部分非空。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3546) {
    Solution s;
    vector<vector<int>> eg{{54756, 54756}};
    EXPECT_EQ(true, s.canPartitionGrid(eg));
}

TEST(Daily, 3546_2x2) {
    Solution s;
    vector<vector<int>> eg{{1, 4}, {2, 3}};
    EXPECT_EQ(true, s.canPartitionGrid(eg));
}
```
{% endraw %}

## 总结

1. 平分判断等价于前缀和的两倍等于总和；
2. 分别检查行、列两个方向，边界不包含最后一行列；
3. 总和为奇数可提前剪枝。
