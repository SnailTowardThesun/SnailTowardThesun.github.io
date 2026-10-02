---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.125: 验证回文串"
categories: LeetCode
---

> 数据清洗后再判断：回文比较本身只有 O(n)，本题真正的工作量在「只保留字母数字并统一小写」的预处理。

## 题目

LeetCode 125. Valid Palindrome（验证回文串）

Difficulty: **Easy**

给定字符串，只考虑字母和数字、忽略大小写，判断是否为回文串。

### 示例

```
输入："A man, a plan, a canal: Panama"
输出：true（清洗后为 "amanaplanacanalpanama"）

输入："race a car"
输出：false（清洗后 "raceacar"）
```

## 解题思路

### 预处理 + 双指针

1. 遍历原串：小写字母、数字直接保留，大写字母转小写后保留，其余字符丢弃。
2. 在清洗后的字符串上用首尾双指针向中间比较，出现不同字符返回 false。

进阶做法是不额外存储，双指针直接在原串上跳过非法字符，空间 O(1)。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(n)，清洗结果；直接双指针可 O(1)。

## 代码实现

```cpp
class Solution {
public:
    bool isPalindrome(string s) {
        string helper = "";
        for (char i : s) {
            if (i >= 'a' && i <= 'z') {
                helper += i;
            } else if (i >= 'A' && i <= 'Z') {
                helper += (char)tolower(i);
            } else if (i >= '0' && i <= '9') {
                helper += i;
            }
        }

        for (int i = 0, j = (int)helper.size() - 1; i < j; i++, j--) {
            if (helper[i] != helper[j]) return false;
        }
        return true;
    }
};
```

### 代码解析

- 三类保留字符分别处理，tolower 仅对大写字母调用。

## 测试用例

```cpp
TEST(top150, 125) {
    Solution s;
    EXPECT_TRUE(s.isPalindrome("A man, a plan, a canal: Panama"));
    EXPECT_FALSE(s.isPalindrome("race a car"));
    EXPECT_TRUE(s.isPalindrome("0P") == false);
}
```

## 总结

1. 先清洗再回文比较，职责分离；
2. 比较阶段首尾双指针；
3. 追求 O(1) 空间时可在原串上直接跳字符。
