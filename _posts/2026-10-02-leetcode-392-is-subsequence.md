---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.392: 判断子序列"
categories: LeetCode
---

> 子序列不要求连续，贪心匹配即可：每次在 t 中为 s 的当前字符找最早的出现位置，把后续空间留得最大。

## 题目

LeetCode 392. Is Subsequence（判断子序列）

Difficulty: **Easy**

给定字符串 s、t，判断 s 是否为 t 的子序列（删 t 中若干字符可得到 s，顺序不变）。

### 示例

```
输入：s = "abc", t = "ahbgdc"
输出：true

输入：s = "axc", t = "ahbgdc"
输出：false
```

## 解题思路

### 双指针贪心

1. s_p、t_p 分别扫描两串。
2. 字符匹配：s_p 前进一步。
3. 无论是否匹配，t_p 都前进。
4. s_p 走完 s 全部字符即子序列成立。

若 t 固定、s 有大量查询（进阶问），预处理 t 中每个位置之后各字符的首次出现位置（数组 + 二分/倍增），每个 s 可按 |s| 跳表匹配。

### 复杂度分析

- **时间复杂度**：O(n)，n 为 t 长度。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    bool isSubsequence(string s, string t) {
        size_t s_p = 0, t_p = 0;
        while (s_p < s.size() && t_p < t.size()) {
            if (s[s_p] == t[t_p]) s_p++;
            t_p++;
        }
        return s_p == s.size();
    }
};
```

### 代码解析

- t_p 单调前进体现贪心：匹配当前字符选最早位置永远不劣。

## 测试用例

```cpp
TEST(top150, 392) {
    Solution s;
    EXPECT_TRUE(s.isSubsequence("abc", "ahbgdc"));
    EXPECT_FALSE(s.isSubsequence("axc", "ahbgdc"));
    EXPECT_TRUE(s.isSubsequence("", "anything"));  // 空串是任意串子序列
}
```

## 总结

1. 双指针一次扫描，匹配即推进 s；
2. 贪心取最早匹配位置；
3. 多查询场景预处理「下一个字符位置」即可加速。
