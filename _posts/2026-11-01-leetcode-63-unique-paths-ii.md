---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.63: 不同路径 II"
categories: LeetCode
tags: [中等, 动态规划, 网格, 计数, top150]
---

> 网格计数 DP 里障碍处理有一条万用定律：障碍格的 dp 恒为 0，转移时"加 0"自然等价于"该方向无路可来"——前驱是否障碍、边界行列，全都不用再特判，一个转移式走天下。

## 题目

LeetCode 63. Unique Paths II（不同路径 II）

Difficulty: **Medium**

一个机器人位于 `m x n` 网格的左上角（起点 `grid[0][0]`）。机器人每次只能**向下或者向右**移动一步，试图到达网格的右下角 `grid[m-1][n-1]`。

网格中的障碍物和空位置分别用 `1` 和 `0` 表示，机器人的移动路径中不能包含任何障碍物。返回机器人能够到达右下角的不同路径数量。测试用例保证答案 `<= 2 * 10^9`。

约束：

- `m == obstacleGrid.length`，`n == obstacleGrid[i].length`
- `1 <= m, n <= 100`
- `obstacleGrid[i][j]` 为 `0` 或 `1`

### 示例

```text
输入：obstacleGrid = [[0,0,0],[0,1,0],[0,0,0]]
输出：2
解释：3x3 网格正中间有一个障碍物，共 2 条路径：
     右→右→下→下；下→下→右→右。
```

```text
输入：obstacleGrid = [[0,1],[0,0]]
输出：1
```

## 解题思路

### 从无障碍版（62）到有障碍版：只多一条规则

无障碍的不同路径（LeetCode 62）是纯组合数 `C(m+n-2, m-1)`；加入障碍后组合数失效，回归 DP：`dp[i][j] = 到达 (i,j) 的路径数`。

障碍的处理只需要一条规则：**障碍格的 dp 恒为 0**。它自动派生出所有"看似需要特判"的情形：

| 看似要特判的情形 | 实际发生的事 |
| ---- | ---- |
| 前驱是障碍 | 转移 `top + left` 中那一项是 0，加 0 = 该方向无贡献 |
| 首行/首列 | `top` 或 `left` 按 0 处理，退化为单前驱相加 |
| 起点是障碍 | `dp[0][0]` 保持 0，全表传播 0，答案自然为 0 |
| 终点是障碍 | 同上，`dp[m-1][n-1] = 0`，无需提前返回 |

### 初版的死代码：为"已经免费的语义"付出的分支

初版实现是正确的，但转移写成了四分支：判断上方/左方是否障碍分别取值，首行首列还各自套了一层"前驱为 0 则置 0 否则继承"的 if/else。逐条对照会发现这些分支全部等价于一句 `dp[i][j] = top + left`：

- "前驱是障碍取另一边" ⟷ `0 + 另一边`；
- "前驱 dp 为 0 则置 0 否则继承" ⟷ `dp[i][j] = dp[i][j-1]` 本身——0 就继承 0；
- 双前驱都是障碍 ⟷ `0 + 0`。

障碍 `dp = 0` 这一步初始化已经把"无路可来"编进了数值里，后续转移只需做加法，不需要再"理解"障碍。两版行为完全一致（200 组随机网格对拍验证），但简化版少 10 余行、少 4 个分支点——DP 代码的分支越少，错的地方越少。

### 复杂度分析

- 时间复杂度：`O(m * n)`——每格一次加法
- 空间复杂度：`O(m * n)`；逐行滚动（`dp[j] += dp[j-1]`）可压到 `O(n)`

## 代码实现

```python
class Solution:
    def uniquePathsWithObstacles(self, obstacleGrid: list[list[int]]) -> int:
        m, n = len(obstacleGrid), len(obstacleGrid[0])
        # dp[i][j] = 到达 (i,j) 的路径数；障碍格保持 0，转移加 0 即"该方向无路可来"
        dp = [[0] * n for _ in range(m)]
        for i in range(m):
            for j in range(n):
                if obstacleGrid[i][j] == 1:
                    continue  # 障碍：保持 0（起点/终点是障碍时答案自然为 0）
                if i == 0 and j == 0:
                    dp[i][j] = 1  # 起点可达时恰有 1 种走法
                    continue
                top = dp[i - 1][j] if i > 0 else 0
                left = dp[i][j - 1] if j > 0 else 0
                dp[i][j] = top + left
        return dp[m - 1][n - 1]
```

### 代码解析

- `continue` 让障碍格保持全表初始化的 0——这是全题唯一"感知"障碍的语句；
- `top`/`left` 用条件表达式处理越界方向，首行首列不再单列分支；
- 起点是障碍不需要提前 `return 0`：`dp[0][0]` 为 0 会向全表传播，语义自洽；
- 滚动数组版把 `dp` 换成一维：`dp[j] = 0 if grid[i][j] else dp[j] + dp[j-1]`，注意每行行首要按障碍重置。

## 测试用例

覆盖官方示例、1×1、起点/终点即障碍、单行单列中段封死、无障碍退化组合数、挡墙留缺口，以及暴力验证的随机含障网格：

```python
def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.uniquePathsWithObstacles([[0, 0, 0], [0, 1, 0], [0, 0, 0]]) == 2
    assert solution.uniquePathsWithObstacles([[0, 1], [0, 0]]) == 1
    # 边界：1x1（含起点即障碍）
    assert solution.uniquePathsWithObstacles([[0]]) == 1
    assert solution.uniquePathsWithObstacles([[1]]) == 0
    # 单行 / 单列：中间障碍会整段封死
    assert solution.uniquePathsWithObstacles([[0, 0, 0]]) == 1
    assert solution.uniquePathsWithObstacles([[0, 1, 0]]) == 0
    assert solution.uniquePathsWithObstacles([[0], [1], [0]]) == 0
    # 终点是障碍：一步之遥也算 0（注意 [[0,1]] 这类"终点即障碍"的小网格）
    assert solution.uniquePathsWithObstacles([[0, 0], [0, 1]]) == 0
    assert solution.uniquePathsWithObstacles([[0, 1]]) == 0
    # 无障碍退化为组合数：3x3 = C(4,2) = 6
    assert solution.uniquePathsWithObstacles([[0, 0, 0], [0, 0, 0], [0, 0, 0]]) == 6
    # 挡墙只留一个缺口：所有路径被迫走同一列
    assert solution.uniquePathsWithObstacles([[0, 0, 0], [1, 1, 0], [0, 0, 0]]) == 1
    # 随机含障网格（期望值经 DFS 全路径计数暴力验证）
    assert solution.uniquePathsWithObstacles([[0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 0]]) == 1
    assert solution.uniquePathsWithObstacles([[0, 0], [1, 0], [0, 0], [0, 0]]) == 1
```

## 总结

- 障碍 DP 只需一条规则：障碍格 dp 置 0，其余交给加法——前驱障碍、边界、起点终点特判全部被"加 0"吸收；
- 初版四分支转移与简化版一行转移行为完全一致：能被初始化语义覆盖的判断就是死代码，DP 写得越平越不容易错；
- `[[0,1]]` 这类"终点即障碍"的小网格值得专门留在测试里——它同时钉住起点分支、终点读取和障碍传播三条路径。
