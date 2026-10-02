---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1614: 括号的最大嵌套深度"
categories: LeetCode
---

> 括号深度的本质是「当前未闭合的左括号数量」，一个计数器就够，栈反而不是必须的。

## 题目

LeetCode 1614. Maximum Nesting Depth of the Parentheses（括号的最大嵌套深度）

Difficulty: **Easy**

给你一个**有效**括号字符串 `s`，返回字符串的**嵌套深度**。嵌套深度是指字符串中括号的最大嵌套层数。

### 示例

```
示例 1：
输入：s = "(1+(2*3)+((8)/4))+1"
输出：3
解释：数字 8 在嵌套的 3 层括号中。

示例 2：
输入：s = "(1)+((2))+(((3)))"
输出：3
```

## 解题思路

### 计数器法

括号的嵌套深度等于「当前未闭合的左括号数量」。因此只需一个计数器：

1. 遍历字符串，遇到 `'('` 时 `count++`，并更新最大深度 `ret = max(ret, count)`。
2. 遇到 `')'` 时 `count--`。
3. 其他字符（数字、运算符）不影响深度，直接跳过。

本实现额外使用了栈来辅助匹配括号（弹栈直到遇到 `'('`），但核心深度信息完全由 `count` 维护，栈并非必需。

### 复杂度分析

- **时间复杂度**：O(n)，单次遍历。
- **空间复杂度**：O(n)，本实现用了栈；纯计数器版为 O(1)。

## 代码实现

```cpp
class Solution {
public:
    int maxDepth(string s) {
        stack<char> st;
        int ret = 0;

        int count = 0;
        for (auto i: s) {
            if (i == '(') {
                st.emplace(i);
                count++;
                ret = max(ret, count);
            } else if (i == ')') {
                count--;

                // pop
                while (st.top() != '(') {
                    st.pop();
                }

                // pop '('
                st.pop();
            } else {
                st.emplace(i);
            }
        }

        return ret;
    }
};
```

### 代码解析

- `count` 维护当前未闭合的左括号数，即当前深度。
- `ret = max(ret, count)` 在每次左括号入栈时更新最大深度。
- 栈的弹栈逻辑保证括号匹配，但 `count` 才是深度的唯一来源。

## 测试用例

```cpp
TEST(Daily, 1614) {
    Solution s;
    string ss = "(1+(2*3)+((8)/4))+1";
    auto ret = s.maxDepth(ss);
    EXPECT_EQ(ret, 3);
}
```

## 总结

求括号最大嵌套深度的最简方法：

1. 一个计数器 `count` 记录当前深度；
2. 遇 `'('` 加一并更新最大值，遇 `')'` 减一；
3. 栈可省略，纯计数器即可 O(1) 空间解决。
