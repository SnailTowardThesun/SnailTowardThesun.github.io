---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2567: 修改两个元素后的最小分数"
categories: LeetCode
tags: [中等, 数组, 排序, 贪心]
---

> 把两个位置改成保留值域内的同一个数，可以让最小绝对差变为零，同时保持保留元素的极差。

## 题目

LeetCode 2567. Minimum Score by Changing Two Elements（修改两个元素后的最小分数）

Difficulty: **Medium**

给你一个整数数组 `nums`。在所有不同下标的元素对中，最小绝对差叫低分，最大绝对差叫高分，两者之和就是数组的分数。将两个位置的元素改为任意整数，求修改后能得到的最小分数。

[LeetCode 原题](https://leetcode.com/problems/minimum-score-by-changing-two-elements/description/)

约束：

- `3 <= nums.length <= 10^5`
- `1 <= nums[i] <= 10^9`

### 示例

```text
输入：nums = [1,4,3]
输出：0
解释：把 1 和 4 改成 3，高分和低分均为 0。

输入：nums = [1,4,7,8,5]
输出：3
解释：把 1 和 4 都改成 6，得到 [6,6,7,8,5]。低分为 0，高分为 8 - 5 = 3。
```

## 解题思路

### 固定要修改的两个位置

设保留元素的最小值为 `lo`、最大值为 `hi`。无论如何修改，其余元素仍在数组中，因此高分至少是 `hi-lo`，低分至少是零。把两个位置都改成 `[lo,hi]` 中的同一个整数，就能让低分为零、高分等于 `hi-lo`，恰好达到下界。

### 排序后检查三个保留窗口

排序后，任取 `n-2` 个保留元素，它们的最小值到最大值之间至少包含 `n-2` 个排序位置。因此其中总能选出一段连续的 `n-2` 个元素，极差至多与原方案相等。长度为 `n-2` 的连续窗口只有三个，分别对应以下方案。

| 修改的位置 | 保留元素的极差 |
|-------------|----------------|
| 最大的两个 | `nums[n-3] - nums[0]` |
| 最大和最小各一个 | `nums[n-2] - nums[1]` |
| 最小的两个 | `nums[n-1] - nums[2]` |

三个值的最小值就是答案。

### 手算示例 2（nums = [1,4,7,8,5] → 排序 [1,4,5,7,8]）

- 删两个最大（7、8）：极差 `5 - 1 = 4`
- 删一大一小（8、1）：极差 `7 - 4 = 3`
- 删两个最小（1、4）：极差 `8 - 5 = 3`

后两个窗口都得到最小分数 3。例如，把 8 和 1 都改成 5 后，低分为 0，高分为 3。

### 复杂度分析

- 两种实现的时间均为 O(n log n)，主要开销来自排序。
- C++ 的常见 `std::sort` 实现使用 O(log n) 栈空间，CPython 的 `list.sort()` 最坏需要 O(n) 临时空间。计算三个候选值只需 O(1) 额外空间。

## 代码实现

C++ 与 Python 逐行对应（排序 + 三式取最小），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt2567-cpp" name="lt2567" checked>
  <input type="radio" id="lt2567-py" name="lt2567">
  <div class="lang-tab-nav">
    <label for="lt2567-cpp">C++</label>
    <label for="lt2567-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int minimizeSum(vector<int>& nums) {
        int n = nums.size();
        sort(nums.begin(), nums.end());
        // 三种删法：删两个最大 / 删一大一最小 / 删两个最小
        return min(nums[n - 3] - nums[0], min(nums[n - 2] - nums[1], nums[n - 1] - nums[2]));
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def minimizeSum(self, nums: list[int]) -> int:
        nums.sort()
        # 三种删法：删两个最大 / 删一大一最小 / 删两个最小
        return min(nums[-3] - nums[0], nums[-2] - nums[1], nums[-1] - nums[2])
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 两个版本都直接对输入数组排序。Python 的 `nums[-3]` 对应 C++ 的 `nums[n-3]`。
- 当 `n=3` 时，只需保留一个元素，三个保留窗口的极差都为零。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.minimizeSum([1, 4, 3]) == 0
    assert solution.minimizeSum([1, 4, 7, 8, 5]) == 3

    # ---- 全相等：极差本就是 0 ----
    assert solution.minimizeSum([1, 1, 1, 1]) == 0

    # ---- 最小规模 n=3：必可全改成同一个值，答案恒 0 ----
    assert solution.minimizeSum([1, 2, 3]) == 0

    # ---- n=4：只保留两个相邻值 ----
    assert solution.minimizeSum([1, 2, 3, 4]) == 1

    # ---- 三种端点组合分别是唯一最优解 ----
    assert solution.minimizeSum([1, 2, 3, 10, 20]) == 2
    assert solution.minimizeSum([1, 10, 11, 12, 100]) == 2
    assert solution.minimizeSum([1, 10, 20, 21, 22]) == 2
```

## 总结

把两个修改位置设为保留值域内的同一个数，分数就等于保留元素的极差。排序后比较三个长度为 `n-2` 的连续窗口即可。
