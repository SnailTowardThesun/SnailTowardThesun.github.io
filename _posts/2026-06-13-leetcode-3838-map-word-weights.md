---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3838: Map Word Weights"
categories: LeetCode
---

> 字符权重映射在密码学和数据加密中广泛应用，通过字符频率分析可以破解简单的替换密码。

## 题目

**No.3838: Map Word Weights**

难度：中等

给定一个字符串数组 `words` 和一个长度为 26 的整数数组 `weights`，其中 `weights[i]` 表示字母 `'a' + i` 的权重。

对于每个单词，计算其所有字符权重之和，然后将结果对 26 取模得到一个值 `k`，将其映射为字母 `'z' - k`。

返回一个字符串，其中每个字符对应 `words` 中每个单词的映射结果。

### 示例

**输入**：
```
words = ["abcd", "def", "xyz"]
weights = [5, 3, 12, 14, 1, 2, 3, 2, 10, 6, 6, 9, 7, 8, 7, 10, 8, 9, 6, 9, 9, 8, 3, 7, 7, 2]
```

**输出**：
```
"rij"
```

**解释**：
- "abcd": a(5) + b(3) + c(12) + d(14) = 34, 34 % 26 = 8, 'z' - 8 = 'r'
- "def": d(14) + e(1) + f(2) = 17, 17 % 26 = 17, 'z' - 17 = 'i'
- "xyz": x(8) + y(7) + z(2) = 17, 17 % 26 = 17, 'z' - 17 = 'j'

## 解题思路

这道题的核心是对每个单词进行字符权重累加和映射操作：

1. **遍历单词数组**：逐个处理 `words` 中的每个单词
2. **计算权重和**：对于每个单词，累加其所有字符对应的权重值
3. **取模运算**：将权重和对 26 取模得到映射值 `k`
4. **字符映射**：将 `k` 映射为字母 `'z' - k`
5. **拼接结果**：将所有映射结果拼接成最终字符串返回

该思路的关键在于理解字符到权重的映射关系以及取模后的字母转换逻辑。

## 代码实现

{% raw %}
```cpp
#include <vector>
#include <string>

using namespace std;

class Solution {
public:
    string map_word_weights(vector<string>& words, vector<int>& weights) {
        string ret;
        for (const auto& word : words) {
            int weight_sum = 0;
            for (char c : word) {
                weight_sum += weights[c - 'a'];
            }
            weight_sum %= 26;
            ret += 'z' - weight_sum;
        }
        return ret;
    }
};
```
{% endraw %}

## 复杂度分析

- **时间复杂度**：O(N * L)，其中 N 是单词数量，L 是单词的平均长度。需要遍历每个单词的每个字符。
- **空间复杂度**：O(N)，用于存储结果字符串，结果长度等于单词数量。

## 测试用例

```cpp
TEST(Daily, 3838) {
    Solution s;
    vector<string> words{"abcd", "def", "xyz"};
    vector<int> weights{5, 3, 12, 14, 1, 2, 3, 2, 10, 6, 6, 9, 7, 8, 7, 10, 8, 9, 6, 9, 9, 8, 3, 7, 7, 2};
    EXPECT_EQ(s.map_word_weights(words, weights), "rij");
}
```

## 总结

本题是一道简单的字符串处理题，核心考察了字符操作和模运算的应用。通过遍历每个字符并累加权重，再通过模运算将结果映射到字母表范围，最终得到加密后的字符串。这类问题在密码学和数据转换场景中较为常见。
