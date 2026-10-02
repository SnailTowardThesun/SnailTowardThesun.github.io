---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.68: 文本左右对齐"
categories: LeetCode
---

> 空格分配的两个特殊规则：普通行空格均匀摊、余数从左到右逐个多分一个；最后一行和单词行左对齐，空格全补尾部。

## 题目

LeetCode 68. Text Justification（文本左右对齐）

Difficulty: **Hard**

给定单词数组和每行最大宽度 maxWidth，重新排版文本使每行恰好有 maxWidth 个字符：
- 普通行：空格在单词间尽可能均匀分布，不能均分时空格从左到右逐个多分一个
- 最后一行左对齐，单词间一个空格，剩余补在尾部
- 只有一个单词的行同样左对齐

### 示例

```
words = ["This","is","an","example","of","text","justification."], maxWidth = 16
输出：
[
  "This    is    an",
  "example  of text",
  "justification.  "
]
```

## 解题思路

### 贪心分行 + 空格分配

1. 遍历单词，在不超过 maxWidth 的前提下尽量往当前行加单词（每个单词至少预留一个空格）。
2. 对一行的 `[left, right]` 单词：
   - 单词数 = 1，或 right 是最后一个单词：左对齐，单词间单空格，尾部补齐。
   - 否则：空格总数 = maxWidth - 单词字母总长；间隔数 = right - left；
     - 每个间隔分 `spaces / gaps` 个空格；
     - 前 `spaces % gaps` 个间隔多分一个。
3. 拼出整行加入结果。

注意：本地源文件中该函数目前为占位实现（返回空），下文为标准参考实现。

### 复杂度分析

- **时间复杂度**：O(n)，每个单词处理常数次（拼接字符数与 maxWidth 成正比）。
- **空间复杂度**：O(maxWidth)，单行缓冲。

## 代码实现

```cpp
class Solution {
public:
    vector<string> fullJustify(vector<string>& words, int maxWidth) {
        vector<string> result;
        int n = words.size();
        int left = 0;

        while (left < n) {
            // 确定当前行能容纳的单词范围
            int len = words[left].size();
            int right = left + 1;
            while (right < n && len + 1 + words[right].size() <= maxWidth) {
                len += 1 + words[right].size();
                right++;
            }

            int wordCount = right - left;
            int gaps = wordCount - 1;
            string line;

            // 最后一行或只有一个单词：左对齐
            if (right == n || gaps == 0) {
                for (int i = left; i < right; i++) {
                    if (i > left) line += " ";
                    line += words[i];
                }
                line += string(maxWidth - line.size(), ' ');
            } else {
                // 普通行：均匀分配空格
                int letters = 0;
                for (int i = left; i < right; i++) letters += words[i].size();
                int spaces = maxWidth - letters;
                int base = spaces / gaps;
                int extra = spaces % gaps;

                for (int i = left; i < right; i++) {
                    line += words[i];
                    if (i < right - 1) {
                        line += string(base + (i - left < extra ? 1 : 0), ' ');
                    }
                }
            }

            result.push_back(line);
            left = right;
        }
        return result;
    }
};
```

### 代码解析

- 分行判定时把每个后续单词前的空格一并计入 `len + 1`。
- `i - left < extra` 让前 extra 个间隔多一个空格。

## 测试用例

```cpp
TEST(Daily, 68) {
    Solution s;
    vector<string> words = {"This", "is", "an", "example", "of", "text", "justification."};
    auto ret = s.fullJustify(words, 16);
    EXPECT_EQ(ret.size(), 3);
    EXPECT_EQ(ret[0].size(), 16);
    EXPECT_EQ(ret[0], "This    is    an");
}
```

## 总结

1. 先贪心确定每行单词区间；
2. 普通行按「商 + 余数」分配空格，余数从左往右摊；
3. 最后一行与单词行左对齐，空格补尾部。
