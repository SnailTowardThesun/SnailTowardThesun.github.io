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
输入：nums = [1,2,3,4], l = 2, r = 4
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
2. 先用生成器计算首个长度 `l` 的基础窗口和 `base`，不创建切片。左端移动时，减去离开的值、加上进入的值，O(1) 更新 `base`；
3. 从 `s = base` 开始扩展右端，直到长度 `r`，每次 `s += nums[j]`，单次 O(1)；
4. 用 `inf` 做哨兵：`0 < s < ret` 链式比较一步完成「是正数且更小」的判定；
5. 扫完哨兵未更新则返回 `-1`。

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

- 时间复杂度：`O(l + (n-l+1)·(r-l+1))`：初始化需要 O(l)，每个左端的基础和 O(1) 更新，再枚举至多 `r-l+1` 个长度；更宽松的上界为 `O(n·(r-l+1))`。
- 辅助空间复杂度：`O(1)`，生成器不复制切片，只维护几个整数。

这里不能在每个左端重新计算 `sum(nums[i:i+l])`：它既有 O(l) 的求和代价，也会创建 O(l) 的临时切片。基础窗口滑动与右端扩展各用一个和值，避免相互污染。对于本题 n ≤ 100，枚举足够简洁；这并非对更大数据规模的最优性证明。

## 代码实现

```python
from math import inf


class Solution:
    def minimumSumSubarray(self, nums: list[int], l: int, r: int) -> int:  # noqa: E741  # l 保持 LeetCode 官方签名
        ret = inf
        n = len(nums)
        base = sum(nums[j] for j in range(l))
        for i in range(n - l + 1):
            # 基础窗口随左端滑动，之后从长度 l 扩到 r，全程不创建切片
            if i:
                base += nums[i + l - 1] - nums[i - 1]
            s = base
            if 0 < s < ret:
                ret = s
            for j in range(i + l, min(n, i + r)):
                s += nums[j]
                if 0 < s < ret:
                    ret = s

        return ret if ret < inf else -1
```

### 代码解析

- 两种增量分别维护：`base` 只代表长度 l 的窗口，`s` 负责当前左端的向右扩展；下一个左端不能沿用扩展后的 `s`；
- 循环边界 `range(n - l + 1)` 把「窗口放得下」的不变式写进 range，循环体里不再需要 `if i + l > n: break`；
- `inf` 哨兵天然大于一切正数，`0 < s < ret` 把「正数且更小」两个条件链在一个表达式里，免去 `ret == -1` 的特判分支；
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
    assert solution.minimumSumSubarray([1, 2, 3, 4], 2, 4) == 3

    # ---- 最小规模：单元素正数 ----
    assert solution.minimumSumSubarray([5], 1, 1) == 5

    # ---- 单元素负数：无解 ----
    assert solution.minimumSumSubarray([-5], 1, 1) == -1

    # ---- l == r == n：整个数组是唯一候选 ----
    assert solution.minimumSumSubarray([2, -1, 2], 3, 3) == 3

    # ---- 和为 0 不算正数：[1,-1]=0 被跳过，[-1,2]=1 入选 ----
    assert solution.minimumSumSubarray([1, -1, 2], 2, 3) == 1

    # ---- 固定长度窗口的最小正和在末尾，检查基础窗口滑动 ----
    assert solution.minimumSumSubarray([10, -4, 3, -2], 2, 2) == 1

    # ---- 最优值来自扩展窗口，下一左端的基础和不应混入扩展部分 ----
    assert solution.minimumSumSubarray([4, -2, -1], 2, 3) == 1
```

提交前用「逐个子数组重新求和」的朴素版随机对照 2000 组，与增量版结果全部一致。

## 总结

- 固定左端时右端单向扩张，和值增量维护，每个子数组 O(1) 求值，基础窗口 O(l) 初始化，之后总 `O((n-l+1)·(r-l+1))`；
- `inf` 哨兵 + 链式比较替代「首个正和」特判，代码更贴近题意本身；
- Easy 题的教训朴素但通用：别为每个子数组重新求和，也别让调试 print 跟着提交。
