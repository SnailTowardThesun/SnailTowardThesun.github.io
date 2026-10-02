---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1848: 到目标元素的最小距离"
categories: LeetCode
---

> 在普通（非环形）数组中，两点距离就是下标差的绝对值 `|i - j|`，一次遍历维护最小值即可。

## 题目

LeetCode 1848. Minimum Distance to the Target Element（到目标元素的最小距离）

Difficulty: **Easy**

给你一个整数数组 `nums`（下标从 `0` 开始）和两个整数 `target` 和 `start`。请你找出一个下标 `i`，满足 `nums[i] == target` 且 `abs(i - start)` 最小化。返回 `abs(i - start)` 的最小值。

### 示例

```
示例 1：
输入：nums = [1, 2, 3, 4, 5], target = 5, start = 3
输出：1
解释：nums[4] = 5，|4 - 3| = 1。

示例 2：
输入：nums = [1], target = 1, start = 0
输出：0
```

## 解题思路

### 单次遍历维护最小值

由于数组不是环形的，两点距离就是下标差的绝对值。

1. 初始化 `ret = INT_MAX`。
2. 遍历数组，若 `nums[i] == target`，更新 `ret = min(ret, abs(i - start))`。
3. 返回 `ret`。

### 复杂度分析

- **时间复杂度**：O(n)，单次遍历。
- **空间复杂度**：O(1)，仅使用常数变量。

## 代码实现

```cpp
class Solution {
   public:
    int getMinDistance(vector<int>& nums, int target, int start) {
        int ret = INT_MAX;
        for (int i = 0; i < nums.size(); ++i) {
            if (nums[i] == target) {
                ret = min(ret, abs(i - start));
            }
        }
        return ret;
    }
};
```

### 代码解析

- `abs(i - start)`：非环形数组的直接距离。
- 遍历所有等于 `target` 的元素，维护最小距离。

## 测试用例

```cpp
TEST(Daily, 1848) {
    Solution s;
    auto nums = vector<int>{1, 2, 3, 4, 5};
    auto target = 5, start = 3;
    auto ret = s.getMinDistance(nums, target, start);
    EXPECT_EQ(ret, 1);
}
```

## 总结

本题是数组距离计算的最基础形式：

1. 非环形数组 → 距离 = `|i - j|`；
2. 环形数组 → 距离 = `min(|i - j|, n - |i - j|)`。

本题只需一次遍历、维护最小值，是理解数组距离问题的起点。
