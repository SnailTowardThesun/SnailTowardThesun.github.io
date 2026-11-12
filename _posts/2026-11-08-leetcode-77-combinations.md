---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.77: 组合"
categories: LeetCode
tags: [中等, 回溯]
---

> C(n,k) 就是杨辉三角第 n 行第 k 项——帕斯卡恒等式 C(n,k) = C(n-1,k) + C(n-1,k-1) 正是「这个元素选或不选」的递归分裂，与本实现的分解同源。

## 题目

LeetCode 77. Combinations（组合）

Difficulty: **Medium**

给定两个整数 `n` 和 `k`，返回范围 `[1, n]` 中所有可能的 `k` 个数的组合。

可以按**任何顺序**返回答案。

约束：

- `1 <= n <= 20`
- `1 <= k <= n`

### 示例

```text
输入：n = 4, k = 2
输出：[[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]]
解释：[1, n] 中所有可能的 2 个数的组合，共 C(4,2) = 6 个。
```

```text
输入：n = 1, k = 1
输出：[[1]]
```

## 解题思路

本题属于 top150 的回溯分类。

### 组合无序：让路径严格递增

排列问题里 `[1,2]` 和 `[2,1]` 是两个答案，组合问题里它们是同一个——`{1,2}` 不区分顺序。枚举时若不加约束，每个组合会按各种顺序被重复产出。解法不是靠判重集合，而是靠枚举结构本身：让路径上的数**严格递增**，每个组合只以升序形态被生成一次，天然无重。

### 本实现：共享路径 + 剩余数量剪枝

用 `backtrack(start)` 表示下一位只能从 `start..n` 中选择，所有递归层共用一条 `path`。

1. 选择 `value` 后，下一层从 `value + 1` 开始，保证路径严格递增；
2. 还缺 `remaining = k - len(path)` 个数时，当前值至多为 `n - remaining + 1`；更大的值会让剩余候选不足，直接剪掉；
3. 收满 k 个数时复制路径并返回；每次递归后弹出刚选的值。

剪枝保证每个被访问的前缀都能扩展成完整组合；不创建后缀切片，也不保存子问题的全部答案。

### 复杂度分析

- 时间复杂度：`O(C(n,k) * k)`——共 C(n,k) 个组合，每个组合构造 O(k)
- 空间复杂度：`O(k)`（递归栈与共享路径，不计输出）

## 代码实现

```python
class Solution:
    def combine(self, n: int, k: int) -> list[list[int]]:
        ret: list[list[int]] = []
        path: list[int] = []

        def backtrack(start: int) -> None:
            remaining = k - len(path)
            if remaining == 0:
                ret.append(path.copy())
                return
            # 选 value 后，后面还须留出 remaining - 1 个数。
            for value in range(start, n - remaining + 2):
                path.append(value)
                backtrack(value + 1)
                path.pop()

        backtrack(1)
        return ret
```

### 代码解析

- `remaining == 0` 时 `path.copy()` 收集独立结果，避免后续回溯修改已保存的组合；
- `range(start, n - remaining + 2)` 的右端点不包含在循环中，实际最大候选恰为 `n - remaining + 1`；
- 下一层用 `value + 1`，保证每个数至多出现一次且顺序严格递增；
- `k == n` 时剪枝只保留全选路径，`k == 1` 时自然枚举所有单元素，无需额外分支。

## 测试用例

覆盖两个官方示例与三个边界（k=3 抽查首尾组合、k=n 只能全选、上界规模 n=20 且 k=1）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：n=4, k=2，C(4,2)=6 个组合 ----
    assert sorted(solution.combine(4, 2)) == [[1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4]]

    # ---- 官方示例 2：n=1, k=1，唯一组合 ----
    assert sorted(solution.combine(1, 1)) == [[1]]

    # ---- n=5, k=3：C(5,3)=10 个，抽查首尾边界组合 ----
    result_5_3 = sorted(solution.combine(5, 3))
    assert len(result_5_3) == 10
    assert [1, 2, 5] in result_5_3  # 跨度最大：含最小起点与最大终点
    assert [3, 4, 5] in result_5_3  # 最晚起点的组合

    # ---- k=n：只能选满 [1,n]，唯一组合 ----
    assert sorted(solution.combine(4, 4)) == [[1, 2, 3, 4]]

    # ---- 上界规模 n=20, k=1：20 个单元素组合 ----
    result_20_1 = sorted(solution.combine(20, 1))
    assert len(result_20_1) == 20
    assert result_20_1 == [[i] for i in range(1, 21)]

    # ---- 小规模穷举对照标准库，覆盖剪枝上界、漏解与重复解 ----
    from itertools import combinations

    for n in range(1, 9):
        for k in range(1, n + 1):
            assert sorted(map(tuple, solution.combine(n, k))) == list(combinations(range(1, n + 1), k))
```

`uv run pytest top150/backtracking/top150_77.py` 全部通过。

## 总结

- 组合按升序生成，靠 start 限制消除重复；
- 剩余数量决定候选上界，提前剪掉无法补足 k 个数的分支；
- 共享路径避免切片和中间结果，辅助空间 O(k)，时间 O(k·C(n,k))。
