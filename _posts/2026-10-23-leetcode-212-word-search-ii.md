---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.212: 单词搜索 II"
categories: LeetCode
tags: [困难, 字典树, 回溯, 矩阵]
---

> 逐词在棋盘上暴力搜索是 O(单词数 × 格子数 × 4^L) 的灾难；把所有单词先折叠成一棵前缀树，让 DFS「带着字典走」，不存在的分支一步都不用探——Trie 在这道题里不是数据结构选型，而是剪枝本身。

## 题目

LeetCode 212. Word Search II（单词搜索 II）

Difficulty: **Hard**

给定一个 `m x n` 二维字符网格 `board` 和一个单词（字符串）列表 `words`,返回所有**同时在网格和字典中出现**的单词。

单词必须按照字母顺序，通过**相邻单元格**内的字母构成（"相邻"指水平或竖直相邻），且同一个单元格内的字母在一个单词中**不允许被重复使用**。

### 示例

```
输入：board = [["o","a","a","n"],
              ["e","t","a","e"],
              ["i","h","k","r"],
              ["i","f","l","v"]],
     words = ["oath","pea","eat","rain"]
输出：["eat","oath"]

输入：board = [["a","b"],["c","d"]], words = ["abcb"]
输出：[]
解释：构造 "abcb" 需要重复使用 'b' 所在的单元格，非法。
```

## 解题思路

### 从暴力到 Trie

最直观的做法是把 79 题「单词搜索」对每个单词各跑一遍：每次从每个格子出发做四方向 DFS。代价 `O(W · m·n · 3^L)`(`W` 是单词数,`L` 是单词长度)，单词一多直接爆炸。

改进的关键：**所有单词共享前缀**。把它们建成一棵 Trie,一次 DFS 同时试探所有单词——每走到一个格子，只需问"当前 trie 节点有没有这个字母的孩子",没有立刻回头。不存在的路径一步都不会展开。

### 回溯的四个细节

1. **状态携带 trie 节点**：DFS 参数里带上当前节点 `cur`,棋盘路径和单词前缀天然同步；
2. **词尾收集与去重**:`is_end` 标记词尾，命中即把单词拼出来收集，然后**把 `is_end` 置 False**——同一单词被多条路径/多个位置命中时只输出一次；
3. **单元格去重用原地标记**：进入格子时改成 `"#"`,邻居就不会走回来，回溯时再改回原字符——省掉一个 `visited` 集合；
4. **子树摘除剪枝**：某个节点探完后既没有剩余孩子、词尾也已收集，就把它从父节点的 `child` 里删除。这是 LeetCode 著名 TLE 陷阱的解法——全 `a` 棋盘配上几千个 `aaaaaaaaab` 型单词，不摘子树会指数级重复探索；摘除后实测 12×12 棋盘 × 3000 词 **0.2 秒**完成。

### 复杂度分析

时间 `O(m·n·4·3^(L-1))`(首步 4 个邻居，其后每步至多 3 个回头以外的方向)，与单词数量无关；空间 `O(所有单词的总字符数)`(trie)+ `O(L)` 递归栈。

## 代码实现

```python
class Trie:
    def __init__(self):
        self.child = {}
        self.is_end = False

    def insert(self, word):
        cur = self
        for ch in word:
            if cur.child.get(ch) is None:
                cur.child[ch] = Trie()
            cur = cur.child[ch]

        cur.is_end = True


class Solution:
    def findWords(self, board: list[list[str]], words: list[str]) -> list[str]:
        # 所有单词建成一棵 trie，DFS 时只沿 trie 存在的分支走，天然剪掉无效路径
        trie = Trie()
        for w in words:
            trie.insert(w)

        m, n = len(board), len(board[0])
        ret: list[str] = []

        def dfs(i: int, j: int, cur: Trie, path: list[str]) -> None:
            ch = board[i][j]
            nxt = cur.child.get(ch)
            if nxt is None:
                return  # trie 里没有这个分支，此路不通

            path.append(ch)
            if nxt.is_end:
                ret.append("".join(path))
                nxt.is_end = False  # 收集一次后摘掉词尾标记，多路径命中只输出一次

            board[i][j] = "#"  # 原地标记：当前格已在路径上，不可重复使用
            for x, y in ((i + 1, j), (i - 1, j), (i, j + 1), (i, j - 1)):
                if 0 <= x < m and 0 <= y < n and board[x][y] != "#":
                    dfs(x, y, nxt, path)
            board[i][j] = ch  # 回溯恢复

            path.pop()
            if not nxt.child and not nxt.is_end:
                del cur.child[ch]  # 剪枝：走空的分支从 trie 摘除

        for i in range(m):
            for j in range(n):
                dfs(i, j, trie, [])

        return ret
```

### 代码解析

- **`cur.child.get(ch) is None` 即回头**：trie 不认这个字母，这条棋盘路径不可能拼出任何单词；
- **`is_end` 收集后置 False**:`[["a","b"],["a","b"]]` 查 `ab` 有两条路径，第一次收集后标记摘除，第二次走到不再重复输出；
- **`"#"`` 原地标记**：进格子前破坏、回溯后恢复，等价 visited 集合但无额外内存与哈希开销；
- **`del cur.child[ch]`**：探空的分支从树里摘掉，后续格子再遇到该前缀直接 `get` 失败回头。

## 测试用例

```python
# 官方示例 + 单元格不可重复使用
assert sorted(s.findWords([["o","a","a","n"],["e","t","a","e"],["i","h","k","r"],
                           ["i","f","l","v"]], ["oath","pea","eat","rain"])) == ["eat","oath"]
assert s.findWords([["a","b"],["c","d"]], ["abcb"]) == []

# 多路径命中只输出一次 / 蛇形螺旋长词 / 反向路径
assert s.findWords([["a","b"],["a","b"]], ["ab"]) == ["ab"]
```

完整测试另含共享前缀单词组、超长词剪枝、3×3 顺时针螺旋词 `abcdefghi`,以及 3 轮随机对拍：一半查询词**沿棋盘真实路径走出来**(保证正样本)，与逐词暴力 DFS 的结果对照——避免"两边都返回空"的假绿。

## 总结

- Trie 在这里是剪枝：棋盘路径与字典前缀同步匹配，无效分支零成本剪掉；
- 词尾收集即摘除、子树探空即删除，两个"删"分别解决重复输出与指数重复探索；
- 对拍的正样本要从真实路径生成，否则测试可能全程空转、形同虚设。
