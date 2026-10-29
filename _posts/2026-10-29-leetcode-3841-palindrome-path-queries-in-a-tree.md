---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3841: 查询树上回文路径"
categories: LeetCode
tags: [困难, 树, 最近公共祖先, 树状数组, 位运算, 二进制倍增]
---

> 树上两点的路径信息可用「根到点前缀 + LCA」拼接：前缀做可逆运算（异或、加减）正好抵消公共祖先段，O(1) 拼出任意路径的答案——这正是树上差分的核心思想。

## 题目

LeetCode 3841. Palindromic Path Queries in a Tree（查询树上回文路径）

Difficulty: **Hard**

给你一棵包含 `n` 个节点的无向树，节点编号从 `0` 到 `n - 1`。树由长度为 `n - 1` 的二维数组 `edges` 表示，`edges[i] = [ui, vi]` 表示节点 `ui` 和 `vi` 之间存在一条无向边。

另给你一个长度为 `n`、由小写英文字母组成的字符串 `s`，其中 `s[i]` 表示分配给节点 `i` 的字符。

还给你一个字符串数组 `queries`，其中每个 `queries[i]` 为以下形式之一：

- `"update ui c"`：将节点 `ui` 处的字符更改为 `c`（即 `s[ui] = c`）；
- `"query ui vi"`：判断从 `ui` 到 `vi` 的**唯一**路径（含两端点）上的字符所组成的字符串，是否可以**重新排列**成一个**回文串**。

返回一个布尔数组 `answer`：第 `i` 个 `"query"` 型查询可以重排成回文串则 `answer[i]` 为 `true`，否则为 `false`。

约束：

- `1 <= n == s.length <= 5 * 10^4`
- `edges.length == n - 1`，输入的 `edges` 表示一棵有效的树
- `1 <= queries.length <= 5 * 10^4`
- `s` 由小写英文字母组成；`c` 是一个小写英文字母

### 示例

```text
输入：n = 3, edges = [[0,1],[1,2]], s = "aac",
     queries = ["query 0 2","update 1 b","query 0 2"]
输出：[true,false]
解释：路径 0→1→2 为 "aac"，可重排为 "aca"；update 1 b 后路径为 "abc"，无法重排成回文串。
```

```text
输入：n = 4, edges = [[0,1],[0,2],[0,3]], s = "abca",
     queries = ["query 1 2","update 0 b","query 2 3","update 3 a","query 1 3"]
输出：[false,false,true]
解释：query 1 2 路径为 "bac" 不可行；update 0 b 后 query 2 3 路径为 "cba" 不可行；
     update 3 a 后 query 1 3 路径为 "bba"，可重排为 "bab"。
```

## 解题思路

这道题表面是「路径 + 回文」，实际是三个独立子问题的组装题，每个子问题都有一个经典对应物：

| 子问题 | 解法 |
| ---- | ---- |
| ① 判断「能否重排成回文」 | 26 位奇偶掩码 + `popcount <= 1` |
| ② 算出「任意两点路径」的掩码 | 根到点前缀掩码 + **LCA** |
| ③ update 改一个点，如何维护 | Euler 序（子树 = 连续区间）+ 树状数组 |

没有 update 的话，①+② 就是道模板题；正是 update 把它抬成了 Hard。下面按依赖顺序逐个拆解，每一步都用示例 1（链 `0-1-2`，`s = "aac"`）代入数值。

### 第一步：回文判定 ⇔ 奇数次字符不超过一个

一个字符串能重排成回文，当且仅当**出现奇数次的字符至多一个**：回文串关于中心对称，除中心位外每个字符都必须成对出现。

- `"aac"`：a 出现 2 次（偶）、c 出现 1 次（奇）→ 只有 1 个奇 → 可以（排成 `"aca"`）
- `"abc"`：a、b、c 全奇 → 3 个奇 → 不行

26 个小写字母，恰好用 26 个二进制位：**第 `i` 位 = 字母 `i` 出现奇数次**。这个整数称为「奇偶掩码」，判定条件浓缩为 `mask.bit_count() <= 1`。

选**异或**做运算是关键：两个字符串拼接后，每个字母的奇偶 = 各自奇偶相加再模 2——这正是按位异或。可逆、可结合，后面所有推导都建立在它之上。

### 第二步：前缀掩码——每个点只存「根到我」

以节点 0 为根，定义 `base[x]` = 从根到 `x`（含两端）路径上所有字符的奇偶掩码：

```python
base[u] = base[parent[u]] ^ (1 << chars[u])   # 我的掩码 = 父亲的掩码 ^ 我的字符
```

