---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3420: 统计 K 次操作以内得到的非递减子数组数目"
categories: LeetCode
tags: [困难, 单调栈, 滑动窗口, 队列]
---

> 从右向左加入新元素时，只会抬高右侧较小的值；用双端队列记录等高段，就能同时处理左端合并和右端收缩，在线性时间内统计合法子数组。

## 题目

LeetCode 3420. Count Non-Decreasing Subarrays After K Operations（统计 K 次操作以内得到的非递减子数组数目）

Difficulty: **Hard**

给你一个长度为 `n` 的整数数组 `nums` 和一个整数 `k`。对于 `nums` 的每一个子数组，可以进行**至多** `k` 次操作，每次操作可以把子数组中任意一个元素加 1（各子数组相互独立，修改不保留）。返回经过至多 `k` 次操作后能变成**非递减**的子数组数目。

约束：

- `1 <= nums.length <= 10^5`
- `1 <= nums[i] <= 10^9`
- `1 <= k <= 10^9`

### 示例

```text
输入：nums = [6,3,1,2,4,4], k = 7
输出：17
解释：全部 21 个子数组中，只有 [6,3,1]、[6,3,1,2]、[6,3,1,2,4]、[6,3,1,2,4,4]
（代价 8/12/14/16 超过 7）无法达成，21 - 4 = 17。
```

```text
输入：nums = [6,3,1,3,6], k = 4
输出：12
```

## 解题思路

### 转化一：单个子数组的最小代价

每次操作是「某个元素 +1」。让子数组非递减的最优策略：**从左到右把每个元素抬到它左侧的前缀最大值**。记 `mx(i) = max(nums[l..i])`，代价 = `Σ (mx(i) - nums[i])`（左端点自己免费）。

为什么最优？任何合法结果逐点 `≥` 前缀最大值（归纳可证），该代价是下界且可达。例如 `[6,3,1,2]` 抬成 `[6,6,6,6]`，代价 `3+5+4 = 12`。

### 转化二：方向反过来做滑动窗口

正面（固定右端、左端右移）的代价更新很别扭——左端移除一个「前缀最大值」会连带改变后面一片元素的高度。技巧是**反向**：

- 左端 `i` 从右往左扫，右端 `j` 只会单调左移；
- 新元素 `num` 从左侧进入时，迫使它右侧所有调整值比它小的元素抬高——**窗口向左扩时代价只增不减**，双指针成立。

### 转化三：单调双端队列维护「调整后的窗口形态」

队列存 `(值, 个数)` 分段，**back 是窗口左端（进元素侧），front 是右端（收缩侧）**，从 back 到 front 值非递减（与调整后数组从左到右的顺序一致）：

- **进**（`num` 加入左侧）：back 侧所有值 `< num` 的段都要抬到 `num`——逐段弹出，`cost += (num - 值) × 个数`，最后合并成一段 `(num, 总个数)` 压回；
- **出**（`cost > k` 收缩右侧）：最右元素被抬到了 `front` 段的值，退回 `front值 - nums[j]`，段个数减一（减到 0 弹出），`j--`。

每个左端 `i` 收缩完毕后累加 `j - i + 1`（合法右端点个数）。

### 手算示例 1（nums = [6,3,1,2,4,4], k = 7）

| i | 进入后窗口（调整形态） | cost | 收缩后 j | 计入个数 |
|---|----------------------|------|---------|---------|
| 5 | [4] | 0 | 5 | 1 |
| 4 | [4,4] | 0 | 5 | 2 |
| 3 | [2,4,4] | 0 | 5 | 3 |
| 2 | [1,2,4,4] | 0 | 5 | 4 |
| 1 | [3,3,3,4,4]（1、2 抬到 3） | 3 | 5 | 5 |
| 0 | [6,6,6,6,6,6]（+9+2+2） | 16 → 连缩 4 次到 3 | 1 | 2 |

答案 `1+2+3+4+5+2 = 17` ✓。

### 复杂度分析

