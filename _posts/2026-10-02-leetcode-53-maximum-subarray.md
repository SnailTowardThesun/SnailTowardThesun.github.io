---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.53: 最大子数组和"
categories: LeetCode
tags: [简单, 数组, 动态规划]
---

> Kadane 算法的一句核心决策：当前元素单独成段，还是接上之前的段？取两者较大值即可。

## 题目

LeetCode 53. Maximum Subarray（最大子数组和）

Difficulty: **Easy**

给定整数数组，找出和最大的连续非空子数组，返回其和。

### 示例

```
输入：nums = [-2,1,-3,4,-1,2,1,-5,4]
输出：6
解释：子数组 [4,-1,2,1] 和最大。
```

## 解题思路

### Kadane 动态规划

- local：以当前元素结尾的最大子数组和。
- 转移：`local = max(nums[i], local + nums[i])`。
- global：过程中出现的最大 local。

之前段和为正时接上有益，为负时不如从当前元素重新开始。

### 复杂度分析

- **时间复杂度**：O(n)。
- **额外空间复杂度**：C++ 滚动变量版为 O(1)，Python dp 数组版为 O(n)。

## 代码实现

C++ 是滚动变量版（O(1) 空间），Python 是 dp 数组版（O(n) 空间，保存每个位置的状态），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt53-cpp" name="lt53" checked>
  <input type="radio" id="lt53-py" name="lt53">
  <div class="lang-tab-nav">
    <label for="lt53-cpp">C++</label>
    <label for="lt53-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        int global = nums[0];
        int local = nums[0];
        for (int i = 1; i < nums.size(); i++) {
            local = nums[i] > local + nums[i] ? nums[i] : local + nums[i];
            global = local > global ? local : global;
        }
        return global;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def maxSubArray(self, nums: list[int]) -> int:
        n = len(nums)
        dp = [0] * n
        dp[0] = nums[0]
        for i in range(1, n):
            # 接上前段（dp[i-1] > 0 时有益）还是单独成段，取较大者
            if nums[i] > nums[i] + dp[i - 1]:
                dp[i] = nums[i]
            else:
                dp[i] = nums[i] + dp[i - 1]
        return max(dp)
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 两个版本是同一转移的两种形态：C++ 的 `local` 即 Python 的 `dp[i]`，前者只保留上一步的状态；`global` 对应 Python 的 `max(dp)`；
- Python 版把「以每个位置结尾的最优」显式存下来，便于理解与调试；如果只保留上一步的状态，也能像 C++ 版一样将额外空间降到 O(1)；
- 全负数组无需特判：`max(dp)` 至少选中最大的单个元素（`[-2,-1]` → `-1`）。

## 测试用例

C++ 侧：

```cpp
TEST(Daily, 53) {
    Solution s;
    vector<int> nums1 = {-2, 1, -3, 4, -1, 2, 1, -5, 4};
    EXPECT_EQ(s.maxSubArray(nums1), 6);
    vector<int> nums5 = {-2, -1};
    EXPECT_EQ(s.maxSubArray(nums5), -1);
}
```

Python 侧（hot100 版）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.maxSubArray([-2, 1, -3, 4, -1, 2, 1, -5, 4]) == 6
    assert solution.maxSubArray([1]) == 1
    assert solution.maxSubArray([5, 4, -1, 7, 8]) == 23

    # ---- 全负数组：必须选至少一个元素，答案是最大单元素 ----
    assert solution.maxSubArray([-1]) == -1
    assert solution.maxSubArray([-2, -1]) == -1

    # ---- 负数在中间被两侧正段跨越 ----
    assert solution.maxSubArray([1, -2, 3]) == 3
    assert solution.maxSubArray([2, -1, 2]) == 3
```

提交前用「枚举所有子数组」的 O(n²) 朴素版随机对照 1500 组（含全负数组），与 dp 版结果全部一致。

## 总结

1. 每步决定「重开」还是「接上」；
2. local 记录当前段，global 记录历史最优；
3. 两版时间均为 O(n)；C++ 滚动变量版额外空间为 O(1)，Python dp 数组版为 O(n)。