示例 1（a=第 0 位，c=第 2 位）：

| 节点 | 根→该点路径 | 计算 | base 值 |
| ---- | ------ | ------ | ------ |
| 0 | "a" | `0 ^ 0b001` | `0b001` |
| 1 | "aa" | `0b001 ^ 0b001` | `0`（两个 a 抵消） |
| 2 | "aac" | `0 ^ 0b100` | `0b100` |

实现上按 DFS 先序遍历计算，保证算 `x` 时 `base[parent[x]]` 已就绪。

### 第三步：LCA 一行公式拼出任意路径

任意路径 `u→v` 的掩码不需要单独算，由两条「根路径」异或出来：

```text
mask(u→v) = pref[u] ^ pref[v] ^ bit(s[lca])
```

推导只有一句话：**一个点若在 `pref[u]` 和 `pref[v]` 里各出现一次，它就被异或抵消**。「根→u」与「根→v」的公共部分恰是「根→lca」这一段（**含 lca 自身**，因为 lca 在两条根路径上各出现一次）——整段抵消；剩下的恰好是 lca 两侧的分叉路径。但 lca 本身在 `u→v` 路径上，所以最后单独补回它的字符。

数值验证（`query 0 2`，lca = 0）：

```text
m = 0b001 ^ 0b100 ^ 0b001 = 0b100   → 1 个 1 → true（"aac" → "aca"）
```

再看 `query 1 2`（lca = 1）：`0 ^ 0b100 ^ 0b001 = 0b101`，两个 1 → false（"ac" 确实不行）。公式对「一端是另一端祖先」的情形同样成立，无需特判。

### 倍增 LCA：O(log n) 找公共祖先

朴素做法是两点各自一步步上爬，链形树退化 O(n)。倍增的思路：**任意跳跃距离都能写成若干个 2 的幂**（即距离的二进制表示），预存「跳 `2^k` 步到哪」即可一次跳一大步：

- `up[0][x]` = x 的父亲（跳 1 步）；
- `up[k][x] = up[k-1][ up[k-1][x] ]`：两次 `2^(k-1)` 跳 = 一次 `2^k` 跳。

查询 `find(a, b)` 分两段：

1. **拉平深度**：设 a 更深，把 `depth[a] - depth[b]` 按二进制拆位，哪一位是 1 就用对应的 `up[k]` 跳，a 到达与 b 同一深度；
2. **同步上跳**：若此时 a == b，b 本来就是祖先，直接返回；否则**从最大的 k 往小试**——`up[k][a] != up[k][b]` 才跳（祖先不同说明 LCA 还在更高处，此步安全），相同则不跳（可能跳过头，换小步）。循环结束后 a、b 正好停在 LCA 的两个孩子上，再上一步即答案。

### 第四步：update 才是 Hard 的本体

`pref[x]` 是「根→x 所有节点的字符」，所以 `s[u]` 一改，**所有祖链里含 u 的点的前缀全部变化**——这恰好就是 **u 的整棵子树**（u 自己、孩子、孩子的孩子……）。每个受影响点的变化量相同：旧字符位翻转、新字符位翻转，即 `delta = bit(旧) ^ bit(新)`。

朴素做法是每次 update 遍历整棵子树打补丁，最坏 O(n)；`5×10^4` 次 update × `5×10^4` 节点 = 25 亿次操作，必超时。

### Euler 序：子树 = 先序中的连续区间

看 DFS 先序（先访问自己，再访问所有孩子）：进入 u 之后，DFS 会一口气走完 u 的全部后代才离开，中途不会访问别的点。因此**子树 u 在先序序列里永远占据一段连续区间** `[tin[u], tout[u]]`（`tin` 是进入时间戳，`tout = tin + 子树大小 - 1`）。

示例 1 的先序是 `[0, 1, 2]`：节点 1 的子树是 两个点，对应区间 `[tin[1], tout[1]] = [1, 2]`。

于是「给整棵子树异或 delta」=「给数组的连续区间异或 delta」——经典数据结构问题。

### 树状数组：区间异或 / 单点查询

注意我们从不需要整体重算 `pref`，而是维护「所有 update 的累计增量」：真实前缀 = `base[x] ^ (x 收到的所有 delta 之异或)`。`base` 是初始快照，永远不变。

树状数组的差分技巧对异或同样成立：

- **改区间 `[lo, hi]`**：只做两次单点修改——`flip(lo+1, delta)` 和 `flip(hi+2, delta)`；
- **读单点 `i`**：取前缀异或 `tree[1] ^ ... ^ tree[i+1]`。

