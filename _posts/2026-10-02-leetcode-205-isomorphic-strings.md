---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.205: 同构字符串"
categories: LeetCode
---

> 同构要求映射双向唯一：一张表管 s→t，一张表管 t→s。只建单向表会漏掉「多个字符挤到同一个映射」的冲突。

## 题目

LeetCode 205. Isomorphic Strings（同构字符串）

Difficulty: **Easy**

给定长度相同的 s、t，判断能否把 s 的字符按一一对应关系替换为 t。不同字符不能映到同一字符。

### 示例

```
输入：s = "egg", t = "add"      输出：true
输入：s = "foo", t = "bar"      输出：false
输入：s = "paper", t = "title"  输出：true
```

## 解题思路

### 双向映射表

1. container_s、container_t 分别记录 s→t、t→s。
2. 首次出现的字符建立映射。
3. 之后每对字符都核对两张表与当前对应是否一致；任一方向冲突返回 false。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(k)，k 为字符种类数。

## 代码实现

```cpp
class Solution {
public:
    bool isIsomorphic(string s, string t) {
        unordered_map<char, char> container_s;
        unordered_map<char, char> container_t;
        for (int i = 0; i < (int)s.size(); i++) {
            if (container_s.count(s[i]) < 1) container_s[s[i]] = t[i];
            if (container_t.count(t[i]) < 1) container_t[t[i]] = s[i];
            if (container_s[s[i]] != t[i]) return false;
            if (container_t[t[i]] != s[i]) return false;
        }
        return true;
    }
};
```

### 代码解析

- "badc"→"baba" 这类用例：s 中 b、d 都要映到 b，第二张表在 d 位置发现冲突而返回 false。

## 测试用例

```cpp
TEST(top150, 205) {
    Solution s;
    EXPECT_TRUE(s.isIsomorphic("egg", "add"));
    EXPECT_FALSE(s.isIsomorphic("badc", "baba"));
    EXPECT_FALSE(s.isIsomorphic("foo", "bar"));
    EXPECT_TRUE(s.isIsomorphic("paper", "title"));
}
```

## 总结

1. 字符替换关系必须双向唯一；
2. 两张映射表各司其职，缺一不可；
3. 同类思路可用于「单词规律」(Word Pattern) 一题。
