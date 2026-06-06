---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2574: 左右元素和的差值"
categories: LeetCode
---

> 前缀和技术常用于快速计算数组区间和，在数组运算中非常实用。

## 题目

LeetCode 2574. Left and Right Sum Differences（左右元素和的差值）

Difficulty: **Easy**

给你一个下标从 0 开始的整数数组 nums，请你找出一个下标从 0 开始的整数数组 answer，其中：
- answer.length == nums.length
- answer[i] = |leftSum[i] - rightSum[i]|

其中：
- leftSum[i] 是数组 nums 中下标 i 左侧元素之和。如果不存在对应的元素，leftSum[i] = 0。
- rightSum[i] 是数组 nums 中下标 i 右侧元素之和。如果不存在对应的元素，rightSum[i] = 0。

返回数组 answer。

### 示例

```
示例 1：
输入：nums = [10,4,8,3]
输出：[15,1,11,22]
解释：
数组 leftSum 为 [0,10,14,22]，数组 rightSum 为 [15,11,3,0]。
数组 answer 为 [|0 - 15|, |10 - 11|, |14 - 3|, |22 - 0|] = [15,1,11,22]

示例 2：
输入：nums = [1]
输出：[0]
解释：
数组 leftSum 为 [0]，数组 rightSum 为 [0]。
数组 answer 为 [|0 - 0|] = [0]
```

## 解题思路

这道题可以使用前缀和数组法来解决，直观且高效。

### 核心思路

1. 创建 leftSum 数组，leftSum[i] 表示 nums[0..i-1] 的和
2. 创建 rightSum 数组，rightSum[i] 表示 nums[i+1..n-1] 的和
3. 遍历数组，计算 answer[i] = |leftSum[i] - rightSum[i]|

### 算法详解

以示例 1 的数组 [10,4,8,3] 为例：

```
步骤 1：计算左前缀和
leftSum[0] = 0（没有左侧元素）
leftSum[1] = leftSum[0] + nums[0] = 0 + 10 = 10
leftSum[2] = leftSum[1] + nums[1] = 10 + 4 = 14
leftSum[3] = leftSum[2] + nums[2] = 14 + 8 = 22

步骤 2：计算右前缀和
rightSum[3] = 0（没有右侧元素）
rightSum[2] = rightSum[3] + nums[3] = 0 + 3 = 3
rightSum[1] = rightSum[2] + nums[2] = 3 + 8 = 11
rightSum[0] = rightSum[1] + nums[1] = 11 + 4 = 15

步骤 3：计算绝对差值
answer[0] = |0 - 15| = 15
answer[1] = |10 - 11| = 1
answer[2] = |14 - 3| = 11
answer[3] = |22 - 0| = 22

最终结果：[15,1,11,22]
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    vector<int> leftRightDifference(vector<int> &nums) {
        int n = nums.size();

        vector<int> left_pre(n, 0);
        for (int i = 1; i < n; i++) {
            left_pre[i] = nums[i - 1] + left_pre[i - 1];
        }

        vector<int> right_pre(n, 0);
        for (int i = n - 2; i >= 0; i--) {
            right_pre[i] = nums[i + 1] + right_pre[i + 1];
        }

        vector<int> ret;
        for (int i = 0; i < n; i++) {
            ret.push_back(abs(left_pre[i] - right_pre[i]));
        }

        return ret;
    }
};
```
{% endraw %}

### 代码解析

1. **计算左前缀和**：left_pre[i] 表示 nums[0..i-1] 的和，从左到右遍历
2. **计算右前缀和**：right_pre[i] 表示 nums[i+1..n-1] 的和，从右到左遍历
3. **计算绝对差值**：遍历数组，计算每个位置的 |left_pre[i] - right_pre[i]|

### 复杂度分析

- **时间复杂度**: O(n)，需要遍历数组三次（计算左前缀和、右前缀和、计算结果）
- **空间复杂度**: O(n)，需要额外的数组存储前缀和

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2574) {
    Solution s;
    vector<int> nums{10, 4, 8, 3};
    auto ret = s.leftRightDifference(nums);
    EXPECT_EQ(vector<int>({15,1,11,22}), ret);
}
```
{% endraw %}

## 总结

这道题是一道经典的前缀和应用问题。通过预先计算左右两侧的前缀和，可以在 O(n) 时间内求解所有位置的差值。虽然需要 O(n) 的额外空间，但代码清晰直观，易于理解和实现。对于空间优化感兴趣的读者，可以进一步思考如何在 O(1) 空间内解决这个问题。
