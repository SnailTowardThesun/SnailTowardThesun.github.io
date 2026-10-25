---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.200: 岛屿数量"
categories: LeetCode
tags: [中等, 并查集, 图, 网格]
---

> 网格并查集的钥匙是坐标压缩 i*n+j：四方向相邻关系被拆成一次次的 union，岛屿数就是所有陆地格根节点的去重个数。

## 题目

LeetCode 200. Number of Islands（岛屿数量）

Difficulty: **Medium**

给你一个由 `'1'`（陆地）和 `'0'`（水）组成的二维网格 `grid`，请你计算网格中岛屿的数量。

岛屿总是被水包围，并且每座岛屿只能由水平方向和/或竖直方向上相邻的陆地连接形成。

此外，你可以假设该网格的四条边均被水包围。

约束：

- `1 <= m, n <= 300`
- `grid[i][j]` 的值为 `'0'` 或 `'1'`

### 示例

```
输入：grid = [["1","1","1","1","0"],
             ["1","1","0","1","0"],
             ["1","1","0","0","0"],
             ["0","0","0","0","0"]]
输出：1

输入：grid = [["1","1","0","0","0"],
             ["1","1","0","0","0"],
             ["0","0","1","0","0"],
             ["0","0","0","1","1"]]
输出：3
解释：三座岛屿分别位于左上（4 格）、中部（1 格）和右下（2 格）。
```

## 解题思路

经典的网格连通分量计数，DFS 淹岛、BFS 扩散都能做，这里用并查集：不修改原网格，把「哪些格子属于同一座岛」动态维护成集合关系。

### 坐标压缩

并查集的节点是整数，把 `(i, j)` 压缩成一维编号 `i * n + j`，`m × n` 个格子正好对应 `0 .. m*n-1`。四个方向的邻居编号只差一个常数：

- 上 `(i-1)*n + j`，下 `(i+1)*n + j`；
- 左 `i*n + j - 1`，右 `i*n + j + 1`。

### 合并相邻陆地

遍历网格，对每个陆地格，把上下左右四个方向相邻的陆地格与它合并。每对相邻陆地会被两个格子各处理一次（A 找 B、B 找 A），但并查集对已连通的合并直接返回，重复无害；若想省一半操作，只查上、左两个方向即可覆盖每对关系。

### 统计岛屿数

合并完成后，一座岛屿 = 一个陆地连通分量 = 一个根节点。收集所有陆地格 `find` 的根并去重，集合的大小就是岛屿数。水格自成一集但不参与统计，天然被排除。

以示例 2 为例：左上 4 格陆地互相合并成一个分量（根 0），中部单格 `(2,2)` 没有任何相邻陆地、自成一集（根 12），右下 `(3,3)`、`(3,4)` 合并成第三个分量（根 18）。去重后 `{0, 12, 18}`，答案 `3`。

### 复杂度分析

设矩阵大小为 `m × n`，`α` 为反阿克曼函数（路径压缩 + 按秩合并后的近似常数）。每个格子做常数次合并/查询，时间复杂度 `O(mn·α(mn))`，`parent` 和 `rank` 数组占用 `O(mn)` 空间。

## 代码实现

```python
class UnionFind:
    def __init__(self, n):
        self._parent = list(range(n))
        self._rank = [0] * n

    def find(self, x):
        if self._parent[x] != x:
            self._parent[x] = self.find(self._parent[x])

        return self._parent[x]

    def union(self, x, y):
        root_x, root_y = self.find(x), self.find(y)
        if root_x == root_y:
            return

        if self._rank[root_x] > self._rank[root_y]:
            self._parent[root_y] = root_x
        elif self._rank[root_x] < self._rank[root_y]:
            self._parent[root_x] = root_y
        else:
            self._parent[root_y] = root_x
            self._rank[root_x] += 1


class Solution:
    def numIslands(self, grid: list[list[str]]) -> int:
        m = len(grid)
        n = len(grid[0])
        uf = UnionFind(m * n)

        for i in range(m):
            for j in range(n):
                if grid[i][j] == "0":
                    continue

                # up, bottom, left, right
                if i > 0:  # up
                    if grid[i - 1][j] == "1":
                        uf.union(i * n + j, (i - 1) * n + j)
                if i < m - 1:
                    if grid[i + 1][j] == "1":
                        uf.union(i * n + j, (i + 1) * n + j)
                if j > 0:
                    if grid[i][j - 1] == "1":
                        uf.union(i * n + j, i * n + j - 1)
                if j < n - 1:
                    if grid[i][j + 1] == "1":
                        uf.union(i * n + j, i * n + j + 1)

        dic = set()
        for i in range(m):
            for j in range(n):
                if grid[i][j] == "1":
                    dic.add(uf.find(i * n + j))
        return len(dic)
```

