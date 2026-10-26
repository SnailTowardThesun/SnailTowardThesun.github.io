---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3619: 总价值可以被 K 整除的岛屿数目"
categories: LeetCode
tags: [中等, 并查集, 图, 网格]
---

> 这题的陆地是任意正整数而不只是 1：在 No.200 的网格并查集上多加一步「按根累加价值」，再统计和能被 k 整除的分量即可。

## 题目

LeetCode 3619. Count Islands With Total Value Divisible by K（总价值可以被 K 整除的岛屿数目）

Difficulty: **Medium**

给你一个 `m x n` 的矩阵 `grid` 和一个正整数 `k`。

一个「岛屿」是由**正整数**（表示陆地）组成、且陆地间四方向连通（水平或垂直）的区域；值为 `0` 的格子是水。

一个岛屿的总价值是该岛屿中所有单元格的值之和。

返回总价值可以被 `k` 整除的岛屿数量。

约束：

- `1 <= m, n <= 1000`
- `1 <= m * n <= 10^5`
- `0 <= grid[i][j] <= 10^6`
- `1 <= k <= 10^6`

### 示例

```
输入：grid = [[0,2,1,0,0],
             [0,5,0,0,5],
             [0,0,1,0,0],
             [0,1,4,7,0],
             [0,2,0,0,8]], k = 5
输出：2
解释：四座岛的总价值分别为 8、5、15、8，其中 5 和 15 能被 5 整除。

输入：grid = [[3,0,3,0],
             [0,3,0,3],
             [3,0,3,0]], k = 3
输出：6
解释：六座单格岛，每座总价值 3 都能被 3 整除。
```

## 解题思路

和 No.200 岛屿数量同源的网格并查集，区别只有一处：数的不只是分量个数，而是「价值总和能被 `k` 整除」的分量个数。于是在合并之后增加一步**按根聚合数值**。

### 坐标压缩与合并

格子 `(i, j)` 压缩成一维编号 `i * n + j`；遍历网格，对每个**陆地格**把上下左右相邻的陆地格与它合并。

本题的关键判据：**陆地是任意正整数**，判断陆地必须用 `grid[i][j] != 0`，而不是 No.200 那样的 `== "1"`、更不是 `== 1`。

### 按根累加总价值

合并完成后，每座岛屿对应唯一的根节点。再扫一遍网格，把每个陆地格的值累加到 `dic[uf.find(编号)]` 上——`dic` 以根为键、以岛的总价值为值，`find` 天然把同一座岛的所有格子路由到同一个键上。

### 统计

遍历 `dic` 的所有值，`value % k == 0` 则计数加一。水格从不进 `dic`，无需排除；`k = 1` 时任何总和都可整除，退化为数岛屿个数。

以示例 1 为例：四座岛的根分别聚合出 8、5、15、8，其中 5 和 15 被 5 整除，答案 `2`。

### 复杂度分析

设矩阵大小为 `m × n`，`α` 为反阿克曼函数。合并与聚合都是每个格子常数次操作，时间复杂度 `O(mn·α(mn))`，`parent`、`rank` 和聚合字典占用 `O(mn)` 空间。

## 代码实现

```python
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        root_x, root_y = self.find(x), self.find(y)
        if root_x == root_y:
            return

        if self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
        elif self.rank[root_x] < self.rank[root_y]:
            self.parent[root_x] = root_y
        else:
            self.parent[root_y] = root_x
            self.rank[root_x] += 1


class Solution:
    def countIslands(self, grid: list[list[int]], k: int) -> int:
        if len(grid) == 0:
            return 0

        if len(grid[0]) == 0:
            return 0

        m, n = len(grid), len(grid[0])
        uf = UnionFind(m * n)
        for i in range(m):
            for j in range(n):
                if grid[i][j] == 0:
                    continue
                if j > 0:
                    if grid[i][j - 1] != 0:
                        uf.union(i * n + j, i * n + j - 1)
                if j < n - 1:
                    if grid[i][j + 1] != 0:
                        uf.union(i * n + j, i * n + j + 1)
                if i > 0:
                    if grid[i - 1][j] != 0:
                        uf.union(i * n + j, (i - 1) * n + j)
                if i < m - 1:
                    if grid[i + 1][j] != 0:
                        uf.union(i * n + j, (i + 1) * n + j)
        dic = {}
        for i in range(m):
            for j in range(n):
                if grid[i][j] != 0:
                    root = uf.find(i * n + j)
                    if dic.get(root, None) is None:
                        dic[root] = grid[i][j]
                    else:
                        dic[root] += grid[i][j]

        ret = 0
        for _, v in dic.items():
            if v % k == 0:
                ret += 1
        return ret
```

### 代码解析

