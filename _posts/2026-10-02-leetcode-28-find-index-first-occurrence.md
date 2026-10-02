---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.28: 找出字符串中第一个匹配项的下标"
categories: LeetCode
---

> 先按首字符筛掉绝大多数起点，再对首字符相同的位置逐字符核对——朴素匹配在面试白板上最不容易写错。

## 题目

LeetCode 28. Find the Index of the First Occurrence in a String（找出字符串中第一个匹配项的下标）

Difficulty: **Easy**

给定 haystack 和 needle，返回 needle 在 haystack 中第一次出现的下标，不存在返回 -1。

### 示例

```
输入：haystack = "sadbutsad", needle = "sad"    输出：0
输入：haystack = "leetcode", needle = "leeto"  输出：-1
```

## 解题思路

### 朴素匹配（首字符剪枝）

1. 只枚举能完整容纳 needle 的起点 `i ∈ [0, n-m]`。
2. 起点字符与 needle 首字符相同时才逐位比较。
3. 全部字符相同立即返回 i，否则继续。

### 复杂度分析

- **时间复杂度**：O(n × m)，最坏情况；KMP 可优化到 O(n+m)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int strStr(string haystack, string needle) {
        int n = haystack.length();
        int m = needle.length();

        for (int i = 0; i < n - m + 1; i++) {
            if (haystack.at(i) == needle.at(0)) {
                bool is_equal = true;
                for (int j = 0; j < m; j++) {
                    if (haystack.at(i + j) != needle.at(j)) {
                        is_equal = false;
                        break;
                    }
                }
                if (is_equal) return i;
            }
        }
        return -1;
    }
};
```

### 代码解析

- 循环上界 `n - m + 1` 保证起点之后留够 m 个字符。
- `break` 后继续枚举下一起点，即朴素匹配的「失败回退」。

## 测试用例

```cpp
TEST(TOP150, 28) {
    Solution s;
    EXPECT_EQ(s.strStr("sadbutsad", "sad"), 0);
    EXPECT_EQ(s.strStr("leetcode", "leeto"), -1);
}
```

## 总结

1. 朴素匹配按起点枚举，首字符剪枝；
2. 边界 `n-m+1` 防止越界；
3. 追求线性复杂度时换 KMP。
