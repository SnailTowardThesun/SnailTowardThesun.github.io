---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.79: 单词搜索"
categories: LeetCode
tags: [中等, 回溯, 矩阵]
---

> Boggle 桌游（1972 年风靡欧美）：摇出 16 颗骰子的 4×4 字母盘上按相邻规则连词——本题正是它的算法版，网格搜词是拼字游戏 AI 的祖传基本功。

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

外层双重循环扫全网格：凡 `board[i][j] == word[0]` 的格子都可能是一条合法路径的起点，逐一启动 DFS。DFS 内部：当前格已匹配 `word[no]`，向上下左右四个方向寻找 `word[no + 1]`——字符相等且未访问即可踏入，踏上即匹配下一个字符；匹配到最后一个字符（`no == len(word) - 1`）立即返回 `True`，逐层短路返回，不做多余搜索。

### 标记防复用，撤销保干净——回溯的灵魂

「同一单元格不能走两次」靠标记实现：进入格子时打上访问标记（思路演示常原地改写成 `'#'`，本实现用独立的 `visited` 0/1 矩阵，语义等价）；**该分支探索失败、返回之前必须恢复标记**——这正是回溯的「撤销选择」。

恢复不可省：失败分支留下的残留标记会污染棋盘，把后续本可走通的分支误判成不可走。测试里专门备了 `word = "ABCESEEE"` 一例：只标记不恢复的错误实现**在官方示例 1 上照样通过**，却在这个用例上误判 `False`——示例全过、专项翻车，本例专防此类缺陷。

### 复杂度分析

- 时间复杂度：`O(m·n·3^L)`，`L` 为词长——起点至多 `m·n` 个；路径首步 4 个方向，其后每步**不回头**走刚来的格子，至多 3 个方向；
- 空间复杂度：`O(L)`（递归栈深度至多 15 层；`visited` 至多 6×6 = 36 格，视为常数）。

## 代码实现

```python
class Solution:
    def exist(self, board: list[list[str]], word: str) -> bool:
        # TODO: 枚举每个等于 word[0] 的格子作为起点，逐一启动 DFS 回溯
        # TODO: 当前格匹配 word[i] 后向上下左右四方向扩展，尝试匹配 word[i+1]
        # TODO: 进入格子时原地标记（如置 '#'）防止路径内复用，返回前恢复原字母（撤销选择）
        # TODO: 匹配到最后一个字符立即返回 True 短路，避免多余搜索
        def dfs(board, i, j, no, word, visited):
            m, n = len(board), len(board[0])
            if no == len(word) - 1:
                return True
            no += 1
            if i + 1 < m:
                if board[i + 1][j] == word[no] and not visited[i + 1][j]:
                    visited[i + 1][j] = 1
                    if dfs(board, i + 1, j, no, word, visited):
                        return True
                    visited[i + 1][j] = 0
            if i - 1 >= 0:
                if board[i - 1][j] == word[no] and not visited[i - 1][j]:
                    visited[i - 1][j] = 1
                    if dfs(board, i - 1, j, no, word, visited):
                        return True
                    visited[i - 1][j] = 0
            if j + 1 < n:
                if board[i][j + 1] == word[no] and not visited[i][j + 1]:
                    visited[i][j + 1] = 1
                    if dfs(board, i, j + 1, no, word, visited):
                        return True
                    visited[i][j + 1] = 0
            if j - 1 >= 0:
                if board[i][j - 1] == word[no] and not visited[i][j - 1]:
                    visited[i][j - 1] = 1
                    if dfs(board, i, j - 1, no, word, visited):
                        return True
                    visited[i][j - 1] = 0

            return False

        m, n = len(board), len(board[0])
        if len(word) > m * n:
            return False
        for i in range(m):
            for j in range(n):
                visited = [[0] * n for _ in range(m)]
                visited[i][j] = 1
                if board[i][j] == word[0]:
                    if dfs(board, i, j, 0, word, visited):
                        return True

        return False
```

### 代码解析

- **标记与恢复**：`visited` 用 0/1 矩阵而非原地改写 `'#'`，且**每个起点新开一张**——起点之间互不污染；踏入邻居前先置 1，该方向递归返回 `False` 后立即置 0 恢复，「标记—探索—撤销」三拍子就是回溯的全部节奏；
- **边界判断**：四个方向各自把关——`i + 1 < m`、`i - 1 >= 0`、`j + 1 < n`、`j - 1 >= 0`，越界方向直接跳过，不引入方向数组与循环；
- **递归前三重把关**：`board[i + 1][j] == word[no] and not visited[i + 1][j]` 把「字符不匹配」与「已访问」的分支挡在递归之外，无效路径根本不入栈；
- **短路返回**：进入 `dfs` 先查 `no == len(word) - 1`——命中最后一个字符立即 `return True` 逐层穿透；外层起点循环同理，`if dfs(...): return True`，找到后不再枚举剩余起点；
- **入口修剪**：`len(word) > m * n` 时格子总数不够铺满单词，直接返回 `False`，一次搜索都不必启动。

## 测试用例

覆盖四个官方示例与五个边界（混排大小写、同盘小写全词、单格命中与未命中、回溯撤销专项 `ABCESEEE`）：

```python
def test_solution() -> None:
    solution = Solution()
    assert not solution.exist([["a", "a"], ["A", "A"]], "aaa")

    assert not solution.exist([["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "ABCB")

    # ---- 官方示例 1：ABCCED 沿 A(0,0)→B→C→C→E→D 走通 ----
    assert solution.exist([["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "ABCCED")

    # ---- 官方示例 2：SEE 从 S(1,3) 出发，走下方 E(2,3)→E(2,2) ----
    assert solution.exist([["A", "B", "C", "E"], ["S", "F", "C", "S"], ["A", "D", "E", "E"]], "SEE")

    # ---- 官方示例 3：ABCB 回到 B 必须复用已走过的格子，false ----

    # ---- 官方示例 4：2x2 小写棋盘，b 之后无相邻 c，false ----
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
```

`uv run pytest top150/backtracking/top150_79.py` 全部通过。

## 总结

- 单词搜索 = 枚举起点 + 网格 DFS 回溯：标记防复用、撤销保干净、命中即短路，三件事做对即通关；
- 「恢复标记」是回溯的灵魂，也是最容易被漏掉的一步——`ABCESEEE` 专项用例证明：只标记不撤销的实现能骗过官方示例，却会因失败分支的残留标记误判 `False`；
- `O(m·n·3^L)` 的「首步 4 方向、其后不回头至多 3 方向」是网格回溯的通用度量口径，进阶版 No.212（单词搜索 II）在此之上再叠加 Trie 剪枝。
