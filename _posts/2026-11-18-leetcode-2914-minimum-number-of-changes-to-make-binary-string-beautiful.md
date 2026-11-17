---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2914: 使二进制字符串变美丽的最少修改次数"
categories: LeetCode
tags: [中等, 字符串, 贪心]
---

> 美丽串的最优划分永远是相邻两两一组：任何均匀偶长块都能再切成全同的字符对，所以只需数出 (s[0],s[1])、(s[2],s[3])… 里有多少对不同——对内不同改一个，相同零修改。

## 题目

LeetCode 2914. Minimum Number of Changes to Make Binary String Beautiful（使二进制字符串变美丽的最少修改次数）

Difficulty: **Medium**

给你一个长度为偶数 n 的二进制字符串 s。如果 s 可以分割成若干子串，满足每个子串长度均为偶数、且每个子串只包含 1 或只包含 0，则称 s 是「美丽的」。一次修改可以将一个字符翻转，返回使 s 美丽的最少修改次数。

### 示例

```
输入：s = "1001"    输出：2（改成 "1100"，分割为 "11" + "00"）
输入：s = "10"      输出：1
输入：s = "0000"    输出：0
```

## 解题思路

### 相邻两两分组

关键观察：**任何合法的「均匀偶长块」（如 `"0000"`、`"11"`）都可以进一步切成两两一组的全同字符对**，不增加任何修改次数。因此最优划分永远是相邻配对 (s[0],s[1])、(s[2],s[3])、…

- 对内**相同**：本身就是合法的「长度为 2 的均匀块」，0 次修改；
- 对内**不同**：翻转其中任意一个即全同，1 次修改。

答案 = 不相等的对的个数。

为什么不能更少：每一对 (2k, 2k+1) 落在某个划分块内。若划分块跨过了这对（块边界把这对拆到两个块），把该块再切成两两一组仍合法；若这对落在同一块中且两字符不同，则该块必含混合字符，必须至少改一个。所以「不同对的个数」是下界，两两分组恰好达到。

### 复杂度分析

- **时间复杂度**：O(n)，一趟扫描。
- **空间复杂度**：O(1)。

## 代码实现

```python
class Solution:
    def minChanges(self, s: str) -> int:
        ret = 0
        # 相邻两两一组：组内不同则改任意一个，+1
        for i in range(0, len(s), 2):
            if s[i] != s[i + 1]:
                ret += 1
        return ret
```

### 代码解析

- `range(0, len(s), 2)` 步长为 2，i 与 i+1 恰好构成一对，题目保证长度为偶数，不会越界。
- 不需要真的构造划分和修改，只统计「不同对」个数即可。
- 更 Pythonic 的等价写法：`sum(s[i] != s[i + 1] for i in range(0, len(s), 2))`。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.minChanges("1001") == 2
    assert solution.minChanges("10") == 1
    assert solution.minChanges("0000") == 0

    # ---- 最小规模 ----
    assert solution.minChanges("00") == 0
    assert solution.minChanges("01") == 1

    # ---- 全交替：每对都要改 ----
    assert solution.minChanges("0101") == 2
    assert solution.minChanges("1010") == 2

    # ---- 已美丽：两两分组即可满足 ----
    assert solution.minChanges("1100") == 0
    assert solution.minChanges("110100") == 1  # "11"+"01"+"00"，中间对改一个
```

## 总结

1. 「可划分为均匀偶长块」的判定可以化简到两两一组——均匀偶长块总能无损再切；
2. 每对独立决策：相同 0 次、不同 1 次，贪心即最优；
3. 答案是统计量而非构造量，一趟扫描 O(n)/O(1) 完成。
