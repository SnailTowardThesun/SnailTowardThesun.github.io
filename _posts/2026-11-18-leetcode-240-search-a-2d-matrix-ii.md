---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.240: 搜索二维矩阵 II"
categories: LeetCode
tags: [中等, 矩阵, 二分查找]
---

> 从右上角出发做阶梯搜索：右上角是行内最大、列内最小，比 target 大就排除整列左移，比 target 小就排除整行下移，每步排除一行或一列。

## 题目

LeetCode 240. Search a 2D Matrix II（搜索二维矩阵 II）

Difficulty: **Medium**

给定一个 m × n 矩阵，每行从左到右升序、每列从上到下升序，判断目标值 target 是否存在于矩阵中。

### 示例

```
输入：matrix = [[1,4,7,11,15],[2,5,8,12,19],[3,6,9,16,22],[10,13,14,17,24],[18,21,23,26,30]], target = 5
输出：true

输入：matrix = [[1,4,7,11,15],[2,5,8,12,19],[3,6,9,16,22],[10,13,14,17,24],[18,21,23,26,30]], target = 20
输出：false
```

## 解题思路

### 右上角阶梯搜索

从右上角 (0, n-1) 出发——它是**所在行的最大值、所在列的最小值**，向左数值不增、向下数值不减，因此能确定下一步移动方向：

1. 当前值 **大于** target：本列往下不会更小，目标不在此列，**排除整列**，左移一列；
2. 当前值 **小于** target：本行往左不会更大，目标不在此行，**排除整行**，下移一行；
3. 相等则找到；走出边界则不存在。

每步至少排除一行或一列，最多 **m + n** 步出结果。

**阶梯搜索为什么选择右上或左下角**：在剩余搜索区域中，右上角的左侧元素不大于它、下方元素不小于它，因此可以根据比较结果排除一行或一列。左下角同理。左上角的两个方向都不减、右下角的两个方向都不增，无法沿用这种仅靠当前值决定移动方向的规则。

**与 74 题的区别**：74 题保证下一行首元素大于上一行末元素，可以按行展开成一维有序数组；240 题仅保证各行、各列有序，不满足这一条件。逐行二分为 O(m log(n+1))，阶梯搜索为 O(m+n)，两者优劣取决于矩阵形状。例如单行矩阵中，二分为 O(log(n+1))，阶梯搜索最坏为 O(n)。

### 复杂度分析

- **时间复杂度**：O(m + n)，每步排除一行或一列。
- **空间复杂度**：O(1)。

## 代码实现

```python
class Solution:
    def searchMatrix(self, matrix: list[list[int]], target: int) -> bool:
        m, n = len(matrix), len(matrix[0])
        x, y = 0, n - 1  # 从右上角出发：行内最大、列内最小，两向单调性相反
        while x < m and y >= 0:
            if matrix[x][y] == target:
                return True

            if matrix[x][y] > target:
                y -= 1  # 本列往下更大 → 整列排除，左移
            else:
                x += 1  # 本行往左更小 → 整行排除，下移

        return False
```

### 代码解析

- 循环条件 `x < m and y >= 0`：从右上往左下走，越界即搜索空间耗尽。
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
    assert solution.searchMatrix(mx, 31) is False # 大于最大

    # ---- 单行 / 单列 / 单元素 ----
    assert solution.searchMatrix([[1, 3, 5]], 5) is True
    assert solution.searchMatrix([[1, 3, 5]], 4) is False
    assert solution.searchMatrix([[1], [3], [5]], 3) is True
    assert solution.searchMatrix([[1]], 1) is True
```

## 总结

1. 行列双升序的矩阵，从右上或左下出发，每步可排除一整行或一整列；
2. 右上或左下角允许根据当前值排除一侧，比较范围随之缩小；
3. 阶梯搜索为 O(m+n) 时间、O(1) 空间，与逐行二分的优劣取决于矩阵形状；
4. 74 题可按行展开为有序数组做一次二分；本题可用阶梯搜索，也可逐行二分。
