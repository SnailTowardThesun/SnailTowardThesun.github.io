---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2914: 使二进制字符串变美丽的最少修改次数"
categories: LeetCode
tags: [中等, 字符串, 贪心]
---

> 偶数长度的子串依次拼接，边界只能落在偶数偏移处。因此下标 (0,1)、(2,3)… 的字符对不会被合法划分拆开，这是将问题化为逐对判断的关键。

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

关键观察：**长度为偶数且字符相同的子串（如 `"0000"`、`"11"`），都可以继续分成字符相同的二元组**，不需要额外修改。因此，总能通过相邻配对 (s[0],s[1])、(s[2],s[3])、… 达到最少修改次数。最优划分不必唯一，例如 `"0000"` 可以保留为一段，也可以分成 `"00" + "00"`。

- 对内**相同**：本身就是合法的长度为 2 的子串，0 次修改；
- 对内**不同**：翻转其中任意一个即可使两个字符相同，1 次修改。

答案 = 不相等的对的个数。

**为什么不能修改得更少**：合法子串的长度均为偶数，所以边界只能位于偶数偏移处，不可能拆开下标 (2k, 2k+1) 的字符对。每对字符在修改后必须相同，因此原本不同的每一对至少需要一次修改。各对互不重叠，这些修改次数可以相加；逐对修改恰好达到这个下界。

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

    # ---- 已满足条件 / 只有一对不同 ----
    assert solution.minChanges("1100") == 0
    assert solution.minChanges("110100") == 1  # "11"+"01"+"00"，中间对改一个
```

## 总结

1. 长度为偶数且字符相同的子串可以继续分成二元组，因此只需判断相邻字符对；
2. 每对独立决策：相同 0 次、不同 1 次，贪心即最优；
3. 只需统计不同字符对的数量，无需实际修改字符串；时间 O(n)，额外空间 O(1)。
