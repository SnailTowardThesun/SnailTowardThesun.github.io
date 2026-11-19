---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.41: 缺失的第一个正数"
categories: LeetCode
tags: [困难, 数组, 哈希表]
---

> 把数组本身当哈希表：数字 x 应该坐在下标 x-1 的位置。归位后第一个「坐错位置」的下标加一就是答案。

## 题目

LeetCode 41. First Missing Positive（缺失的第一个正数）

Difficulty: **Hard**

给定未排序整数数组，找出没有出现的最小正整数。要求 O(n) 时间、O(1) 额外空间。

### 示例

```
输入：nums = [1,2,0]       输出：3
输入：nums = [3,4,-1,1]    输出：2
输入：nums = [7,8,9,11,12] 输出：1
```

## 解题思路

### 原地哈希

长度为 `n` 的数组最多包含 `n` 个不同正整数，答案一定在 `[1, n+1]` 内。先把 `[1,n]` 中出现的值放到对应位置，值 `x` 对应下标 `x-1`。

1. 遍历每个位置。如果当前值在 `[1,n]` 内，且目标位置还没有存放相同的值，就交换这两个元素。
2. 交换后继续检查当前位置，因为换来的元素也可能需要归位。目标位置已有相同值时停止，避免重复交换。
3. 再遍历一次。第一个不满足 `nums[i] == i+1` 的位置给出答案 `i+1`。若全部对应，返回 `n+1`。

### 复杂度分析

- **时间复杂度**：O(n)，每次有效交换至少固定一个位置，总交换次数不超过 n。
- **空间复杂度**：O(1)。

## 代码实现

C++ 与 Python 均为原地哈希（交换归位），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt41-cpp" name="lt41" checked>
  <input type="radio" id="lt41-py" name="lt41">
  <div class="lang-tab-nav">
    <label for="lt41-cpp">C++</label>
    <label for="lt41-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int firstMissingPositive(vector<int>& nums) {
        int n = nums.size();
        for (int i = 0; i < n; ++i) {
            while (nums[i] >= 1 && nums[i] <= n && nums[nums[i] - 1] != nums[i]) {
                int target = nums[i] - 1;
                std::swap(nums[i], nums[target]);
            }
        }
        for (int i = 0; i < n; ++i) {
            if (nums[i] != i + 1) return i + 1;
        }
        return n + 1;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def firstMissingPositive(self, nums: list[int]) -> int:
        n = len(nums)
        for i in range(n):
            # 目标位置已有相同值时停止，避免重复值导致无限交换
            while 1 <= nums[i] <= n and nums[nums[i] - 1] != nums[i]:
                j = nums[i] - 1
                nums[i], nums[j] = nums[j], nums[i]

        for i in range(n):
            if nums[i] != i + 1:
                return i + 1
        return n + 1
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- C++ 先检查值是否在 `[1,n]` 内，再减一计算目标下标。这样可以处理 `INT_MIN`，避免有符号整数溢出。
- 目标位置已经保存相同值时无需交换。这涵盖元素已经归位和存在重复值两种情况。
- 两个版本都直接修改输入数组，额外只保存常数个变量。

## 测试用例

C++ 回归用例覆盖 32 位整数边界。

```cpp
#include <limits>

TEST(Daily, 41) {
    Solution s;
    vector<int> nums{std::numeric_limits<int>::min(), std::numeric_limits<int>::max(), 1};
    EXPECT_EQ(s.firstMissingPositive(nums), 2);
}
```

Python 侧（与仓库 hot100 版一致，使用原地哈希）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.firstMissingPositive([1, 2, 0]) == 3
    assert solution.firstMissingPositive([3, 4, -1, 1]) == 2
    assert solution.firstMissingPositive([7, 8, 9, 11, 12]) == 1

    # ---- 1..n 齐全：答案是 n+1 ----
    assert solution.firstMissingPositive([1]) == 2
    assert solution.firstMissingPositive([2, 1]) == 3

    # ---- 重复值：[1,1] 缺 2 ----
    assert solution.firstMissingPositive([1, 1]) == 2
    assert solution.firstMissingPositive([2, 2, 1]) == 3

    # ---- 同一位置需要连续交换，才能完成归位 ----
    assert solution.firstMissingPositive([2, 3, 4, 1]) == 5

    # ---- 全负 / 含大数：答案是 1 ----
    assert solution.firstMissingPositive([-5, -3]) == 1
    assert solution.firstMissingPositive([100, 200]) == 1
```

## 总结

1. 答案只可能在 [1, n+1] 中，用数组自身做哈希；
2. 交换归位，注意重复值导致的死循环；
3. 遍历找第一个不满足 nums[i] == i+1 的位置。
