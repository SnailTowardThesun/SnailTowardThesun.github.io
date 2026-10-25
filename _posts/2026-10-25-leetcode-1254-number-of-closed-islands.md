---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1254: 统计封闭岛屿的数目"
categories: LeetCode
tags: [中等, 并查集, 图, 网格]
---

> 网格连通性问题加一个哨兵节点，就能把「贴边界」变成一次合并：所有触边的陆地都归入哨兵分量，最后把它排除即可。

## 题目

LeetCode 1254. Number of Closed Islands（统计封闭岛屿的数目）

Difficulty: **Medium**

二维矩阵 `grid` 由 `0`（陆地）和 `1`（水域）组成。

「岛屿」是由上下左右四个方向相邻的 `0` 组成的最大连通群，「封闭岛屿」是完全被 `1`（水域）包围的岛屿——即岛屿中任何格子都不接触矩阵边界。

请返回封闭岛屿的数目。

约束：

- `1 <= grid.length, grid[i].length <= 100`
- `0 <= grid[i][j] <= 1`

### 示例

```
输入：grid = [[1,1,1,1,1,1,1,0],
             [1,0,0,0,0,1,1,0],
             [1,0,1,0,1,1,1,0],
             [1,0,0,0,0,1,0,1],
             [1,1,1,1,1,1,1,0]]
输出：2
解释：灰色部分是两个封闭岛屿，因为它们四周完全被 1 包围。

输入：grid = [[0,0,1,0,0],[0,1,0,1,0],[0,1,1,1,0]]
输出：1

输入：grid = [[1,1,1,1,1,1,1],
             [1,0,0,0,0,0,1],
             [1,0,1,1,1,0,1],
             [1,0,1,0,1,0,1],
             [1,0,1,1,1,0,1],
             [1,0,0,0,0,0,1],
             [1,1,1,1,1,1,1]]
输出：2
```

## 解题思路

这题是典型的网格连通性问题，除了 DFS/BFS 淹没边界岛屿外，还可以用并查集优雅地解决。

### 哨兵节点：把「贴边界」变成一次合并

封闭岛屿的定义可以反过来理解：**不封闭 = 触碰矩阵边界**。只要一个陆地格位于四条边界上，它所在的整个连通分量都不可能被水域完全包围。

于是引入编号 `0` 的格子作为哨兵（它同时也是左上角真实格子的编号），把四条边界上的所有陆地格统一与哨兵合并。这样所有「贴边岛屿」最终都落在哨兵所在的分量里。

### 合并相邻陆地

遍历整个矩阵，对每个值为 `0` 的格子只需向左、向上各尝试一次合并——因为右侧和下方的格子会在自己轮到时反向补上这两对关系，每一对相邻陆地恰好被处理一次。

### 统计封闭岛屿

合并完成后，收集所有陆地格的根节点并去重，得到陆地分量总数；若哨兵的根也在集合中（说明存在贴边岛屿），总数减一。剩下的就是被水域完全包围的封闭岛屿数。

以示例 2 为例，`grid = [[0,0,1,0,0],[0,1,0,1,0],[0,1,1,1,0]]`：上下边界的一整排陆地全部与哨兵合并成一个分量；中间 `(1,2)` 的陆地四周都是 1，自成一个分量。去重后有 2 个根，减去哨兵分量后答案为 `1`。

### 复杂度分析

设矩阵大小为 `m × n`，`α` 为反阿克曼函数（并查集路径压缩 + 按秩合并后的近似常数）。每个格子做常数次合并/查询操作，时间复杂度 `O(mn·α(mn))`，并查集的 `parent` 和 `rank` 数组占用 `O(mn)` 空间。

## 代码实现

