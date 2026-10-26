---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.133: 克隆图"
categories: LeetCode
tags: [中等, 图, DFS, 哈希表]
---

> Python 标准库 copy.deepcopy 克隆对象图时，内部也维护一张 memo 字典记录「原对象 → 副本」。本题考的正是这个机制：哈希表破环，一次遍历得到结构同构、对象全新的图。

## 题目

LeetCode 133. Clone Graph（克隆图）

Difficulty: **Medium**

给你 **无向连通图** 中一个节点的引用，请你返回该图的 **深拷贝（克隆）**。图中的每个节点都包含它的值 `val`（int）和其邻居的列表 `neighbors`（`list[Node]`）。

节点定义：

```python
class Node:
    def __init__(self, val=0, neighbors=None):
        self.val = val
        self.neighbors = neighbors if neighbors is not None else []
```

测试用例用邻接列表表示：每个节点的值与它的索引相同（第一个节点 `val = 1`），给定节点始终是值为 1 的节点。你必须将 **给定节点的拷贝** 作为对克隆图的引用返回。

约束：

- 图中的节点数在 `[0, 100]` 之间
- `1 <= Node.val <= 100`，且每个节点值都是唯一的
- 图中没有重复的边，也没有自环
- 图是连通图，你可以从给定节点访问到所有节点

### 示例

```
输入：adjList = [[2,4],[1,3],[2,4],[1,3]]
输出：[[2,4],[1,3],[2,4],[1,3]]
解释：图中有 4 个节点。节点 1 的邻居是 2 和 4；节点 2 的邻居是 1 和 3；
     节点 3 的邻居是 2 和 4；节点 4 的邻居是 1 和 3。

输入：adjList = [[]]
输出：[[]]
解释：图仅有一个值为 1 的节点，它没有任何邻居。

输入：adjList = []
输出：[]
解释：空图，不含任何节点。
```

## 解题思路

### 难点在环

无向图每条边都是双向的，从节点 1 出发遍历，迟早会沿着某条边绕回已访问过的节点。朴素递归「克隆自己 → 克隆邻居」遇到环就会无限递归；即便没有环，菱形结构（两条路到达同一节点）也会让同一节点被克隆两份，破坏「深拷贝但保持同构」的要求。

### 哈希表破环

核心工具是一张哈希表 `lookup`：**原节点 → 克隆节点**。

1. 空节点直接返回 `None`；
2. 当前节点已在 `lookup` 中，说明副本已建好，直接返回对应引用——环在这里被截断，共享邻居（菱形）也复用同一个副本；
3. 否则创建副本，**立刻** 登记进 `lookup`，再 DFS 每个邻居填充 `clone.neighbors`。

### 登记必须先于递归

顺序是本题最容易写错的地方：副本必须在递归邻居 **之前** 登记。如果先递归再登记，递归沿着环回到自身时查表落空，又会创建一个新副本，无限递归直到栈溢出。「先登记、后递归」让环上的回边在查表时直接命中。

### 为什么不用并查集

图论标签下容易联想到并查集，但它在此无用武之地：并查集回答的是「两点是否连通 / 有几个连通分量」，而本题 **保证图连通**，跑一遍只能得到「1 个分量」，零信息增量。本题要的是构造——一份节点对象全新、邻接结构同构的图，需要的是「原节点 → 副本」的一一映射，这是遍历 + 哈希表的职责。并查集适合的是 No.200 岛屿数量这类连通分量计数问题。

### 复杂度分析

每个节点克隆一次、每条边经过两个方向各一次（无向图），时间复杂度 `O(N + E)`；`lookup` 与递归栈各占 `O(N)`，空间复杂度 `O(N)`。递归最深 `N` 层，本题 `N <= 100` 远低于 Python 限制；节点规模大时可换成 BFS 迭代写法。

## 代码实现

```python
class Node:
    def __init__(self, val=0, neighbors=None):
        self.val = val
        self.neighbors = neighbors if neighbors is not None else []


class Solution:
    def cloneGraph(self, node: Node | None) -> Node | None:
        # 原节点 -> 克隆节点。必须在递归邻居之前登记，环才能在这里被截断。
        lookup: dict[Node, Node] = {}

        def dfs(n: Node | None) -> Node | None:
            if not n:
                return None
            if n in lookup:
                return lookup[n]

            clone = Node(n.val, [])
            lookup[n] = clone
            for ne in n.neighbors:
                clone.neighbors.append(dfs(ne))

            return clone

        return dfs(node)
```

### 代码解析

