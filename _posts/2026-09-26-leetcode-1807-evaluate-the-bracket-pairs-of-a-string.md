---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1807: 替换字符串中的括号内容"
categories: LeetCode
---

> 哈希表预处理 + 顺序扫描，是字符串模板替换最直接的组合。括号不嵌套时无需栈，找到配对的右括号即可。

## 题目

LeetCode 1807. Evaluate the Bracket Pairs of a String（替换字符串中的括号内容）

Difficulty: **Easy**

给定一个字符串 `s`，其中包含若干对括号；每对括号内是一个键 `key`。

同时给定二维字符串数组 `knowledge`，其中 `knowledge[i] = [key_i, value_i]`。

请把 `s` 中每对括号及其中的 `key` 替换为对应的 `value_i`；如果 `key` 不存在于 `knowledge` 中，则替换为 `'?'`。

### 示例

```
示例 1：
输入：s = "(name)is(age)yearsold"
      knowledge = [["name","bob"],["age","two"]]
输出："bobistwoyearsold"

示例 2：
输入：s = "hi(name)"
      knowledge = [["a","b"]]
输出："hi?"

示例 3：
输入：s = "(a)(a)(a)aaa"
      knowledge = [["a","yes"]]
输出："yesyesyesaaa"
```

## 解题思路

### 先哈希化知识库

把 `knowledge` 转成 `unordered_map<string, string>`，用空间换时间，让每次查询替换值都从线性查找降为平均 O(1)。

### 再顺序扫描原字符串

维护扫描指针 `i`：

- 遇到普通字符：直接追加到结果串，`i++`；
- 遇到 `'('`：从 `i + 1` 开始找到对应的 `')'`，提取括号内的 key；然后把 `i` 移到 `')'` 的下一个位置；
- 如果 key 在哈希表中，追加对应 value，否则追加 `'?'`。

由于题目保证括号**不会嵌套**，因此不需要栈或递归。每遇到 `'('`，直接找下一个 `')'` 就能完成一次替换。

### 手算示例 2

原串：`hi(name)`，`knowledge` 中没有 `"name"`。

扫描过程：

1. `h`、`i` 是普通字符，直接输出；
2. 遇到 `'('`，提取 key = `"name"`；
3. 哈希表查不到 `"name"`，输出 `'?'`；
4. 最终结果：`"hi?"`。

### 复杂度分析

- **时间复杂度**：O(n + m)，其中 `n` 是原字符串长度，`m` 是 `knowledge` 中所有 key/value 的总长度。
- **空间复杂度**：O(m + n)，用于哈希表和结果字符串。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    string evaluate(string s, vector<vector<string>> &knowledge) {
        // 建立 key -> value 的哈希映射
        unordered_map<string, string> lookup;
        for (auto i : knowledge) {
            lookup[i[0]] = i[1];
        }

        string ret = "";
        for (auto i = 0; i < s.size();) {
            // 普通字符直接输出
            if (s.at(i) != '(') {
                ret += s.at(i);
                i++;
                continue;
            }

            // 遇到 '('，提取括号内的 key
            string tmp = "";
            int j = i + 1;
            for (; j < s.size(); j++) {
                if (s.at(j) == ')') {
                    break;
                }
                tmp += s.at(j);
            }
            i = j + 1;  // 跳到 ')' 之后

            // 查表替换，不存在则替换为 '?'
            if (lookup.count(tmp) > 0) {
                ret += lookup[tmp];
            } else {
                ret += '?';
            }
        }

        return ret;
    }
};
```
{% endraw %}

### 代码解析

- `lookup[i[0]] = i[1]`：把每条知识规则转为 O(1) 查询。
- `i` 和 `j` 形成一次性的双指针：`j` 负责提取括号内容，`i` 随后直接跳过整个括号区间。
- `lookup.count(tmp)` 先判断 key 是否存在，避免误用 `lookup[tmp]` 自动插入空字符串。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 1807) {
    Solution s;

    // 示例 1：所有 key 都存在
    auto ss = "(name)is(age)yearsold";
    vector<vector<string>> knowledge = {{"name", "bob"}, {"age", "two"}};
    EXPECT_EQ(s.evaluate(ss, knowledge), "bobistwoyearsold");

    // 示例 2：key 不存在
    vector<vector<string>> knowledge2 = {{"a", "b"}};
    EXPECT_EQ(s.evaluate("hi(name)", knowledge2), "hi?");

    // 示例 3：多个连续括号
    vector<vector<string>> knowledge3 = {{"a", "yes"}};
    EXPECT_EQ(s.evaluate("(a)(a)(a)aaa", knowledge3), "yesyesyesaaa");

    // 边界：无括号，直接返回原串
    vector<vector<string>> empty_knowledge;
    EXPECT_EQ(s.evaluate("hello", empty_knowledge), "hello");

    // 边界：整个串都是括号
    vector<vector<string>> knowledge4 = {{"key", "value"}};
    EXPECT_EQ(s.evaluate("(key)", knowledge4), "value");
}
```
{% endraw %}

## 总结

本题是标准的「预处理映射 + 单次扫描」。关键不是算法难度，而是识别题目中的两个约束：

1. 括号不嵌套，所以不需要栈；
2. 查找次数可能很多，所以先把 `knowledge` 转成哈希表。

掌握这两个判断后，实现只需要普通字符直出、括号内容查表替换两个分支即可。
