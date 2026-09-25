---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1096: 花括号展开 II"
categories: LeetCode
---

{% raw %}

> 括号展开的本质是「上下文栈 + 两种运算」：并列做笛卡尔积、逗号做并集。同一套模型也是 shell glob、JSON 模板、DSL 解析器的基础结构。

## 题目

LeetCode 1096. Brace Expansion II（花括号展开 II）

Difficulty: **Hard**

给定表达式 `expression`：

- 花括号外的每个字母按**顺序连接**；
- 花括号内用逗号分隔的选项是**「或」关系**（取其一）；
- 表达式可以**嵌套**花括号。

返回所有可能字符串的列表，按**字典序**排序，且**不含重复**。

### 示例

```
示例 1：
输入：expression = "{a,b}{c,{d,e}}"
输出：["ac","ad","ae","bc","bd","be"]

示例 2：
输入：expression = "{{a,z},a{b,c},{ab,z}}"
输出：["a","ab","ac","z"]
解释：去重后按字典序。
```

## 解题思路

### 两种运算：积 与 并

理解规则是解题关键：

- **并列**（花括号外相邻，如 `ab` 或 `{a,b}c`）= **笛卡尔积**：把左侧每个串与右侧每个串拼接。
- **花括号内逗号**（如 `{a,b,c}`）= **并集**：任选一项。

这两种运算交替出现，配合嵌套，正是栈的用武之地。

### 栈保存上下文

维护两个集合：

```
res = 当前「逗号分隔」层累积的并集（取其一）
cur = 当前正在拼接的「并列」积的集合
```

用一个栈保存每层进入 `{` 之前的 `(res, cur)`。

按字符分类处理：

1. **字母 `c`**：cur 中每个串末尾追加 `c`（并列，更新积）。
2. **`,`**：当前并列组结束，把 cur 并入 res，cur 重置为 `{""}`（下一个候选从空串开始累积）。
3. **`{`**：把当前 `(res, cur)` 压栈，res、cur 都重置，开始解析括号内层。
4. **`}`**：
   - 先 `res ∪ cur` 得到括号内所有候选 `sub_arr`；
   - 弹出外层 `(res, cur)`；
   - 令 `cur = 外层 cur × sub_arr`（笛卡尔积，因为括号整体作为并列的一项拼到外层 cur 后面）。

遍历结束，把最后的 cur 并入 res，排序后返回。

用 `unordered_set<string>` 天然去重，最后 `sort` 保证字典序。

### 手算示例 1：`{a,b}{c,{d,e}}`

| 步骤 | 字符 | 操作 | res | cur |
|------|------|------|-----|-----|
| 1 | `{` | push({}, {""})，重置 | {} | {""} |
| 2 | `a` | cur 追加 a | {} | {"a"} |
| 3 | `,` | cur 入 res，重置 | {"a"} | {""} |
| 4 | `b` | cur 追加 b | {"a"} | {"b"} |
| 5 | `}` | sub_arr={a,b}，弹栈，cur=外层cur×sub | {} | {"a","b"} |
| 6 | `{` | push({}, {a,b})，重置 | {} | {""} |
| 7 | `c` | cur 追加 c | {} | {"c"} |
| 8 | `,` | cur 入 res，重置 | {"c"} | {""} |
| 9 | `{` | push({c}, {""})，重置 | {} | {""} |
| 10 | `d` | cur 追加 d | {} | {"d"} |
| 11 | `,` | cur 入 res，重置 | {"d"} | {""} |
| 12 | `e` | cur 追加 e | {"d"} | {"e"} |
| 13 | `}` | sub_arr={d,e}，弹栈，cur=外层cur×sub | {} | {"d","e"} |
| 14 | `}` | sub_arr={c,d,e}，弹栈，cur=外层cur×sub | {} | {"ac","ad","ae","bc","bd","be"} |

最终 cur 并入 res，排序得 `["ac","ad","ae","bc","bd","be"]`，与样例一致。

### 复杂度分析

- **时间复杂度**：与输出结果集大小相关，最坏指数级；本题数据规模下可接受。
- **空间复杂度**：与结果集大小同阶。

## 代码实现

```cpp
class Solution {
public:
    vector<string> braceExpansionII(string expression) {
        using SET = unordered_set<string>;
        // 栈元素：(进入当前 '{' 前的并集 res, 并列积 cur)
        stack<pair<SET, SET>> container;
        SET res;
        SET cur{""};

        for (auto ch : expression) {
            if (ch >= 'a' && ch <= 'z') {
                // 并列：cur 中每个串末尾追加该字母
                SET tmp;
                for (auto s : cur) tmp.insert(s + ch);
                cur = tmp;
            } else if (ch == ',') {
                // 逗号：当前并列组结束，cur 并入 res
                res.insert(cur.begin(), cur.end());
                cur = {""};
            } else if (ch == '{') {
                // 保存上下文，进入括号内层
                container.emplace(std::move(res), std::move(cur));
                res = {};
                cur = {""};
            } else if (ch == '}') {
                // 括号内所有候选 = res ∪ cur
                res.insert(cur.begin(), cur.end());
                auto sub_arr = std::move(res);

                // 恢复外层上下文
                res = container.top().first;
                cur = container.top().second;
                container.pop();

                // 括号整体作为并列的一项：cur = 外层 cur × sub_arr
                SET tmp;
                for (auto i : cur)
                    for (auto j : sub_arr)
                        tmp.insert(i + j);
                cur = tmp;
            }
        }

        // 最后一组 cur 并入 res
        res.insert(cur.begin(), cur.end());

        vector<string> ret(res.begin(), res.end());
        sort(ret.begin(), ret.end());
        return ret;
    }
};
```

### 代码解析

- `cur` 初始为 `{""}` 而非空集——这是为了让「并列追加」从一个空串开始生长，否则第一个字母无处拼接。
- `}` 分支是核心：括号内的所有候选先求并（res ∪ cur），再作为一个整体与外层 cur 做笛卡尔积，正好对应「括号是并列的一项」。
- `unordered_set` 自动去重，最后用 `sort` 把无序集合变成字典序输出。

## 测试用例

```cpp
TEST(Daily, 1096) {
    Solution s;

    // 示例 1：嵌套花括号
    auto ret = s.braceExpansionII("{a,b}{c,{d,e}}");
    EXPECT_EQ(ret, vector<string>({"ac", "ad", "ae", "bc", "bd", "be"}));

    // 示例 2：含去重与字典序
    EXPECT_EQ(s.braceExpansionII("{{a,z},a{b,c},{ab,z}}"),
              vector<string>({"a", "ab", "ac", "z"}));

    // 简单并列
    EXPECT_EQ(s.braceExpansionII("a{b,c}"), vector<string>({"ab", "ac"}));

    // 嵌套花括号
    EXPECT_EQ(s.braceExpansionII("{x{a,b}}"), vector<string>({"xa", "xb"}));
}
```

## 总结

1096 是「括号展开」家族里的综合题，难点不在栈本身，而在于**分清两种运算的语义**：花括号外的相邻是积，花括号内的逗号是并。记住三点：① `cur` 初始为 `{""}` 才能生长；② `,` 做并（cur 入 res）、字母做积（追加到 cur）；③ `}` 时括号整体作为并列项，与外层 cur 做笛卡尔积。这个「res 表并、cur 表积、栈存上下文」的三件套，能直接迁移到表达式求值、模板引擎解析等更复杂的场景。

{% endraw %}
