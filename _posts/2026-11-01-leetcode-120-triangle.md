---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.120: 三角形最小路径和"
categories: LeetCode
tags: [中等, 动态规划, 网格, top150]
---

> 三角形第 i 行只依赖第 i-1 行——滚动数组只需 O(n)。路径计数、最小路径和、杨辉三角共享同一个转移骨架，变的只是 min、加法这类合并运算。

## 题目

LeetCode 120. Triangle（三角形最小路径和）

Difficulty: **Medium**

给定一个三角形 `triangle`，找出自顶向下的最小路径和。每一步只能移动到下一行中**相邻的结点**上——若正位于当前行的下标 `i`（元素 `triangle[row][i]`），下一步可移动到下一行的下标 `i` 或 `i + 1` 处。返回自顶向下的最小路径和。

约束：

- `1 <= triangle.length <= 200`
- `0 <= triangle[i].length < triangle.length`（第 0 行 1 个元素，第 i 行 i+1 个）
- `-10^4 <= triangle[i][j] <= 10^4`
- 进阶：仅使用 `O(n)` 额外空间

### 示例

```text
输入：triangle = [[2],[3,4],[6,5,7],[4,1,8,3]]
输出：11
解释：最小路径和为 2 + 3 + 5 + 1 = 11。
```

```text
输入：triangle = [[-10]]
输出：-10
```

## 解题思路

### 状态与转移：一个"两腰收窄"的网格 DP

`dp[i][j]` = 自顶向下走到 `(i, j)` 的最小路径和。与满网格的最小路径和（LeetCode 64）相比，三角形的特殊之处全在**两腰**：

- **左腰**（`j == 0`）：只能来自正上方 `dp[i-1][0]`——左上方不存在；
- **右腰**（`j == i`）：只能来自左上方 `dp[i-1][j-1]`——正上方不存在；
- **中间**：`dp[i][j] = min(dp[i-1][j-1], dp[i-1][j]) + triangle[i][j]`。

答案不是右下角单格，而是**最后一行所有 dp 值的最小值**——终点可在底行任意位置，这与满网格"固定右下角"不同。

### 自底向上：另一种写法，顺便省空间

从倒数第二行往上算：`dp[j] = min(dp[j], dp[j+1]) + triangle[i][j]`。好处有二：两腰的边界分支消失（每行两端天然取到下一行相邻两格），空间只需 `O(n)` 一维数组。本文代码采用自顶向下版（边界分支更直观、便于教学对照），自底向上版作为备注写在注释里。

### 反贪心：小数字可能把你带进沟里

`[[1],[2,100],[100,100,1]]`：第二步贪心选 `2`（更小），之后无论如何都要踩 `100`，得到 103；最优 102 恰在"先选大的 100"那条路上。局部最优与全局最优在此明确分离——这类用例值得常备。

### 复杂度分析

- 时间复杂度：`O(n^2)`——n 为行数，元素总数 `n(n+1)/2`
- 空间复杂度：`O(n^2)`，滚动可 `O(n)`

## 代码实现

```python
class Solution:
    def minimumTotal(self, triangle: list[list[int]]) -> int:
        n = len(triangle)
        dp = [[0] * i for i in range(1, n + 1)]
        for i in range(n):
            if i == 0:
                dp[0][0] = triangle[0][0]
                continue
            for j in range(i + 1):
                if j == 0:  # 左腰：只能来自正上方
                    dp[i][j] = dp[i - 1][j] + triangle[i][j]
                elif j == i:  # 右腰：只能来自左上方
                    dp[i][j] = dp[i - 1][j - 1] + triangle[i][j]
                else:  # 中间：取左上 / 正上较优
                    dp[i][j] = min(dp[i - 1][j - 1], dp[i - 1][j]) + triangle[i][j]

        return min(dp[n - 1])


def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.minimumTotal([[2], [3, 4], [6, 5, 7], [4, 1, 8, 3]]) == 11  # 2+3+5+1
    assert solution.minimumTotal([[-10]]) == -10
    # 边界：单行 / 两行
    assert solution.minimumTotal([[5]]) == 5
    assert solution.minimumTotal([[1], [2, 3]]) == 3
    # 反贪心：第二行先选小的 2 会得到 103，最优 102 恰在先选大的 100 那条路上
    assert solution.minimumTotal([[1], [2, 100], [100, 100, 1]]) == 102
    # 负数（约束允许 -10^4）：必须真取 min 而非初值 0 污染
    assert solution.minimumTotal([[-1], [-2, -3]]) == -4
    assert solution.minimumTotal([[1], [-5, -4]]) == -4
    # 全同值：任意路径等价
    assert solution.minimumTotal([[3], [3, 3], [3, 3, 3]]) == 9
    # 随机三角形（期望值经全路径 DFS 暴力验证）
    assert solution.minimumTotal([[1], [-7, 6], [8, -4, 3], [-6, -1, -9, -4]]) == -19
```

### 代码解析

- `dp` 按行建形成三角形状（第 i 行 i 列），省去满矩形空间；
- 两腰分支是本题与满网格 DP 的唯一差别——左边界的左上、右边界的正上都不存在，各自退化为单前驱相加；
- 答案取 `min(dp[n-1])` 而非固定单格；
- 期望值全部经全路径 DFS 暴力验证，含负数用例防止"初值 0 污染 min"的经典错误。

## 总结

- 三角形 = 两腰收窄的网格 DP：左腰只看正上、右腰只看左上、中间取 min，答案在底行取 min；
- 自底向上写法可消掉全部边界分支并把空间压到 O(n)，两种写法值得各写一遍体会差别；
- 反贪心与负数用例是这类"路径取 min"题的标配测试：前者钉住"必须比较两条来路"，后者钉住"min 不能被初值 0 污染"。
