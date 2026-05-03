---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.796: 旋转字符串"
categories: LeetCode
---

## 题目

LeetCode 796. Rotate String (旋转字符串)

Difficulty: **Easy**

给定两个字符串 s 和 goal，如果 s 可以通过若干次字符移位得到 goal，返回 true。

字符移位定义：将字符串的第一个字符移动到末尾。

### 示例

```
示例 1：
输入：s = "abcde", goal = "cdeab"
输出：true
解释：
"abcde" 经过一次移位变为 "bcdea"
"bcdea" 经过一次移位变为 "cdeab"
共移位 2 次得到 "cdeab"
```

```
示例 2：
输入：s = "abcde", goal = "abced"
输出：false
解释：无论移位多少次都无法得到 "abced"
```

## 解题思路

这道题有一个非常巧妙的解法，不需要实际进行旋转操作。

### 核心思路

1. **长度检查**：如果 s 和 goal 长度不同，直接返回 false
2. **字符串拼接**：将 s 与自身拼接，s + s 包含 s 所有可能的旋转结果
3. **子串检查**：检查 goal 是否为 s + s 的子串

### 为什么这个方法有效？

以 s = "abcde" 为例：

- s + s = "abcdeabcde"
- 这个字符串包含了所有可能的旋转结果：
  - "abcde" (0次旋转)
  - "bcdea" (1次旋转)
  - "cdeab" (2次旋转)
  - "deabc" (3次旋转)
  - "eabcd" (4次旋转)

所以只需要检查 goal 是否在 s + s 中即可！

### 趣味性知识

这个技巧类似于环形缓冲区（Circular Buffer）的思想，将线性字符串变成了环形结构。在实际开发中，这种思路常用于处理循环队列、滑动窗口等问题。

## 代码实现

```cpp
class Solution {
public:
    bool rotateString(string s, string goal) {
        if (s.length() != goal.length()) {
            return false;
        }

        string combined = s + s;
        return combined.find(goal) != string::npos;
    }
};
```

### 代码解析

1. **长度检查**（第34-37行）：首先比较 s 和 goal 的长度，不相等直接返回 false
2. **拼接字符串**（第39行）：创建 s + s，包含所有可能的旋转结果
3. **查找子串**（第40行）：使用 `find` 方法检查 goal 是否是 combined 的子串，`string::npos` 表示未找到

### 复杂度分析

- **时间复杂度**：O(n)，字符串拼接和查找子串的时间复杂度都是线性的
- **空间复杂度**：O(n)，需要额外存储 s + s

## 测试用例

```cpp
TEST(Daily, 796) {
    Solution sl;
    auto s = "abcde", goal = "cdeab";
    EXPECT_TRUE(sl.rotateString(s, goal));
}
```

## 总结

这道题的关键在于发现「s + s 包含所有旋转结果」这个巧妙的规律。不需要模拟旋转过程，直接利用字符串拼接和子串查找就可以高效解决问题。这个方法展示了算法中「数学规律发现」的重要性，有时候换个角度思考问题可以让解法变得非常简洁。
