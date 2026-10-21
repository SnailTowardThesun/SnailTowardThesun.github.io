---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.215: 数组中的第K个最大元素"
categories: LeetCode
tags: [中等, 堆, 数组, Top-K]
---

> 大小为 k 的最小堆是「Top-K 问题」的瑞士军刀：海量数据流里求前 k 大无需全排序，内存也只与 k 有关——这正是搜索引擎热榜、推荐系统热门榜单的通用做法。

## 题目

LeetCode 215. Kth Largest Element in an Array（数组中的第K个最大元素）

Difficulty: **Medium**

给定整数数组 `nums` 和整数 `k`，请返回数组中第 **k** 个最大的元素。

请注意，你需要找的是数组排序后的第 `k` 个最大的元素，而不是第 `k` 个不同的元素。

你必须设计并实现时间复杂度为 `O(n)` 的算法解决此问题。

### 示例

```
输入：nums = [3,2,1,5,6,4], k = 2
输出：5

输入：nums = [3,2,3,1,2,4,5,5,6], k = 4
输出：4
```

## 解题思路

### 大小为 k 的最小堆

求第 k 大，等价于维护「至今最大的 k 个元素」：

1. 依次把每个元素压入最小堆；
2. 一旦堆大小超过 `k`，弹出堆顶——堆顶是当前堆里最小的，被淘汰说明它进不了前 k 大；
3. 遍历结束后，堆里恰好是全数组最大的 k 个元素，堆顶（堆内最小值）就是第 k 大。

整个过程堆大小不超过 `k + 1`，与数组总长 `n` 无关。

### 为什么不用排序

整体排序是 `O(n log n)`，而这题只关心前 k 个：堆解法是 `O(n log k)`，当 `k` 远小于 `n`（如千万数据取 Top 100）时差距显著；数据以流式到达时，排序根本不可行，堆却天然支持在线处理。若要严格 `O(n)` 期望时间，可以用快速选择（quickselect）。

### 复杂度分析

| 解法 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| 排序 | `O(n log n)` | `O(log n)` |
| k 小堆 | `O(n log k)` | `O(k)` |
| 快速选择 | `O(n)` 期望 | `O(1)` |

## 代码实现

```python
import heapq


class Solution:
    def findKthLargest(self, nums: list[int], k: int) -> int:
        container = []
        for n in nums:
            heapq.heappush(container, n)

            if len(container) > k:
                heapq.heappop(container)

        return container[0]
```

### 代码解析

- **入堆再判长**：每个元素先入堆，再检查是否超编，逻辑简单且无需特判前 k 个元素；
- **`heapq` 是最小堆**：求「第 k 大」用最小堆淘汰尾部，求「第 k 小」则对称地用最大堆（Python 中存负数模拟）；
- **堆顶即答案**：遍历结束时堆中保留的正是最大的 k 个元素，`container[0]` 就是其中的最小值。

## 测试用例

```python
def test_find_kth_largest():
    s = Solution()
    assert s.findKthLargest([3, 2, 1, 5, 6, 4], 2) == 5
    assert s.findKthLargest([3, 2, 3, 1, 2, 4, 5, 5, 6], 4) == 4
    assert s.findKthLargest([1], 1) == 1  # 单元素边界
```

## 总结

- 「第 k 大」= 维护最大的 k 个元素，最小堆以 `O(n log k)` 在线求解；
- 堆大小只与 k 相关，适合海量数据与流式场景，这是它相对排序的本质优势；
- Top-K 与 373（和最小的 K 对数字）、502（IPO）共享同一思想：不要物化全集，用有界堆增量维护候选。
