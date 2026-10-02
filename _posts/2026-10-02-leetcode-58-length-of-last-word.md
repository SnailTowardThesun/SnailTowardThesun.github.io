---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.58: 最后一个单词的长度"
categories: LeetCode
---

> 从末尾倒着走，先跳过空格再数字母，两段 while 即可，不用切分整个字符串。

## 题目

LeetCode 58. Length of Last Word（最后一个单词的长度）

Difficulty: **Easy**

给定由单词和空格组成的字符串，返回最后一个单词的长度。

### 示例

```
输入："Hello World"                 输出：5
输入："   fly me   to   the moon  " 输出：4
输入："luffy is still joyboy"       输出：6
```

## 解题思路

### 反向扫描

1. 从最后一个字符开始，跳过尾部所有空格。
2. 继续向前，统计连续非空格字符的数量，遇到空格停止。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int lengthOfLastWord(string s) {
        int count = 0;
        int i = s.length() - 1;

        while (i >= 0 && s[i] == ' ') i--;
        while (i >= 0 && s[i] != ' ') {
            count++;
            i--;
        }
        return count;
    }
};
```

## 测试用例

```cpp
TEST(Daily, 58) {
    Solution s;
    EXPECT_EQ(s.lengthOfLastWord("Hello World"), 5);
    EXPECT_EQ(s.lengthOfLastWord("   fly me   to   the moon  "), 4);
    EXPECT_EQ(s.lengthOfLastWord("a"), 1);
}
```

## 总结

1. 反向扫描天然定位最后一个单词；
2. 先跳空格再计数，尾部空格不影响；
3. O(n) 时间 O(1) 空间。