```python
class UnionFind:
    """路径压缩 + 按秩合并的并查集。"""

    def __init__(self, n: int) -> None:
        self.parent = list(range(n))
        self.rank = [0] * n

    def find(self, x: int) -> int:
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])  # 路径压缩
        return self.parent[x]

    def union(self, x: int, y: int) -> None:
        root_x, root_y = self.find(x), self.find(y)
        if root_x == root_y:
            return

        # 按秩合并：矮树挂到高树下，避免树退化成链表
        if self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
        elif self.rank[root_x] < self.rank[root_y]:
            self.parent[root_x] = root_y
        else:
            self.parent[root_y] = root_x
            self.rank[root_x] += 1


class Solution:
    def closedIsland(self, grid: list[list[int]]) -> int:
        m, n = len(grid), len(grid[0])
        uf = UnionFind(m * n)
        land = 0

        # 四条边界上的陆地统一并入哨兵节点 0：所在岛屿必然接触矩阵外缘
        for i in range(m):
            if grid[i][0] == land:
                uf.union(i * n, 0)
            if grid[i][n - 1] == land:
                uf.union(i * n + n - 1, 0)
        for j in range(1, n - 1):
            if grid[0][j] == land:
                uf.union(j, 0)
            if grid[m - 1][j] == land:
                uf.union((m - 1) * n + j, 0)

        # 每个格子只需向左、向上尝试合并，即可覆盖每一对相邻陆地
        for i in range(m):
            for j in range(n):
                if grid[i][j] != land:
                    continue
                if i > 0 and grid[i - 1][j] == land:
                    uf.union(i * n + j, (i - 1) * n + j)
                if j > 0 and grid[i][j - 1] == land:
                    uf.union(i * n + j, i * n + j - 1)

        # 统计陆地连通分量的根，再排除与哨兵 0 同根的「边界岛屿」
        roots = {uf.find(i * n + j) for i in range(m) for j in range(n) if grid[i][j] == land}
        total = len(roots)
        if uf.find(0) in roots:
            total -= 1
        return total
```

### 代码解析

- **哨兵复用 0 号节点**：左上角格子本身就是边界格，直接拿它的编号当哨兵，不需要额外开辟 `m*n + 1` 个节点；
- **边界四条边分开处理**：左右两列在每个 `i` 处理，上下两行从 `j = 1` 到 `n - 2`，避免四个角被重复合并（重复合并本身无害，只是省几次操作）；
- **只向左、向上合并**：每对相邻陆地只被访问一次，`grid[i][j] != land` 的水域格直接跳过；
- **`uf.find(0) in roots` 的边界含义**：哨兵根出现在陆地根集合中，说明矩阵存在贴边陆地分量，需要从分量总数中剔除。若矩阵全是水域 `1`，集合为空，直接返回 0；
- **路径压缩 + 按秩合并**：两者叠加让单次操作的均摊代价接近常数，即使 100×100 的最大规模也毫无压力。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # 官方示例
    assert (
        solution.closedIsland(
            [
                [1, 1, 1, 1, 1, 1, 1, 0],
                [1, 0, 0, 0, 0, 1, 1, 0],
                [1, 0, 1, 0, 1, 1, 1, 0],
                [1, 0, 0, 0, 0, 1, 0, 1],
                [1, 1, 1, 1, 1, 1, 1, 0],
            ]
        )
        == 2
    )
    assert solution.closedIsland([[0, 0, 1, 0, 0], [0, 1, 0, 1, 0], [0, 1, 1, 1, 0]]) == 1
    assert (
        solution.closedIsland(
            [
                [1, 1, 1, 1, 1, 1, 1],
                [1, 0, 0, 0, 0, 0, 1],
                [1, 0, 1, 1, 1, 0, 1],
                [1, 0, 1, 0, 1, 0, 1],
                [1, 0, 1, 1, 1, 0, 1],
                [1, 0, 0, 0, 0, 0, 1],
                [1, 1, 1, 1, 1, 1, 1],
            ]
        )
        == 2
    )

    # 边界情况
    assert solution.closedIsland([[1]]) == 0  # 没有陆地
    assert solution.closedIsland([[0]]) == 0  # 单格陆地接触边界
    assert solution.closedIsland([[0, 0], [0, 0]]) == 0  # 全陆地必然接触边界
    assert solution.closedIsland([[1, 1, 1], [1, 0, 1], [1, 1, 1]]) == 1  # 单格被水域完全包围
    assert solution.closedIsland([[1, 1], [1, 0]]) == 0  # 角格陆地仍接触矩阵外缘
```

这组用例覆盖了三个容易判断错的地方：全水域返回 0、单格陆地贴边不算封闭、以及「角格只被两条边的水域包围」仍然不是封闭岛屿。

## 总结

- 封闭岛屿的判定等价于排除所有触碰矩阵边界的连通分量，用哨兵节点把边界条件转成一次普通合并，代码不需要任何特判；
- 网格并查集的关键是坐标压缩 `i * n + j`，以及每个格子只向左、向上合并，保证每对相邻关系只处理一次；
- 测试中「角格陆地」这类用例最容易被忽略，边界判定必须覆盖四条边，缺任何一条都会误判为封闭岛屿。
