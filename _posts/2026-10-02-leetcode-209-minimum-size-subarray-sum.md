---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.209: 长度最小的子数组"
categories: LeetCode
---

> 所有元素均为正是滑动窗口有效的根基：纳入元素只增和、移出元素只减和，窗口才能单向收缩而不回头。

## 题目

LeetCode 209. Minimum Size Subarray Sum（长度最小的子数组）

Difficulty: **Medium**

给定 n 个正整数和正整数 target，找元素和 >= target 的最短连续子数组，返回长度，不存在返回 0。

### 示例

```
输入：target = 7, nums = [2,3,1,2,4,3]
输出：2（子数组 [4,3]）

输入：target = 11, nums = [1,1,1,1,1,1,1,1]
输出：0
```

## 解题思路

### 滑动窗口

1. 右指针扩窗累加 sum。
2. sum >= target 时进入收缩：记录窗口长度后左指针移出元素，直到 sum < target。
3. 结果保持 INT_MAX 表示始终未达标，返回 0。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int minSubArrayLen(int target, vector<int>& nums) {
        int n = nums.size();
        int left = 0, sum = 0;
        int result = INT_MAX;

        for (int right = 0; right < n; right++) {
            sum += nums[right];
            while (sum >= target) {
                result = min(result, right - left + 1);
                sum -= nums[left++];
            }
        }
        return result == INT_MAX ? 0 : result;
    }
};
```

### 代码解析

- 内层 while 一次收缩到不达标为止，所有「最短候选」都在收缩临界点产出。

## 测试用例

```cpp
TEST(TOP150, 209) {
    Solution s;
    vector<int> nums{2, 3, 1, 2, 4, 3};
    EXPECT_EQ(2, s.minSubArrayLen(7, nums));
}
```

## 总结

1. 正数数组上的定条件窗口问题；
2. 右扩左缩，两指针各走一遍；
3. 注意「未达标」与「长度为 0」的区分。
