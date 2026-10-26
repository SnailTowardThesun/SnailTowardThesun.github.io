---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.399: 除法求值"
categories: LeetCode
tags: [中等, 并查集, 图, 哈希表]
---

> 外汇市场只需挂出美元/欧元、欧元/日元两个牌价，美元/日元就能沿链相乘得到——这叫交叉汇率。本题正是它的抽象：等式是牌价，查询是任意两种货币间的换算。

## 题目

LeetCode 399. Evaluate Division（除法求值）

Difficulty: **Medium**

给你一个变量对数组 `equations` 和一个实数值数组 `values` 作为已知条件，其中 `equations[i] = [Ai, Bi]` 和 `values[i]` 共同表示等式 `Ai / Bi = values[i]`。每个 `Ai` 或 `Bi` 是一个表示单个变量的字符串。

另有一些以数组 `queries` 表示的问题，其中 `queries[j] = [Cj, Dj]` 表示第 `j` 个问题，请你根据已知条件找出 `Cj / Dj = ?` 的结果作为答案。

返回 **所有问题的答案**。如果存在某个无法确定的答案，则用 `-1.0` 替代这个答案。如果问题中出现了给定的已知条件中没有出现的字符串，也需要用 `-1.0` 替代这个答案。

**注意**：输入总是有效的。你可以假设除法运算中不会出现除数为 0 的情况，且不存在任何矛盾的结果。未在等式列表中出现的变量是未定义的，因此无法确定它们的答案。

约束：

- `1 <= equations.length <= 20`
- `equations[i].length == 2`，`1 <= Ai.length, Bi.length <= 5`
- `values.length == equations.length`，`0.0 < values[i] <= 20.0`
- `1 <= queries.length <= 20`
- `queries[i].length == 2`，`1 <= Cj.length, Dj.length <= 5`
- `Ai, Bi, Cj, Dj` 由小写英文字母与数字组成

### 示例

```
输入：equations = [["a","b"],["b","c"]], values = [2.0,3.0],
     queries = [["a","c"],["b","a"],["a","e"],["a","a"],["x","x"]]
输出：[6.00000,0.50000,-1.00000,1.00000,-1.00000]
解释：条件：a / b = 2.0, b / c = 3.0
     问题：a / c = ?, b / a = ?, a / e = ?, a / a = ?, x / x = ?
     结果：[6.0, 0.5, -1.0, 1.0, -1.0]；x 是未定义的 => -1.0

输入：equations = [["a","b"],["b","c"],["bc","cd"]], values = [1.5,2.5,5.0],
     queries = [["a","c"],["c","b"],["bc","cd"],["cd","bc"]]
输出：[3.75000,0.40000,5.00000,0.20000]

输入：equations = [["a","b"]], values = [0.5],
     queries = [["a","b"],["b","a"],["a","c"],["x","x"]]
输出：[0.50000,2.00000,-1.00000,-1.00000]
```

## 解题思路

把每条等式 `a / b = v` 看成一条带权边：`a → b` 权 `v`，`b → a` 权 `1/v`。查询 `c / d` 就是 `c` 到 `d` 路径上权值的乘积；不连通或变量根本没出现过，就是 `-1`。

两条路都能走：建带权邻接表，每个查询 BFS/DFS 沿路累乘；或者沿着 No.200 → No.1254 → No.130 这条线，继续用并查集。但这里有一个关键的坎——**普通并查集只回答"连不连通"，本题还要回答"比值是多少"**。连通性只能告诉你该不该输出 `-1`，真正的答案 `c / d` 这个数，`parent` 数组里没地方存。所以并查集要**带权**。

### 字符串变量 → 下标

并查集按整数下标工作，变量却是 `"a"`、`"bc"` 这样的字符串。先扫一遍 `equations`，给每个首次出现的变量分配一个递增编号存进 dict，扫完才知道节点总数（最多 40 个），再构造并查集。查询时任一变量不在 dict 里直接 `-1`，`a/e`、`x/x` 这类未定义情况就此解决。