- **登记先于递归**：`clone` 创建后立即 `lookup[n] = clone`，再遍历邻居。顺序颠倒后，环的回边查表落空，无限递归建新副本，这是本题最经典的错误；
- **dict 按对象身份索引**：`Node` 未定义 `__eq__`/`__hash__`，默认按 `id` 哈希，恰好符合「每个原节点恰好一个副本」的语义。按 `val` 建字典也可行（题目保证 `val` 唯一），但按身份更通用；
- **可变默认参数陷阱**：`Node.__init__` 用 `None` 哨兵而不是 `neighbors=[]`。后者会让所有无邻居节点共享同一个 list 对象，示例 2（`[[]]`）克隆后一旦修改一个节点的邻居，全部节点跟着变；
- **`Node(n.val, [])` 显式传新列表**：每个副本的邻居列表都是独立对象，深拷贝的「互不影响」由测试用例最后一段独立性断言钉死。

## 测试用例

```python
def build_graph(adj_list: list[list[int]]) -> Node | None:
    """LeetCode 邻接表 -> 图，返回值为 1 的节点；空列表返回 None。"""
    if not adj_list:
        return None
    nodes = {v: Node(v) for v in range(1, len(adj_list) + 1)}
    for v, neighbors in enumerate(adj_list, start=1):
        nodes[v].neighbors = [nodes[w] for w in neighbors]
    return nodes[1]


def graph_to_adj(node: Node | None) -> list[list[int]]:
    """图 -> LeetCode 邻接表（按 val 升序，便于断言）。"""
    if node is None:
        return []
    seen, order = set(), []
    queue = deque([node])
    while queue:
        cur = queue.popleft()
        if id(cur) in seen:
            continue
        seen.add(id(cur))
        order.append(cur)
        queue.extend(cur.neighbors)
    order.sort(key=lambda cur: cur.val)
    return [sorted(nb.val for nb in cur.neighbors) for cur in order]


def assert_deep_clone(adj_list: list[list[int]]) -> None:
    """按邻接表建图并克隆，校验：邻接结构一致 + 全部是新对象 + 每个节点只克隆一次。"""
    original = build_graph(adj_list)
    clone = Solution().cloneGraph(original)

    expected = [sorted(nb) for nb in adj_list]
    assert graph_to_adj(original) == expected
    assert graph_to_adj(clone) == expected  # 结构同构

    original_ids = {id(n) for n in bfs_nodes(original)}  # bfs_nodes 同 graph_to_adj 的收集逻辑
    clone_nodes = bfs_nodes(clone)
    assert all(id(n) not in original_ids for n in clone_nodes)  # 深拷贝：无原图对象混入
    assert sorted(n.val for n in clone_nodes) == list(range(1, len(adj_list) + 1))  # 只克隆一次


def test_solution() -> None:
    # ---- 官方示例 ----
    assert_deep_clone([[2, 4], [1, 3], [2, 4], [1, 3]])  # 示例 1：四节点环
    assert_deep_clone([[]])  # 示例 2：单节点无邻居
    assert Solution().cloneGraph(None) is None  # 示例 3：空图

    # ---- 边界：两节点一条边 / 链 / 星型 ----
    assert_deep_clone([[2], [1]])
    assert_deep_clone([[2], [1, 3], [2, 4], [3, 5], [4]])
    assert_deep_clone([[2, 3, 4, 5], [1], [1], [1], [1]])

    # ---- 三角形 + 尾巴：含环且有共享邻居 ----
    assert_deep_clone([[2, 3], [1, 3], [1, 2, 4], [3]])

    # ---- 菱形：节点 4 可由 2、3 两条路到达，必须只克隆一次 ----
    assert_deep_clone([[2, 3], [1, 4], [1, 4], [2, 3]])

    # ---- 完全图 K5 ----
    n = 5
    assert_deep_clone([[w for w in range(1, n + 1) if w != v] for v in range(1, n + 1)])

    # ---- 题目上限：100 个节点的大环 + 一条弦 1-51 ----
    n = 100
    ring = [[(v - 2) % n + 1, v % n + 1] for v in range(1, n + 1)]
    ring[0].append(51)
    ring[50].append(1)
    assert_deep_clone(ring)

    # ---- 独立性：修改克隆的邻居列表不能影响原图（防止只做了浅拷贝） ----
    original = build_graph([[2, 3], [1, 3], [1, 2]])
    clone = Solution().cloneGraph(original)
    clone.neighbors.clear()
    assert graph_to_adj(original) == [[2, 3], [1, 3], [1, 2]]
```

菱形与完全图用例专盯「共享邻居只能有一份副本」；100 节点大环 + 弦验证递归深度与环截断；最后的独立性断言则排除浅拷贝——三层校验分别对应深拷贝的三个要件。

## 总结

- 克隆图的万能钥匙是一张「原节点 → 副本」哈希表：破环、防重复、共享邻居复用，一份 DFS 带走，登记必须发生在递归邻居之前；
- 并查集在此无用武之地：它回答「谁和谁连通」，本题图保证连通，要的是构造对象全新的同构图——做映射，不做合并；
- Python `copy.deepcopy` 的 memo 字典是同一思想的工业实现，面试中说清 `lookup` 的登记时机即抓住了全部要点。
