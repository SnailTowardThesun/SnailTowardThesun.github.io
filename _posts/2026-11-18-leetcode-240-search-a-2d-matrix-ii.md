---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.240: 搜索二维矩阵 II"
categories: LeetCode
tags: [中等, 矩阵, 查找]
---

> 在行列分别有序的矩阵里，剩余区域的右上角是同行最大值、同列最小值。一次比较就能排除一行或一列。

## 题目

LeetCode 240. Search a 2D Matrix II（搜索二维矩阵 II）

Difficulty: **Medium**

给定一个 m × n 矩阵，每行从左到右非递减、每列从上到下非递减，判断目标值 target 是否存在于矩阵中。

### 示例

```
输入：matrix = [[1,4,7,11,15],[2,5,8,12,19],[3,6,9,16,22],[10,13,14,17,24],[18,21,23,26,30]], target = 5
输出：true

输入：matrix = [[1,4,7,11,15],[2,5,8,12,19],[3,6,9,16,22],[10,13,14,17,24],[18,21,23,26,30]], target = 20
输出：false
```

## 解题思路

### 右上角阶梯搜索

从 `(0,n-1)` 开始，每一步都位于剩余搜索区域的右上角。它左侧的候选值不大于它，下方的候选值不小于它。

1. 若当前值大于 `target`，这列剩余的值也都大于 `target`，排除该列并左移。
2. 若当前值小于 `target`，这行剩余的值也都小于 `target`，排除该行并下移。
3. 若当前值等于 `target`，返回 `true`。越界说明剩余区域已为空，返回 `false`。

也可以从左下角出发，此时大于目标就上移，小于目标就右移。

第 74 题额外保证下一行首元素大于上一行末元素，因此可以在按行展开的序列中做一次二分。本题的行与列分别有序，按行展开后不一定有序。逐行二分仍然可行，时间为 O(m log(n+1))。例如在单行矩阵中，二分的最坏时间为 O(log(n+1))，阶梯搜索为 O(n)。

### 复杂度分析

- **时间复杂度**：O(m + n)，每步排除一行或一列。
- **空间复杂度**：O(1)。

## 代码实现

```python
class Solution:
    def searchMatrix(self, matrix: list[list[int]], target: int) -> bool:
        m, n = len(matrix), len(matrix[0])
        row, col = 0, n - 1
        while row < m and col >= 0:
            value = matrix[row][col]
            if value == target:
                return True

            if value > target:
                col -= 1
            else:
                row += 1

        return False
```

### 代码解析

- 循环条件 `row < m and col >= 0`：从右上往左下走，越界即搜索空间耗尽。
- 搜索过程中只会左移或下移，最多访问 m+n−1 个位置。若 target 小于所有元素，会连续左移 n 次后退出；若大于所有元素，会连续下移 m 次后退出。
- 对称写法：从左下角 (m-1, 0) 出发，大于则上移、小于则右移，逻辑完全对称。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    mx = [[1, 4, 7, 11, 15], [2, 5, 8, 12, 19], [3, 6, 9, 16, 22], [10, 13, 14, 17, 24], [18, 21, 23, 26, 30]]
    assert solution.searchMatrix(mx, 5) is True
    assert solution.searchMatrix(mx, 20) is False

    # ---- 四个角与界外 ----
    assert solution.searchMatrix(mx, 1) is True   # 左上最小
    assert solution.searchMatrix(mx, 30) is True  # 右下最大
    assert solution.searchMatrix(mx, 0) is False  # 小于最小
    assert solution.searchMatrix(mx, 31) is False  # 大于最大

    # ---- 单行 / 单列 / 单元素 ----
    assert solution.searchMatrix([[1, 3, 5]], 5) is True
    assert solution.searchMatrix([[1, 3, 5]], 4) is False
    assert solution.searchMatrix([[1], [3], [5]], 3) is True
    assert solution.searchMatrix([[1]], 1) is True
```

## 总结

从右上角或左下角出发，每次比较排除一行或一列。阶梯搜索使用 O(m+n) 时间和 O(1) 额外空间。
