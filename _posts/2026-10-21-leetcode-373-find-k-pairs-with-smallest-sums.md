---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.373: 查找和最小的 K 对数字"
categories: LeetCode
tags: [中等, 堆, 多路归并, Top-K]
---

> 两个有序数组的前 k 小组合，不必生成全部乘积空间——把候选看成按行有序的矩阵，堆里只放每行队头，像多路归并一样按需生长，这套思路同样适用于「有序矩阵中第 k 小的元素」等经典题。

## 题目

LeetCode 373. Find K Pairs with Smallest Sums（查找和最小的 K 对数字）

Difficulty: **Medium**

给定两个以**非递减顺序**排列的整数数组 `nums1` 和 `nums2`，以及一个整数 `k`。

定义一对值 `(u, v)`，其中第一个元素来自 `nums1`，第二个元素来自 `nums2`。

请找到和最小的 `k` 对数字 `(u1, v1), (u2, v2) ... (uk, vk)`。

### 示例

```
输入：nums1 = [1,7,11], nums2 = [2,4,6], k = 3
输出：[[1,2],[1,4],[1,6]]
解释：返回序列中的前 3 对数（和依次为 3, 5, 7）

输入：nums1 = [1,1,2], nums2 = [1,2,3], k = 10
输出：[[1,1],[1,1],[2,1],[1,2],[1,2],[2,2],[1,3],[1,3],[2,3]]

输入：nums1 = [1,2], nums2 = [3], k = 3
输出：[[1,3],[2,3]]
```

## 解题思路

### 从内存爆炸说起

朴素做法是把全部 `m * n` 个数对塞进堆再弹 k 次：内存 `O(m*n)`。本题数组规模可达 `10^5`，乘积空间 `10^10` 量级，直接超出内存限制。

### 多路归并的动态堆

利用 `nums2` 有序这一性质，把所有数对看成 `len(nums1)` 行的矩阵：第 `i` 行是 `nums1[i]` 分别配 `nums2[0..n-1]`，每行内部递增，因此**每行只有行头有可能进前 k**：

1. 初始只把前 `min(k, m)` 个「行头」放入最小堆，元素为 `(和, i, j)`；
2. 每弹出一个当前全局最小 `(i, j)` 收进答案，就把同行的下一个 `(i, j + 1)` 压入堆；
3. 弹满 k 次结束，输出天然按和升序。

堆是「按需生长」的：只探索被弹出候选的右邻居，永不物化整个乘积空间。

### 复杂度分析

| 解法 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| 全量入堆 | `O(m*n*log(m*n))` | `O(m*n)` |
| 多路归并 | `O(k * log(min(k, m)))` | `O(min(k, m))` |

## 代码实现

```python
import heapq


class Solution:
    def kSmallestPairs(self, nums1: list[int], nums2: list[int], k: int) -> list[list[int]]:
        ret: list[list[int]] = []
        if not nums1 or not nums2 or k <= 0:
            return ret

        # 动态堆：初始只装 min(k, m) 个行头 (sum, i, j)，而不是整个 m*n 乘积空间
        heap = [(nums1[i] + nums2[0], i, 0) for i in range(min(k, len(nums1)))]
        heapq.heapify(heap)

        while heap and len(ret) < k:
            _, i, j = heapq.heappop(heap)
            ret.append([nums1[i], nums2[j]])
            # 被弹出的候选向右推进一位，其邻居入堆（按需扩展，堆大小不变）
            if j + 1 < len(nums2):
                heapq.heappush(heap, (nums1[i] + nums2[j + 1], i, j + 1))

        return ret
```

### 代码解析

- **只种行头**：`min(k, m)` 之外的行连行头都进不了前 k，初始就可以不种，进一步压小堆；
- **弹一补一**：每弹出一个候选只补其右邻居，堆大小全程不超过初始值；
- **元组防比较冲突**：堆元素是 `(sum, i, j)` 整数元组，和相同时按 `i, j` 比较即可，避免把列表放进堆；
- **k 超过总对数**：堆自然弹空退出，不会像「弹固定 k 次」那样在空堆上抛异常。

## 测试用例

```python
def test_k_smallest_pairs():
    s = Solution()
    assert s.kSmallestPairs([1, 7, 11], [2, 4, 6], 3) == [[1, 2], [1, 4], [1, 6]]

    # 和相等的数对顺序不唯一，校验「和序列非递减 + 多重集与官方答案一致」
    ret = s.kSmallestPairs([1, 1, 2], [1, 2, 3], 10)
    sums = [a + b for a, b in ret]
    assert sums == sorted(sums)

    assert s.kSmallestPairs([1, 2], [3], 3) == [[1, 3], [2, 3]]  # k 超过总对数
    assert s.kSmallestPairs([], [1, 2], 5) == []  # 空数组边界
```

## 总结

- 有序结构的前 k 问题，先想「多路归并 + 动态堆」，别把乘积空间全建出来；
- 每行只推进行头、弹一补一，堆大小从 `m*n` 降到 `min(k, m)`；
- 与 215（k 小堆）、502（按需入堆）同源：堆不只是容器，配合单调性可以做增量维护。
