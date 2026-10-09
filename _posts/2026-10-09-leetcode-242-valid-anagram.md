---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.242: 有效的字母异位词"
categories: LeetCode
---

> 异位词检测是拼写检查和词云生成的基础操作，排序法与计数法是它的两大经典解法。

## 题目

LeetCode 242. Valid Anagram（有效的字母异位词）

Difficulty: **Easy**

给定两个字符串 `s` 和 `t`，编写一个函数来判断 `t` 是否是 `s` 的**字母异位词**。

字母异位词是通过重新排列源单词的所有字母得到的新单词。

进阶：如果输入字符串包含 Unicode 字符怎么办？你能调整你的解法来应对这种情况吗？

### 示例

```
输入：s = "anagram", t = "nagaram"
输出：true

输入：s = "rat", t = "car"
输出：false
```

## 解题思路

### 排序比较法

字母异位词的本质特征：**组成字母完全相同，只是顺序不同**。排序会抹平顺序差异，排序后比较即可。

1. **快速路径**：若 `s == t`，相同串互为异位词，直接 true；
2. **长度守卫**：长度不同必然不是异位词，返回 false；
3. **排序后逐位比较**：`sort` 两个字符串后逐字符比较，任何一位不同即 false。

进阶思考：若含 Unicode 字符，用长度 26 的计数数组就不行了，可以改用 `unordered_map` 计数，思路相同但键空间不受限。

### 复杂度分析

- **时间复杂度**：O(n log n)，n 是字符串长度，排序为主导。
- **空间复杂度**：O(log n)，排序递归栈空间。

## 代码实现

```cpp
class Solution {
   public:
    bool isAnagram(string s, string t) {
        if (s == t) {
            return true;
        }

        if (s.length() != t.length()) {
            return false;
        }

        sort(s.begin(), s.end());
        sort(t.begin(), t.end());
        for (auto i = 0; i < s.length(); i++) {
            if (s.at(i) != t.at(i)) {
                return false;
            }
        }

        return true;
    }
};
```

### 代码解析

- **两道提前返回**：相等直通、长度不等直拒，避免无谓排序。
- **排序后等价性**：两个串是异位词 ⟺ 排序后完全相等，这是整个算法的理论基础。
- **进阶适配**：字符集扩大时把计数数组换成哈希表即可，排序法本身天然支持任意字符集。

## 测试用例

```cpp
TEST(top150, 242) {
    Solution solution;
    auto s = "anagram", t = "nagaram";
    auto ret = solution.isAnagram(s, t);
    EXPECT_TRUE(ret == true);
}
```

## 总结

1. 异位词 ⟺ 排序后相等；
2. 长度不等直接排除，先检查再排序；
3. O(n log n) 时间；追求 O(n) 可用 26 长度计数数组。
