---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1190: 反转每对括号间的子串"
categories: LeetCode
---

> 括号与嵌套结构的第一反应应该是栈。本题中「弹栈顺序」本身就是反转，连 reverse 都可以省掉一次。

## 题目

LeetCode 1190. Reverse Substrings Between Each Pair of Parentheses（反转每对括号间的子串）

Difficulty: **Easy**

给出一个字符串 `s`（仅含有小写英文字母和括号）。请你按照从括号内到外的顺序，逐层反转每对匹配括号中的字符串，并返回最终的字符串。

注意：结果中不应包含任何括号。

### 示例

```
示例 1：
输入：s = "(abcd)"
输出："dcba"

示例 2：
输入：s = "(u(love)i)"
输出："iloveu"
解释：先反转内层 (love) -> evol，得到 "(uevoli)"，再整体反转 -> "iloveu"。

示例 3：
输入：s = "a(bcdefghijkl(mno)p)q"
输出："apmnolkjihgfedcbq"
```

## 解题思路

### 栈模拟

只要题目涉及「括号」和「嵌套」，栈几乎都是首选数据结构。

维护一个字符栈，顺序扫描 `s`：

1. **普通字符或 `'('`**：直接压栈；
2. **遇到 `')'`**：不断弹栈直到弹出 `'('`，把弹出的字符依次收集到 `tmp`；
3. 弹出 `'('` 本身，再把 `tmp` 中的字符依次压回栈。

关键在于：**从栈顶往下弹出来的顺序，天然就是反转顺序**。比如括号内是 `"love"`，栈中自底向上是 `l o v e`，弹栈时依次得到 `e v o l`，即 `"evol"`，所以 `tmp` 不需要再调用 `reverse`，直接压回即可。

嵌套括号也被自动处理：内层括号先闭合、先反转并压回栈，外层括号闭合时会把内层结果当作普通字符再反转一次，正好实现「由内到外逐层反转」。

最后，栈中自底向上存放的就是正序结果，但弹栈只能从栈顶开始，所以全部弹出得到逆序字符串，最后再整体 `reverse` 一次还原。

### 手算示例 2

`s = "(u(love)i)"`：

| 步骤 | 扫描到 | 栈变化（自底向上） |
|------|--------|--------------------|
| 1 | `(` | `(` |
| 2 | `u` | `( u` |
| 3 | `(` | `( u (` |
| 4 | `l o v e` | `( u ( l o v e` |
| 5 | `)` | 弹出 `evol`，去掉 `(`，压回 → `( u e v o l` |
| 6 | `i` | `( u e v o l i` |
| 7 | `)` | 弹出 `iloveu`，去掉 `(`，压回 → `i l o v e u` |

弹栈后整体 reverse，得到 `"iloveu"`。

### 复杂度分析

- **时间复杂度**：O(n²)，最坏情况（完全嵌套）每个字符进出栈 O(n) 次。
- **空间复杂度**：O(n)，栈和临时字符串。

> 进阶：本题还有 O(n) 的「预处理括号配对 + 方向翻转（wormhole）」写法，扫描时预先记录每对括号的位置，遇到括号直接「穿越」并掉转行进方向，适合面试拔高。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    string reverseParentheses(string s) {
        stack<char> st;
        for (auto i : s) {
            if (i == ')') {
                // 收集 '(' 之后的全部字符，弹栈顺序本身就是反转顺序
                string tmp = "";
                while (st.top() != '(') {
                    tmp += st.top();
                    st.pop();
                }

                // pop '('
                st.pop();
                // tmp 已经是反转后的结果，依次压回栈即可，无需 reverse
                for (auto j : tmp) {
                    st.emplace(j);
                }
            } else {
                st.emplace(i);
            }
        }

        // 栈中自底向上是正序串，弹栈得到逆序，最后再 reverse 还原
        string ret = "";
        while (st.empty() == false) {
            ret += st.top();
            st.pop();
        }
        reverse(ret.begin(), ret.end());

        return ret;
    }
};
```
{% endraw %}

### 代码解析

- `while (st.top() != '(')`：题目保证括号合法，所以栈中一定能找到 `'('`，无需判空。
- 收集 `tmp` 时**不要**再 `reverse`：栈弹出顺序已经是反序，多做一次反而错。
- 最后一次 `reverse` 容易遗漏：栈只能逆序弹出，直接拼接得到的是倒序结果。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 1190) {
    Solution s;
    // 示例 2：嵌套括号
    string ss = "(u(love)i)";
    EXPECT_EQ(s.reverseParentheses(ss), "iloveu");

    // 示例 1：单层括号
    EXPECT_EQ(s.reverseParentheses("(abcd)"), "dcba");

    // 示例 3：括号外有普通字符，多层嵌套
    EXPECT_EQ(s.reverseParentheses("a(bcdefghijkl(mno)p)q"), "apmnolkjihgfedcbq");

    // 边界：无括号，原样返回
    EXPECT_EQ(s.reverseParentheses("abcd"), "abcd");

    // 边界：多段并列括号 "(ab)(cd)" -> "ba" + "dc"
    EXPECT_EQ(s.reverseParentheses("(ab)(cd)"), "badc");
}
```
{% endraw %}

## 总结

本题是栈处理嵌套结构的经典练习，记忆要点有三个：

1. 遇 `)` 弹栈到 `(`，弹出顺序即反转顺序，`tmp` 不用再 reverse；
2. 内层结果压回栈，外层闭合时自然被二次反转，嵌套自动成立；
3. 最后整体弹栈得到逆序，别忘了收尾的那一次 `reverse`。
