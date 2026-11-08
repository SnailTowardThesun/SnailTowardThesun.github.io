---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.22: 括号生成"
categories: LeetCode
tags: [中等, 回溯, 字符串]
---

> 卡特兰数——n 对括号的合法串数恰是 C_n：1, 2, 5, 14, 42, 132, 429, 1430…；同一数列还数着出栈序列与二叉树形态。

## 题目

LeetCode 22. Generate Parentheses（括号生成）

Difficulty: **Medium**

数字 `n` 代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且 **有效的** 括号组合。

约束：

- `1 <= n <= 8`

### 示例

```text
输入：n = 3
输出：["((()))", "(()())", "(())()", "()(())", "()()()"]
```

```text
输入：n = 1
输出：["()"]
```

## 解题思路

### 合法性的前缀刻画

一个括号串「有效」等价于：**任意前缀中左括号数 ≥ 右括号数**，且左右各恰好 `n` 个——扫描途中永远不会出现配不上对的右括号，扫完时所有括号又全部配对。本题在 top150 中归入回溯分类：与其枚举全部括号串再逐一过滤，不如把合法性条件折叠进构造过程，只在合法分支上扩展。

### 回溯的两个分支规则

在构造过程中维护已放的左括号数 `open` 与右括号数 `close` 两个计数，每一步只有两种选择：

1. `open < n`：左括号还没放满，可以放 `(`；
2. `close < open`：右括号数未超过左括号数（正是前缀合法条件），可以放 `)`。

每一步的扩展都不破坏合法性，搜索树中所有叶子都是有效组合——无需事后校验。当前串长度到达 `2n` 时收集结果，回溯撤销选择继续穷举。n 对括号的有效组合数是卡特兰数 `C_n`（n=1..8 依次为 1, 2, 5, 14, 42, 132, 429, 1430）。

### 复杂度分析

- 时间复杂度：`O(4^n / sqrt(n))`（卡特兰数 `C_n` 的渐近量级）
- 空间复杂度：`O(n)`（递归深度 + 当前路径）

## 代码实现

```python
class Solution:
    def generateParenthesis(self, n: int) -> list[str]:
        # TODO 回溯：维护已放左括号数 open 与右括号数 close——
        #   open < n 时可放 '('，close < open 时可放 ')'，
        #   串长达到 2n 时收集结果，回溯撤销选择
        ret = set()

        def dfs(path, n, left, right):
            if left > n:
                return
            if right > left:
                return

            if len(path) == 2 * n:
                ret.add(path)

            dfs(path + "(", n, left + 1, right)
            dfs(path + ")", n, left, right + 1)

        dfs("", n, 0, 0)

        return list(ret)
```

### 代码解析

- `dfs` 的参数 `left` / `right` 就是思路中的 `open` / `close` 计数——随递归参数 +1 传入，不维护可变状态；
- 剪枝写在**子调用入口**：`dfs(path + "(", ...)` 无条件发起，非法分支由下一层的 `left > n`、`right > left` 两道闸拦下——与「放之前判断」等价，只是把守卫挪到了「放之后」；
- 收集时机是 `len(path) == 2 * n`：入口两道闸保证此刻必有 `left == right == n`（`left + right == 2n` 且双双不越界），收进 `ret` 的串必然有效；
- `path + "("` 每次生成新字符串，返回上层时旧 `path` 原封不动——「撤销选择」被字符串不可变性吸收，不需要显式 pop；
- 收集后代码仍会发起两次子调用，但 `left + 1 > n` 立刻被剪掉，正确性不受影响；结果收进 `set` 再转 `list`，是对「每条路径对应唯一串」的双保险。

## 测试用例

覆盖两个官方示例与三个规模边界（n=2 列出全部，n=4 与约束上界 n=8 做卡特兰数数量断言）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：n=3，5 个组合（卡特兰数 C_3 = 5） ----
    assert sorted(solution.generateParenthesis(3)) == sorted(["((()))", "(()())", "(())()", "()(())", "()()()"])

    # ---- 官方示例 2：n=1 ----
    assert sorted(solution.generateParenthesis(1)) == ["()"]

    # ---- n=2：卡特兰数 C_2 = 2 个，列出全部 ----
    assert sorted(solution.generateParenthesis(2)) == ["(())", "()()"]

    # ---- n=4：卡特兰数 C_4 = 14 个，数量断言 ----
    assert len(solution.generateParenthesis(4)) == 14

    # ---- n=8：约束上界，卡特兰数 C_8 = 1430 个，数量断言 ----
    assert len(solution.generateParenthesis(8)) == 1430
```

`uv run pytest top150/backtracking/top150_22.py` 全部通过。

## 总结

- 有效性可以边构造边保证：前缀条件（任意前缀左 ≥ 右）折叠进分支规则后，搜索树的叶子全是合法组合，省掉「全枚举 + 过滤」；
- 计数随递归参数传递、路径用不可变字符串拼接，「撤销选择」被语言特性吸收，回溯只剩两条递归分支；
- n 对括号的有效组合数是卡特兰数 `C_n`——n=8 时恰 1430 个，数量断言是回溯正确性最便宜的体检。
