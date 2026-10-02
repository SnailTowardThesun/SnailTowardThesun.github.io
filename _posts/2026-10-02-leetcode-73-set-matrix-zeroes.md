---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.73: 矩阵置零"
categories: LeetCode
---

> 用第一行第一列本身做标记位，先标记再置零；但两个标记位会互相污染，需额外两个 bool 记录它们自身是否有零。

## 题目

LeetCode 73. Set Matrix Zeroes（矩阵置零）

Difficulty: **Medium**

给定 m × n 矩阵，若某元素为 0，则将其所在行和列全部置零。要求原地算法。

### 示例

```
输入：[[1,1,1],[1,0,1],[1,1,1]]
输出：[[1,0,1],[0,0,0],[1,0,1]]
```

## 解题思路

### 首行首列标记法

1. 遍历矩阵，遇到 0 时把该行首列 `matrix[i][0]`、该列首行 `matrix[0][j]` 标记为 0；同时用 row、col 两个 bool 记录第一行、第一列自身是否出现零。
2. 从下标 (1,1) 开始第二遍遍历，只要行首或列首标记为 0，就把当前元素置零。
3. 最后根据 row、col 决定是否把第一行、第一列整体置零。

顺序很重要：必须先完成标记，再从第二行第二列开始置零，否则标记会被提前污染。

### 复杂度分析

- **时间复杂度**：O(m × n)。
- **空间复杂度**：O(1)。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    void setZeroes(vector<vector<int>>& matrix) {
        if (matrix.empty()) return;
        int m = matrix.size();
        int n = matrix[0].size();
        bool row = false, col = false;

        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; j++) {
                if (matrix[i][j] == 0) {
                    if (i == 0) row = true;
                    if (j == 0) col = true;
                    matrix[i][0] = 0;
                    matrix[0][j] = 0;
                }
            }
        }

        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; j++) {
                if (matrix[i][0] == 0 || matrix[0][j] == 0) matrix[i][j] = 0;
            }
        }

        if (row) for (int j = 0; j < n; ++j) matrix[0][j] = 0;
        if (col) for (int i = 0; i < m; ++i) matrix[i][0] = 0;
    }
};
```
{% endraw %}

## 测试用例

{% raw %}
```cpp
TEST(Daily, 73) {
    Solution s;
    vector<vector<int>> matrix1 = {{1,1,1},{1,0,1},{1,1,1}};
    s.setZeroes(matrix1);
    EXPECT_EQ(matrix1[1], vector<int>({0,0,0}));
}
```
{% endraw %}

## 总结

1. 首行首列复用为标记数组，省掉 O(m+n) 空间；
2. 两个 bool 单独记录标记行/列自身的零；
3. 置零从 (1,1) 开始，避免标记被提前覆盖。
