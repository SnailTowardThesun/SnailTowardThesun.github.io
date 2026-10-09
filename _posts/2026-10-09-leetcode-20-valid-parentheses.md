---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.20: 有效的括号"
categories: LeetCode
---

> 括号匹配是编译器词法分析的第一课，JSON、XML 校验器内部都在做同样的事。

## 题目

LeetCode 20. Valid Parentheses（有效的括号）

Difficulty: **Easy**

给定一个只包括 `'('`，`')'`，`'{'`，`'}'`，`'['`，`']'` 的字符串 `s`，判断字符串是否有效。

有效字符串需满足：

- 左括号必须用相同类型的右括号闭合；
- 左括号必须以正确的顺序闭合；
- 每个右括号都有一个对应的相同类型的左括号。

### 示例

```
输入：s = "()"
输出：true

输入：s = "()[]{}"
输出：true

输入：s = "(]"
输出：false

输入：s = "([)]"
输出：false

输入：s = "{[]}"
输出：true
```

## 解题思路

### 栈匹配

括号的嵌套规则天然符合**后进先出**：最内层的左括号总是最先被右括号闭合。这正是栈的主场。

1. 遇到左括号 `'('`、`'{'`、`'['` 时入栈；
2. 遇到右括号时：
   - **栈为空** → 没有左括号可配（如 `"()]"`），返回 false；
   - **栈顶与当前右括号不同类** → 交叉嵌套（如 `"([)]"`）或类型不符（如 `"(]"`），返回 false；
   - 匹配成功 → 弹栈；
3. 遍历结束后**栈必须为空**：还有剩余说明左括号多于右括号（如 `"(("`）。

以 `"{[]}"` 为例：`{` 入栈，`[` 入栈，`]` 与栈顶 `[` 匹配弹出，`}` 与栈顶 `{` 匹配弹出，栈空 → true。

### 复杂度分析

- **时间复杂度**：O(n)，每个字符处理一次。
- **空间复杂度**：O(n)，最坏情况全是左括号（如 `"((((("`）。

## 代码实现

```cpp
class Solution {
   public:
    bool isValid(string s) {
        stack<char> container;
        for (auto ch : s) {
            if (ch == '(' || ch == '{' || ch == '[') {
                container.emplace(ch);
            } else {
                if (container.size() == 0) {
                    return false;
                }

                auto top = container.top();
                if (top == '(' && ch != ')') {
                    return false;
                }
                if (top == '[' && ch != ']') {
                    return false;
                }
                if (top == '{' && ch != '}') {
                    return false;
                }

                container.pop();
            }
        }

        return container.empty();
    }
};
```

### 代码解析

- **三类失败全覆盖**：栈空（右多）、失配（交叉/类型错）、结束非空（左多），三种非法形态都有对应检查。
- **`emplace` 直接入栈**：字符构造无歧义，`push` 亦可。
- **进阶写法**：可以用哈希表存右括号→左括号的映射，或遇左括号直接压"期待的右括号"，减少 if 链。

## 测试用例

```cpp
TEST(Daily, 20) {
    Solution s;
    auto ss = "()[]{}";
    auto ret = s.isValid(ss);
    EXPECT_TRUE(ret);
}
```

## 总结

1. 左括号入栈、右括号查栈顶，后进先出匹配嵌套；
2. 三种非法：栈空、失配、结束非空，逐一拦截；
3. O(n) 时间、O(n) 空间，栈是括号问题的标配。
