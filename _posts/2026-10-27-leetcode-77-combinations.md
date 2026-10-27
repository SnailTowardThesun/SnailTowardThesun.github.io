---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.77: 组合"
categories: LeetCode
tags: [中等, 递归, 组合数学]
---

> C(n, k) 就是二项式系数——帕斯卡三角第 n 行的第 k 项，满足 C(n,k) = C(n-1,k-1) + C(n-1,k)。这个递推本身就是「选或不选最后一个元素」的分治，正是本题解法的数学原型。

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
解释：[1, 4] 中取 2 个数的全部组合，共 C(4, 2) = 6 个。
```

```text
输入：n = 1, k = 1
输出：[[1]]
```

## 解题思路

经典做法是回溯：维护路径 `path` 与枚举起点 `start`，选一个数进路径、递归、再撤销。本次实现换成了更直观的**分治递归**：

1. `dfs(arr, k)` 表示「从数组 `arr` 中选 `k` 个数的全部组合」；
2. 枚举组合的**首元素** `start = arr[i]`，则剩余 `k - 1` 个数只能从后缀 `arr[i+1:]` 中选——后缀保证了每个数字只用一次，且天然去重（组合内递增）；
3. 把首元素与每个子组合拼接：`[start, *c]`；
4. 三个边界：
   - `k == 1`：每个元素自成一组，`[[i] for i in arr]`；
   - `k > len(arr)`：凑不满，无解，返回空；
   - `k == len(arr)`：只能全选，恰好一组。

由于 `i` 从左到右推进、子问题只在后缀上递归，生成的组合按字典序排列，不会出现重复组合。

### 复杂度分析

- 时间复杂度：`O(C(n, k) * k)`——共有 C(n, k) 个组合，每个拼接耗时 O(k)
- 空间复杂度：`O(k)` 递归栈（不计输出占用的 `O(C(n, k) * k)`）

## 代码实现

```python
from math import comb


class Solution:
    def combine(self, n: int, k: int) -> list[list[int]]:
        def dfs(arr: list[int], k: int) -> list[list[int]]:
            if k == 1:
                return [[i] for i in arr]
            if k > len(arr):
                return []
            if k == len(arr):
                return [arr]

            ret = []
            for i in range(len(arr)):
                start = arr[i]
                combines = dfs(arr[i + 1 :], k - 1)
                for c in combines:
                    ret.append([start, *c])

            return ret

        arr = list(range(n + 1))[1:]
        return dfs(arr, k)
```

### 代码解析

- `arr[i + 1:]` 是关键：首元素取 `arr[i]` 后只在后缀递归，避免重复使用同一数字，也避免出现 `[2, 1]` 这种逆序组合；
- `[start, *c]` 用解包把首元素与子组合拼成新列表，等价于 `[start] + c` 但少一次列表拼接；
- `k == len(arr)` 的短路省去了「全选」情形的逐层递归；
- `list(range(n + 1))[1:]` 生成 `[1..n]`。

## 测试用例

题目允许任意顺序返回，断言统一先 `sorted` 再比较；组合数量用 `math.comb` 交叉验证：

```python
def test_combine() -> None:
    solution = Solution()

    # 官方示例 1：n = 4, k = 2（题目允许任意顺序，排序后比较）
    assert sorted(solution.combine(4, 2)) == [
        [1, 2], [1, 3], [1, 4], [2, 3], [2, 4], [3, 4],
    ]

    # 官方示例 2：n = 1, k = 1
    assert sorted(solution.combine(1, 1)) == [[1]]

    # 边界：k = 1，每个数单独成组
    assert sorted(solution.combine(3, 1)) == [[1], [2], [3]]

    # 边界：k = n，只能全选
    assert sorted(solution.combine(3, 3)) == [[1, 2, 3]]

    # 规模较大：C(5, 3) = 10 个组合
    assert sorted(solution.combine(5, 3)) == [
        [1, 2, 3], [1, 2, 4], [1, 2, 5], [1, 3, 4], [1, 3, 5],
        [1, 4, 5], [2, 3, 4], [2, 3, 5], [2, 4, 5], [3, 4, 5],
    ]

    # 组合数量与数学组合数一致
    assert len(solution.combine(6, 2)) == comb(6, 2)
    assert len(solution.combine(10, 5)) == comb(10, 5)
```

## 总结

- 分治视角（枚举首元素 + 后缀子问题）与回溯等价，但不用维护和撤销路径状态；
- 边界 `k == 1` 返回「每个元素自成一组」而非空集，是递归正确收敛的根基；
- 测试用 `sorted` 适配任意顺序输出，用 `math.comb` 验证组合总数，成本低、覆盖强。
