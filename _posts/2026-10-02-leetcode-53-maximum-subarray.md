---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.53: 最大子数组和"
categories: LeetCode
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
- **空间复杂度**：O(1)。

## 代码实现

```cpp
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
```

## 测试用例

```cpp
TEST(Daily, 53) {
    Solution s;
    vector<int> nums1 = {-2, 1, -3, 4, -1, 2, 1, -5, 4};
    EXPECT_EQ(s.maxSubArray(nums1), 6);
    vector<int> nums5 = {-2, -1};
    EXPECT_EQ(s.maxSubArray(nums5), -1);
}
```

## 总结

1. 每步决定「重开」还是「接上」；
2. local 记录当前段，global 记录历史最优；
3. O(n) 时间 O(1) 空间。
