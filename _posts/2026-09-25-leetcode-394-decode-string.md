---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.394: 字符串解码"
categories: LeetCode
---

> 「遇到嵌套就想栈」是字符串解析的第一直觉：HTML/XML 标签、括号匹配、表达式求值、压缩字符串解码，都靠一个栈保存「进入内层之前的上下文」。

## 题目

LeetCode 394. Decode String（字符串解码）

Difficulty: **Medium**

给定一个经过编码的字符串，返回它解码后的字符串。

编码规则为：`k[encoded_string]`，表示其中方括号内部的 `encoded_string` 重复 `k` 次。注意 `k` 保证为正整数。

你可以认为输入字符串总是有效的：没有多余空格，方括号格式正确。此外，原始数据不包含数字，数字只用来表示重复次数 `k`。

### 示例

```
示例 1：
输入：s = "3[a]2[bc]"
输出："aaabcbc"

示例 2：
输入：s = "3[a2[c]]"
输出："accaccacc"
解释：先解内层 2[c]="cc"，得 3[acc]，再展开为 "accaccacc"。

示例 3：
输入：s = "2[abc]3[cd]ef"
输出："abcabccdcdcdef"

示例 4：
输入：s = "abc3[cd]xyz"
输出："abccdcdcdxyz"
```

## 解题思路

### 核心：栈保存进入括号前的上下文

嵌套结构天然对应「先进后出」。遇到 `[` 就进入一层新作用域，遇到 `]` 就要回到外层，并把内层结果按次数拼回去。

用一个栈保存每层进入 `[` 之前的状态：

```
栈元素 = (进入当前 '[' 之前已累积的字符串, 当前括号的重复次数 k)
```

遍历字符串，按字符分类处理：

1. **数字**：按位累加解析完整次数 `times = times*10 + (c-'0')`。`k` 可能大于 9（如 `"12[a]"`），必须累乘，不能直接取字符面值。
2. **小写字母**：直接追加到当前构造串 `ret`。
3. **`[`**：把当前 `ret` 和 `times` 压栈，然后清空 `ret`、`times` 归零，准备解析括号内层。
4. **`]`**：弹出栈顶 `(prev_str, repeat_times)`，把内层结果 `ret` 重复 `repeat_times` 次后拼到 `prev_str` 后面，作为新的 `ret`。

遍历结束，`ret` 就是完整解码结果。

### 为什么用 pair 而不是两个独立栈？

每个 `[` 同时对应「外层已拼好的字符串」和「该层重复次数」两个值，二者必须同步压栈、同步弹栈。用一个 `pair<string, int>` 把它们绑在一起，避免两个栈长度错位，是更稳健的写法。

### 复杂度分析

- **时间复杂度**：O(解码后字符串长度)。每个结果字符都被拼接常数次，没有重复计算。
- **空间复杂度**：O(n)，n 为输入长度，栈深由括号嵌套层数决定，加上当前构造串。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    string decodeString(string s) {
        // 栈元素：(进入当前 '[' 之前已累积的字符串, 当前括号的重复次数)
        stack<pair<string, int>> container;
        string ret;      // 当前正在构造的字符串
        int times = 0;   // 当前正在解析的重复次数
        for (auto c : s) {
            if (c >= '0' && c <= '9') {
                // 按位累加，支持多位数（如 "12[a]"）
                times = times * 10 + c - '0';
            } else if (c >= 'a' && c <= 'z') {
                ret += c;
            } else if (c == '[') {
                // 保存当前上下文，进入括号内层
                container.emplace(std::move(ret), times);
                times = 0;
                ret = "";
            } else if (c == ']') {
                // 弹出外层上下文，把内层字符串重复 repeat 次拼到外层后面
                auto tmp_ret = container.top().first;
                auto tmp_times = container.top().second;
                container.pop();

                for (auto i = 0; i < tmp_times; i++) {
                    tmp_ret += ret;
                }

                ret = tmp_ret;
            }
        }

        return ret;
    }
};
```
{% endraw %}

### 代码解析

- `times * 10 + c - '0'`：数字解析的标准写法，支持任意位数。
- `emplace(std::move(ret), times)`：就地构造 pair，`std::move` 把 `ret` 的内容移动进栈，避免拷贝长字符串。
- `]` 分支是核心：内层串 `ret` 被复制 `tmp_times` 份拼回外层 `tmp_ret`，这一步正好对应「展开 k 次」的语义。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 394) {
    Solution s;

    // 示例 1：并列括号
    EXPECT_EQ(s.decodeString("3[a]2[bc]"), "aaabcbc");

    // 嵌套括号：3[a2[c]] -> 3[acc] -> accaccacc
    EXPECT_EQ(s.decodeString("3[a2[c]]"), "accaccacc");

    // 多个并列括号 + 普通字符
    EXPECT_EQ(s.decodeString("2[abc]3[cd]ef"), "abcabccdcdcdef");

    // 普通字符穿插括号
    EXPECT_EQ(s.decodeString("abc3[cd]xyz"), "abccdcdcdxyz");

    // 多位数次数：10[z]
    EXPECT_EQ(s.decodeString("10[z]"), "zzzzzzzzzz");
}
```
{% endraw %}

## 总结

394 是栈题的入门模板：**一层括号对应一层栈帧，进入 `[` 保存上下文，离开 `]` 恢复并合并**。记住三个易错点：① 数字按位累加别漏 `times*10`；② 栈元素用 pair 把「外层串」和「次数」绑定，避免双栈错位；③ `std::move` 进栈省拷贝。这套「上下文入栈、结果回填」的模式在括号匹配、表达式求值、目录路径简化等题里都会反复出现。
