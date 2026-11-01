---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.5: 最长回文子串"
categories: LeetCode
tags: [中等, 动态规划, 字符串, 回文, top150]
---

> 判断回文有两种等价视角：区间 DP 的"两端相等且内部回文"，或中心向外扩展。前者转移好证、能顺带产出所有子串的回文性，后者常数更小——O(n²) 时间下殊途同归。

## 题目

LeetCode 5. Longest Palindromic Substring（最长回文子串）

Difficulty: **Medium**

给你一个字符串 `s`，找到 `s` 中最长的回文子串。如果存在多个最长回文子串，返回其中任意一个。

约束：

- `1 <= s.length <= 1000`
- `s` 仅由数字和英文字母组成

### 示例

```text
输入：s = "babad"
输出："bab"
解释："aba" 同样是符合题意的答案。
```

```text
输入：s = "cbbd"
输出："bb"
```

## 解题思路

### 区间 DP：回文的递归结构

`dp[i][j]` = `s[i..j]` 是否回文。回文的定义天然递归：**两端相等，且掐头去尾后仍是回文**：

- 长度 1：`dp[i][i] = True`；
- 长度 2/3：两端相等即回文（中间夹 0 或 1 个字符，不构成威胁）——`j - i < 3` 时免查内部；
- 更长：`dp[i][j] = (s[i] == s[j]) and dp[i+1][j-1]`。

按**子串长度**从 2 到 n 枚举（外层）、左端点 i 枚举（内层），保证算 `dp[i][j]` 时更短的内部子串已就绪。过程中记录最长回文的起点与长度即可。

### 一个 `==` 笔误：ruff 替你站岗

初版把"s[i] != s[j] 时置 False"写成了 `dp[i][j] == False`——**比较而非赋值**。它碰巧不出错：dp 初始化本就全 False，这条空比较什么都没做，行为恰好正确。这类"初值掩护下的死语句"肉眼极难发现，ruff 的 B015（无意义比较）与 E712（与 False 比较）两条规则一跑即现形。修成 `=` 后语义显式，不再依赖初值巧合。

### 构造测试数据的两次翻车：直觉不可靠

为覆盖 1000 长上界，需要手工构造"超长串 + 唯一中段回文"。两次构造都被暴力打脸：

1. `"abc"*332 + "aba" + "abc"`——拼接处 `"aba"+"abc"` 意外产生了 4 长回文 `"baab"`，比目标 `"aba"` 还长；
2. `"ab"*498 + ...`——更惨：**交替串本身就是一个 995 长的巨型回文**（`"abab...a"` 反转不变）。

最终 `"abc"*332 + "q"*7 + "abc"` 经 O(n³) 暴力核验"最长回文长度 7 且唯一"才定稿。教训：极端测试数据必须暴力核验后再写进断言，构造直觉在这类组合问题上极不可靠。

### 复杂度分析

- 时间复杂度：`O(n^2)`——长度 × 左端点双重枚举，每格 O(1)
- 空间复杂度：`O(n^2)`；中心扩展法可做到 O(1) 空间，Manacher 可 O(n) 时间

## 代码实现

```python
class Solution:
    def longestPalindrome(self, s: str) -> str:
        if len(s) < 2:
            return s

        n = len(s)
        dp = [[False] * n for _ in range(n)]
        for i in range(n):
            dp[i][i] = True

        max_len = 1
        begin = 0

        for length in range(2, n + 1):  # 枚举子串长度
            for i in range(n):  # 枚举左端点
                j = length + i - 1  # 右端点
                if j >= n:
                    break

                if s[i] != s[j]:
                    dp[i][j] = False  # 初版误写为 ==（比较无效果，幸而初值即 False）
                else:
                    if j - i < 3:  # 长度 2 或 3：两端相等即回文
                        dp[i][j] = True
                    else:
                        dp[i][j] = dp[i + 1][j - 1]  # 取决于内部子串
                if dp[i][j] and j - i + 1 > max_len:
                    max_len = j - i + 1
                    begin = i

        return s[begin : begin + max_len]


def test_solution() -> None:
    solution = Solution()
    # 官方示例（答案不唯一时接受任一合法解）
    assert solution.longestPalindrome("babad") in ("bab", "aba")
    assert solution.longestPalindrome("cbbd") == "bb"
    # 边界：单字符 / 无回文的双字符
    assert solution.longestPalindrome("a") == "a"
    assert solution.longestPalindrome("ac") in ("a", "c")
    assert solution.longestPalindrome("bb") == "bb"
    # 唯一答案：整串回文（奇/偶长度）、回文在中段
    assert solution.longestPalindrome("abcba") == "abcba"
    assert solution.longestPalindrome("abccba") == "abccba"
    assert solution.longestPalindrome("forgeeksskeegfor") == "geeksskeeg"
    assert solution.longestPalindrome("abacab") == "bacab"
    assert solution.longestPalindrome("aaaa") == "aaaa"
    # 无奇偶中心回文时返回任一单字符（多解按属性校验）
    r = solution.longestPalindrome("abcda")
    assert len(r) == 1 and r in "abcda"
    # 长输入上界：全同字符整串即最长；"abc" 周期填充中嵌入唯一长回文（暴力核验唯一性）
    assert solution.longestPalindrome("a" * 1000) == "a" * 1000
    assert solution.longestPalindrome("abc" * 332 + "q" * 7 + "abc") == "q" * 7
```

### 代码解析

- 外层枚举长度而非左端点，是区间 DP 的标准姿势：`dp[i+1][j-1]` 比 `dp[i][j]` 短，必须先算短的；
- `j - i < 3` 一行同时覆盖长度 2 与长度 3 的免查基例，避免单独初始化；
- 多解输入（如 `"babad"`）的断言用 `in ("bab", "aba")` 接受任一合法解，唯一解输入才断言精确值；
- 长上界用例的两条构造（全同字符、周期串嵌唯一回文块）均经暴力核验唯一性。

## 总结

- 回文的递归结构"两端相等 + 内部回文"直接就是区间 DP 的转移，按长度枚举保证依赖就绪；
- `==` 误代 `=` 这类被初值掩护的死语句，肉眼难查、lint 秒杀——DP 表初值语义越强，越要警惕"碰巧正确"；
- 手工构造的极端用例（长串、唯一回文）必须先过暴力再进测试：交替串自身是巨型回文、拼接处会凭空长出短回文，直觉在这里极不可靠。
