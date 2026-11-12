---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.79: 单词搜索"
categories: LeetCode
tags: [中等, 回溯, 矩阵]
---

> 网格搜词可以看成路径搜索：格子是节点，相邻格子之间连边。匹配字符之外，还要记录当前路径已经访问的格子；换一条路径时，这些标记必须撤销。

## 题目

LeetCode 79. Word Search（单词搜索）

Difficulty: **Medium**

给定一个 `m x n` 的字符网格 `board` 和一个字符串 `word`。如果 `word` 存在于网格中，返回 `true`；否则返回 `false`。

单词必须按照字母顺序，通过**上下左右相邻**单元格内的字母构成一条路径：从一个单元格开始，每一步可以移动到相邻的一个单元格；**同一个单元格内的字母在一个单词中不允许被重复使用**。

约束：

- `1 <= m, n <= 6`
- `1 <= word.length <= 15`
- `board` 与 `word` 仅由大小写英文字母组成（大小写敏感）

### 示例

```text
输入：board = [["A","B","C","E"],["S","F","C","S"],["A","D","E","E"]], word = "ABCCED"
输出：true
解释：A(0,0)→B(0,1)→C(0,2)→C(1,2)→E(2,2)→D(2,1) 依次相邻，走通。
```

```text
输入：board 同示例 1，word = "SEE"
输出：true
解释：S(1,3)→E(2,3)→E(2,2)，从右侧的 S 出发向下拐弯连出 SEE。
```

```text
输入：board 同示例 1，word = "ABCB"
输出：false
解释：A→B→C 之后要回到 B，但 (0,1) 的 B 已被走过——同一单元格不允许复用。
```

```text
输入：board = [["a","b"],["c","d"]], word = "abcd"
输出：false
解释：a→b 之后，b 的相邻格只剩（已用过的）a 和 d，没有 c，路径断在第二字符。
```

## 解题思路

top150 面试经典 150 题把本题归入「回溯」分类，是网格版回溯的入门一课：没有预制的选择列表，**每一步的「选择」就是当前格的上下左右四个邻居**。

### 枚举起点，DFS 逐字符推进

外层双重循环扫全网格：凡 `board[i][j] == word[0]` 的格子都可能是一条合法路径的起点，逐一启动 DFS。DFS 内部：先检查当前字符是否匹配 `word[index]`，不匹配立即返回；匹配最后一位则成功，否则标记当前格并向四个方向递归。找到后停止搜索，但各层仍须先恢复棋盘再返回。

### 标记防复用，撤销保干净——回溯的灵魂

「同一单元格不能走两次」靠标记实现：进入格子时暂存原字母并改写成 `'#'`（输入仅含英文字母，不会冲突）；**无论搜索成功还是失败，返回之前都恢复原字母**——这正是回溯的「撤销选择」。

恢复不可省：失败分支留下的残留标记会污染棋盘，把后续本可走通的分支误判成不可走。测试里专门备了 `word = "ABCESEEE"` 一例：只标记不恢复的错误实现**在官方示例 1 上照样通过**，却在这个用例上误判 `False`——示例全过、专项翻车，本例专防此类缺陷。

### 复杂度分析

- 时间复杂度：`O(m·n·3^L)`，`L` 为词长——起点至多 `m·n` 个；路径首步 4 个方向，其后每步**不回头**走刚来的格子，至多 3 个方向；
- 空间复杂度：`O(L)`（递归栈；原地标记不另建 visited 矩阵）。

## 代码实现

```python
class Solution:
    def exist(self, board: list[list[str]], word: str) -> bool:
        m, n = len(board), len(board[0])
        if len(word) > m * n:
            return False

        def dfs(i: int, j: int, index: int) -> bool:
            if board[i][j] != word[index]:
                return False
            if index == len(word) - 1:
                return True

            letter = board[i][j]
            board[i][j] = "#"  # 输入只有英文字母，标记不会与 word 中的字符冲突。
            found = False
            for di, dj in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                ni, nj = i + di, j + dj
                if 0 <= ni < m and 0 <= nj < n and dfs(ni, nj, index + 1):
                    found = True
                    break
            board[i][j] = letter  # 成功或失败都恢复，调用结束后棋盘保持原样。
            return found

        for i in range(m):
            for j in range(n):
                if dfs(i, j, 0):
                    return True
        return False
```

### 代码解析

- 当前格先比字符，再判定是否匹配完毕；标记 `'#'` 永远不会匹配下一位，因而防止路径复用；
- 方向数组统一四邻域遍历，只对未越界坐标递归；
- 成功时先记下 `found` 并退出方向循环，恢复原字母后才返回，避免短路遗漏撤销；
- `len(word) > m*n` 时直接返回 False；结束后输入棋盘保持原样，可连续搜索不同单词。

## 测试用例

覆盖三个官方示例、补充示例与边界（混排大小写、同盘小写全词、单格命中与未命中、回溯撤销专项 `ABCESEEE`）：

```python
def test_solution() -> None:
    solution = Solution()
    assert not solution.exist([["a", "a"], ["A", "A"]], "aaa")

    # ---- 官方示例 1：ABCCED 沿 A(0,0)→B→C→C→E→D 走通 ----
    assert solution.exist([["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "ABCCED")

    # ---- 官方示例 2：SEE 从 S(1,3) 出发，走下方 E(2,3)→E(2,2) ----
    assert solution.exist([["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "SEE")

    # ---- 官方示例 3：ABCB 回到 B 必须复用已走过的格子，false ----
    assert not solution.exist([["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "ABCB")

    # ---- 补充示例：2x2 小写棋盘，b 之后无相邻 c，false ----
    assert not solution.exist([["a", "b"], ["c", "d"]], "abcd")

    # ---- 大小写敏感：同官方示例 1 棋盘，小写 abcced 匹配不到，false ----
    assert not solution.exist([["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "abcced")

    # ---- 单格棋盘：命中 ----
    assert solution.exist([["a"]], "a")

    # ---- 单格棋盘：未命中 ----
    assert not solution.exist([["a"]], "b")

    # ---- 回溯必备用例：word = "ABCESEEE" ----
    # C 之后棋盘上存在会走进死胡同的 E 分支，必须撤销标记回溯换路才能走通；
    # 已程序化验证：只标记不恢复（不会撤销选择）的错误实现在本例上误判
    # False，而它在官方示例 1 上仍能通过——本例专防此类缺陷
    assert solution.exist([["A", "B", "C", "E"], ["S", "F", "E", "S"], ["A", "D", "E", "E"]], "ABCESEEE")

    # ---- 成功短路与失败回溯都必须恢复棋盘，同一对象可连续搜索 ----
    board = [["A", "B"], ["C", "D"]]
    original = [row.copy() for row in board]
    for word, expected in (("ABD", True), ("ABA", False), ("ACDB", True), ("ABCD", False)):
        assert solution.exist(board, word) == expected
        assert board == original
```

`uv run pytest top150/backtracking/top150_79.py` 全部通过。

## 总结

- 单词搜索 = 枚举起点 + 网格 DFS 回溯：标记防复用、撤销保干净、命中即短路，三件事做对即通关；
- 「恢复标记」是回溯的灵魂，也是最容易被漏掉的一步——`ABCESEEE` 专项用例证明：只标记不撤销的实现能骗过官方示例，却会因失败分支的残留标记误判 `False`；
- `O(m·n·3^L)` 的「首步 4 方向、其后不回头至多 3 方向」是网格回溯的通用度量口径，进阶版 No.212（单词搜索 II）在此之上再叠加 Trie 剪枝。
