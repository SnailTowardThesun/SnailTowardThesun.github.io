---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.97: 交错字符串"
categories: LeetCode
tags: [中等, 动态规划, 双序列, 字符串, top150]
---

> 交错字符串是"双指针贪心"的经典反例：两串字符相同（歧义）时先取谁都可能错，必须两条来源都试——二维 DP 的 (i,j) 记录的正是两个前缀各自的消耗量。

## 题目

LeetCode 97. Interleaving String（交错字符串）

Difficulty: **Medium**

给定三个字符串 `s1`、`s2`、`s3`，请判断 `s3` 是否由 `s1` 和 `s2` **交错组成**。交错定义为：将 `s1`、`s2` 分别分割成若干非空子串后，按 `s1 + t1 + s2 + t2 + ...` 或 `t1 + s1 + t2 + s2 + ...` 的顺序交织（`s = s1 + s2 + ... + sn`，`t = t1 + t2 + ... + tm`，`|n - m| <= 1`，分割出的子串保持原序）。

约束：

- `0 <= s1.length, s2.length <= 100`
- `0 <= s3.length <= 200`
- `s1`、`s2`、`s3` 由小写英文字母组成

### 示例

```text
输入：s1 = "aabcc", s2 = "dbbca", s3 = "aadbbcbcac"
输出：True
```

```text
输入：s1 = "aabcc", s2 = "dbbca", s3 = "aadbbbaccc"
输出：False
```

```text
输入：s1 = "", s2 = "", s3 = ""
输出：True
```

## 解题思路

### 状态：两个前缀的消耗量

`s3` 的每个字符要么来自 `s1` 要么来自 `s2`，且各自保持原序。定义 `dp[i][j]` = `s3` 前 `i+j` 个字符能否由 `s1` 前 `i` 个与 `s2` 前 `j` 个交错组成，答案 `dp[n1][n2]`。

- **长度先判**：`n1 + n2 != n3` 直接 False——交错不改总长；
- **边界**：`dp[0][0] = True`；首列 `dp[i][0]` 要求 `s1` 前 `i` 个恰与 `s3` 前 `i` 个逐位相同（只消耗 s1），首行同理；
- **转移**：`s3` 的第 `i+j` 个字符只有两个来处——

```text
dp[i][j] = (dp[i-1][j] 且 s3[i+j-1] == s1[i-1])    # 取自 s1
        or (dp[i][j-1] 且 s3[i+j-1] == s2[j-1])    # 取自 s2
```

### 为什么双指针贪心不行

`s1 = "aa"`、`s2 = "ab"`、`s3 = "aaba"`：扫描到 `s3` 的第二个 `a` 时，`s1` 和 `s2` 都能提供——先取谁？取错的那条路会把后面的 `b` 逼到无源。**歧义时刻的两个选择都可能通向合法解，也都可能死路**，局部信息无法裁决，必须两条都试。DP 表的每个 `(i, j)` 格子正是"两个前缀各消耗多少"的全部状态，一表扫尽所有分叉的组合。

### 复杂度分析

- 时间复杂度：`O(n1 * n2)`
- 空间复杂度：`O(n1 * n2)`，逐行滚动可压到 `O(n2)`

## 代码实现

```python
class Solution:
    def isInterleave(self, s1: str, s2: str, s3: str) -> bool:
        n1, n2, n3 = len(s1), len(s2), len(s3)
        if n1 + n2 != n3:
            return False
        # dp[i][j]：s3[:i+j] 能否由 s1[:i] 与 s2[:j] 交错组成
        dp = [[False] * (n2 + 1) for _ in range(n1 + 1)]
        dp[0][0] = True
        for i in range(1, n1 + 1):  # 首列：只消耗 s1
            dp[i][0] = dp[i - 1][0] and s1[i - 1] == s3[i - 1]
        for j in range(1, n2 + 1):  # 首行：只消耗 s2
            dp[0][j] = dp[0][j - 1] and s2[j - 1] == s3[j - 1]
        for i in range(1, n1 + 1):
            for j in range(1, n2 + 1):
                if dp[i - 1][j] and s1[i - 1] == s3[i + j - 1]:  # 第 i+j 个字符取自 s1
                    dp[i][j] = True
                elif dp[i][j - 1] and s2[j - 1] == s3[i + j - 1]:  # 取自 s2（歧义时两条都试）
                    dp[i][j] = True

        return dp[n1][n2]


def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.isInterleave("aabcc", "dbbca", "aadbbcbcac") is True
    assert solution.isInterleave("aabcc", "dbbca", "aadbbbaccc") is False
    assert solution.isInterleave("", "", "") is True
    # 边界：某一串为空，另一串须恰为 s3（含前缀失配）
    assert solution.isInterleave("", "abc", "abc") is True
    assert solution.isInterleave("", "abc", "abd") is False
    assert solution.isInterleave("abc", "", "abc") is True
    # 长度不符直接 False（即使字符都对得上）
    assert solution.isInterleave("ab", "cd", "abc") is False
    # 单字符与基本交错
    assert solution.isInterleave("a", "b", "ab") is True
    assert solution.isInterleave("a", "b", "ba") is True
    assert solution.isInterleave("ab", "cd", "acbd") is True
    # 歧义用例：同一字符两条来源都可行时，贪心（固定先取某一串）会错
    assert solution.isInterleave("aa", "ab", "aaba") is True
    assert solution.isInterleave("aa", "ab", "abaa") is True
    assert solution.isInterleave("aaa", "aaa", "aaaaaa") is True
    # 随机用例（期望值经带备忘递归暴力验证）
    assert solution.isInterleave("aabc", "abad", "aababadc") is True
```

### 代码解析

- 长度不等早退，避免后续所有下标白算；
- 首列/首行的"前缀链"初始化用 `dp[i-1][0] and ...` 链式传播——一旦某位失配，后面全 False，正是"只消耗一串"的语义；
- 主转移虽然写成 if/elif，两个条件**互不排斥**：都成立时任一为 True 即可，elif 只是不重复赋值；
- 状态下标与字符下标的换算（`s3[i+j-1]` 对 `s1[i-1]`）是本题最容易差一位的地方，测试里 `("ab","cd","acbd")` 这类小例专门钉它。

## 总结

- 交错判断的状态是"两个前缀各消耗多少"：`dp[i][j]` 的两个来向恰对应 `s3` 末字符的两个可能出处；
- 字符歧义（两串当前字符相同）使贪心失效，必须两路并试——这正是本题从双指针升级为二维 DP 的原因；
- 长度先判、空串边界、"长度不符但字符吻合"的陷阱用例，是这类三串题的三个必测点。
