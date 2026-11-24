---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3411: 最长乘积等价子数组"
categories: LeetCode
tags: [简单, 数组, 枚举, 数学]
---

> 两个正整数的乘积恒等于它们的最大公因数乘以最小公倍数。到了三个数，这个等式就可能失效。例如 2、3、4 的乘积为 24，而最大公因数与最小公倍数相乘只有 12。

## 题目

给定正整数数组 `nums`，求最长连续子数组的长度，使区间内所有元素的乘积恰好等于它们的最大公因数与最小公倍数之积。数组有 2 到 100 个元素，每个元素在 1 到 10 之间。[LeetCode 3411. Maximum Subarray With Equal Products（简单）](https://leetcode.cn/problems/maximum-subarray-with-equal-products/description/)

### 示例

```text
[1, 2, 1, 2, 1, 1, 1] → 5
[2, 3, 4, 5, 6]       → 3
[1, 2, 3, 1, 4, 5, 1] → 5
```

第一组的末尾五个数是 `[1, 2, 1, 1, 1]`。它们的乘积为 2，最大公因数为 1，最小公倍数为 2，恰好满足等式。两个长度为 6 的区间和整个数组都包含两个 2，乘积变成 4，而最小公倍数仍为 2。

## 解题思路

固定左端点，让右端点每次向右移动一格。设当前区间的乘积、最大公因数和最小公倍数分别为 `product`、`divisor` 和 `multiple`。加入一个新数 `x` 后，只需做三次更新。

| 区间量 | 加入 x 后的值 |
| --- | --- |
| 乘积 | `product * x` |
| 最大公因数 | `gcd(divisor, x)` |
| 最小公倍数 | `lcm(multiple, x)` |

对第二组示例，从元素 3 开始。窗口扩展到 `[3, 4, 5]` 时，乘积为 60，最大公因数为 1，最小公倍数为 60，可以用长度 3 更新答案。再加上 6，乘积变成 360，而最小公倍数仍为 60，这次保留已有答案。

### 为什么从长度 2 开始

对任意相邻的正整数 `a, b`，都有 `a * b == gcd(a, b) * lcm(a, b)`。题目保证至少有两个数，因此答案可以初始化为 2。外层循环覆盖每一个起点，内层依次检查从该点出发的所有长度至少为 2 的区间，最长的合法区间一定会被检查到。

### 复杂度分析

长度为 `n` 的数组共有 `n(n-1)/2` 个长度至少为 2 的区间。按常数时间整数运算计，时间复杂度为 `O(n²)`，算法使用常数个变量。若按实际存储的位数计，乘积至多为 `10ⁿ`，占用 `O(n)` 位。Python 的整数能精确表示题目上限对应的乘积 `10¹⁰⁰`。

## 代码实现

```python
from math import gcd, lcm


class Solution:
    def maxLength(self, nums: list[int]) -> int:
        best = 2
        for left, first in enumerate(nums):
            product = divisor = multiple = first
            for right in range(left + 1, len(nums)):
                value = nums[right]
                product *= value
                divisor = gcd(divisor, value)
                multiple = lcm(multiple, value)
                if product == divisor * multiple:
                    best = max(best, right - left + 1)
        return best
```

### 代码解析

当窗口只有一个元素 `first` 时，三个区间量的初值都等于它。内层每次先把 `nums[right]` 纳入计算，再判断等式，因此比较的三个量始终对应同一段闭区间，长度为 `right - left + 1`。

## 测试用例

```python
solution = Solution()
assert solution.maxLength([6, 6]) == 2
assert solution.maxLength([4, 9, 5, 7]) == 4
assert solution.maxLength([1] * 100) == 100
assert solution.maxLength([10] * 100) == 2
```

最后两个用例的长度相同，但答案相差很大。一串 1 的三个区间量始终为 1。一串 10 的最大公因数和最小公倍数都为 10，只有选两个数时，乘积才等于 100。

## 总结

两数恒等式给出了答案的下界。固定左端点并沿用上一轮的三个区间量后，即使数组达到 100 项，也只需检查 4950 个区间。
