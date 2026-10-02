---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.30: 串联所有单词的子串"
categories: LeetCode
---

> 窗口长度和每个单词长度都固定，按单词长度把窗口切成 n 份，用频率表逐份核对即可。难点不在算法而在细节边界。

## 题目

LeetCode 30. Substring with Concatenation of All Words（串联所有单词的子串）

Difficulty: **Hard**

给定字符串 s 和长度全部相同的单词数组 words。找出 s 中所有「恰好包含 words 中每个单词一次、任意顺序、无多余字符」的子串起始下标。

### 示例

```
输入：s = "wordgoodgoodgoodbestword", words = ["word","good","best","good"]
输出：[8]
解释：下标 8 开始的 "goodgoodbestword" 切分为 good/good/best/word，频率匹配。
```

## 解题思路

### 枚举窗口 + 单词频率计数

1. 单词长 ws，窗口长 window_length = n × ws；s 比窗口短直接返回空。
2. lookup 记录 words 中单词目标次数。
3. 枚举每个起点 i：把窗口按 ws 切为 n 段，tmp 记录实际次数。
   - 单词不在 lookup，或 `tmp[word]` 超过目标次数：失败并提前退出；
   - 全部匹配记录 i。

### 复杂度分析

- **时间复杂度**：约 O((L - n·ws) × n × ws)，L 为 s 长度。
- **空间复杂度**：O(n)。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    vector<int> findSubstring(string s, vector<string>& words) {
        vector<int> ret;
        int n = words.size();
        int ws = words[0].size();
        int window_length = n * ws;

        if (s.size() < window_length) return ret;

        unordered_map<string, int> lookup;
        for (int i = 0; i < n; i++) lookup[words[i]]++;

        for (int i = 0; i <= (int)s.size() - window_length; i++) {
            unordered_map<string, int> tmp;
            bool is_same = true;
            for (int j = 0; j < n; j++) {
                string word = s.substr(i + j * ws, ws);
                auto it = lookup.find(word);
                if (it == lookup.end() || ++tmp[word] > it->second) {
                    is_same = false;
                    break;
                }
            }
            if (is_same) ret.push_back(i);
        }
        return ret;
    }
};
```
{% endraw %}

### 代码解析

- `++tmp[word] > it->second` 利用前置自增一次完成「计数 + 超标判断」。
- 循环上界用 `<= s.size() - window_length`，包含最后一个合法起点。

## 测试用例

{% raw %}
```cpp
TEST(top150, 30) {
    Solution s;
    auto st = "wordgoodgoodgoodbestword";
    vector<string> words{"word", "good", "best", "good"};
    EXPECT_EQ(s.findSubstring(st, words), (vector<int>{8}));
}
```
{% endraw %}

## 总结

1. 固定窗口按固定单词长切片，问题本质是频率匹配；
2. 单词缺失或计数超标立即失败；
3. 进阶做法对每个起点偏移量（共 ws 种）做滑动窗口，可降到 O(L × ws)。