- 时间复杂度：`O(n)`——每次外层循环新增一段，每段至多从 back 被合并弹出一次；收缩时 j 总共左移至多 n 次；
- 空间复杂度：`O(n)`；
- 数值安全：代价上限约 `10^5 × 10^9 = 10^14`，答案上限 `n(n+1)/2 ≈ 5×10^9`——Python 大整数无忧，C++ 版必须 `long long`。

## 代码实现

```python
from collections import deque


class Solution:
    def countNonDecreasingSubarrays(self, nums: list[int], k: int) -> int:
        ans = 0
        cost = 0
        # (调整后的值, 覆盖的连续元素个数)：back 是窗口左端（新元素进入侧），
        # front 是右端（超预算弹出侧）；从 back 到 front 值非递减
        dq: deque[tuple[int, int]] = deque()

        j = len(nums) - 1
        for i in range(len(nums) - 1, -1, -1):
            num = nums[i]
            count = 1
            # 新元素从左侧进入：所有比它小的段（都在 back 侧）抬高到 num
            while dq and dq[-1][0] < num:
                next_num, next_count = dq.pop()
                count += next_count
                cost += (num - next_num) * next_count
            dq.append((num, count))

            # 代价超预算：从右侧收缩窗口
            while cost > k:
                right_num, right_count = dq.popleft()
                cost -= right_num - nums[j]
                j -= 1
                if right_count > 1:
                    dq.appendleft((right_num, right_count - 1))

            ans += j - i + 1

        return ans
```

### 代码解析

- 队列里存的是「窗口调整后的形态」而非原始值：一次合并形成的等高段记录为 `(值, 个数)`。本实现用 `< num`，允许相邻等高段并存；加入按段合并，收缩则每次移除一个元素；
- 进元素在 back 侧弹小段（它们被迫抬高），出元素在 front 侧退账（它被抬的高度 = front 值 - 原值）——两端各司其职，所以必须是**双端**队列；
- `count` 合并逻辑：新元素与被它抬高的所有段最终值相同，压成一段，下轮再统一处理；
- 溢出是 C++ 版的隐形坑：`cost` 与 `ans` 都超 int32，需 `long long`。

## 测试用例

覆盖两个官方示例、单元素、已有序列 k=0、严格递减 k=0、全相等、预算无穷：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：21 个子数组中 4 个超预算，21 - 4 = 17 ----
    assert solution.countNonDecreasingSubarrays([6, 3, 1, 2, 4, 4], 7) == 17

    # ---- 官方示例 2 ----
    assert solution.countNonDecreasingSubarrays([6, 3, 1, 3, 6], 4) == 12

    # ---- 最小规模：单元素零代价 ----
    assert solution.countNonDecreasingSubarrays([5], 1) == 1

    # ---- 已经非递减：所有子数组都免费 ----
    assert solution.countNonDecreasingSubarrays([1, 2, 3, 4], 0) == 10

    # ---- 严格递减 + k=0：只有单元素子数组 ----
    assert solution.countNonDecreasingSubarrays([4, 3, 2, 1], 0) == 4

    # ---- 全相等：k=0 即可全部非递减 ----
    assert solution.countNonDecreasingSubarrays([2, 2, 2], 0) == 6

    # ---- 预算极大：全部子数组合法 ----
    assert solution.countNonDecreasingSubarrays([6, 3, 1, 2, 4, 4], 10**9) == 21
```

提交前用 O(n²) 朴素版（逐个子数组按前缀最大值算代价）随机对照 2000 组，与单调队列版结果全部一致。

## 总结

- 三个转化层层递进：最小代价 = 抬到前缀最大值 → 窗口反向单调 → 单调双端队列按段维护「调整后形态」；
- 进（back 弹小段抬值）与出（front 退账）两端分工，每个元素 O(1) 均摊，总 O(n)；
- Hard 的难度在构造而非代码量：认出「加法操作的最优形态是抬到前缀最大」是第一道门，反向滑窗是第二道。
