---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2840: 检查字符串是否可以通过排序子字符串得到另一个字符串"
categories: LeetCode
---

> 「下标差为偶数才能交换」等价于「奇偶位置各自独立重排」，用频率计数一次遍历即可判断。

## 题目

LeetCode 2840. Check if Strings Can be Made Equal With Substring Operations（检查字符串是否可以通过排序子字符串得到另一个字符串）

Difficulty: **Medium**

给你两个长度均为 n、只含小写字母的字符串 `s1` 和 `s2`。你可以对任意一个字符串执行任意次操作：选择下标 i、j，满足 i < j 且 j - i 为偶数，交换这两个位置的字符。判断能否使两个字符串相等。

### 示例

```
示例 1：
输入：s1 = "abcdba", s2 = "cabdab"
输出：true

示例 2：
输入：s1 = "abe", s2 = "bea"
输出：false
```

## 解题思路

### 奇偶分组计数

关键观察：`j - i` 为偶数当且仅当 i、j 奇偶性相同。因此：
- 偶数下标上的字符只能在偶数下标之间重排
- 奇数下标同理，两组互不影响

所以只需比较两个字符串在偶数位置上的字符多重集、奇数位置上的字符多重集是否分别相同。

计数法实现：用两个长度 26 的数组，一次遍历中 s1 计数 +1、s2 计数 -1，最终全为 0 即多重集相同。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)，两个固定大小数组。

## 代码实现

```cpp
class Solution {
   public:
    bool checkStrings(string s1, string s2) {
        vector<int> even_counts(26, 0);
        vector<int> odd_counts(26, 0);

        for (int i = 0; i < s1.length(); i++) {
            if (i % 2 == 0) {
                even_counts[s1[i] - 'a']++;
                even_counts[s2[i] - 'a']--;
            } else {
                odd_counts[s1[i] - 'a']++;
                odd_counts[s2[i] - 'a']--;
            }
        }

        for (int i = 0; i < 26; i++) {
            if (even_counts[i] != 0 || odd_counts[i] != 0) return false;
        }
        return true;
    }
};
```

### 代码解析

- 源文件还保留了排序法版本（O(n log n)），计数法是其线性优化版。
- `+1/-1` 合并到同一数组，省去分别统计再比较的步骤。

## 测试用例

```cpp
TEST(Daily, 2840) {
    Solution s;
    EXPECT_TRUE(s.checkStrings("abcdba", "cabdab"));
}
```

## 总结

1. 差为偶数 ⟺ 同奇偶，奇偶位置独立重排；
2. 比较两组位置上的字符多重集是否相同；
3. 计数法 O(n) 时间、O(1) 空间。
