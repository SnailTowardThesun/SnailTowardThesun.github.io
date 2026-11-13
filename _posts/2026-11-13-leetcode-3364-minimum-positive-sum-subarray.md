---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3364: 最小正和子数组"
categories: LeetCode
tags: [简单, 数组, 滑动窗口]
---

> 枚举子数组时维护增量：右端每移一位只加一个元素，把每个子数组和的求值代价从 O(长度) 降到 O(1)。这个小习惯是所有子数组题的基本功。

## 题目

LeetCode 3364. Minimum Positive Sum Subarray（最小正和子数组）

Difficulty: **Easy**

给你一个整数数组 `nums` 和两个整数 `l` 和 `r`。找到一个长度在 `[l, r]` 之间（含边界）且**和大于 0** 的子数组，返回其最小和；不存在这样的子数组返回 `-1`。

约束：

- `1 <= nums.length <= 100`
- `-1000 <= nums[i] <= 1000`
- `1 <= l <= r <= nums.length`

### 示例

```text
输入：nums = [3,-2,1,4], l = 2, r = 3
输出：1
解释：长度 2 的子数组 [3,-2] 和为 1，是所有和为正的子数组中最小的。
```

```text
输入：nums = [-2,2,-3,1], l = 2, r = 3
输出：-1
解释：所有长度 2/3 的子数组和都 <= 0。
```

```text
输入：nums = [1,2,3,4], l = 2, r = 3
输出：3
解释：[1,2] 和为 3 最小。
```

## 解题思路

### 从暴力到增量

最直觉的写法是双重循环枚举所有 `(左端 i, 右端 j)`，每个子数组用 `sum(nums[i:j])` 求和：

```python
for i in range(n):
    for j in range(i + l, min(n + 1, i + r + 1)):
        tmp = sum(nums[i:j])   # 切片复制 + 再遍历，每次 O(长度)
```

正确但浪费：固定左端 `i` 时，`j` 每右移一位，窗口只多一个元素——和值只需加一个数。这就是**增量求和**：

1. 左端 `i` 从 `0` 到 `n - l`（长度 `l` 的窗口放得下为止）；
2. 先算长度恰为 `l` 的起始窗口和，之后右端每扩一位 `s += nums[j]`，单次 O(1)；
3. 用 `inf` 做哨兵：`0 < s < ret` 链式比较一步完成「是正数且更小」的判定；
4. 扫完哨兵未更新则返回 `-1`。

### 手算示例 1（nums = [3,-2,1,4], l = 2, r = 3）

| 子数组 | 长度 | 和 |
|--------|------|-----|
| [3,-2] | 2 | 1 ← 最小正和 |
| [-2,1] | 2 | -1 |
| [1,4] | 2 | 5 |
| [3,-2,1] | 3 | 2 |
| [-2,1,4] | 3 | 3 |

答案 1。

### 复杂度分析

- 时间复杂度：`O(n·r)`——候选子数组总数级别（原暴力为 `O(n²·r)`，差一个「每次重算长度」的因子）；
- 空间复杂度：`O(1)`——增量法不需要前缀和数组。

`O(n·(r-l+1))` 已是本题的标准复杂度：长度在 `[l, r]` 内的候选本来就有这么多，逐个检查和值就是全部工作量，排序等花活没有收益。

## 代码实现

```python
from math import inf


class Solution:
    def minimumSumSubarray(self, nums: list[int], l: int, r: int) -> int:
        ret = inf
        n = len(nums)
        for i in range(n - l + 1):
            # 长度恰为 l 的起始窗口，之后每扩一位只加一个元素
            s = sum(nums[i : i + l])
            if 0 < s < ret:
                ret = s
            for j in range(i + l, min(n, i + r)):
                s += nums[j]
                if 0 < s < ret:
                    ret = s

        return ret if ret < inf else -1
```

### 代码解析

- 增量求和是核心：`sum(nums[i:j])` 每次要「切片复制 + 重新遍历」两遍长度，而 `s += nums[j]` 只碰一个元素——`n = r = 100` 时约 **10⁶ 次元素访问降到 10⁴ 次**；
- 循环边界 `range(n - l + 1)` 把「窗口放得下」的不变式写进 range，循环体里不再需要 `if i + l > n: break`；
- `inf` 哨根天然大于一切正数，`0 < s < ret` 把「正数且更小」两个条件链在一个表达式里，免去 `ret == -1` 的特判分支；
- 若需要随机访问任意区间和，等价方案是前缀和 `pre[j] - pre[i]`；本题顺次扫描，增量法更省空间。

## 测试用例

覆盖三个官方示例、单元素正/负、`l == r == n`、和为 0 不算正数：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：[3,-2] 和为 1 是最小正和 ----
    assert solution.minimumSumSubarray([3, -2, 1, 4], 2, 3) == 1

    # ---- 官方示例 2：所有合法长度子数组和都 <= 0 ----
    assert solution.minimumSumSubarray([-2, 2, -3, 1], 2, 3) == -1

    # ---- 官方示例 3：[1,2] 和为 3 ----
    assert solution.minimumSumSubarray([1, 2, 3, 4], 2, 3) == 3

    # ---- 最小规模：单元素正数 ----
    assert solution.minimumSumSubarray([5], 1, 1) == 5

    # ---- 单元素负数：无解 ----
    assert solution.minimumSumSubarray([-5], 1, 1) == -1

    # ---- l == r == n：整个数组是唯一候选 ----
    assert solution.minimumSumSubarray([2, -1, 2], 3, 3) == 3

    # ---- 和为 0 不算正数：[1,-1]=0 被跳过，[-1,2]=1 入选 ----
    assert solution.minimumSumSubarray([1, -1, 2], 2, 3) == 1
```

提交前用「逐个子数组重新求和」的朴素版随机对照 2000 组，与增量版结果全部一致。

## 总结

- 固定左端时右端单向扩张，和值增量维护，每个子数组 O(1) 求值，总 `O(n·r)`；
- `inf` 哨兵 + 链式比较替代「首个正和」特判，代码更贴近题意本身；
- Easy 题的教训朴素但通用：别为每个子数组重新求和，也别让调试 print 跟着提交。