### 带权并查集的不变量

给每个节点加一个权值，定义必须钉死，后面三条公式全由它推出：

> `weight[x] = x 的值 / parent[x] 的值`，根节点的 `weight` 恒为 `1`。

一半的 bug 来自中途把它搞成 `parent / x`，写代码前先把这行注释写在类顶上。

### find：路径压缩时权值同步累乘

设 `x` 的父亲是 `p`。先递归 `find(p)`，回来时 `p` 已经直接挂到根 `r` 下、`weight[p] = p / r`；于是 `x / r = (x / p) · (p / r)`，即 `weight[x] *= weight[p]`；最后才把 `parent[x]` 改成 `r`。四步顺序是**记旧父亲 → 递归 → 乘权值 → 改父亲**，一步都不能换。

### union：由 a / b = v 推出两个根之间的比值

先 `ra = find(a)`、`rb = find(b)`，此时 `weight[a] = a / ra`，`weight[b] = b / rb`。固定把 `ra` 挂到 `rb` 下，需要的权值是 `ra / rb`：

```
ra = a / weight[a],  rb = b / weight[b]
ra / rb = (a / b) · weight[b] / weight[a] = v · weight[b] / weight[a]
```

节点最多 40 个，路径压缩已经足够，不再做按秩合并——固定方向还顺带省掉了"反向挂接要用倒数公式"的分支。

### 查询

两个变量都在 dict 里才继续；`find` 两次，根不同 `-1`；根相同时 `c / d = (c / r) / (d / r) = weight[c] / weight[d]`。`a / a` 自然得到 `1.0`，无需特判。

以示例 1 手算：`a/b = 2`、`b/c = 3`。两次 `union` 后链是 `a → b → c`，`weight` 分别 `2、3、1`。查 `a/c`：`find(a)` 一路压缩，`weight[a] = 2 × 3 = 6`，a 直接挂到 c；同根，答案 `6 / 1 = 6`。查 `b/a`：`weight[b] = 3`，`weight[a] = 6`，答案 `0.5`。`a/e`、`x/x` 中 e、x 不在 dict，`-1`；`a/a` 得 `6 / 6 = 1`。五个输出全对。

### 复杂度分析

设变量数 `V`（≤ 40）、等式数 `E`、查询数 `Q`，`α` 为反阿克曼函数。每条等式和每个查询都只做常数次 `find`，时间复杂度 `O((E + Q)·α(V))`；`parent`、`weight` 两个数组加一个 dict，空间 `O(V)`。

## 代码实现

```python
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.weight = [1.0] * n

    def find(self, x):
        if self.parent[x] != x:
            p = self.parent[x]
            root = self.find(p)
            self.weight[x] *= self.weight[p]
            self.parent[x] = root
        return self.parent[x]

    def union(self, x, y, v):
        root_x, root_y = self.find(x), self.find(y)
        if root_x == root_y:
            return

        self.parent[root_x] = root_y
        self.weight[root_x] = v * self.weight[y] / self.weight[x]


class Solution:
    def calcEquation(self, equations: list[list[str]], values: list[float], queries: list[list[str]]) -> list[float]:
        ids = {}
        for a, b in equations:
            for s in (a, b):
                if s not in ids:
                    ids[s] = len(ids)

        uf = UnionFind(len(ids))
        for (a, b), v in zip(equations, values, strict=True):
            uf.union(ids[a], ids[b], v)

        res = []
        for c, d in queries:
            if c not in ids or d not in ids:
                res.append(-1.0)
            elif uf.find(ids[c]) != uf.find(ids[d]):
                res.append(-1.0)
            else:
                res.append(uf.weight[ids[c]] / uf.weight[ids[d]])

        return res
```

### 代码解析

