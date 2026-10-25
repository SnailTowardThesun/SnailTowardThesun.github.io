---
author: SnailTowardThesun
title: "算法系列--并查集：把连通性压缩成一棵矮树"
categories: 算法系列
tags: [数据结构, 并查集, Python]
---

> 并查集维护的是一种等价关系：两个元素一旦被合并，就共享同一个代表元。路径压缩和按秩合并，让这棵关系树几乎始终保持平坦。

# 算法系列--并查集：把连通性压缩成一棵矮树

## 为什么需要并查集

假设有 6 个点，一开始彼此孤立：

```text
0  1  2  3  4  5
```

随后不断加入边：

```text
0-1、1-2、3-4
```

我们关心的不是整张图长什么样，而是几个很小的动态问题：

- `0` 和 `2` 是否连通？
- 新加入的一条边，连接的是两个原本独立的分量，还是同一分量内部的一条多余边？

如果每来一条边都重新做一次 DFS/BFS，代价太高。并查集把这类问题变成两个近似常数时间的操作：

- **查找 `find`**：找到一个元素所在集合的代表元；
- **合并 `union`**：把两个集合接成一棵树。

它适合“边一条条加入、连通性随时查询”的场景，例如动态连通性、最小生成树的 Kruskal 算法、账号合并、图片连通块合并等。

## 核心思想

并查集用森林表示若干个不相交集合：

- 每个集合是一棵树；
- 树根是集合的代表元；
- `parent[x]` 表示 `x` 的父节点；
- 如果 `find(x) == find(y)`，说明两个元素属于同一个集合。

初始时，每个元素的父节点都指向自己，表示每个元素单独成一个集合。

```text
parent = [0, 1, 2, 3, 4, 5]
```

合并 `0` 和 `1` 后，可以令 `parent[1] = 0`（箭头由孩子指向父亲）：

```text
1 -> 0
2
3
4
5
```

此时 `find(1)` 会沿着父指针向上走到 `0`，所以 `0` 和 `1` 的代表元相同，它们连通。

### 优化一：路径压缩

如果每次都从叶子一路爬到根，树可能退化成链表。路径压缩的做法是：找到根之后，把路径上的节点直接挂到根下面。

例如原来的路径是：

```text
0 -> 1 -> 2 -> 3
```

执行 `find(0)` 后可以变成：

```text
0 -> 3
1 -> 3
2 -> 3
```

树的高度被大幅压低，后续查询会越来越快。本文的实现用递归完成这件事：`find` 沿父指针递归找到根，回溯时把路径上的节点逐个直接挂到根下，一次递归同时完成查找和压缩。

### 优化二：按秩合并

合并两棵树时，不随机挂接，而是给每棵树的根记一个"秩"（rank），可以理解为树高度的上界，然后把矮树挂到高树下：

```text
矮树 root  ──>  高树 root
```

- 两棵树秩不同：矮树挂到高树下，高度不变；
- 两棵树秩相同：任挂一侧，合并后的树高度加一，新根的秩随之加一。

秩只增不减，也只对当前的根有意义。这样树的高度增长更慢。若只使用路径压缩或只使用按秩合并，效果已经不错；两者结合后，单次操作的均摊复杂度近似为反阿克曼函数 `α(n)`，在常规数据规模下可以当作常数。

## Python 实现

下面是仓库中的 `UnionFind` 实现。它只保留 `find` / `union` 两个核心方法，元素固定为 `0 .. size-1`，适合顶点编号、数组下标等连续整数场景；连通性判断就是比较两次 `find` 的结果。

```python
"""通用并查集（Disjoint Set Union / Union-Find）实现。"""

from __future__ import annotations


class UnionFind:
    """路径压缩 + 按秩合并的并查集。"""

    def __init__(self, size: int) -> None:
        self._parent = list(range(size))
        self._rank = [0] * size

    def find(self, x: int) -> int:
        if self._parent[x] != x:
            self._parent[x] = self.find(self._parent[x])
        return self._parent[x]

    def union(self, x: int, y: int) -> None:
        root_x, root_y = self.find(x), self.find(y)
        if root_x == root_y:
            return

        # 按秩合并：比较的是两个根的秩，y 只是普通成员时 _rank[y] 没有意义。
        if self._rank[root_x] > self._rank[root_y]:
            self._parent[root_y] = root_x
        elif self._rank[root_x] < self._rank[root_y]:
            self._parent[root_x] = root_y
        else:
            self._parent[root_y] = root_x
            self._rank[root_x] += 1
```

## 关键实现解析

### `find` 是一次递归回溯

```python
if self._parent[x] != x:
    self._parent[x] = self.find(self._parent[x])
return self._parent[x]
```

- 递归出口是 `parent[x] == x`：`x` 自己就是根；
- 递归返回的是所在集合的根，回溯途中顺手把 `parent[x]` 改成根，于是路径上的每个节点都被直接挂到根下，查找和路径压缩在一次递归里同时完成；
- 按秩合并保证树高不超过 `O(log n)`，递归深度始终安全，不会逼近 Python 的默认递归上限。

