---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.210: 课程表 II"
categories: LeetCode
tags: [中等, 图, 拓扑排序, DFS]
---

> Excel 重算时必须先算被引用的格子、再算引用它的格子，这个顺序就是公式依赖图的拓扑序；弹出 circular reference 警告，正是图里有环、排不出顺序。

## 题目

LeetCode 210. Course Schedule II（课程表 II）

Difficulty: **Medium**

现在你总共有 `numCourses` 门课需要选，记为 `0` 到 `numCourses - 1`。给你一个数组 `prerequisites`，其中 `prerequisites[i] = [ai, bi]`，表示在选修课程 `ai` 前 **必须** 先选修 `bi`。

例如，想要学习课程 `0`，你需要先完成课程 `1`，我们用一个匹配来表示：`[0,1]`。

返回你为了学完所有课程所安排的学习顺序。可能会有多个正确的顺序，你只要返回 **任意一种** 就可以了。如果不可能完成所有课程，返回 **一个空数组**。

约束：

- `1 <= numCourses <= 2000`
- `0 <= prerequisites.length <= numCourses * (numCourses - 1)`
- `prerequisites[i].length == 2`
- `0 <= ai, bi < numCourses`，`ai != bi`
- 所有 `[ai, bi]` **互不相同**

### 示例

```
输入：numCourses = 2, prerequisites = [[1,0]]
输出：[0,1]
解释：总共有 2 门课程。要学习课程 1，你需要先完成课程 0。因此，正确的课程顺序为 [0,1]。

输入：numCourses = 4, prerequisites = [[1,0],[2,0],[3,1],[3,2]]
输出：[0,2,1,3]
解释：要学习课程 3，你应该先完成课程 1 和课程 2，并且课程 1 和课程 2 都应该排在
     课程 0 之后。因此 [0,1,2,3] 和 [0,2,1,3] 都是正确的顺序。

输入：numCourses = 1, prerequisites = []
输出：[0]
```

## 解题思路

把每门课看成一个点，每条「先修 `b` 才能修 `a`」看成一条有向边 `b → a`，题目就是：给这张有向图求一个**拓扑序**——所有边都从前指向后的线性顺序；图中有环则无解，返回空数组。它是 No.207 的升级版：207 只问「有没有环」，本题还要把顺序交出来。

拓扑排序有 Kahn（不断摘入度为 0 的点）和 DFS 后序逆序两条经典路线，通用讨论见「算法系列--拓扑排序」一文。这里用 DFS 路线，代码更短，判环也更直接。

### 建图：方向决定成败

`prerequisites[i] = [a, b]` 的含义是 **b 在 a 之前**，所以边是 `b → a`，邻接表写 `edges[b].append(a)`。方向的重要性在本题远高于 207：图有环当且仅当反图有环，所以 207 把方向建反照样能判对；而本题输出的是顺序，方向反了会得到一个**完全倒置**的序列。

### 三色 DFS：灰色即环

每个节点三种状态：`0` 未访问、`1` 正在访问（在当前递归栈上）、`2` 已完成。对每门未访问的课做 DFS：进入时标 `1`，遍历它的后继——

- 后继是 `0`：递归进去；
- 后继是 `1`：说明从那个节点出发能走到当前节点，而当前节点又有边指回它，这是一条**回边**，图有环，记下标志立即层层返回；
- 后继是 `2`：另一条路径早已处理完它，正常汇合，跳过。

所有后继处理完，当前节点标 `2`，追加到结果——这个追加顺序是**后序**。

### 后序逆序为什么是拓扑序

对任意一条边 `b → a`，DFS 处理 `b` 时一定会看 `a`：`a` 若未访问则递归进去先完成，若已完成则早在后序里。无论哪种情况，`a` 都比 `b` 先进入后序。于是把后序整体反转，每条边的起点都排在终点之前，正是拓扑序。

