---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.290: 单词规律"
categories: LeetCode
---

> 双向映射是判断"一一对应"的关键，它在编译器符号表和数据库字段映射中随处可见。

## 题目

LeetCode 290. Word Pattern（单词规律）

Difficulty: **Easy**

给定一种规律 `pattern` 和一个字符串 `s`，判断 `s` 是否遵循相同的规律。

这里的"遵循"指完全匹配，例如 `pattern` 里的每个字母和字符串 `s` 中的每个非空单词之间存在着**双向连接**的对应规律。

### 示例

```
输入：pattern = "abba", s = "dog cat cat dog"
输出：true
解释：a ↔ dog, b ↔ cat。

输入：pattern = "abba", s = "dog dog dog dog"
输出：false
解释：a 和 b 都应映射到 dog，违反双向一一对应。

输入：pattern = "aaaa", s = "dog cat cat dog"
输出：false
```

## 解题思路

### 分词 + 双向哈希映射

这道题的本质是判断**两个序列之间的双射关系**：`pattern` 的第 `i` 个字母对应 `s` 的第 `i` 个单词。

容易踩的坑是只做单向映射：`"abba"` 与 `"dog dog dog dog"` 中，a→dog、b→dog 每个字母的映射都"自洽"，但实际上 a 和 b 不能同时映射到 dog。因此需要**两个哈希表**保证双向一致：

1. **分词**：把 `s` 按空格拆分成单词数组 `words`；若 `pattern` 长度与单词数不等，直接返回 false；
2. **双向校验**：遍历每一对（字母 `c`，单词 `w`）：
   - 双方都是新面孔 → 建立双向映射 `m1[c] = w`、`m2[w] = c`；
   - 只有一方出现过 → 一对多冲突，返回 false；
   - 双方都出现过 → 检查现有映射是否互相指向对方，不一致返回 false。

### 复杂度分析

- **时间复杂度**：O(n + m)，n 是 `pattern` 长度，m 是字符串总长度。
- **空间复杂度**：O(n + m)，用于单词数组和两个哈希表。

## 代码实现

```cpp
class Solution {
   public:
    bool wordPattern(string pattern, string s) {
        vector<string> words;
        string tmp = "";
        for (auto ch : s) {
            if (ch == ' ' && !tmp.empty()) {
                words.emplace_back(tmp);
                tmp = "";
                continue;
            }

            tmp += ch;
        }
        if (!tmp.empty()) {
            words.emplace_back(tmp);
        }

        if (pattern.size() != words.size()) {
            return false;
        }

        unordered_map<char, string> m1;
        unordered_map<string, char> m2;
        for (auto i = 0; i < pattern.size(); ++i) {
            auto c = pattern.at(i);
            auto w = words.at(i);
            if (m1.find(c) == m1.end() && m2.find(w) == m2.end()) {
                m1[c] = w;
                m2[w] = c;
            } else {
                if (m1.find(c) == m1.end() || m2.find(w) == m2.end()) {
                    return false;
                }

                if (m1[c] != w || m2[w] != c) {
                    return false;
                }
            }
        }

        return true;
    }
};
```

### 代码解析

- **手工分词**：逐字符扫描，遇空格且缓存非空时结算单词；循环结束后补上最后一个单词（注意 `tmp.empty()` 判断，避免连续空格产生空词）。
- **长度守卫**：字母数与单词数不等时不可能构成双射，提前返回。
- **三分支校验**：`双新 → 建映射`、`单新 → 冲突`、`双旧 → 查一致`，逻辑覆盖所有情况。

## 测试用例

```cpp
TEST(top150, 290) {
    Solution solution;
    // 正常双射
    string pattern = "abba";
    string sentence = "dog cat cat dog";
    auto ret = solution.wordPattern(pattern, sentence);
    EXPECT_TRUE(ret);

    // 多对一冲突
    string duplicate_pattern = "abba";
    string duplicate_sentence = "dog dog dog dog";
    EXPECT_FALSE(solution.wordPattern(duplicate_pattern, duplicate_sentence));
}
```

## 总结

1. 双射判定必须双向映射，单看字母→单词会漏判多对一；
2. 先分词、先比长度，再做逐位校验；
3. 时间 O(n + m)，两个哈希表各管一个方向。
