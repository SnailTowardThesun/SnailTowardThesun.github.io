---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.39: 组合总和"
categories: LeetCode
tags: [中等, 回溯, 数组]
---

> 完全背包的「凑硬币」视角：本题就是凑 target、每种面额无限张的枚举版——动态规划（零钱兑换 II）求方案数，回溯求方案列表，是一枚硬币的两面。

## 题目

LeetCode 39. Combination Sum（组合总和）

Difficulty: **Medium**

给你一个 **无重复元素** 的整数数组 `candidates` 和一个目标整数 `target`，找出 `candidates` 中可以使数字和为目标数 `target` 的所有 **不同组合**，并以列表形式返回。`candidates` 中的同一个数字可以 **无限制重复被选取**。如果至少一个数字的被选数量不同，则两种组合是不同的。

可以按任意顺序返回这些组合。

约束：

- `2 <= candidates.length <= 40`
- `1 <= candidates[i] <= 40`，且 `candidates` 中的元素互不相同
- `1 <= target <= 40`
- 题目保证符合要求的组合数少于 150 个

### 示例

```text
输入：candidates = [2,3,6,7], target = 7
输出：[[2,2,3],[7]]
解释：2 和 3 是候选，2 + 2 + 3 = 7；7 也是候选，7 = 7。
其余组合不满足。
```

```text
输入：candidates = [2,3,5], target = 8
输出：[[2,2,2,2],[2,3,3],[3,5]]
```

```text
输入：candidates = [2], target = 1
输出：[]
```

## 解题思路

面试经典 150 题把本题归入「回溯」分类——它是组合型搜索的模板题，解法是排序 + 带 `start` 索引的回溯。

### 重复的来源：组合还是排列？

题目要的是**组合**：`[2,2,3]` 与 `[2,3,2]` 中各数字的被选数量完全相同，算同一个解。若每层递归都从 `0` 号候选扫起（排列式枚举），同一组数字会按不同顺序被反复收集——`[2,2,3]`、`[2,3,2]`、`[3,2,2]` 三条路径产出三个「解」。重复的根源是**顺序被计入了解**。收集后再排序去重当然可行，但代价高也不优雅；正确做法是在搜索结构上直接保证：每个组合只有唯一一条生成路径。

### start 索引：强制下标单调不减

给递归加一个 `start` 参数，本层只从 `candidates[start..]` 里选。上一层选了第 `i` 个，下一层的 `start` 至少是 `i`——于是任意一条完整路径的下标序列**单调不减**。`[2,3,2]`（下标 `0,1,0`）这类回头路径在结构上根本不会发生，每个组合固定按「下标不减」的顺序被生成且仅生成一次，不重不漏。

### 传 i 而非 i+1：同一元素可选无限次

子集型回溯（每个元素至多选一次）里下一层传 `i + 1`；本题允许**无限制重复选取**，所以传 `i`——下一层还能继续选第 `i` 个，`2+2+3` 里的两个 2 正是这么来的。一个字符的差别，就是「子集/组合去重」与「组合总和」两类题型的分叉口。

### 排序后剪枝：超缺口即 break

先把 `candidates` 升序排序——题目允许任意顺序返回，排序不改变解集。循环中一旦 `candidates[i] > remaining`（超过剩余缺口），后面的候选只会更大，直接 `break` 整层循环——剪掉的不是单个分支，而是整棵子树。

### 复杂度分析

- 时间复杂度：指数级——搜索树规模与满足条件的组合数相关，上界由候选数决定的指数增长（题目保证组合数少于 150，实际搜索量远小于理论上限）
- 空间复杂度：`O(target / min(candidates))`——递归栈深度即最长路径长度，路径上每个数至少贡献最小候选值（不计输出空间）

## 代码实现

```python
class Solution:
    def combinationSum(self, candidates: list[int], target: int) -> list[list[int]]:
        candidates = sorted(candidates)  # 升序排序，为剪枝做准备
        ret: list[list[int]] = []
        path: list[int] = []

        def backtrack(start: int, remaining: int) -> None:
            if remaining == 0:  # 当前和恰好等于 target，收集路径副本
                ret.append(path[:])
                return
            for i in range(start, len(candidates)):
                # 剪枝：已排序，当前候选已超缺口，后面只会更大
                if candidates[i] > remaining:
                    break
                path.append(candidates[i])
                backtrack(i, remaining - candidates[i])  # 传 i 非 i+1：允许重复选同一元素
                path.pop()

        backtrack(0, target)
        return ret
```

### 代码解析

- 递归参数取 `remaining`（剩余缺口）口径，而不是另外维护「已选累加和」：`remaining == target - 累加和`，两者完全等价，但判停条件收敛成 `remaining == 0` 一行，选入动作 `remaining - candidates[i]` 一步完成「选入 + 扣减」——少一个变量，也少一次比较；
- `break` 写在 `path.append` 之前：排序保证超缺口的候选之后全超，终止的是整层循环而非跳过一个候选——`O(n log n)` 的排序换来的是整棵子树的剪除；
- `ret.append(path[:])` 收集的是**副本**：`path` 是贯穿全程、随递归增删的同一个列表，若直接 append 引用，后续 `path.pop()` 会把已收进结果的组合一并拆掉。

## 测试用例

覆盖三个官方示例与四个补充边界（单元素重复凑整、乱序输入同解、奇偶性无解、两种组合并存）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：2+2+3 与 7 ----
    assert sorted(sorted(x) for x in solution.combinationSum([2, 3, 6, 7], 7)) == [[2, 2, 3], [7]]

    # ---- 官方示例 2：四种组合中的三种 ----
    assert sorted(sorted(x) for x in solution.combinationSum([2, 3, 5], 8)) == [
        [2, 2, 2, 2],
        [2, 3, 3],
        [3, 5],
    ]

    # ---- 官方示例 3：最小候选 2 > target 1，无解 ----
    assert solution.combinationSum([2], 1) == []

    # ---- 同一元素重复选：3+3+3 = 9 ----
    assert sorted(sorted(x) for x in solution.combinationSum([3], 9)) == [[3, 3, 3]]

    # ---- 乱序输入：与官方示例 1 同解 ----
    assert sorted(sorted(x) for x in solution.combinationSum([7, 3, 2], 7)) == [[2, 2, 3], [7]]

    # ---- 无解：2a+4b=11 无非负整数解 ----
    assert solution.combinationSum([2, 4], 11) == []

    # ---- 混合重复：5+5+5 与 10+5 ----
    assert sorted(sorted(x) for x in solution.combinationSum([5, 10], 15)) == [[5, 5, 5], [5, 10]]
```

`uv run pytest top150/backtracking/top150_39.py` 全部通过。

## 总结

- 组合去重不靠结果集合去重，靠搜索结构：`start` 索引强制下标单调不减，每个组合只剩「下标不减」这一条生成路径；
- 递归传 `i` 还是 `i + 1` 是题型分界：前者面额无限（本题、完全背包），后者每个元素至多选一次（子集型、0-1 背包）——两侧的划分一一对应；
- 排序是剪枝的前置投资：`candidates[i] > remaining` 时的 `break` 剪掉整棵子树，`remaining` 缺口口径则把判停与扣减各收敛成一行。