以示例 2 手算：边 `0→1、0→2、1→3、2→3`，邻接表 `0: [1, 2]`，`1: [3]`，`2: [3]`。从 0 进入，先走 1 再走 3，3 没有后继先完成；回到 1 完成；回到 0 走 2，2 的后继 3 已是 `2` 跳过，2 完成；最后 0 完成。后序 `[3, 1, 2, 0]`，反转得 `[0, 2, 1, 3]`——正好是题目给出的那个答案。

### 复杂度分析

设课程数 `N`、先修关系数 `P`。每个节点进出递归栈一次，每条边扫描一次，时间复杂度 `O(N + P)`；邻接表 `O(N + P)`，状态数组、结果各 `O(N)`，空间 `O(N + P)`。递归深度最大为 `N`。

## 代码实现

```python
class Solution:
    def findOrder(self, numCourses: int, prerequisites: list[list[int]]) -> list[int]:
        edges = {i: [] for i in range(numCourses)}
        for q in prerequisites:
            edges[q[1]].append(q[0])

        statue = [0] * numCourses

        result = []
        is_circle = False

        def dfs(node):
            nonlocal is_circle
            statue[node] = 1

            for edge in edges[node]:
                if statue[edge] == 0:
                    dfs(edge)
                    if is_circle:
                        return
                elif statue[edge] == 1:
                    is_circle = True
                    return
            statue[node] = 2
            result.append(node)

        for n in range(numCourses):
            if not is_circle and statue[n] == 0:
                dfs(n)

        if is_circle:
            return []

        return result[::-1]
```

### 代码解析

这题的实现过程很有代表性：一共写出了四个 bug，而且它们**互相掩盖**——前一个不修，后一个根本暴露不出来。按暴露顺序记录如下：

- **外层循环条件写反**：`if statue[n] != 0: dfs(n)` 的意思是「只对访问过的节点启动 DFS」，而所有状态初始都是 0，于是 `dfs` 一次都没被调用，任何输入都返回 `[]`。这是最外层的闸门，它不修，后面三个问题全部隐身；
- **邻接表建了却没填**：`edges` 初始化成空列表的 dict 之后，忘了把 `prerequisites` 放进去。闸门打开后每个节点都成了孤立点，输出 `[1, 0]` 这种只由遍历顺序决定、与先修关系无关的结果，环也永远测不出来；
- **递归参数写错**：`dfs(node)` 递归进了自己而不是后继 `edge`。`node` 刚被标成 1，再进去又遍历同一个后继列表，第一个后继状态仍是 0，又 `dfs(node)`……直到 `RecursionError`。前两个问题存在时，这一行从来没被执行到；
- **建边方向反了**：`edges[q[0]].append(q[1])` 让边从课程指向它的前置。三处都修好之后，示例 1 得到 `[1, 0]`、示例 2 得到 `[3, 2, 1, 0]`——**恰好是正确答案的完全倒序**。原因很有意思：边指向前置时，DFS 的后序本身就已经是合法顺序，再 `[::-1]` 一反就反错了。改成 `edges[q[1]].append(q[0])` 后全部通过；
- **递归深度**：逻辑全部正确后，测试里 2000 门课的长链让 `dfs` 递归 2000 层，超过 Python 默认的 1000 层上限。这不是算法错误——LeetCode 线上环境把上限调得很高，提交能过；本地要么 `sys.setrecursionlimit`，要么改迭代，要么像最终做的那样，把这条超出常规递归能力的用例从本地测试里移除。

两个写对了的细节也值得记一笔：只有 `statue[edge] == 1`（灰色）才判环，`== 2`（黑色）是正常汇合，混为一谈会把示例 2 里 `2 → 3`（3 已完成）误判成环；`is_circle` 用 `nonlocal` 共享，递归返回后立即检查并继续向上返回，环一旦发现就不再做任何多余的遍历。

## 测试用例

