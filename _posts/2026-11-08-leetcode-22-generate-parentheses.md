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

- 时间复杂度：`O(n·C_n) = O(4^n / sqrt(n))`——`C_n = O(4^n / n^(3/2))` 个结果，每条拼接 O(n)
- 空间复杂度：`O(n)`（递归深度 + 共享路径，不计输出）

## 代码实现

```python
class Solution:
    def generateParenthesis(self, n: int) -> list[str]:
        ret: list[str] = []
        path: list[str] = []

        def backtrack(left: int, right: int) -> None:
            if len(path) == 2 * n:
                ret.append("".join(path))
                return
            if left < n:
                path.append("(")
                backtrack(left + 1, right)
                path.pop()
            if right < left:
                path.append(")")
                backtrack(left, right + 1)
                path.pop()

        backtrack(0, 0)
        return ret
```

### 代码解析

- `left`、`right` 分别记录已放的左右括号数；只在 `left < n` 或 `right < left` 时进入对应分支；
- `path` 是共享字符列表，追加、递归、弹出，避免递归栈同时持有多份字符串前缀；
- 长度到达 `2*n` 时拼接并立即返回，不再扩展；每条路径唯一，直接存入列表，无需集合去重。

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

    # ---- 数量正确还不够：所有结果必须唯一，任意前缀合法且左右括号等量 ----
    for n, expected in enumerate((1, 2, 5, 14, 42, 132, 429, 1430), start=1):
        result = solution.generateParenthesis(n)
        assert len(result) == len(set(result)) == expected
        for parentheses in result:
            assert len(parentheses) == 2 * n
            balance = 0
            for char in parentheses:
                balance += 1 if char == "(" else -1
                assert balance >= 0
            assert balance == 0
```

`uv run pytest top150/backtracking/top150_22.py` 全部通过。

## 总结

- 有效性可以边构造边保证：前缀条件（任意前缀左 ≥ 右）折叠进分支规则后，搜索树的叶子全是合法组合，省掉「全枚举 + 过滤」；
- 计数随递归参数传递，共享路径在递归前追加、递归后撤销，只有收集答案时拼接字符串；
- n 对括号的有效组合数是卡特兰数 `C_n`——n=8 时恰 1430 个，数量断言是回溯正确性最便宜的体检。
