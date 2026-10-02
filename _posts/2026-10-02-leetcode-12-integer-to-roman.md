---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.12: 整数转罗马数字"
categories: LeetCode
---

> 按千、百、十、个位逐位处理，每一位只有 0-9 十种形态，用同一套符号数组按规则拼接即可。

## 题目

LeetCode 12. Integer to Roman（整数转罗马数字）

Difficulty: **Medium**

罗马数字包含 I、V、X、L、C、D、M 七种字符。给定 1 到 3999 范围内的整数，将其转为罗马数字。

### 示例

```
输入：3       输出："III"
输入：4       输出："IV"
输入：58      输出："LVIII"
输入：1994    输出："MCMXCIV"
```

## 解题思路

### 逐位处理

罗马数字每一位独立表示，符号按 `I V X`、`X L C`、`C D M` 成组。对当前位的数字 d：
- d < 4：重复 d 次基本符号（III）
- d = 4：基本符号 + 5 倍符号（IV）
- d < 9：5 倍符号 + (d-5) 次基本符号（VII）
- d = 9：基本符号 + 10 倍符号（IX）

从千位到个位逐位提取数字，符号指针每次向前移动 2 个位置。

### 复杂度分析

- **时间复杂度**：O(1)，最多处理 4 位。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    void romanstr(string& roman, int num, char* symbol) {
        if (num == 0) return;
        else if (num < 4) {
            for (int i = 0; i < num; i++) roman += *symbol;
        } else if (num == 4) {
            roman += *symbol;
            roman += *(symbol + 1);
        } else if (num < 9) {
            roman += *(symbol + 1);
            for (int i = 0; i < num - 5; i++) roman += *symbol;
        } else if (num == 9) {
            roman += *symbol;
            roman += *(symbol + 2);
        }
    }

    string intToRoman(int num) {
        char symbol[7] = {'I', 'V', 'X', 'L', 'C', 'D', 'M'};
        string roman = "";
        int scale = 1000;
        int p = 6;
        while (num > 0) {
            int bit = num / scale;
            romanstr(roman, bit, symbol + p);
            num %= scale;
            scale /= 10;
            p -= 2;
        }
        return roman;
    }
};
```

### 代码解析

- `symbol + p` 指向当前位的符号组起始，组内三个符号分别表示 1、5、10 倍。
- 4 和 9 是减法表示的特殊情况，单独处理。

## 测试用例

```cpp
TEST(Daily, 12) {
    Solution s;
    EXPECT_EQ(s.intToRoman(3), "III");
    EXPECT_EQ(s.intToRoman(58), "LVIII");
    EXPECT_EQ(s.intToRoman(1994), "MCMXCIV");
    EXPECT_EQ(s.intToRoman(3999), "MMMCMXCIX");
}
```

## 总结

1. 每一位只有十种形态，4 和 9 用减法规则；
2. 符号数组按位移动 2 格，逻辑统一；
3. 输入范围固定，时间空间均 O(1)。