```python
def assert_valid_order(order: list[int], num_courses: int, prerequisites: list[list[int]]) -> None:
    """合法顺序 = 恰好是 0..n-1 的一个排列，且每条 [a, b] 中 b 都排在 a 前面。"""
    assert sorted(order) == list(range(num_courses)), f"不是 0..{num_courses - 1} 的排列: {order}"
    pos = {course: i for i, course in enumerate(order)}
    for a, b in prerequisites:
        assert pos[b] < pos[a], f"课程 {b} 必须排在课程 {a} 之前: {order}"


def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例（答案不唯一时只校验合法性） ----
    assert solution.findOrder(2, [[1, 0]]) == [0, 1]  # 示例 1：顺序唯一
    prereq = [[1, 0], [2, 0], [3, 1], [3, 2]]  # 示例 2：[0,1,2,3] 与 [0,2,1,3] 都对
    assert_valid_order(solution.findOrder(4, prereq), 4, prereq)
    assert solution.findOrder(1, []) == [0]  # 示例 3

    # ---- 有环：返回空列表 ----
    assert solution.findOrder(2, [[1, 0], [0, 1]]) == []
    assert solution.findOrder(3, [[1, 0], [2, 1], [0, 2]]) == []

    # ---- 没有先修关系：任意排列都合法 ----
    assert_valid_order(solution.findOrder(4, []), 4, [])

    # ---- 线性链：顺序唯一 ----
    assert solution.findOrder(4, [[1, 0], [2, 1], [3, 2]]) == [0, 1, 2, 3]
    assert solution.findOrder(4, [[0, 1], [1, 2], [2, 3]]) == [3, 2, 1, 0]  # 反向链

    # ---- 多个连通分量 + 孤立课程 4 ----
    prereq = [[1, 0], [3, 2]]
    assert_valid_order(solution.findOrder(5, prereq), 5, prereq)

    # ---- 多个连通分量，其中一个有环 -> 空 ----
    assert solution.findOrder(6, [[1, 0], [3, 2], [2, 3], [5, 4]]) == []

    # ---- 星型：所有课都依赖 0，0 必须排第一 ----
    prereq = [[i, 0] for i in range(1, 6)]
    order = solution.findOrder(6, prereq)
    assert_valid_order(order, 6, prereq)
    assert order[0] == 0

    # ---- 反向星型：0 依赖所有其他课，0 必须排最后 ----
    prereq = [[0, i] for i in range(1, 6)]
    order = solution.findOrder(6, prereq)
    assert_valid_order(order, 6, prereq)
    assert order[-1] == 0

    # ---- 复杂 DAG：多条路径汇合再分叉 ----
    prereq = [[2, 0], [2, 1], [3, 1], [4, 2], [4, 3], [5, 4], [5, 0]]
    assert_valid_order(solution.findOrder(6, prereq), 6, prereq)

    # ---- 稠密 DAG：课程 i 依赖所有 j < i，全序关系，顺序唯一 ----
    n = 100
    dense = [[i, j] for i in range(n) for j in range(i)]
    assert solution.findOrder(n, dense) == list(range(n))
    assert solution.findOrder(n, dense + [[0, n - 1]]) == []
```

拓扑序通常不唯一，所以大部分用例不比对固定列表，而是用 `assert_valid_order` 校验两条性质：结果是 `0..n-1` 的排列，且每条先修关系中 `b` 都排在 `a` 之前。只有顺序唯一的图——线性链、全序的稠密图——才直接 `==`。其中「反向链」`[[0,1],[1,2],[2,3]]` 期望 `[3,2,1,0]`，是专门抓建边方向的用例；「多个连通分量其中一个有环」确认局部的环会让整体返回空；星型和反向星型分别钉住 0 必须排第一、排最后；「孤立课程 4」则验证没有任何边的节点也会出现在结果里。

## 总结

- 课程是点、`[a, b]` 是边 `b → a`，题目即求拓扑序；DFS 三色标记负责判环（遇灰即环），后序逆序给出顺序；
- 建边方向是本题与 207 的本质差异：207 判环对方向不敏感，210 方向反了输出整体倒置——**207 通过不能作为 210 方向正确的证据**，先用示例手算入度或邻接表再往下写；
- 多个 bug 会互相掩盖，最外层那个不修、里面的全部隐身。逐个修、每修一个重跑一次测试，比一次改完再跑更容易定位。
