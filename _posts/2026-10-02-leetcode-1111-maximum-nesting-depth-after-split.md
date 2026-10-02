---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1111: 有效括号的嵌套深度"
categories: LeetCode
---

> 把括号按「深度奇偶」交替分给两组，就能让两组的最大深度都不超过原深度的一半，从而使最大值最小。

## 题目

LeetCode 1111. Maximum Nesting Depth of Two Valid Parentheses Strings（有效括号的嵌套深度）

Difficulty: **Medium**

有效括号字符串仅由 `'('` 和 `')'` 构成。给你一个有效括号字符串 `seq`，请将其分成两个不相交的有效括号子序列 `A` 和 `B`，使 `A` 和 `B` 的**最大嵌套深度的最大值**尽可能小。

返回一个长度等于 `seq.length()` 的答案数组 `answer`，`answer[i] = 0` 表示 `seq[i]` 属于 `A`，`answer[i] = 1` 表示属于 `B`。

### 示例

```
示例 1：
输入：seq = "(()())"
输出：[0,1,1,1,1,0]

示例 2：
输入：seq = "()(())()"
输出：[0,0,0,1,1,0,0,0]
```

## 解题思路

### 奇偶分组

关键观察：要让两组深度的最大值最小，应让两组的深度尽可能均衡。最简单的均衡方式是**按深度奇偶交替分配**。

1. 维护当前嵌套深度 `depth`。
2. 遇到 `'('`：将其分配给 `depth % 2` 组，然后 `depth++`（进入更深一层）。
3. 遇到 `')'`：先 `depth--`（回到上一层），再分配给 `depth % 2` 组，保证与对应的左括号同组。

这样同一深度的括号被交替分到 A、B 两组，两组的最大深度都不超过原深度的一半，最大值即最小化。

### 手算示例 1

`seq = "(()())"`：

| i | seq[i] | depth（处理前） | 分配组 | depth（处理后） |
|---|--------|-----------------|--------|-----------------|
| 0 | `(` | 0 | 0 | 1 |
| 1 | `(` | 1 | 1 | 2 |
| 2 | `)` | 2 | 1 | 1 |
| 3 | `(` | 1 | 1 | 2 |
| 4 | `)` | 2 | 1 | 1 |
| 5 | `)` | 1 | 0 | 0 |

结果：`[0,1,1,1,1,0]`。

### 复杂度分析

- **时间复杂度**：O(n)，单次遍历。
- **空间复杂度**：O(1)，不计返回数组。

## 代码实现

```cpp
class Solution {
public:
    vector<int> maxDepthAfterSplit(string seq) {
        vector<int> ret(seq.size(), 0);

        int depth = 0;
        for (auto i = 0; i < seq.size(); ++i) {
            if (seq.at(i) == '(') {
                ret[i] = depth % 2;
                depth++;
            } else if (seq.at(i) == ')') {
                depth--;
                ret[i] = depth % 2;
            }
        }

        return ret;
    }
};
```

### 代码解析

- `'('` 先分配再 `depth++`：当前左括号属于进入前的深度层。
- `')'` 先 `depth--` 再分配：右括号与匹配的左括号处于同一深度层，分配结果一致。

## 测试用例

```cpp
TEST(Daily, 1111) {
    Solution s;
    auto seq = "(()())";
    auto ret = s.maxDepthAfterSplit(seq);
    EXPECT_EQ(vector<int>({0,1,1,1,1,0}), ret);
}
```

## 总结

本题的核心是**奇偶交替分组**：

1. 左括号：`ret[i] = depth % 2; depth++;`
2. 右括号：`depth--; ret[i] = depth % 2;`
3. 保证匹配的左右括号同组，且两组深度均衡。
