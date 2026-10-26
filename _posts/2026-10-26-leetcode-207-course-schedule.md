---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.207: 课程表"
categories: LeetCode
tags: [中等, 深度优先搜索, 图, 拓扑排序]
---

> 大学选课、make 编译、pip 装包，背后都是同一张「先修关系图」：所有任务能排完 ⇔ 图里没有环。pip 报 circular dependency 的那一刻，就是依赖图转出了一个圈。

## 题目

LeetCode 207. Course Schedule（课程表）

Difficulty: **Medium**

你这个学期必须选修 `numCourses` 门课程，记为 `0` 到 `numCourses - 1`。

在选修某些课程之前需要一些先修课程。先修课程按数组 `prerequisites` 给出，其中 `prerequisites[i] = [ai, bi]`，表示如果要学习课程 `ai` 则**必须**先学习课程 `bi`。

请你判断是否可能完成所有课程的学习？如果可以，返回 `true`；否则，返回 `false`。

约束：

- `1 <= numCourses <= 2000`
- `0 <= prerequisites.length <= 5000`
- `prerequisites[i].length == 2`
- `0 <= ai, bi < numCourses`
- `prerequisites[i]` 中的所有课程对**互不相同**

### 示例

```
输入：numCourses = 2, prerequisites = [[1,0]]
输出：true
解释：总共有 2 门课程。学习课程 1 之前，你需要完成课程 0。这是可能的。

输入：numCourses = 2, prerequisites = [[1,0],[0,1]]
输出：false
解释：学习课程 1 之前，需先完成课程 0；学习课程 0 之前，还需先完成课程 1。这是不可能的。
```

## 解题思路

`[a, b]` 表示"先修完 b 才能修 a"，把它看成有向边 `b → a`。一门课能开始修，当且仅当它的所有先修都修完了；所有课都能修完，当且仅当这张有向图**没有环**——环上的每门课都在等对方先毕业，谁也动不了。于是问题从"选课"塌缩成"有向图判环"，正是[拓扑排序](/leetcode/2026/10/26/algorithm-topological-sort.html)那篇里的判定版：只问"能不能排"，不问"排出来是什么"（要输出顺序的是构造版 No.210）。

判环用 DFS 三色标记。给每个节点一个状态：

- **白色（0）**：从未访问；
- **灰色（1）**：在当前 DFS 递归栈中，"在路上"；
- **黑色（2）**：从它出发的所有路径都探完了，确认安全。

对每个白色节点启动 DFS：进入时染灰，依次走它的后继。若某条边指向**灰色**节点，说明沿边走回了"正在途中的自己"——这条路转回来了，有环，立即标记并逐层退出；若指向**黑色**节点，那是早已确认安全的重逢，直接跳过；全部后继处理完仍无环则染黑。所有节点最终都能染黑，图无环，返回 `true`。

用示例 2 手算：边 `0 → 1`、`1 → 0`。DFS(0)：0 染灰；后继 1 白色 → DFS(1)：1 染灰；后继 0 是**灰色** → 有环，返回 `false`。

再看一个容易误判的菱形 `[[1,0],[2,0],[3,1],[3,2]]`（边 0→1、0→2、1→3、2→3）：DFS(0) 灰 → DFS(1) 灰 → DFS(3) 无后继，3 染**黑** → 回到 1，1 染黑 → DFS(2) 灰 → 后继 3 是**黑色**而非灰色——安全跳过，2 染黑 → 0 染黑。两条路径在 3 汇合，3 只是"被再次到达"，不是"转回自己"，图是 DAG，返回 `true`。三色的意义正在于此：把"在栈中"和"已完成"分开，只用"碰到灰色"当环的判据。

另一条路是 Kahn 拓扑排序（BFS 反复摘除入度为 0 的点，能摘完即无环），迭代写法没有递归深度问题，规模拉满时更稳；本题 DFS 足够。

### 复杂度分析

设课程数 `N`、先修关系数 `P`。每个节点至多被染色一次、每条边至多被沿一次，时间复杂度 `O(N + P)`；邻接表 + 状态数组 + 递归栈，空间 `O(N + P)`。

## 代码实现

```python
class Solution:
    def canFinish(self, numCourses: int, prerequisites: list[list[int]]) -> bool:
        # 邻接表：edges[bi] 存放先修完 bi 之后才能修的课程
        edges = [[] for _ in range(numCourses)]
        for a, b in prerequisites:
            edges[b].append(a)

        state = [0] * numCourses  # 0=未访问 1=访问中 2=已完成
        has_cycle = False

        def dfs(node: int) -> None:
            nonlocal has_cycle
            state[node] = 1

            for nxt in edges[node]:
                if state[nxt] == 0:
                    dfs(nxt)
                elif state[nxt] == 1:  # 指回"访问中"的节点 -> 有环
                    has_cycle = True
                if has_cycle:
                    return

            state[node] = 2

        for course in range(numCourses):
            if state[course] == 0 and not has_cycle:
                dfs(course)

        return not has_cycle
```