为什么这样就对了？按位置 i 与区间的相对关系分三种情况：

| 位置 | 前缀里包含 | 净效果 |
| ---- | ------ | ------ |
| 区间内（lo ≤ i ≤ hi） | 只含 lo 处的 delta | delta |
| 区间左侧（i < lo） | 两处都不含 | 0 |
| 区间右侧（i > hi） | 两处都含 | delta ^ delta = 0 |

异或是自身的逆运算，所以「区间端点打两个标记 + 前缀异或」天然实现了「区间是否覆盖我奇数次」。

**踩过的坑**：差分右端是 `tout[u] + 2` 而不是 `tout[u] + 1`。子树区间 0 下标是 `[tin, tout]`，转成树状数组的 1 下标是 `[tin+1, tout+1]`，差分的「右端 +1」再叠加一层就是 `tout+2`。写成 `tout+1` 会漏掉子树区间最后一个点——本地测试第一条断言就红了。这类下标细节已封装进 `_RangeXorBit` 内部，对外只暴露 0 下标接口。

### 手算示例：完整走一遍示例 1

初始：`base = [0b001, 0, 0b100]`，`tin = [0, 1, 2]`，树状数组全 0。

1. **`query 0 2`**：无增量，`pref = base`。lca(0,2) = 0，
   `m = 0b001 ^ 0b100 ^ 0b001 = 0b100` → 1 个 1 → **true**
2. **`update 1 b`**：节点 1 从 a(第 0 位) 改成 b(第 1 位)，`delta = 0b001 ^ 0b010 = 0b011`，打在子树区间 `[1, 2]` 上。此后逻辑上节点 1、2 的前缀都要 ^ 0b011。
3. **`query 0 2`**：节点 0 不在子树 里，`pref[0]` 仍是 `0b001`；节点 2 在子树里，`pref[2] = 0b100 ^ 0b011 = 0b111`（对应 "abc"：a、b、c 各一次，符合直觉）。
   `m = 0b001 ^ 0b111 ^ 0b001 = 0b111` → 3 个 1 → **false**

输出 `[true, false]`，与官方一致。

### 复杂度分析

- 时间复杂度：`O((n + q) log n)`——预处理 DFS 与前缀 O(n)、倍增表 O(n log n)；每次 update 两次树状数组单点改 O(log n)，每次 query 一次 LCA + 两次点查 O(log n)
- 空间复杂度：`O(n log n)`（倍增表占大头）；实测 n = q = 5×10^4 约 0.1s

## 代码实现

按「图结构 → 查询结构 → 区间结构 → 业务状态」分成四个小类，主流程只剩解析与分派：

