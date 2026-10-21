---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.295: 数据流的中位数"
categories: LeetCode
tags: [困难, 堆, 设计, 数据流]
---

> 双堆对劈是流式中位数的经典解法：大顶堆扛较小一半、小顶堆扛较大一半，两堆顶正好卡在中位数的「腰部」。同样的套路还见于滑动窗口中位数、实时 P50 监控指标等场景。

## 题目

LeetCode 295. Find Median from Data Stream（数据流的中位数）

Difficulty: **Hard**

**中位数**是有序整数列表中的中间值。如果列表的长度为偶数，则中位数是中间两个数的平均值。

实现 `MedianFinder` 类：

- `MedianFinder()` 初始化 `MedianFinder` 对象。
- `addNum(int num)` 从数据流中添加一个整数到数据结构中。
- `findMedian()` 返回目前所有元素的中位数。

### 示例

```
输入：
["MedianFinder", "addNum", "addNum", "findMedian", "addNum", "findMedian"]
[[], [1], [2], [], [3], []]
输出：
[null, null, null, 1.5, null, 2.0]
解释：
插入 1、2 后中位数为 (1 + 2) / 2 = 1.5；再插入 3 后中位数为 2。
```

## 解题思路

### 为什么排序不行

每次查询前把已有元素排序取中间：单次 `O(n log n)`，`k` 次查询累计 `O(k * n log n)`；插入挪动数组也是 `O(n)`。数据流场景下代价太高。

### 双堆对劈（对顶堆）

用两个堆把流「对半劈开」，中位数永远在两个堆顶：

1. `queue_min` 存**较小的一半**，存取负的值，用小顶堆模拟大顶堆，堆顶即较小一半的最大值；
2. `queue_max` 存**较大的一半**，普通小顶堆，堆顶即较大一半的最小值；
3. 插入时按「新数与下半堆顶比较」决定入哪个堆，入堆后**立即回搬**维持不变式：

```
len(queue_min) == len(queue_max)      （总数偶数）
len(queue_min) == len(queue_max) + 1  （总数奇数）
```

查询时：奇数取下半堆顶（取负还原），偶数取两堆顶平均——都是 `O(1)`。

### 手算示例

插入 `1, 2, 3`：下半 `{1}`、上半 `{}` → 上半 `{2}` → `3 ≥ 1` 入上半后上半变多，把堆顶 `2` 回搬下半。最终下半 `{1,2}`、上半 `{3}`，总数奇数，中位数 = 下半堆顶 = `2`。

### 复杂度分析

| 解法 | addNum | findMedian | 空间 |
|------|--------|-----------|------|
| 每次排序 | `O(log n)` 查找 + `O(n)` 挪动 | `O(1)` | `O(n)` |
| 双堆 | `O(log n)` | `O(1)` | `O(n)` |

## 代码实现

```python
import heapq


class MedianFinder:
    def __init__(self):
        self.queue_min = []
        self.queue_max = []

    def addNum(self, num: int) -> None:
        if len(self.queue_min) < 1 or num < 0 - self.queue_min[0]:
            heapq.heappush(self.queue_min, 0 - num)
            if len(self.queue_max) + 1 < len(self.queue_min):
                heapq.heappush(self.queue_max, 0 - heapq.heappop(self.queue_min))
        else:
            heapq.heappush(self.queue_max, num)
            if len(self.queue_max) > len(self.queue_min):
                heapq.heappush(self.queue_min, 0 - heapq.heappop(self.queue_max))

    def findMedian(self) -> float:
        if len(self.queue_min) > len(self.queue_max):
            return 0 - self.queue_min[0]

        return (0 - self.queue_min[0] + self.queue_max[0]) / 2.0
```

### 代码解析

- **取负模拟大顶堆**：`heapq` 只有小顶堆，较小一半存 `0 - num`，堆顶取负还原即是较小一半的最大值；
- **双向回搬**：入下半后若下半多出超过 1 个，搬堆顶给上半；入上半后若上半反超，搬堆顶给下半——不变式两个方向都被守住（只写单向平衡，递增流会全部堆进上半导致中位数算错）；
- **两个堆顶即答案**：奇数长度下半多 1 个元素，堆顶就是中位数；偶数长度两堆等大，两堆顶取平均。

## 测试用例

```python
def _naive_median(nums: list[int]) -> float:
    """朴素参照解法：排序后取中位数，仅用于对拍。"""
    s = sorted(nums)
    n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def test_median_finder() -> None:
    # 官方示例 1：偶数取平均、奇数取中间
    mf = MedianFinder()
    mf.addNum(1)
    mf.addNum(2)
    assert mf.findMedian() == 1.5
    mf.addNum(3)
    assert mf.findMedian() == 2

    # 官方示例 2：负数流，每插一个查一次
    mf = MedianFinder()
    for x, expect in [(-1, -1.0), (-2, -1.5), (-3, -2.0), (-4, -2.5), (-5, -3.0)]:
        mf.addNum(x)
        assert mf.findMedian() == expect

    # 边界：单元素 / 全相同 / 极值 ±1e5
    ...

    # 随机对拍：5 轮 x 500 次插入查询交错，与朴素解法逐次对照
    ...


test_median_finder()
```

完整测试见题解文件 `top150_295.py`，其中随机对拍部分在 500 次交错操作中逐次校验与「排序取中位数」的一致性——开发过程中它确实抓到过一个只做单向平衡的 bug。

## 总结

- 对顶堆把「动态中位数」化为两个堆顶的 `O(1)` 读取，插入 `O(log n)`；
- 不变式必须**双向维护**：下半至多多 1 个，上半不得反超，缺一个方向递增/递减流就会翻车；
- 「测试先行 + 随机对拍」对这类状态型数据结构题尤其值钱：官方示例只覆盖前几步，长流才能暴露平衡缺陷。