- **`find` 的四步顺序是全题最容易写错的地方**。实现时曾把 `self.weight[x] *= self.weight[p]` 写在递归 `find(p)` **之前**：那一刻 `weight[p]` 还是"p 相对它自己父亲"的比值，没被递归刷成"p 相对根"，于是 `weight[x]` 只累到祖父那一层，`parent[x]` 却已指向根。诡异之处在于示例 1 全部通过——链 `a → b → c` 只有两跳，p 的父亲恰好就是根，`weight[p]` 碰巧已是最终值。直到"长链传递"用例 `a/b=2, b/c=3, c/d=4` 查 `a/d`，得到 `6` 而不是 `24`，错误才暴露。**链深 2 时错序碰巧正确，链深 3 才露馅**，所以测试里必须有三跳以上的链；
- **`union` 公式里用的是节点自己的权值**：`v * weight[y] / weight[x]`，不是 `weight[root_x]`、`weight[root_y]`——根的权值恒为 `1`，代进去等于把推导扔掉了。前面两次 `find` 的副作用正是把 `weight[x]`、`weight[y]` 刷成相对各自根的比值，公式才成立；
- **字符串与下标的转换要处处一致**：另一处真实踩坑是查询的 `elif` 分支写成了 `uf.find(c)`，把字符串直接喂进 `find`，`self.parent["a"]` 当场 `TypeError`；而紧跟的 `else` 分支用的是 `ids[c]`。两行相邻、一行转了一行没转，是这类"外部字符串 + 内部下标"代码的典型事故；
- **查询时 `find` 必须在读 `weight` 之前**：`elif` 里的两次 `find` 把 `c`、`d` 都压到公共根下并刷新权值，`else` 里再读 `weight` 才是"相对同一个根"的值。若跳过 `find` 直接读，拿到的是相对旧父亲的比值，相除没有意义；
- **去掉按秩合并**：规模只有几十个节点，路径压缩单独摊还下来已近常数；保留 rank 需要为"反向挂接"再写一条倒数公式，多一个分支多一处出错点，收益为零。

## 测试用例

