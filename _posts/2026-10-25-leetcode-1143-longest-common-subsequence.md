---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1143: 最长公共子序列"
categories: LeetCode
tags: [中等, 动态规划, 字符串]
---

> 最长公共子序列是 diff、版本对比和基因相似度的基础：它关心的不只是字符是否相同，更是相对顺序能否被保留。

## 题目

LeetCode 1143. Longest Common Subsequence（最长公共子序列）

Difficulty: **Medium**

给定两个字符串 `text1` 和 `text2`，返回它们**最长公共子序列**的长度。如果不存在公共子序列，返回 `0`。

一个字符串的**子序列**可以通过删除若干个字符（也可以不删）得到，但必须保持剩余字符的相对顺序。

约束：

- `1 <= text1.length, text2.length <= 1000`
- `text1` 和 `text2` 仅由小写英文字符组成

### 示例

```
输入：text1 = "abcde", text2 = "ace"
输出：3
解释：最长公共子序列是 "ace"。

输入：text1 = "abc", text2 = "abc"
输出：3
解释：最长公共子序列是 "abc"。

输入：text1 = "abc", text2 = "def"
输出：0
解释：两个字符串没有公共子序列。
```

## 解题思路

### 状态定义

令 `dp[i][j]` 表示 `text1` 前 `i` 个字符与 `text2` 前 `j` 个字符的最长公共子序列长度。这里的“前 `i` 个字符”使用的是字符串前缀，而不是下标 `i`，所以边界可以自然表示空串：`dp[0][j]` 和 `dp[i][0]` 都是 `0`。

### 转移方程

比较两个前缀的最后一个字符：

- 当 `text1[i - 1] == text2[j - 1]` 时，这个字符可以作为公共子序列的当前结尾，接到两侧都去掉该结尾后的结果后面，所以 `dp[i][j] = dp[i - 1][j - 1] + 1`；
- 当它们不相等时，公共子序列不可能同时以这两个结尾字符结束，至少要舍弃其中一个，所以取较大值：`dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])`。

以 `text1 = "abcde"`、`text2 = "ace"` 为例，计算到 `i = 3`、`j = 3` 时，比较的是 `'c'` 和 `'e'`，不相等，于是回看 `dp[2][3]` 和 `dp[3][2]`。前者的答案已经包含 `"ac"`，最终 `dp[5][3]` 继续扩展为 `"ace"`。

### 复杂度分析

`m` 和 `n` 分别是两个字符串的长度。二维表有 `(m + 1)(n + 1)` 个状态，每个状态只做常数次比较和赋值，所以时间复杂度是 `O(mn)`，空间复杂度也是 `O(mn)`。

## 代码实现

```python
class Solution:
    def longestCommonSubsequence(self, text1: str, text2: str) -> int:
        m, n = len(text1), len(text2)
        dp = [[0] * (n + 1) for _ in range(m + 1)]

        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if text1[i - 1] == text2[j - 1]:
                    dp[i][j] = dp[i - 1][j - 1] + 1
                else:
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])

        return dp[m][n]
```

### 代码解析

- **维度加一**：`dp` 的大小是 `(m + 1) × (n + 1)`，第 0 行和第 0 列表示空串前缀，天然初始化为 `0`；
- **下标减一**：`dp[i][j]` 描述的是长度为 `i`、`j` 的前缀，因此访问最后一个字符时要用 `text1[i - 1]` 和 `text2[j - 1]`；
- **相等时用左上角**：`dp[i - 1][j - 1] + 1` 保证当前相同字符只被消费一次；
- **不相等时取上、左最大值**：对应分别舍弃 `text1` 或 `text2` 的末尾字符，保留另一侧完整参与匹配。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # 官方示例
    assert solution.longestCommonSubsequence("abcde", "ace") == 3  # "ace"
    assert solution.longestCommonSubsequence("abc", "abc") == 3  # 两个字符串完全相同
    assert solution.longestCommonSubsequence("abc", "def") == 0  # 没有公共字符

    # 边界与重复字符
    assert solution.longestCommonSubsequence("a", "a") == 1  # 单字符相同
    assert solution.longestCommonSubsequence("a", "b") == 0  # 单字符不同
    assert solution.longestCommonSubsequence("aaaa", "aa") == 2  # 重复字符不能重复超过较短串次数

    # 子序列必须保持相对顺序
    assert solution.longestCommonSubsequence("abc", "cba") == 1  # 只能选一个公共字符
    assert solution.longestCommonSubsequence("abcde", "aec") == 2  # "ac"，不能取乱序的 "aec"

    # 交换参数后结果不变
    assert solution.longestCommonSubsequence("ace", "abcde") == 3

    # 较复杂的重复与穿插
    assert solution.longestCommonSubsequence("abcba", "abcbcba") == 5  # "abcba"
    assert solution.longestCommonSubsequence("aabaa", "azbaa") == 4  # "abaa"
```

这组用例特意覆盖了三类容易出错的点：重复字符不能无中生有、公共字符必须保持相对顺序，以及结果对参数交换的对称性。

## 总结

- LCS 的关键是把问题拆成两个前缀的关系，`dp[i][j]` 明确表示长度而不是下标，边界处理会简单很多；
- 相等时从左上角加一，不相等时从上、左取最大值，这个转移同时覆盖了“消费当前字符”和“舍弃某个末尾字符”两种选择；
- 测试里加入乱序和重复字符，比只用官方示例更能暴露状态转移中的逻辑错误。
