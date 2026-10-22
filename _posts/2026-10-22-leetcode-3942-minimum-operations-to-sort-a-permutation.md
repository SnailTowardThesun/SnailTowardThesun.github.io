---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3942: 排序排列的最少操作数"
categories: LeetCode
tags: [中等, 数组, 分类讨论, 数学]
---

> 旋转 + 翻转生成的不是全排列，而是二面体群 D_n 的 2n 个状态——这就是为什么大多数排列在这两种操作下根本无解：从 0 出发沿环要么向右递增、要么向左递增，二者必居其一才排得成。

## 题目

LeetCode 3942. Minimum Operations to Sort a Permutation（排序排列的最少操作数）

Difficulty: **Medium**

给你一个长度为 `n` 的整数数组 `nums`，其中 `nums` 是区间 `[0..n-1]` 中所有数字的一个**排列**。

你**只能**执行以下操作：

- **反转**整个数组。
- **左旋一位**：将第一个元素移动到数组末尾，其余元素整体向左移动一位。

返回将数组按**递增**顺序排序所需的**最少**操作次数。如果仅使用给定操作无法将数组排序，则返回 `-1`。

### 示例

```
输入：nums = [0,2,1]
输出：2
解释：左旋一位得 [2,1,0]，再反转为 [0,1,2]。

输入：nums = [1,0,2]
输出：2
解释：先反转得 [2,0,1]，再左旋一位得 [0,1,2]。

输入：nums = [2,0,1,3]
输出：-1
```

## 解题思路

### 先想清楚能到达哪些状态

旋转的复合还是旋转，再叠加一次翻转，能到达的状态一共只有 `2n` 种：`n` 个旋转态 × 翻转与否。所以绝大多数排列**无解**——判可行性才是第一问。

把数组看成环。一个排列能被排成递增，当且仅当**从 0 出发沿环的某个方向环序递增**：

- 向右（步长 `+1`）环序递增：从 `0, 1, 2, ...` 顺次排布在环上；
- 向左（步长 `-1`）环序递增：等价于环反方向上是 `0, 1, 2, ...`。

### 找 0 的位置，构造两个环序切片

设 `zero = nums.index(0)`（排列的最小值就是 0），两个切片都以 0 开头：

```python
right = nums[zero:] + nums[:zero]          # 从 0 向右走
left  = nums[zero::-1] + nums[:zero:-1]    # 从 0 向左走
```

切片是否「递增」用一次线性扫描判断即可。

### 四种策略与代价

| 环序方向 | 策略 | 代价 |
|---------|------|------|
| 向右递增 | 直接左旋 `zero` 位把 0 转到开头 | `zero` |
| 向右递增 | 反转 → 左旋 `n-zero` 位 → 再反转 | `n - zero + 2` |
| 向左递增 | 左旋 `zero+1` 位把 0 送到末尾 → 反转 | `zero + 2` |
| 向左递增 | 反转 → 左旋 `n-zero-1` 位 | `n - zero` |

每个合法方向各贡献两个候选，全部取最小；两个方向都不递增则返回 `-1`。

### 手算示例 1

`nums = [0,2,1]`，`zero = 0`：向右环序 `0,2,1` 不递增；向左环序 `0,1,2` 递增 ✓。候选 `zero+2 = 2`、`n-zero = 3`，答案 **2**（左旋一位 + 反转）。

### 复杂度分析

构造切片与两次线性扫描均为 `O(n)`；用下标取模代替切片可把空间做到 `O(1)`。

## 代码实现

```python
from itertools import pairwise


class Solution:
    def is_monotonic_one_pass(self, a: list[int]) -> bool:
        inc = dec = True
        for x, y in pairwise(a):
            inc &= x <= y
            dec &= x >= y
            if not inc and not dec:  # 两个方向都破产,提前判乱序
                return False
        return inc or dec

    def minOperations(self, nums: list[int]) -> int:
        n = len(nums)
        zero = nums.index(0)  # 排列的 min 就是 0,一次定位

        # 从 0 出发沿环两个方向的环序（两个切片都以 0 开头，降序分支自动失活）
        right = nums[zero:] + nums[:zero]  # 向右走（步长 +1）
        left = nums[zero::-1] + nums[:zero:-1]  # 向左走（步长 -1）

        ans = n + 1  # 哨兵：任何合法方向至少给出一个 <= n 的候选
        if self.is_monotonic_one_pass(right):
            # 向右递增：直接左旋 zero 位 / 反转 + 左旋 (n-zero) 位 + 再反转
            ans = min(ans, zero, n - zero + 2)
        if self.is_monotonic_one_pass(left):
            # 向左递增：左旋 (zero+1) 位把 0 送到末尾再反转 / 反转 + 左旋 (n-zero-1) 位
            ans = min(ans, zero + 2, n - zero)

        return -1 if ans == n + 1 else ans
```

### 代码解析

- **`is_monotonic_one_pass` 复用**：虽然它双向判序，但两个切片都以全局最小值 0 开头，非递增分支永远不可能成立，不会误判，反而省去单独写一个递增判断；
- **向左切片的写法**：`nums[zero::-1] + nums[:zero:-1]`，第二段是「下标 `n-1` 降到 `zero+1`」——曾误写成 `nums[:zero][::-1]`（下标 `zero-1` 降到 0，与第一段重复访问且产生重复元素），导致无解样例被判可行，被对拍当场抓获；
- **哨兵 `n + 1`**：任一合法方向必然贡献一个 `<= n` 的候选（`zero` 或 `n - zero`），所以哨兵安全。

## 测试用例

```python
s = Solution()
assert s.minOperations([0, 2, 1]) == 2   # 官方示例 1：左旋 + 反转
assert s.minOperations([1, 0, 2]) == 2   # 官方示例 2：反转 + 左旋
assert s.minOperations([2, 0, 1, 3]) == -1  # 官方示例 3：不可行
assert s.minOperations([0]) == 0         # 单元素已有序
```

另做了 300 组随机排列（`n <= 8`）与 BFS 暴力的对拍：暴力在真实操作状态空间（反转 / 左旋一位生成的全部状态）里搜出最少步数，与公式解逐组对照一致——同时验证了可行性判定与四个代价公式。

## 总结

- 旋转 + 翻转只能触达 `2n` 个状态，可行性判定归结为「从 0 出发沿环某方向环序递增」；
- 每个合法方向对应「纯旋转」与「借助反转」两条策略，代价都能由 `zero` 直接算出，无需模拟；
- 公式题最怕切片/边界笔误，BFS 对拍在状态空间里求真值，是最划算的保险。
