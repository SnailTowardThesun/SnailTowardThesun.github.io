---
author: SnailTowardThesun
title: "算法系列--并查集：把连通性压缩成一棵矮树"
categories: 算法系列
tags: [数据结构, 并查集, Python]
---

> 并查集维护的是一种等价关系：两个元素一旦被合并，就共享同一个代表元。路径压缩和按大小合并，让这棵关系树几乎始终保持平坦。

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
- 当前一共有几个连通分量？
- `2` 所在的连通分量里有多少个点？
- 如果再加入一条边，哪些分量会被合并？

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

合并 `0` 和 `1` 后，可以令 `parent[1] = 0`：

```text
0 -> 1
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

树的高度被大幅压低，后续查询会越来越快。

### 优化二：按大小合并

合并两棵树时，不随机挂接，而是把小树挂到大树下：

```text
小树 root  ──>  大树 root
```

这样树的高度增长更慢。若只使用路径压缩或只使用按大小合并，效果已经不错；两者结合后，单次操作的均摊复杂度近似为反阿克曼函数 `α(n)`，在常规数据规模下可以当作常数。

## Python 实现

下面是仓库中的 `UnionFind` 实现。元素固定为 `0 .. size-1`，适合顶点编号、数组下标等连续整数场景。

```python
from __future__ import annotations

from collections.abc import Iterable


class UnionFind:
    __slots__ = ("_parent", "_size", "_count")

    def __init__(self, size: int) -> None:
        if size < 0:
            raise ValueError("size must be non-negative")

        self._parent = list(range(size))
        self._size = [1] * size
        self._count = size

    @property
    def count(self) -> int:
        return self._count

    def find(self, x: int) -> int:
        self._validate(x)

        root = x
        while self._parent[root] != root:
            root = self._parent[root]

        while self._parent[x] != root:
            self._parent[x], x = root, self._parent[x]

        return root

    def union(self, x: int, y: int) -> bool:
        root_x = self.find(x)
        root_y = self.find(y)
        if root_x == root_y:
            return False

        if self._size[root_x] < self._size[root_y]:
            root_x, root_y = root_y, root_x

        self._parent[root_y] = root_x
        self._size[root_x] += self._size[root_y]
        self._count -= 1
        return True

    def union_all(self, pairs: Iterable[tuple[int, int]]) -> int:
        merged_count = 0
        for x, y in pairs:
            if self.union(x, y):
                merged_count += 1
        return merged_count

    def connected(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)

    def size(self, x: int) -> int:
        return self._size[self.find(x)]

    def groups(self) -> list[list[int]]:
        grouped: dict[int, list[int]] = {}
        for x in range(len(self._parent)):
            grouped.setdefault(self.find(x), []).append(x)
        return sorted(grouped.values(), key=lambda group: group[0])

    def _validate(self, x: int) -> None:
        if not 0 <= x < len(self._parent):
            raise IndexError(f"element {x} is out of range [0, {len(self._parent) - 1}]")

    def __len__(self) -> int:
        return len(self._parent)

    def __repr__(self) -> str:
        return f"UnionFind(size={len(self)}, count={self._count}, groups={self.groups()})"
```

## 关键实现解析

### `find` 是两趟扫描

```python
root = x
while self._parent[root] != root:
    root = self._parent[root]
```

第一趟只负责找根。根节点的特征是 `parent[root] == root`。

```python
while self._parent[x] != root:
    self._parent[x], x = root, self._parent[x]
```

第二趟做路径压缩。右侧元组会先求值，所以这行代码等价于：

1. 取出旧的 `self._parent[x]`；
2. 把 `self._parent[x]` 改成 `root`；
3. 让 `x` 继续访问旧父节点。

于是路径上的节点都会被直接挂到根上。

### `union` 先判断是否已经连通

如果两个元素的根相同，说明它们已经在同一个集合里。此时不仅返回 `False`，也不能修改 `_count` 和 `_size`，否则连通分量个数会被错误减少。

### 按大小合并时的交换

```python
if self._size[root_x] < self._size[root_y]:
    root_x, root_y = root_y, root_x
