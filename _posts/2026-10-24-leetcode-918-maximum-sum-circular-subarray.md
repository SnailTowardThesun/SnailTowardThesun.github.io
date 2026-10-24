---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.918: 环形子数组的最大和"
categories: LeetCode
tags: [中等, 数组, 动态规划]
---

> 环形数组是工程常客：音视频缓冲区、时间轮定时器都是首尾相接的 ring buffer。处理跨越边界的区间有个经典技巧——取补集：跨环的一段，恰好等于整圈减去中间不跨环的一段。

## 题目

LeetCode 918. Maximum Sum Circular Subarray（环形子数组的最大和）

Difficulty: **Medium**

给定一个长度为 `n` 的环形整数数组 `nums`，返回 `nums` 的**非空**子数组的最大可能和。

环形数组意味着数组的末端将会与开头相连呈环状：`nums[i]` 的下一个元素是 `nums[(i + 1) % n]`，前一个元素是 `nums[(i - 1 + n) % n]`。子数组最多只能包含固定缓冲区 `nums` 中的每个元素一次。

### 示例

```
输入：nums = [1,-2,3,-2]
输出：3
解释：从子数组 [3] 得到最大和 3

输入：nums = [5,-3,5]
输出：10
解释：从子数组 [5,5] 得到最大和 10

输入：nums = [-3,-2,-3]
输出：-2
解释：从子数组 [-2] 得到最大和 -2
```

## 解题思路

### 两种形态，分别求最大

把环拉直后，一个环形子数组只可能是下面两种形态之一：

1. **不跨环**：就是一段普通的连续子数组，用 Kadane 算法一趟求出最大子数组和 `best_max`——这正是 No.53 的原题；
2. **跨环**：子数组由"数组后缀 + 数组前缀"拼接而成。它的**补集**是中间一段连续的、不跨环的子数组。要让跨环部分的和最大，就要让被挖掉的中间那段和最小，所以跨环最大和 = `total - best_min`，其中 `best_min` 是最小子数组和，把 Kadane 里的 `max` 换成 `min` 就能求出。

答案就是两者取较大：`max(best_max, total - best_min)`。`best_max`、`best_min`、`total` 三个量互不依赖，可以在**同一次遍历**中滚动维护。

### 一个必须单独处理的边界

当数组**全为负数**时，最小子数组就是整个数组，`best_min == total`，于是 `total - best_min == 0`——这个 0 对应的是"把所有元素都挖掉"的**空子数组**，而题目要求非空。此时正确答案是最大的那个负数，也就是 `best_max`。

判定条件非常简洁：只要 `best_max < 0`，数组必然全负（否则任何一个非负元素都会让 `best_max >= 0`），直接返回 `best_max` 即可。

反过来也要确认公式在其余情况下不会"误伤"：若 `best_max >= 0`，哪怕最小子数组恰好是整个数组，`total - best_min` 也只是 0，不会超过 `best_max`，因此不会把空子数组误选为答案。

### 手算示例

以 `nums = [5, -3, 5]` 为例（`cur` 为以当前元素结尾的最优值）：

| 元素 | cur_max | best_max | cur_min | best_min | total |
|------|---------|----------|---------|----------|-------|
| 5    | 5       | 5        | 5       | 5        | 5     |
| -3   | 2       | 5        | -3      | -3       | 2     |
| 5    | 7       | 7        | 2       | -3       | 7     |

不跨环最优为 7（整个数组），跨环最优为 `total - best_min = 7 - (-3) = 10`（挖掉中间的 -3，首尾两个 5 相接），答案 10。

再看全负的 `[-3, -2, -3]`：`best_max = -2`，`best_min = total = -8`，`total - best_min = 0` 是空子数组的和，被 `best_max < 0` 的判定拦下，返回 -2。

### 复杂度分析

- **时间复杂度**：O(n)，只遍历数组一次。
- **空间复杂度**：O(1)，仅用常数个滚动变量。

## 代码实现

```python
class Solution:
    def maxSubarraySumCircular(self, nums: list[int]) -> int:
        # cur_max / cur_min：以当前元素结尾的最大 / 最小子数组和（Kadane 滚动变量）
        cur_max = best_max = cur_min = best_min = total = nums[0]
        for x in nums[1:]:
            cur_max = max(x, cur_max + x)
            best_max = max(best_max, cur_max)
            cur_min = min(x, cur_min + x)
            best_min = min(best_min, cur_min)
            total += x

        # 全负时 total − best_min == 0 对应空子数组，题目要求非空，只能取不跨环的 best_max
        if best_max < 0:
            return best_max
        return max(best_max, total - best_min)
```

### 代码解析

- **五个变量全部用 `nums[0]` 初始化**，再从第二个元素开始遍历——这是 Kadane 的标准写法，全负数组时不会被错误的 0 初值干扰；
- **最大、最小两套 Kadane 共用一次循环**，每一步先更新"以当前元素结尾"的 `cur_*`，再用它刷新全局 `best_*`，顺序不能颠倒；
- **`best_max < 0` 是全负数组的充要条件**，用它守住"空子数组"这一边界后，最后一行的 `max` 才是安全的。

## 测试用例

```python
import random


def _brute_answer(nums: list[int]) -> int:
    """O(n^2) 暴力：枚举环上每个起点、长度 1..n 的所有子数组，作为对拍真值。"""
    n = len(nums)
    best = nums[0]
    for start in range(n):
        acc = 0
        for length in range(1, n + 1):
            acc += nums[(start + length - 1) % n]
            best = max(best, acc)
    return best


s = Solution()

# 官方示例：不跨环 / 跨环 / 全负
assert s.maxSubarraySumCircular([1, -2, 3, -2]) == 3
assert s.maxSubarraySumCircular([5, -3, 5]) == 10
assert s.maxSubarraySumCircular([-3, -2, -3]) == -2

# 全负陷阱：total − best_min = 0 对应空子数组，不能取
assert s.maxSubarraySumCircular([-2, -3, -1]) == -1

# 答案必须跨环
assert s.maxSubarraySumCircular([8, -1, 3, 4]) == 15  # 3+4+8，绕过中间的 -1
assert s.maxSubarraySumCircular([-2, 4, -5, 4, -5, 9, 4]) == 15  # 挖掉中段 [-5,4,-5]

# 含 0：答案为 0 而非负数
assert s.maxSubarraySumCircular([-1, 0, -1]) == 0

# 题目上限，兼作 O(n) 冒烟检查
assert s.maxSubarraySumCircular([30000] * 30000) == 900_000_000

# 随机对拍：300 组长度 1~8 的数组与暴力真值逐一比对
random.seed(42)
for _ in range(300):
    nums = [random.randint(-10, 10) for _ in range(random.randint(1, 8))]
    assert s.maxSubarraySumCircular(nums) == _brute_answer(nums)
```

用例设计围绕三个最容易出错的地方：**全负数组**是否误返回 0、**答案跨环**时是否真的走到了 `total - best_min` 分支、以及**含 0 的数组**答案应为 0 而非负数。暴力函数直接按题意枚举环上所有起点和长度，与被测实现互为印证，随机对拍能覆盖手写用例想不到的组合。

## 总结

- 环形子数组只有"不跨环"和"跨环"两种形态，前者是标准 Kadane，后者借补集转化为"总和减最小子数组和"，一次遍历同时搞定；
- 唯一的坑是全负数组：`total - best_min` 会得到对应空子数组的 0，用 `best_max < 0` 判定后直接返回 `best_max`；
- 把"跨越边界的区间"转化为"整体减去不跨边界的补集"，是处理环形结构的通用思路，值得记住。
