---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.74: 搜索二维矩阵"
categories: LeetCode
tags: 中等
---

> 若矩阵每行有序且行首大于上一行行尾，它可看成一维有序数组；先二分行、再二分列也很清晰。

## 题目

LeetCode 74. Search a 2D Matrix（搜索二维矩阵）

Difficulty: **Medium**

给你一个满足以下性质的 `m x n` 矩阵：

- 每行整数从左到右升序排列；
- 每行第一个整数大于前一行的最后一个整数。

判断目标值 `target` 是否存在于矩阵中。

### 示例

```
输入：matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 3
输出：true

输入：matrix = [[1,3,5,7],[10,11,16,20],[23,30,34,60]], target = 13
输出：false
```

## 解题思路

### 行二分 + 列二分

矩阵行与行之间也是全局升序，因此目标值若存在，只能落在唯一一行：

1. **定位行**：二分比较 `target` 与当前行的首尾元素。
   - `target < matrix[mid].front()`：目标只可能在更上面的行；
   - `target > matrix[mid].back()`：目标只可能在更下面的行；
   - 否则当前行就是候选行。
2. **行内查找**：对候选行执行标准二分查找。

### 复杂度分析

- **时间复杂度**：`O(log m + log n)`。
- **空间复杂度**：`O(1)`。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    bool searchMatrix(vector<vector<int>>& matrix, int target) {
        if (matrix.empty() || matrix[0].empty()) {
            return false;
        }

        int top = 0;
        int bottom = static_cast<int>(matrix.size()) - 1;
        int targetRow = -1;

        // 第一轮二分：利用每行首尾元素定位唯一可能包含 target 的行。
        while (top <= bottom) {
            int mid = top + (bottom - top) / 2;
            if (target < matrix[mid].front()) {
                bottom = mid - 1;
            } else if (target > matrix[mid].back()) {
                top = mid + 1;
            } else {
                targetRow = mid;
                break;
            }
        }

        if (targetRow == -1) {
            return false;
        }

        // 第二轮二分：在有序行内查找 target。
        int left = 0;
        int right = static_cast<int>(matrix[targetRow].size()) - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (matrix[targetRow][mid] == target) {
                return true;
            }

            if (matrix[targetRow][mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return false;
    }
};
```
{% endraw %}

### 代码解析

- 行定位不需要遍历行首或行尾，仍能保持对数复杂度。
- 候选行满足 `front <= target <= back`，端点相等时同样能找到目标行。
- 第二轮是标准闭区间二分，逻辑与一维有序数组完全一致。

## 测试用例

{% raw %}
```cpp
TEST(Top150, 74) {
    Solution s;
    vector<vector<int>> matrix{{1, 3, 5, 7},
                               {10, 11, 16, 20},
                               {23, 30, 34, 60}};
    EXPECT_TRUE(s.searchMatrix(matrix, 3));
    EXPECT_TRUE(s.searchMatrix(matrix, 1));
    EXPECT_TRUE(s.searchMatrix(matrix, 60));
    EXPECT_FALSE(s.searchMatrix(matrix, 13));
    EXPECT_FALSE(s.searchMatrix(matrix, 0));
}
```
{% endraw %}

## 总结

1. 本题矩阵具备“全局有序”性质，可安全地对行做二分。
2. 行二分看首尾，列二分看中值，两次收缩互不干扰。
3. 总复杂度等价于对展开后的一维数组做一次二分。