```python
class _EulerTree:
    """无向树以 0 定根：迭代 DFS 求父节点 / 深度 / 先序 Euler 序。

    用手动栈而非递归——n 达 5e4 的链形输入会触发递归上限。
    先序保证父节点先于子节点出现，且子树 u 恰为连续区间，见 subtree_range()。
    """

    def __init__(self, n: int, edges: list[list[int]]) -> None:
        adj = [[] for _ in range(n)]
        for u, v in edges:
            adj[u].append(v)
            adj[v].append(u)

        self.parent = [0] * n  # parent[0] = 0：根自指，倍增表跳过头时停在根
        self.depth = [0] * n
        self.tin = [0] * n  # 先序时间戳
        order: list[int] = []
        visited = [False] * n
        visited[0] = True
        stack = [0]
        while stack:
            u = stack.pop()
            order.append(u)
            for w in adj[u]:
                if not visited[w]:
                    visited[w] = True
                    self.parent[w] = u
                    self.depth[w] = self.depth[u] + 1
                    stack.append(w)

        self._order = order
        for i, u in enumerate(order):
            self.tin[u] = i
        size = [1] * n
        for u in reversed(order):  # 逆先序累加子树大小
            if u:  # 根是 0：父是自己，跳过避免把自己加给自己
                size[self.parent[u]] += size[u]
        self._tout = [self.tin[u] + size[u] - 1 for u in range(n)]

    def subtree_range(self, u: int) -> tuple[int, int]:
        """子树 u 在先序中的连续区间（0 下标，双闭）。"""
        return self.tin[u], self._tout[u]

    def prefix_masks(self, chars: list[int]) -> list[int]:
        """base[x] = 根→x（含两端）每个字符出现次数的奇偶位图（第 i 位 = 字符 i 奇数次）。"""
        base = [0] * len(chars)
        for u in self._order:  # 先序保证算 x 时 base[parent[x]] 已就绪；根的父是自己，从 0 起算
            base[u] = base[self.parent[u]] ^ (1 << chars[u])
        return base


class _BinaryLiftingLCA:
    """倍增 LCA：up[k][x] = x 的 2^k 级祖先，预处理 O(n log n)，单次查询 O(log n)。"""

    def __init__(self, parent: list[int], depth: list[int]) -> None:
        n = len(parent)
        self._depth = depth
        self._log = max(1, n.bit_length())  # 深度差 ≤ n-1 < 2^log，步长够用
        self._up = [parent[:]] + [[0] * n for _ in range(self._log - 1)]
        for k in range(1, self._log):
            prev, cur = self._up[k - 1], self._up[k]
            for v in range(n):
                cur[v] = prev[prev[v]]

    def find(self, a: int, b: int) -> int:
        depth, up, log = self._depth, self._up, self._log
        if depth[a] < depth[b]:
            a, b = b, a
        for k in range(log):  # 先把 a 提到与 b 同深度
            if (depth[a] - depth[b]) >> k & 1:
                a = up[k][a]
        if a == b:  # b 本来就是 a 的祖先
            return a
        for k in range(log - 1, -1, -1):  # 从最大步长向下试探，最后停在 lca 的孩子
            if up[k][a] != up[k][b]:
                a, b = up[k][a], up[k][b]
        return up[0][a]


class _RangeXorBit:
    """树状数组：对外提供 0 下标的"区间异或 / 单点查询"，点值 = 覆盖该位置的所有增量之异或。"""

    def __init__(self, n: int) -> None:
        self._n = n
        self._tree = [0] * (n + 1)  # 内部按 1 下标实现

    def range_xor(self, lo: int, hi: int, v: int) -> None:
        """区间 [lo, hi]（0 下标，双闭）整体异或 v——差分成两个单点修改。"""
        self._flip(lo + 1, v)
        self._flip(hi + 2, v)  # 差分右端；越界时 _flip 内部条件自然空操作

    def point_xor(self, i: int) -> int:
        """位置 i（0 下标）累计收到的异或增量。"""
        tree, r = self._tree, 0
        i += 1
        while i:
            r ^= tree[i]
            i -= i & -i
        return r

    def _flip(self, i: int, v: int) -> None:
        tree, n = self._tree, self._n
        while i <= n:
            tree[i] ^= v
            i += i & -i


class _RootPathMasks:
    """维护每个节点"根→自己"路径的字符奇偶位图，支持单点改字符。

    改 s[u] 会翻转 u 整棵子树内所有位图的两个字符位；子树在先序中是连续区间，
    于是用 base（初始快照）+ _RangeXorBit（累计增量）表达当前值，避免逐点重建子树。
    """

    def __init__(self, tree: _EulerTree, chars: list[int]) -> None:
        self._tree = tree
        self._chars = chars  # 每个节点当前字符（0-25），update 时就地修改
        self._base = tree.prefix_masks(chars)
        self._bit = _RangeXorBit(len(chars))

    def update(self, u: int, c: int) -> None:
        """s[u] 改为字符 c（0-25）：对子树区间异或 (旧字符位 ^ 新字符位)。"""
        if self._chars[u] != c:
            delta = (1 << self._chars[u]) ^ (1 << c)
            self._bit.range_xor(*self._tree.subtree_range(u), delta)
            self._chars[u] = c

    def path_mask(self, u: int, v: int, w: int) -> int:
        """u→v 路径（含两端）的字符奇偶位图，w = lca(u, v)。

        pref[u] ^ pref[v] 把根→w 公共前缀（含 w 本身）抵消，w 在路径上需补回一次。
        """
        return self.prefix(u) ^ self.prefix(v) ^ (1 << self._chars[w])

    def prefix(self, x: int) -> int:
        """当前（含全部 update 影响）根→x 的位图。"""
        return self._base[x] ^ self._bit.point_xor(self._tree.tin[x])


class Solution:
    def palindromePath(self, n: int, edges: list[list[int]], s: str, queries: list[str]) -> list[bool]:
        tree = _EulerTree(n, edges)
        lca = _BinaryLiftingLCA(tree.parent, tree.depth)
        masks = _RootPathMasks(tree, [ord(c) - 97 for c in s])

        ans = []
        for ops in queries:
            op, a, b = ops.split()
            if op == "update":  # "update u c"：单点改字符
                masks.update(int(a), ord(b) - 97)
            else:  # "query u v"：奇偶位图中 1 的个数 ≤ 1 ⇔ 可重排成回文
                u, v = int(a), int(b)
                ans.append(masks.path_mask(u, v, lca.find(u, v)).bit_count() <= 1)
        return ans
```