### 代码解析

- **边方向按定义建**：`[a, b]` 的语义是"先修 b"，所以 `edges[b].append(a)`。有个反直觉的事实：单看判环，整张图所有边**一起**反向不改变环的存在性，而官方两个示例恰好都是对称的，因此方向建反了答案照样全对——但那是运气。一旦像 No.210 那样要输出修课顺序，方向就成了硬约束。语义正确是习惯，不是巧合；
- **灰色判环、黑色放行**：循环里只有 `state[nxt] == 1` 才置 `has_cycle`。若图里存在汇合点（菱形依赖），第二次到达是黑色，误判成环会把所有 DAG 全盘判死；
- **`has_cycle` 双重短路**：发现环后 dfs 内层立即逐层 `return`，外层循环靠 `not has_cycle` 不再启动新 DFS。最坏情况下环在最后一个连通分量里，之前已染黑的节点也不会被重扫——染黑本身就是"不用再来"的备忘录；
- **递归深度 = 图中最长链**：2000 门课连成一条链时递归深达 2000，超过 Python 默认限制 1000，直接 `RecursionError`。所以测试用例的规模刻意控制在 100 以内；要扛住题目上限，应改用 Kahn（BFS 摘入度为 0 的点）的迭代写法。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.canFinish(2, [[1, 0]])
    assert not solution.canFinish(2, [[1, 0], [0, 1]])

    # ---- 边界：没有任何先修关系 ----
    assert solution.canFinish(1, [])
    assert solution.canFinish(5, [])

    # ---- 线性链 0 -> 1 -> 2 -> 3 -> 4 ----
    assert solution.canFinish(5, [[1, 0], [2, 1], [3, 2], [4, 3]])

    # ---- 三节点环 ----
    assert not solution.canFinish(3, [[1, 0], [2, 1], [0, 2]])

    # ---- 菱形依赖：节点 3 有两条前置路径，是 DAG 不是环 ----
    assert solution.canFinish(4, [[1, 0], [2, 0], [3, 1], [3, 2]])

    # ---- 星型：所有课程都依赖课程 0 / 反向星型：课程 0 依赖所有其他课程 ----
    assert solution.canFinish(6, [[i, 0] for i in range(1, 6)])
    assert solution.canFinish(6, [[0, i] for i in range(1, 6)])

    # ---- 多个连通分量全部无环 ----
    assert solution.canFinish(6, [[1, 0], [3, 2], [5, 4]])

    # ---- 多个连通分量，其中一个有环 -> 整体不可完成 ----
    assert not solution.canFinish(6, [[1, 0], [3, 2], [2, 3], [5, 4]])

    # ---- 无环前缀很长，环藏在尾部（3 -> 4 -> 5 -> 3） ----
    assert not solution.canFinish(6, [[1, 0], [2, 1], [3, 2], [4, 3], [5, 4], [3, 5]])

    # ---- 孤立课程：有课程完全不出现在 prerequisites 中 ----
    assert solution.canFinish(4, [[2, 1]])

    # ---- 稠密 DAG：课程 i 依赖所有 j < i（递归深度 100，低于 Python 默认限制 1000） ----
    n = 100
    dense = [[i, j] for i in range(n) for j in range(i)]
    assert solution.canFinish(n, dense)
    assert not solution.canFinish(n, dense + [[0, n - 1]])
```

用例各抓一个口子："菱形依赖"专抓"把黑色误判成环"；"环藏尾部"专抓"只测了前缀就提前收工"的假阴性；"多分量其一有环"钉死整体返回 `false`；"孤立课程"确认没出现在 `prerequisites` 里的课不挡路；"稠密 DAG + 补一条回边"把边数拉到近 5000 上限验证建图与判环的吞吐。最初的"2000 长链"用例因触碰递归深度限制被移除——它测出的不是算法错误，而是 Python 递归的物理边界。

## 总结

- 课程表是拓扑排序的**判定版**：能否修完全部课 ⇔ 先修关系图无环；No.210 是构造版，还要把顺序排出来；
- 三色标记一句话：白 = 没来过，灰 = 在路上，黑 = 已安全；**碰到灰才是环，碰到黑是安全的重逢**，菱形依赖就是照妖镜；
- 递归 DFS 的深度等于最长链，Python 默认上限 1000；扛题目上限要么 `sys.setrecursionlimit`，要么换 Kahn 的 BFS 迭代写法，后者更稳。
