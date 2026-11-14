---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.438: 找到字符串中所有字母异位词"
categories: LeetCode
tags: [中等, 字符串, 滑动窗口, 哈希表]
---

> 异位词判断不看顺序只看「字母配方」：定长滑窗配 26 格计数数组，进出各一格增量维护，比较配方即可——排序法每个窗口 O(k log k)，计数法全程 O(n·26)。

## 题目

LeetCode 438. Find All Anagrams in a String（找到字符串中所有字母异位词）— HOT 100 滑动窗口

Difficulty: **Medium**

给定两个字符串 `s` 和 `p`，找到 `s` 中所有 `p` 的**异位词**的子串，返回这些子串的起始索引列表。不考虑答案输出的顺序。

异位词指由相同字母重排列形成的字符串（包括相同的字符串）。

约束：

- `1 <= s.length, p.length <= 3 * 10^4`
- `s` 和 `p` 仅包含小写字母

### 示例

```text
输入：s = "cbaebabacd", p = "abc"
输出：[0,6]
解释：起始索引 0 的子串 "cba"、起始索引 6 的子串 "bac" 都是 "abc" 的异位词。

输入：s = "abab", p = "ab"
输出：[0,1,2]
解释："ab"、"ba"、"ab" 都是 "ab" 的异位词。
```

## 解题思路

### 定长滑窗 + 26 格计数数组

`p` 的异位词有固定长度 `len(p)`，所以窗口是**定长**的：

1. 统计 `p` 的字母配方 `p_count` 与 `s` 首个窗口的配方 `s_count`（各一趟 `len(p)`）；
2. 相等则起始索引 0 入答案；
3. 窗口右滑一格 = **出一个进一个**：`s_count` 减去离开的 `s[i]`、加上进入的 `s[i+len(p)]`——增量更新避免每个窗口重新数一遍 O(k)；
4. 每滑一步比较两个数组（26 格，O(26)），相等记录新左端 `i+1`。

两个细节：
- **配方必须用计数**而非字母集合——`"aab"` 与 `"abb"` 字母集相同但不是互为异位词；
- 手算期望值时也容易栽在这里：`"aba"` 排序后就是 `"aab"`，它**是**异位词（本人核对测试期望时就漏了它，被暴力对照抓回）。

### 手算示例 2（s = "abab", p = "ab"）

| 窗口 | 配方 | 与 p_count 比较 | 起始索引 |
|------|------|----------------|---------|
| "ab" | a:1,b:1 | ✓ | 0 |
| "ba" | a:1,b:1 | ✓ | 1 |
| "ab" | a:1,b:1 | ✓ | 2 |

### 复杂度分析

- 时间复杂度：`O(n·26)`——n 为 `s` 长度，每滑一步一次增量更新 + 一次 26 格比较；排序法为 O(n·k log k)；
- 空间复杂度：`O(26)`；
- 进阶：维护「有多少字母的计数不同」的差异变量 `differ`，进出窗口时增量更新，每步比较降到 O(1)——567 题（字符串的排列）就是这个写法。

## 代码实现

```python
class Solution:
    def findAnagrams(self, s: str, p: str) -> list[int]:
        if len(s) < len(p):
            return []

        s_count = [0] * 26
        p_count = [0] * 26
        for i in range(len(p)):
            p_count[ord(p[i]) - ord("a")] += 1
            s_count[ord(s[i]) - ord("a")] += 1

        ret = []
        if s_count == p_count:  # 首个窗口（起始索引 0）单独判定
            ret.append(0)

        # 窗口右滑：左端离开 s[i]，右端进入 s[i+len(p)]，新左端为 i+1
        for i in range(len(s) - len(p)):
            s_count[ord(s[i]) - ord("a")] -= 1
            s_count[ord(s[i + len(p)]) - ord("a")] += 1
            if s_count == p_count:
                ret.append(i + 1)

        return ret
```

### 代码解析

- 首个窗口在循环外单独判定，循环从「滑到左端 1」开始——`ret.append(i+1)` 与滑步同步，避免循环内索引错位；
- 增量更新是定长滑窗的核心：窗口右滑只改变两个字母的计数，比重新统计省一个 k 因子；
- `s_count == p_count` 直接比较两个 26 长列表，Python 的列表相等逐格比较，语义恰是「配方相同」；
- `len(s) < len(p)` 提前返回，循环范围 `len(s) - len(p)` 保证右端 `i+len(p)` 不越界。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1 / 2 ----
    assert solution.findAnagrams("cbaebabacd", "abc") == [0, 6]
    assert solution.findAnagrams("abab", "ab") == [0, 1, 2]

    # ---- s 比 p 短：无解 ----
    assert solution.findAnagrams("a", "ab") == []

    # ---- 窗口等于整串 ----
    assert solution.findAnagrams("abc", "cba") == [0]

    # ---- 无异位词（字母集不同）----
    assert solution.findAnagrams("abcd", "efg") == []

    # ---- 重复字母："aba" 排序后同为 "aab"，也是异位词 ----
    assert solution.findAnagrams("aabaa", "aab") == [0, 1, 2]
    assert solution.findAnagrams("aababaa", "aab") == [0, 1, 3, 4]
```

提交前用「每个起点排序比较」的朴素版随机对照 2000 组，与计数滑窗版结果全部一致。

## 总结

- 异位词 = 相同字母配方：计数数组（而非集合）才能区分重复次数；
- 定长滑窗配「出一个进一个」的增量维护，全程 O(n·26)，排序法只能 O(n·k log k)；
- 首窗口单独判定、滑步记录 `i+1` 是索引不乱的关键；期望值手算不可靠（"aba" 陷阱），机器对照兜底。