### 代码解析

- **字符 `'1'` 不是数字 `1`**：本题网格元素是字符串，判断陆地必须写 `grid[i][j] == "1"`。实现时曾把统计循环写成 `== 1`，字符串与整数永不相等，任何输入都返回 0——两处循环一个用字符一个用数字，正是最容易埋下的坑；
- **右邻居下标的乘号**：`i * n + j + 1` 里 `i` 后面是乘号。曾误写成 `i + n + j + 1`，指向完全无关的格子：错误目标恰好是同岛陆地或水格时侥幸不报错，是另一座岛的陆地时就把两座岛悄悄接在一起，岛屿数悄悄少 1。这种「部分用例通过」的下标笔误比崩溃更难发现；
- **统计阶段重新判断陆地**：`find` 对水格同样有效，所以收集根时必须再用 `== "1"` 过滤一次，水格的分量不能计入；
- **双向合并冗余但安全**：四个方向都尝试时每对邻居合并两次，`union` 开头的同根判断让第二次直接返回；改成只查上、左即可减半；
- **递归 `find` 的深度安全**：按秩合并保证树高不超过 `O(log n)`，300×300 的最大规模下递归深度也远低于 Python 上限。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # 官方示例
    assert (
        solution.numIslands(
            [
                ["1", "1", "1", "1", "0"],
                ["1", "1", "0", "1", "0"],
                ["1", "1", "0", "0", "0"],
                ["0", "0", "0", "0", "0"],
            ]
        )
        == 1
    )
    assert (
        solution.numIslands(
            [
                ["1", "1", "0", "0", "0"],
                ["1", "1", "0", "0", "0"],
                ["0", "0", "1", "0", "0"],
                ["0", "0", "0", "1", "1"],
            ]
        )
        == 3
    )

    # 边界情况
    assert solution.numIslands([["1"]]) == 1  # 单格陆地
    assert solution.numIslands([["0"]]) == 0  # 单格水域
    assert solution.numIslands([["0", "0"], ["0", "0"]]) == 0  # 全是水
    assert solution.numIslands([["1", "1"], ["1", "1"]]) == 1  # 全是陆地，整格为一座岛
    assert solution.numIslands([["1", "0"], ["0", "1"]]) == 2  # 对角相邻不连通
    assert solution.numIslands([["0", "1"], ["1", "0"]]) == 2  # 反对角同理
    assert solution.numIslands([["1", "0", "1", "1", "0"]]) == 2  # 单行：水平相邻才连通
    assert solution.numIslands([["1"], ["1"], ["0"], ["1"]]) == 2  # 单列：竖直相邻才连通

    # 蛇形路径：上下左右交错连成一座岛
    assert (
        solution.numIslands(
            [
                ["1", "1", "1"],
                ["0", "0", "1"],
                ["1", "1", "1"],
                ["1", "0", "0"],
                ["1", "1", "1"],
            ]
        )
        == 1
    )

    # 环形陆地：中间的水洞不会把岛拆开
    assert solution.numIslands([["1", "1", "1"], ["1", "0", "1"], ["1", "1", "1"]]) == 1

    # 棋盘格：所有陆地互不相邻，各成一座岛
    assert (
        solution.numIslands(
            [
                ["1", "0", "1", "0"],
                ["0", "1", "0", "1"],
                ["1", "0", "1", "0"],
                ["0", "1", "0", "1"],
            ]
        )
        == 8
    )
```

对角相邻、单行、单列三条用例专门钉死「只有上下左右才算连通」；蛇形和环形验证多转折路径不会被拆断；棋盘格则反过来确认互不相邻的陆地不会被误合并——这几类正是下标笔误最容易暴露的地方。

## 总结

- 网格并查集三板斧：坐标压缩 `i*n+j`、相邻陆地两两 `union`、陆地根去重计数，不修改原网格；
- 本题的两个高频笔误都藏在细节里：字符串 `'1'` 与整数 `1` 的比较恒为假、右邻居下标 `i*n+j+1` 的乘号，两者都表现为「部分用例通过」而非崩溃，只有覆盖对角/单行/单列/棋盘格的用例才能稳定抓住；
- 与 No.1254 封闭岛屿同源：那题在本文基础上加一个哨兵节点排除贴边分量，坐标压缩与合并策略完全复用。
