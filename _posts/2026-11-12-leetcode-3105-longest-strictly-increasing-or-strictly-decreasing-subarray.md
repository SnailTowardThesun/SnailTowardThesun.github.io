---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3105: 最长的严格递增或递减子数组"
categories: LeetCode
tags: [简单, 数组]
---

> 单调游程是连续上升或下降的一段。相邻相等会同时打断两条游程；维护当前递增、递减长度，相当于把线性 DP 滚动压缩成两个计数器。

## 题目

LeetCode 3105. Longest Strictly Increasing or Strictly Decreasing Subarray（最长的严格递增或递减子数组）

Difficulty: **Easy**

给你一个整数数组 `nums`，返回 `nums` 中最长「严格递增」或「严格递减」**子数组**的长度。

子数组是数组中的一个**连续**元素序列。注意「严格」单调不允许相邻元素相等。

约束：

- `1 <= nums.length <= 50`
- `1 <= nums[i] <= 50`

### 示例

```text
输入：nums = [1,4,3,3,2]
输出：2
解释：严格递增子数组 [1,4]、严格递减子数组 [4,3] 与 [3,2] 长度均为 2；
[3,3] 因相邻相等不算单调，故答案为 2。
```

```text
输入：nums = [3,3,3,3]
输出：1
解释：任何相邻元素都相等，单个元素即最长单调子数组。
```

```text
输入：nums = [3,2,1]
输出：3
解释：整个数组严格递减。
```

## 解题思路

### 游程计数：一次遍历同时盯两条链

以当前元素结尾的「最长严格递增游程」`large` 与「最长严格递减游程」`small` 可以在同一次遍历里同时维护：

- `nums[i] > nums[i-1]`：递增链延续，`large++`；否则（**含相等**）`large` 重置为 1；
- `nums[i] < nums[i-1]`：递减链延续，`small++`；否则（含相等）`small` 重置为 1；
- 每一步用两条链的当前长度更新全局答案 `ret`。

两个计数器初值均为 1——单个元素自成单调子数组，`n == 1` 时循环不执行直接返回 1。

### 为什么相等是唯一坑点

`>` 与 `<` 互斥，而 `==` 落在两个分支的「否则」里：一次相等同时打断递增链和递减链。若误用 `>=` / `<=`（非严格版本），`[3,3,3]` 会错误地给出 3 而不是 1——示例 2 专门守住这一点。

游程计数也可视为滚动 DP：以当前位置结尾的递增/递减长度只依赖上一位置和一次相邻比较，因此无需完整 DP 数组。双指针也能表达同样的连续区间。

### 手算示例 1（nums = [1,4,3,3,2]）

| i | 比较 | large | small | ret |
|---|------|-------|-------|-----|
| 1 | 4 > 1 | 2 | 1 | 2 |
| 2 | 3 < 4 | 1 | 2 | 2 |
| 3 | 3 == 3 | 1 | 1 | 2 |
| 4 | 2 < 3 | 1 | 2 | 2 |

答案 2。

### 复杂度分析

- 时间复杂度：`O(n)`，单次遍历；
- 空间复杂度：`O(1)`，三个计数器。

## 代码实现

C++ 与 Python 逐行对应，仅语言习惯差异，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt3105-cpp" name="lt3105" checked>
  <input type="radio" id="lt3105-py" name="lt3105">
  <div class="lang-tab-nav">
    <label for="lt3105-cpp">C++</label>
    <label for="lt3105-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int longestMonotonicSubarray(vector<int>& nums) {
        int ret = 1, large = 1, small = 1;
        for (size_t i = 1; i < nums.size(); i++) {
            // 严格递增游程：相等也算打断
            if (nums[i] > nums[i - 1]) {
                large++;
                ret = max(ret, large);
            } else {
                large = 1;
            }

            // 严格递减游程：对称处理
            if (nums[i] < nums[i - 1]) {
                small++;
                ret = max(ret, small);
            } else {
                small = 1;
            }
        }

        return ret;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def longestMonotonicSubarray(self, nums: list[int]) -> int:
        ret = 1
        large, small = 1, 1
        for i in range(1, len(nums)):
            # 严格递增游程：相等也算打断
            if nums[i] > nums[i - 1]:
                large += 1
                ret = max(ret, large)
            else:
                large = 1

            # 严格递减游程：对称处理
            if nums[i] < nums[i - 1]:
                small += 1
                ret = max(ret, small)
            else:
                small = 1

        return ret
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 两个 `if` 相互独立而非 `else if`：同一次迭代里 `>` 与 `<` 本就互斥，但两条游程的重置逻辑各自完整，写独立块更贴近「两条链各自演进」的语义；
- 重置发生在「否则」分支——相等元素同时打断两条链，这正是严格单调的判定边界；
- `ret` 的更新放在延续分支内而非循环末尾，重置后的 1 无需再比（不可能刷新最大值）；
- 计数器初值 1 天然覆盖单元素与全相等数组的边界。

## 测试用例

覆盖三个官方示例、单元素、整体递增、山峰形与混合形态：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：相等对打断两条游程，最长为 2 ----
    assert solution.longestMonotonicSubarray([1, 4, 3, 3, 2]) == 2

    # ---- 官方示例 2：全部相等，单个元素即最长 ----
    assert solution.longestMonotonicSubarray([3, 3, 3, 3]) == 1

    # ---- 官方示例 3：整个数组严格递减 ----
    assert solution.longestMonotonicSubarray([3, 2, 1]) == 3

    # ---- 最小规模：单元素 ----
    assert solution.longestMonotonicSubarray([5]) == 1

    # ---- 整体严格递增 ----
    assert solution.longestMonotonicSubarray([1, 2, 3, 4, 5]) == 5

    # ---- 山峰形：先增后减，两侧各取最长 ----
    assert solution.longestMonotonicSubarray([1, 3, 5, 4, 2]) == 3

    # ---- 混合形态：[1,2,3] 增 3 长与 [2,1] 减 2 长，答案 3 ----
    assert solution.longestMonotonicSubarray([1, 2, 3, 2, 2, 1]) == 3
```

C++ 侧在 `TEST(Daily, 3105)` 里用同样的 7 组用例断言，`./tests --gtest_filter='Daily.3105*'` 通过；提交前另用 O(n³) 暴力枚举所有子数组并逐对检查严格单调，随机对照 1000 组，与游程计数结果全部一致。

## 总结

- 游程计数一次遍历、三个计数器，同时维护递增/递减两条链的最大长度；
- 「严格」的边界在相等：`==` 同时打断两条链，误用 `>=`/`<=` 会被全相等数组击穿；
- 相邻比较型子数组问题不需要 DP 数组——`f(i)` 只依赖 `f(i-1)` 时，滚动一个变量就是全部状态。