- **陆地判据必须是 `!= 0`**：实现时曾误写成 `== 1`，导致只有值为 1 的邻居会被合并——相邻的 `2` 和 `2` 是两座岛却被漏合并。最隐蔽的是两个官方示例竟然都侥幸通过：示例 1 拆碎后恰好剩下两个单格 5 的岛可整除，数量碰巧仍是 2；示例 2 全是互不相邻的单格岛，bug 无从发作。最终靠 `[[2,2]], k=4`（每格不整除、总和整除）这类构造用例才暴露；
- **`find` 是聚合的天然键**：同一座岛的所有格子 `find` 结果相同，`dic` 以根为键就完成了「按分量求和」，不需要显式遍历分量成员；
- **聚合阶段重新过滤陆地**：与 No.200 的统计阶段同理，`find` 对水格同样合法，累加前必须再判一次 `!= 0`，否则水格的 0 会给所在分量白加一个 0（数值上无害，但若水格误入 `dic`，会凭空多出一座「总价值 0」的岛——`0 % k == 0` 恒真，直接多计）；
- **防御性空网格检查**：`len(grid) == 0` / `len(grid[0]) == 0` 超出题目约束（`m, n >= 1`），属于保险写法，LeetCode 上可省。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # 官方示例
    assert (
        solution.countIslands(
            [
                [0, 2, 1, 0, 0],
                [0, 5, 0, 0, 5],
                [0, 0, 1, 0, 0],
                [0, 1, 4, 7, 0],
                [0, 2, 0, 0, 8],
            ],
            5,
        )
        == 2
    )
    assert solution.countIslands([[3, 0, 3, 0], [0, 3, 0, 3], [3, 0, 3, 0]], 3) == 6

    # 边界情况
    assert solution.countIslands([[0, 0], [0, 0]], 5) == 0  # 全是水，没有岛屿
    assert solution.countIslands([[0]], 1) == 0  # 单格水
    assert solution.countIslands([[5]], 5) == 1  # 单格陆地，总价值恰为 k
    assert solution.countIslands([[5]], 3) == 0  # 单格陆地，总价值不被 k 整除
    assert solution.countIslands([[1, 0], [0, 1]], 1) == 2  # 对角不连通，是两座岛
    assert solution.countIslands([[1000000]], 1000000) == 1  # 值域上界

    # 判定对象是「总和」而不是单个格子：每格 2 都不被 4 整除，但总和 4 可以
    assert solution.countIslands([[2, 2]], 4) == 1
    # 反例：中间隔水，两座单格岛各自总和 2，都不被 4 整除
    assert solution.countIslands([[2, 0, 2]], 4) == 0

    # 求和要覆盖整座岛：横向三格和为 3 才整除，两格和为 2 则不整除
    assert solution.countIslands([[1, 1, 1]], 3) == 1
    assert solution.countIslands([[1, 1]], 3) == 0

    # 蛇形整座岛：2+1+1+3+1+1 = 9，拐弯的格子不能漏加
    assert solution.countIslands([[0, 2, 1], [0, 1, 0], [3, 1, 1]], 9) == 1

    # 跨四行的蛇形岛 1+6+2+10 = 19 恰好整除 k；单格岛 11 和 8 都不整除
    assert solution.countIslands([[0, 0, 0], [0, 0, 1], [11, 0, 6], [0, 10, 2], [0, 0, 0], [8, 0, 0]], 19) == 1

    # k = 1 时任何总价值都可整除：退化为数岛屿个数（示例 1 网格共四座岛）
    assert (
        solution.countIslands(
            [
                [0, 2, 1, 0, 0],
                [0, 5, 0, 0, 5],
                [0, 0, 1, 0, 0],
                [0, 1, 4, 7, 0],
                [0, 2, 0, 0, 8],
            ],
            1,
        )
        == 4
    )
```

用例围绕三类语义设计：**总和语义**（`[[2,2]], k=4` 恰好是 `== 1` 笔误的克星——它要求两格合并且和整除，两个条件一个不满足就翻车）；**连通语义**（对角不算、0 是水、蛇形不断）；**退化语义**（`k=1` 时答案必须等于岛屿个数 4，任何错误拆分或错误合并都会让这个数对不上）。

## 总结

- 网格并查集的套路与 No.200 完全复用：坐标压缩、相邻陆地合并，本题只多一步「以 `find` 根为键聚合数值，再判整除」；
- 本题最大的坑是陆地判据：值域是任意正整数，`== 1` 的笔误连官方示例都能侥幸骗过，`[[2,2]], k=4` 这类「格子值不整除但总和整除」的用例是唯一可靠的探测器；
- 聚合时水格若不过滤，`0 % k == 0` 恒真会凭空多计岛屿——聚合阶段的 `!= 0` 和合并阶段同样重要。
