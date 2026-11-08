---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.127: 单词接龙"
categories: LeetCode
tags: [困难, 广度优先搜索, 哈希表, 字符串]
---

> 单词接龙是刘易斯·卡罗尔 1877 年发明的文字游戏 Doublets：每次只换一个字母把 WORD 变成 LINK。它的解法骨架就是无权图最短路——BFS 逐层扩展，首次抵达即最短。

## 题目

LeetCode 127. Word Ladder（单词接龙）

Difficulty: **Hard**

字典 `wordList` 中从单词 `beginWord` 到 `endWord` 的**转化序列**是一个按下标递增的单词序列 `beginWord -> s1 -> s2 -> ... -> sk`，满足：

- 每一对相邻的单词**恰好只差一个字母**；
- 序列中的每个 `s_i`（`1 <= i <= k`）都在 `wordList` 中——注意 `beginWord` 不需要在 `wordList` 中；
- `sk == endWord`。

返回从 `beginWord` 到 `endWord` 的**最短转化序列中的单词数目**；如果不存在这样的转化序列，返回 `0`。

约束：

- `1 <= beginWord.length <= 10`，`endWord.length == beginWord.length`
- `1 <= wordList.length <= 5000`，`wordList[i].length == beginWord.length`
- 所有单词由小写英文字母组成，`beginWord != endWord`，`wordList` 中的单词互不相同

### 示例

```text
输入：beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log","cog"]
输出：5
解释：最短转化序列是 "hit" -> "hot" -> "dot" -> "dog" -> "cog"，共 5 个单词。
```

```text
输入：beginWord = "hit", endWord = "cog", wordList = ["hot","dot","dog","lot","log"]
输出：0
解释：endWord "cog" 不在字典中，无法完成转化。
```

## 解题思路

### 和 433 同族，但有两处不同

把单词看成节点、「恰差一个字母」连边，这就是和最小基因变化（LeetCode 433）同族的隐式图最短路，BFS 首触即最优。但有两处关键差异：

1. **返回值是序列中的单词数目**（= 边数 + 1），不是变化次数——`hit -> hot -> dot -> dog -> cog` 返回 5 而不是 4，层数要从 1 起算；
2. **规模不允许暴力找邻居**：`N = 5000` 个词两两比对是 `O(N^2 x L) ≈ 2.5 x 10^8` 次字符比较，Python 直接超时——这正是它从 Medium 升格 Hard 的原因。

### 通配符分桶：一次建桶，处处查邻居

优化思路：不问「谁和它是邻居」，改问「它属于哪些邻居圈」。每个单词生成 `L` 个**模式串**——把第 `i` 位替换成 `*`：

```text
"hot" -> *ot / h*t / ho*
```

同一个模式桶里的单词两两互为邻居（`*ot` 桶里有 `hot`、`dot`、`lot`，它们任意两个都只差中间那位）。BFS 出队一个单词，展开它所属的 `L` 个桶，桶里的词就是全部邻居。

均摊的关键在**桶用完即清**：一个桶被展开时，桶内单词已全部入队（visited 拦下重复的），把桶清空后，后续单词再查到同一模式只会得到空桶——每个桶至多被完整展开一次，总转移均摊 `O(N x L)`。

### BFS 细节

- `beginWord` 不必在字典中——直接作为 BFS 起点；`endWord` **必须**在字典中，先查再搜，不在则提前返回 0；
- 队列元素携带 `(单词, 序列单词数)`，`beginWord` 的计数是 1；
- `visited` 在入队时标记，防止同层互指成环。

### 复杂度分析

- 时间复杂度：`O(N x L^2)`（建桶的切片拼接 + BFS 均摊展开）
- 空间复杂度：`O(N x L^2)`（桶中存模式串与单词、`visited`、队列）

## 代码实现

```python
from collections import deque


class Solution:
    def ladderLength(self, beginWord: str, endWord: str, wordList: list[str]) -> int:
        word_set = set(wordList)
        if endWord not in word_set:
            return 0  # endWord 不在字典中，提前剪枝

        n = len(beginWord)
        # 通配符分桶：模式串 -> 同桶单词（同桶两两互为邻居）
        buckets: dict[str, list[str]] = {}
        for word in wordList:
            for i in range(n):
                buckets.setdefault(word[:i] + "*" + word[i + 1 :], []).append(word)

        visited = {beginWord}
        queue = deque([(beginWord, 1)])  # (单词, 转化序列中的单词数)
        while queue:
            curr, count = queue.popleft()
            if curr == endWord:
                return count
            for i in range(n):
                bucket = buckets.get(curr[:i] + "*" + curr[i + 1 :])
                if not bucket:
                    continue
                for word in bucket:
                    if word not in visited:
                        visited.add(word)
                        queue.append((word, count + 1))
                bucket.clear()  # 桶内单词已全部入队，清空避免重复展开
        return 0
```

### 代码解析

- `setdefault(word[:i] + "*" + word[i+1:], []).append(word)` 一行完成「查桶、建桶、入桶」三步，模式串同时充当字典键和邻接关系；
- `bucket.clear()` 是均摊复杂度的落点：桶是原地清空的（字典里持有同一个 list 引用），后续查到同模式直接得到空桶，`if not bucket: continue` 自然跳过；
- 命中 `endWord` 在**出队时**判定返回 `count`——BFS 的层序保证这是最短的序列长度；
- 循环上界用 `n = len(beginWord)`：题目保证三个串等长，模式桶天然对齐；
- 返回 `0` 的两处语义不同：开头是「`endWord` 不在字典」，结尾是「字典合法但图不连通」。

## 测试用例

覆盖两个官方示例与五类边界（单条边钉死"单词数"语义、邻居缺失、`endWord` 合法但无桥、`beginWord` 也在字典、桶共享中间层）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：hit->hot->dot->dog->cog，5 个单词 ----
    assert solution.ladderLength("hit", "cog", ["hot", "dot", "dog", "lot", "log", "cog"]) == 5

    # ---- 官方示例 2：endWord 不在字典，0 ----
    assert solution.ladderLength("hit", "cog", ["hot", "dot", "dog", "lot", "log"]) == 0

    # ---- 一条边：返回 2 个单词（不是 1 次变化） ----
    assert solution.ladderLength("hit", "hot", ["hot"]) == 2

    # ---- 邻居缺失走不通：hit 与 dot 差两位，0 ----
    assert solution.ladderLength("hit", "dot", ["dot"]) == 0

    # ---- endWord 在字典但与 beginWord 差三位且无桥，0 ----
    assert solution.ladderLength("hit", "cog", ["cog"]) == 0

    # ---- beginWord 也在字典中（允许但非必需） ----
    assert solution.ladderLength("a", "c", ["a", "b", "c"]) == 2

    # ---- 桶共享中间层：hot 同时是 hit 的邻居和 dot 的跳板 ----
    assert solution.ladderLength("hit", "cog", ["hot", "dot", "dog", "cog"]) == 5
```

`uv run pytest top150/graph_bfs/top150_127.py` 全部通过。

## 总结

- 单词接龙的骨架是 BFS 无权图最短路，但 Hard 的分量在邻接查找：两两比对 `O(N^2 x L)` 不可行，通配符分桶把它压到均摊 `O(N x L)`；
- 「桶展开即清空」是分桶法不退化的关键——每个桶只被完整展开一次，这一行 `clear()` 值得单独记下；
- 与 433 同族不同返回：单词数（边数 + 1）从 1 起算，用「单条边返回 2」的用例钉死语义，比写完再猜可靠。