### `union` 先判重，再按秩挂接

如果两个元素的根相同，说明它们已经在同一个集合里，直接 `return`，不改动任何状态。

挂接时比较的是**两个根的秩**。这里是最容易写错的地方：应该读 `_rank[root_y]`，而不是 `_rank[y]`——`y` 可能只是某个集合里的普通成员，它身上的秩没有意义。误用后虽然连通性仍然正确（两个根总会被接起来），但树的平衡性保证会被破坏，均摊复杂度就退化了。

- 秩小的根挂到秩大的根下，树高不变；
- 秩相同时任挂一侧，并让新根的秩加一。

注意 `_rank` 只在根节点上有效。根被挂到别的树下之后，它身上的旧秩就成了历史数据，之后不会再被读取，因此不需要清理。

### 连通查询就是比较代表元

没有单独的 `connected` 方法，`uf.find(x) == uf.find(y)` 就是连通判断。分量个数、分组这类派生信息同样可以随时在外层基于 `find` 统计出来，不需要并查集自己维护。

## 使用示例

```python
from top150.graph.union_find import UnionFind


uf = UnionFind(6)

uf.union(0, 1)
uf.union(1, 2)
uf.union(3, 4)

print(uf.find(0) == uf.find(2))  # True
print(uf.find(1) == uf.find(4))  # False

# 需要分组时，在外层基于 find 统计：
groups: dict[int, list[int]] = {}
for x in range(6):
    groups.setdefault(uf.find(x), []).append(x)
print(sorted(groups.values()))  # [[0, 1, 2], [3, 4], [5]]
```

三条边把 6 个元素变成 3 个分量：`{0, 1, 2}`、`{3, 4}`、`{5}`。如果继续执行：

```python
uf.union(2, 0)
```

`2` 和 `0` 已经连通，两个根相同，`union` 直接返回，结构不变。

## 测试设计

测试围绕公开的 `find` / `union` 展开，重点覆盖容易出错的场景：

```python
from top150.graph.union_find import UnionFind


def test_union_and_connectivity() -> None:
    uf = UnionFind(6)

    uf.union(0, 1)
    uf.union(1, 2)
    uf.union(3, 4)

    # 连通性 = 两个元素的代表元相同。
    assert uf.find(0) == uf.find(2)
    assert uf.find(1) != uf.find(4)
    assert uf.find(5) != uf.find(0)


def test_repeated_union_is_noop() -> None:
    uf = UnionFind(6)

    uf.union(0, 1)
    uf.union(1, 2)
    root = uf.find(0)

    uf.union(2, 0)  # 已连通：合并是无操作
    uf.union(1, 1)  # 自合并：同样是无操作

    assert uf.find(2) == root
    assert uf.find(0) == uf.find(1) == uf.find(2)


def test_groups_by_pattern() -> None:
    size = 200
    uf = UnionFind(size)

    # 每 4 个连续元素合并成一组，最终应形成 50 个大小为 4 的分量。
    for i in range(0, size, 4):
        uf.union(i, i + 1)
        uf.union(i + 1, i + 2)
        uf.union(i + 2, i + 3)

    groups: dict[int, list[int]] = {}
    for x in range(size):
        groups.setdefault(uf.find(x), []).append(x)

    assert len(groups) == 50
    assert all(len(members) == 4 for members in groups.values())
```

这组断言重点检查：

- 连通性以“代表元相同”为准，不受代表元选择影响；
- 已连通的合并和自合并都是无操作，不会破坏已有结构；
- 两个已成分量合并后代表元统一；
- 规模场景验证每一次 `union` 都真正生效，分组结果与预期完全一致。

## 复杂度与适用边界

设元素个数为 `n`，操作数为 `m`：

- 初始化：`O(n)` 时间，`O(n)` 空间；
- `find`、`union`：均摊近似 `O(α(n))`；
- 处理 `m` 次合并或查询：近似 `O(m α(n))`。

这个实现有三个刻意保留的边界：

1. 元素必须是连续非负整数 `0 .. size-1`。它没有内置哈希映射，也没有越界校验，传错下标会直接得到 `IndexError` 或错误结果，因此在顶点编号和数组下标场景中更省内存、更快；
2. 只维护连通性本身。分量个数、集合大小、分组等派生信息需要时在外层基于 `find` 统计，不该塞进热路径；
3. `find` 是递归实现。按秩合并保证树高不超过 `O(log n)`，深度安全；如果改造成超大规模或改用迭代式，可以换成两趟扫描的写法。

如果元素是字符串、对象或其他离散标签，可以在外层维护 `label -> index` 的映射，再交给这个连续整数版并查集处理。

## 总结

- 并查集把“是否属于同一集合”表示成“是否拥有同一个树根”，用极低代价维护动态等价关系；
- 路径压缩负责把查找路径压平，按秩合并负责避免树单向变高，两者搭配后单次操作几乎可以视为常数；
- 核心只有 `find` / `union` 两个方法：连通判断就是比较 `find` 的结果，分量计数、分组等派生信息留给外层按需统计。