```python
def assert_close(actual: list[float], expected: list[float]) -> None:
    """浮点逐项比较（LeetCode 判题允许 1e-5 误差）。"""
    assert len(actual) == len(expected), f"长度不一致: {actual} vs {expected}"
    for i, (a, e) in enumerate(zip(actual, expected, strict=True)):
        assert math.isclose(a, e, rel_tol=1e-9, abs_tol=1e-5), f"第 {i} 项: {a} != {e}"


def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert_close(
        solution.calcEquation(
            [["a", "b"], ["b", "c"]],
            [2.0, 3.0],
            [["a", "c"], ["b", "a"], ["a", "e"], ["a", "a"], ["x", "x"]],
        ),
        [6.0, 0.5, -1.0, 1.0, -1.0],
    )
    assert_close(
        solution.calcEquation(
            [["a", "b"], ["b", "c"], ["bc", "cd"]],
            [1.5, 2.5, 5.0],
            [["a", "c"], ["c", "b"], ["bc", "cd"], ["cd", "bc"]],
        ),
        [3.75, 0.4, 5.0, 0.2],
    )
    assert_close(
        solution.calcEquation(
            [["a", "b"]],
            [0.5],
            [["a", "b"], ["b", "a"], ["a", "c"], ["x", "x"]],
        ),
        [0.5, 2.0, -1.0, -1.0],
    )

    # ---- 查询恰好就是已知等式本身 / 其倒数 ----
    assert_close(solution.calcEquation([["a", "b"]], [4.0], [["a", "b"], ["b", "a"]]), [4.0, 0.25])

    # ---- 自己除自己：变量已知为 1.0，变量未知仍为 -1.0 ----
    assert_close(solution.calcEquation([["a", "b"]], [2.0], [["a", "a"], ["b", "b"], ["z", "z"]]), [1.0, 1.0, -1.0])

    # ---- 一端已知、一端未知 -> -1 ----
    assert_close(solution.calcEquation([["a", "b"]], [2.0], [["a", "q"], ["q", "b"]]), [-1.0, -1.0])

    # ---- 长链传递：a/b=2, b/c=3, c/d=4 ----
    eq = [["a", "b"], ["b", "c"], ["c", "d"]]
    vals = [2.0, 3.0, 4.0]
    assert_close(
        solution.calcEquation(eq, vals, [["a", "d"], ["d", "a"], ["b", "d"], ["a", "c"]]),
        [24.0, 1 / 24, 12.0, 6.0],
    )

    # ---- 两个互不连通的分量：组内可算，跨组 -1 ----
    eq = [["a", "b"], ["x", "y"]]
    vals = [2.0, 4.0]
    assert_close(
        solution.calcEquation(eq, vals, [["a", "b"], ["x", "y"], ["y", "x"], ["a", "x"], ["b", "y"]]),
        [2.0, 4.0, 0.25, -1.0, -1.0],
    )

    # ---- 两个分量被后出现的等式"桥接"后全部可达（等式顺序不应影响结果） ----
    eq = [["a", "b"], ["c", "d"], ["b", "c"]]
    vals = [2.0, 5.0, 3.0]
    assert_close(solution.calcEquation(eq, vals, [["a", "d"], ["d", "a"]]), [30.0, 1 / 30])

    # ---- 等式构成环（题目保证无矛盾）：a/b=2, b/c=3, c/a=1/6 ----
    eq = [["a", "b"], ["b", "c"], ["c", "a"]]
    vals = [2.0, 3.0, 1 / 6]
    assert_close(solution.calcEquation(eq, vals, [["a", "c"], ["c", "a"], ["b", "a"]]), [6.0, 1 / 6, 0.5])

    # ---- 星型：多个变量都以 a 为分子给出，叶子之间也要能互相换算 ----
    eq = [["a", "b"], ["a", "c"], ["a", "d"]]
    vals = [2.0, 4.0, 8.0]
    assert_close(solution.calcEquation(eq, vals, [["b", "c"], ["c", "d"], ["d", "b"]]), [2.0, 2.0, 0.25])

    # ---- 小数与上限值：0.5 与 20.0 ----
    eq = [["p", "q"], ["q", "r"]]
    vals = [0.5, 20.0]
    assert_close(solution.calcEquation(eq, vals, [["p", "r"], ["r", "p"]]), [10.0, 0.1])

    # ---- 变量名含数字 / 多字符（题目允许小写字母与数字） ----
    eq = [["x1", "x2"], ["x2", "x3"]]
    vals = [3.0, 3.0]
    assert_close(solution.calcEquation(eq, vals, [["x1", "x3"], ["x3", "x1"], ["x1", "y1"]]), [9.0, 1 / 9, -1.0])
```

浮点结果用 `math.isclose` 按 `1e-5` 容差比较，和判题一致。"长链传递"是专门抓 `find` 顺序错误的用例，三跳以上才会暴露；"两个互不连通的分量"钉死"根不同返回 -1"；"桥接"验证后出现的等式把两棵已存在的树合并时，公式必须用刷新后的权值而不是初始的 `1`；"环"确认无矛盾的冗余等式被同根判断安全跳过；"星型"检查两个叶子之间的换算要经过公共根正确相除。

## 总结

- 并查集带权的全部秘密是一条不变量：`weight[x] = x / parent[x]`、根恒为 `1`——`find` 的累乘、`union` 的 `v · weight[b] / weight[a]`、查询的 `weight[c] / weight[d]` 三条公式都从它推出，不必死记；
- `find` 的顺序是**记旧父亲 → 递归 → 乘权值 → 改父亲**，写反了只在链深 ≥ 3 时露馅，示例全过不代表正确，测试里必须有一条三跳以上的链；
- 与 No.200 / No.1254 / No.130 同源：那三题的并查集只回答"是否连通"，这题多出一个权值维度去回答"比值多少"，是把并查集从布尔升级成数值的标准范式。
