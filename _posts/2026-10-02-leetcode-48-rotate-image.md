---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.48: 旋转图像"
categories: LeetCode
---

> 原地旋转 90 度拆成两个可逆操作：先沿主对角线转置，再逐行反转，不需要任何额外矩阵。

## 题目

LeetCode 48. Rotate Image（旋转图像）

Difficulty: **Medium**

给定 n × n 矩阵，将其原地顺时针旋转 90 度。

### 示例

```
输入：[[1,2,3],[4,5,6],[7,8,9]]
输出：[[7,4,1],[8,5,2],[9,6,3]]
```

## 解题思路

### 转置 + 行反转

1. **转置**：沿主对角线交换 matrix[i][j] 与 matrix[j][i]（只遍历下三角，避免交换两次还原）。
2. **行反转**：每行元素左右翻转，等价于水平镜像。

两个操作组合后，矩阵恰好顺时针旋转 90 度。

### 复杂度分析

- **时间复杂度**：O(n²)。
- **空间复杂度**：O(1)。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    void rotate(vector<vector<int>>& matrix) {
        int n = matrix.size();

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < i; j++) {
                swap(matrix[i][j], matrix[j][i]);
            }
        }

        for (int i = 0; i < n; i++) {
            reverse(matrix[i].begin(), matrix[i].end());
        }
    }
};
```
{% endraw %}

### 代码解析

- 转置循环用 `j < i` 只处理下三角；`j < n` 会每个元素交换两次回到原状。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 48) {
    Solution s;
    auto matrix = vector<vector<int>>{{1,2,3},{4,5,6},{7,8,9}};
    s.rotate(matrix);
    EXPECT_EQ(matrix[0][0], 7);
}
```
{% endraw %}

## 总结

1. 旋转 90° = 转置 + 行反转；
2. 转置只遍历下三角；
3. 全程原地，O(1) 空间。