### 代码解析

- `_EulerTree`：一次迭代 DFS 同时产出 `parent / depth / tin`；子树大小用「逆先序累加」求得（孩子先算完，把自己的 size 加给父亲）。手动栈是因为 5×10^4 的链形树会触发 CPython 默认 1000 层递归上限；
- `_BinaryLiftingLCA`：`parent[0] = 0` 让根自指，倍增表跳过头时自然停在根，无需越界判断；`log = n.bit_length()` 保证 `n-1 < 2^log`，任何深度差都拆得开；
- `_RangeXorBit`：对外 0 下标，内部 1 下标——`tout+2` 这类下标换算全部封在 `range_xor` 一行里，调用方不可能踩错；
- `_RootPathMasks`：核心状态类。`update` 先判字符是否真的变了（改成原字符是合法输入，直接跳过）；`prefix = base ^ 增量`，读路径与写路径用同一套坐标（`tin`），天然对齐；
- `Solution`：解析后分派，`op, a, b = ops.split()`——两种操作都是三个字段，统一解包。

## 测试用例

覆盖官方示例、单节点树与自查询（`u == v`）、无效果 update、update 翻转结果、query 双向等价等易错点；混合树的期望值经独立 BFS 暴力参考实现逐组验证：

```python
def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.palindromePath(3, [[0, 1], [1, 2]], "aac", ["query 0 2", "update 1 b", "query 0 2"]) == [
        True,
        False,
    ]  # 示例 1：更新节点 1 后 "aac"→"abc"，同一查询由真变假
    assert solution.palindromePath(
        4, [[0, 1], [0, 2], [0, 3]], "abca", ["query 1 2", "update 0 b", "query 2 3", "update 3 a", "query 1 3"]
    ) == [False, False, True]  # 示例 2：含"更新成原字符"的无效果 update
    # 边界：单节点树（edges 为空）与自查询
    assert solution.palindromePath(1, [], "a", ["query 0 0", "update 0 b", "query 0 0"]) == [
        True,
        True,
    ]  # u == v 时路径只含一个字符，必然可重排成回文
    # 链形树：同一棵树上不同长度的路径，及更新后的变化
    assert solution.palindromePath(
        5, [[0, 1], [1, 2], [2, 3], [3, 4]], "abcba", ["query 0 4", "query 0 3", "query 1 2", "update 4 c", "query 0 4"]
    ) == [True, False, False, True]
    # 边界：更新为原字符（无效果 update）不应影响结果；换成不同字符后同一查询由真变假
    assert solution.palindromePath(
        2, [[0, 1]], "aa", ["query 0 1", "update 0 a", "query 0 1", "update 1 b", "query 0 1"]
    ) == [True, True, False]
    # 星形树 + 全同字符：任意两点路径都可行
    assert solution.palindromePath(4, [[0, 1], [0, 2], [0, 3]], "aaaa", ["query 1 2", "query 0 3", "query 3 1"]) == [
        True,
        True,
        True,
    ]
    # 混合树（12 节点）：update 翻转结果（假→真、真→假）、query 双向等价（"query 2 5" 与 "query 5 2"）
    # 期望值经独立 BFS 暴力参考实现验证
    assert solution.palindromePath(
        12,
        [[0, 1], [0, 2], [1, 3], [1, 4], [2, 5], [2, 6], [3, 7], [4, 8], [6, 9], [9, 10], [9, 11]],
        "qcdbbefaaghi",
        [
            "query 7 8",
            "query 0 4",
            "query 10 11",
            "update 1 q",
            "query 0 4",
            "query 2 5",
            "query 5 2",
            "update 8 b",
            "query 7 8",
            "query 0 11",
        ],
    ) == [True, False, False, True, False, False, False, False]
```

## 总结

- 「能否重排成回文」等价于「奇数次字符 ≤ 1」，26 位掩码 + 异或把整个判定变成一次 `bit_count()`；任意路径掩码用「前缀异或 + LCA 补位」一行拼出——LCA 是把任意形态路径转成两条可预计算根路径的桥梁；
- update 的本质是「单点修改 → 子树区间翻转」：Euler 序让子树成为连续区间，树状数组用两次 O(log n) 单点修改完成一次区间翻转，全程不需要重算任何前缀；
- 差分下标（区间右端 +1 再转 1 下标）是这类题最容易错的一格，把下标换算封装进数据结构内部、对外只暴露业务坐标，是防复发的有效手段。