```

交换后，`root_x` 始终代表较大的树。接下来把 `root_y` 挂到 `root_x` 下，并把小树的大小累加到大树根上。

注意 `_size` 只保证根节点上的值有效。查询集合大小时必须先 `find(x)` 找到根，再读取 `_size[root]`。

### `count` 与 `len` 的区别

这两个概念很容易混淆：

- `len(uf)`：元素总数；
- `uf.count`：当前集合个数。

例如 `UnionFind(6)` 初始时 `len(uf) == 6`，`uf.count == 6`；合并 `0-1` 后，`len(uf)` 仍是 `6`，`uf.count` 变成 `5`。

## 使用示例

```python
from top150.graph.union_find import UnionFind


uf = UnionFind(6)

uf.union(0, 1)
uf.union(1, 2)
uf.union(3, 4)

print(uf.connected(0, 2))  # True
print(uf.connected(1, 4))  # False
print(uf.count)            # 3
print(uf.size(2))          # 3
print(uf.groups())         # [[0, 1, 2], [3, 4], [5]]
```

三条边只带来三次真正合并：

- `0-1`：`{0,1}` 与 `{2}`、`{3}`、`{4}`、`{5}` 分开，集合数从 6 变 5；
- `1-2`：`{0,1}` 和 `{2}` 合并，集合数变 4；
- `3-4`：`{3}` 和 `{4}` 合并，集合数变 3。

如果继续执行：

```python
uf.union(2, 0)
```

`2` 和 `0` 已经连通，所以返回 `False`，集合数仍然是 `3`。

## 测试设计

测试不只覆盖“能合并”，还覆盖几个容易出错的状态量：

```python
from top150.graph.union_find import UnionFind


def test_union_and_connected() -> None:
    uf = UnionFind(6)

    assert uf.union(0, 1) is True
    assert uf.union(1, 2) is True
    assert uf.union(3, 4) is True
    assert uf.union(2, 0) is False

    assert uf.connected(0, 2) is True
    assert uf.connected(1, 4) is False
    assert uf.count == 3
    assert uf.size(2) == 3
    assert uf.size(4) == 2
    assert uf.groups() == [[0, 1, 2], [3, 4], [5]]
```

这组断言重点检查：

- 真实合并与重复合并的返回值不同；
- 连通查询不受代表元选择影响；
- `count` 不会因重复边错误减少；
- 集合大小读取的是根节点上的有效值；
- 分组结果的顺序稳定，便于观察和调试。

## 复杂度与适用边界

设元素个数为 `n`，边数为 `m`：

- 初始化：`O(n)` 时间，`O(n)` 空间；
- `find`、`union`、`connected`、`size`：均摊近似 `O(α(n))`；
- 处理 `m` 次合并或查询：近似 `O(m α(n))`。

这个实现有两个刻意保留的边界：

1. 元素必须是连续非负整数 `0 .. size-1`。它没有内置哈希映射，因此在顶点编号和数组下标场景中更省内存、更快；
2. `groups()` 需要遍历所有元素并执行 `find`，更适合调试或最终输出，不适合放在高频循环里。

如果元素是字符串、对象或其他离散标签，可以在外层维护 `label -> index` 的映射，再交给这个连续整数版并查集处理。

## 总结

- 并查集把“是否属于同一集合”表示成“是否拥有同一个树根”，用极低代价维护动态等价关系；
- 路径压缩负责把查找路径压平，按大小合并负责避免树单向变高，两者搭配后单次操作几乎可以视为常数；
- 实现时要特别小心 `count`、`size`、`len` 的语义：重复合并不能改变集合数，集合大小必须从根节点读取，而 `len` 统计的是元素总数。
