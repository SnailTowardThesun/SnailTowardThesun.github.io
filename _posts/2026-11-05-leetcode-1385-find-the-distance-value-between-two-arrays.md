---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1385: 两个数组间的距离值"
categories: LeetCode
tags: [简单, 数组, 枚举, 二分查找]
---

> 「距离值」本质是邻域查询：判断 arr2 是否有元素落入 [i-d, i+d]。排序 + 二分正是数据库 B+ 树范围查找的雏形，能把 O(n·m) 的两两比较降到 O((n+m)·log m)。

## 题目

LeetCode 1385. Find the Distance Value Between Two Arrays（两个数组间的距离值）

Difficulty: **Easy**

给你两个整数数组 `arr1` 和 `arr2`，以及一个整数 `d`，请你返回两个数组间的「距离值」。

「距离值」定义为满足此条件的元素数目：对于元素 `arr1[i]`，不存在任何元素 `arr2[j]` 满足 `|arr1[i] - arr2[j]| <= d`。

约束：

- `1 <= arr1.length, arr2.length <= 500`
- `-1000 <= arr1[i], arr2[j] <= 1000`
- `0 <= d <= 100`

### 示例

```text
输入：arr1 = [4,5,8], arr2 = [10,9,1,8], d = 2
输出：2
解释：4 与 arr2 中所有元素的距离都大于 2，符合要求；5 同理；
而 8 与 10 的距离为 2（<= d）、与 8 的距离为 0（<= d），不符合。
```

```text
输入：arr1 = [1,4,2,3], arr2 = [-4,-3,6,10,20,30], d = 3
输出：2
```

## 解题思路

### 换个角度读定义

把定义倒过来读：「不存在任何 `arr2[j]` 满足 `|arr1[i] - arr2[j]| <= d`」等价于「`arr2` 与区间 `[arr1[i]-d, arr1[i]+d]` 没有交集」。也就是说，对每个 `i`，在 arr2 中找它的邻居——邻居区间里只要落进一个元素，`i` 就出局；一个都落不进，`i` 计入答案。

### 暴力枚举 + 提前剪枝

数据范围只有 500 × 500（至多 25 万次比较），最直接的 O(n·m) 双重循环完全够用：

1. 外层遍历 `arr1` 的每个元素 `i`，先假设它符合（`is_match = True`）；
2. 内层扫描 `arr2`，一旦发现 `|i - k| <= d` 立即置 `False` 并 `break`——找到第一个邻居即可否定假设，后面的元素不必再看；
3. 内层结束后仍是 `True` 才计数。

剪枝的关键在于「否定只需一个反例」：内层平均扫到第一个邻居就停，不需要确认所有元素。

### 进阶：排序 + 二分查找

若规模放大，可先把 `arr2` 排序，再对每个 `i` 用二分查找判断区间 `[i-d, i+d]` 内是否落有元素——`bisect_left` 找到第一个 `>= i-d` 的位置，该位置越界或对应元素 `> i+d`，则区间内无元素，`i` 符合：

```python
import bisect

class Solution:
    def findTheDistanceValue(self, arr1: list[int], arr2: list[int], d: int) -> int:
        arr2.sort()
        ret = 0
        for i in arr1:
            lo = bisect.bisect_left(arr2, i - d)  # 第一个 >= i-d 的位置
            if lo == len(arr2) or arr2[lo] > i + d:  # 区间 [i-d, i+d] 内无 arr2 元素
                ret += 1
        return ret
```

### 复杂度分析

- 时间复杂度：`O(n·m)`（暴力，n、m 为两数组长度；数据范围 500×500 下约 25 万次比较）
- 空间复杂度：`O(1)`（仅计数器与标志位；上面的 Python 二分版使用 sorted，辅助空间 O(m)，时间 O((n+m)·log m)）

## 代码实现

```python
class Solution:
    def findTheDistanceValue(self, arr1: list[int], arr2: list[int], d: int) -> int:
        ret = 0
        for i in arr1:
            is_match = True  # 假设 i 符合：arr2 没有元素落在 [i-d, i+d]
            for k in arr2:
                if abs(i - k) <= d:  # 发现一个邻居即否定假设，提前跳出
                    is_match = False
                    break
            if is_match:
                ret += 1
        return ret
```

### 代码解析

- `is_match` 标志位 + `break` 是「存在性判断」的标准写法：找一个反例就能否决，平均情况下内层扫到第一个邻居即停；
- `abs(i - k) <= d` 一次性覆盖了两侧邻域，等价于 `i - d <= k <= i + d`，不必拆成两个不等式；
- 判断放在内层循环外的 `if is_match` 上而不是 `else` 分支——`for...else` 写法更紧凑但可读性见仁见智，这里选择显式标志位；
- `d = 0` 时退化为「精确匹配是否存在」，是验证边界的好用例。

## 测试用例

覆盖官方示例、d=0 精确匹配、距离恰为 d 与 d+1 的分界、单元素/全部符合/全部不符合、负数邻域、邻居靠后出现（验证 break 后计数正确）：

```python
def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.findTheDistanceValue([4, 5, 8], [10, 9, 1, 8], 2) == 2  # 示例 1：4、5 符合
    assert solution.findTheDistanceValue([1, 4, 2, 3], [-4, -3, 6, 10, 20, 30], 3) == 2  # 示例 2：1、2 符合
    # 边界：d = 0 退化为「精确匹配是否存在」
    assert solution.findTheDistanceValue([1, 2, 3], [3], 0) == 2  # 3 被精确命中
    assert solution.findTheDistanceValue([1, 2, 3], [4], 0) == 3  # 无精确命中，全部符合
    # 距离恰为 d（不符合）与 d+1（符合）的分界
    assert solution.findTheDistanceValue([5], [3], 2) == 0  # |5-3| = 2 <= d
    assert solution.findTheDistanceValue([5], [2], 2) == 1  # |5-2| = 3 > d
    assert solution.findTheDistanceValue([5], [8], 2) == 1  # |5-8| = 3 > d
    # 单元素数组 / 全部符合 / 全部不符合
    assert solution.findTheDistanceValue([7], [7], 100) == 0
    assert solution.findTheDistanceValue([1, 2, 3], [100, 200], 1) == 3
    # 负数邻域：|-5-0| = 5 > 4 符合，|-4-0| = 4 <= 4 不符合
    assert solution.findTheDistanceValue([-5, -4], [0], 4) == 1
    # 邻居在 arr2 中靠后才出现，验证 break 提前跳出后计数仍正确
    assert solution.findTheDistanceValue([10, 20], [100, 15, 25], 5) == 0
```

## 总结

- 把「不存在 `|arr1[i]-arr2[j]| <= d`」改读成「arr2 与邻域区间 `[i-d, i+d]` 无交集」，题意立刻清晰——本质是逐元素的存在性判断；
- 存在性判断配「假设成立 + 找到反例即 break」的剪枝，是暴力解法里最值得固化的套路；
- 规模放大时的升级路线现成：排序 + `bisect` 做范围查找，与数据库 B+ 树的邻域查询同源。
