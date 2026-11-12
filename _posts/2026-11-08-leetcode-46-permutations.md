---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.46: 全排列"
categories: LeetCode
tags: [中等, 回溯, 数组]
---

> n 个互异元素恰有 n! 个排列；康托展开能把任一排列映射成 0..n!-1 的整数（字典序排名），是排列哈希与康托逆展开的基础。

## 题目

LeetCode 46. Permutations（全排列）

Difficulty: **Medium**

给定一个**不含重复数字**的数组 `nums`，返回其**所有可能的全排列**。可以按任意顺序返回答案。

约束：

- `1 <= nums.length <= 6`
- `-10 <= nums[i] <= 10`
- `nums` 中的所有整数**互不相同**

### 示例

```text
输入：nums = [1,2,3]
输出：[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]
解释：3 个互异元素共有 3! = 6 个排列。
```

```text
输入：nums = [0,1]
输出：[[0,1],[1,0]]
```

```text
输入：nums = [1]
输出：[[1]]
```

## 解题思路

本题是面试经典 150 题（top150）**回溯分类**的开篇题：把全排列看作「逐个位置选数」的决策树，用 DFS 沿树下行，走到叶子收集一条完整排列。

### 排列与组合的分岔：顺序有意义

组合题（如同目录的 77 题）里 `[1,2]` 与 `[2,1]` 是同一份答案，靠 `start` 指针让每层只向后枚举就能天然去重；排列里**顺序本身就是意义**，`[1,2,3]` 与 `[2,1,3]` 是两个答案，start 指针用不得。枚举策略随之翻转：

- **每层都从头扫到尾**——任何元素都可能出现在任何位置；
- **防复用**——已选过的元素跳过：用 `used` 布尔数组按下标 O(1) 判重（等价写法 `nums[i] not in path` 是 O(n) 判重）。

### 回溯三步曲：选择 → 递归 → 撤销

决策树上每一层做三件事：

1. **选择**：`used[i] = True`，`path.append(nums[i])`；
2. **递归**：填下一个位置；
3. **撤销**：`path.pop()`，`used[i] = False`——回到本层换下一个候选。

路径长到达 `n` 时把 `path` 的**副本**收进结果（直接收引用的话，后续回溯会把它改掉）。每层候选依次是 n、n-1、…、1，整棵决策树恰好 n! 片叶子。

本文直接用 `path/used` 实现上述三步，不切片或缓存子排列。叶子处统一复制路径，也保证单元素输入的结果不与原列表共享引用。

### 复杂度分析

- 时间复杂度：`O(n·n!)`——共 n! 个排列，每条拼装/拷贝 O(n)
- 空间复杂度：`O(n)`——递归栈、共享路径与 used 数组（不计 `O(n·n!)` 输出）

## 代码实现

```python
class Solution:
    def permute(self, nums: list[int]) -> list[list[int]]:
        ret: list[list[int]] = []
        path: list[int] = []
        used = [False] * len(nums)

        def backtrack() -> None:
            if len(path) == len(nums):
                ret.append(path.copy())
                return
            for i, value in enumerate(nums):
                if used[i]:
                    continue
                used[i] = True
                path.append(value)
                backtrack()
                path.pop()
                used[i] = False

        backtrack()
        return ret
```

### 代码解析

- 每层都枚举所有下标，`used[i]` 阻止一个元素被重复使用；
- 标记、追加后递归，返回时弹出并撤销标记，兄弟分支互不污染；
- `ret.append(path.copy())` 在每个叶子创建独立列表，输入与各结果之间都不会共享可变路径；
- 不修改 `nums`，同一个输入可以多次调用。

## 测试用例

覆盖官方示例、负数与 n=4 的排列，并与标准库核对约束上界 n=6 的全部 720 个结果；另验证单元素结果不会与输入共享列表：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：[1,2,3] 的全部 6 个排列 ----
    assert sorted(solution.permute([1, 2, 3])) == [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]

    # ---- 官方示例 2：[0,1] 两个排列 ----
    assert sorted(solution.permute([0, 1])) == [[0, 1], [1, 0]]

    # ---- 官方示例 3：单元素只有自身 ----
    assert sorted(solution.permute([1])) == [[1]]

    # ---- 多元素：4 个互异数 -> 4! = 24 个排列，且含完全逆序的一个 ----
    result_4 = sorted(solution.permute([1, 2, 3, 4]))
    assert len(result_4) == 24
    assert [4, 3, 2, 1] in result_4

    # ---- 结果必须独立于输入，单元素也不能直接返回输入列表的引用 ----
    nums = [1]
    result = solution.permute(nums)
    result[0][0] = 9
    assert nums == [1]

    # ---- 约束上界：与标准库的全部 720 个排列逐项核对，兼查重复和漏解 ----
    from itertools import permutations

    nums = list(range(6))
    result = solution.permute(nums)
    assert sorted(map(tuple, result)) == list(permutations(nums))
    assert nums == list(range(6))

    # ---- 含负数：互异性与符号无关，仍是 3! = 6 个 ----
    assert sorted(solution.permute([0, -1, 1])) == [
        [-1, 0, 1],
        [-1, 1, 0],
        [0, -1, 1],
        [0, 1, -1],
        [1, -1, 0],
        [1, 0, -1],
    ]
```

`uv run pytest top150/backtracking/top150_46.py` 全部通过。

## 总结

- 排列与组合的分水岭是「顺序是否有意义」：组合（77 题）靠 start 指针只向后枚举天然去重；排列每层从头枚举，靠 used 标记防复用；
- 共享 path 与 used 数组完成「选择 → 递归 → 撤销」，叶子处复制路径，辅助空间 O(n)；
- 标准写法是 used 数组回溯（另有交换法、`itertools.permutations` 等替代）：`n <= 6` 时 n! 至多 720，任何正确写法都轻松通过——把决策树写清楚，比写巧更重要。
