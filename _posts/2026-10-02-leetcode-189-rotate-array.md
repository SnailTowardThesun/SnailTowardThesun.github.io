---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.189: 轮转数组"
categories: LeetCode
---

> 当前实现用额外数组按「尾段 + 头段」重排；O(1) 空间的经典解法是三次翻转，先整体、再前 k、再后 n-k。

## 题目

LeetCode 189. Rotate Array（轮转数组）

Difficulty: **Medium**

给定整数数组，将元素向右轮转 k 个位置，k 非负。

### 示例

```
输入：nums = [1,2,3,4,5,6,7], k = 3
输出：[5,6,7,1,2,3,4]

输入：nums = [-1,-100,3,99], k = 2
输出：[3,99,-1,-100]
```

## 解题思路

### 尾段 + 头段拼接（当前实现）

1. `step = k % n` 去掉整圈轮转。
2. 新数组 = 原数组末尾 step 个元素 + 前面 n-step 个元素。

### 三次翻转（O(1) 空间）

1. 整体翻转
2. 翻转前 step 个元素
3. 翻转后 n-step 个元素

翻转操作两两抵消归位，最终每个元素到达目标位置。

### 复杂度分析

- 当前：时间 O(n)，空间 O(n)。
- 三次翻转：时间 O(n)，空间 O(1)。

## 代码实现

```cpp
class Solution {
public:
    void rotate(vector<int>& nums, int k) {
        int step = k % nums.size();
        vector<int> container;
        container.reserve(nums.size());
        container.insert(container.end(), nums.end() - step, nums.end());
        container.insert(container.end(), nums.begin(), nums.end() - step);
        nums = move(container);
    }
};
```

三次翻转参考实现：

```cpp
class SolutionReverse {
public:
    void rotate(vector<int>& nums, int k) {
        int step = k % (int)nums.size();
        reverse(nums.begin(), nums.end());
        reverse(nums.begin(), nums.begin() + step);
        reverse(nums.begin() + step, nums.end());
    }
};
```

### 代码解析

- k 先取模，k == n 时数组不变。
- 翻转区间以前 step 个为界，正好对应右移距离。

## 测试用例

```cpp
TEST(TOP150, No189_RotateArray) {
    Solution solution;
    vector<int> nums{-1, -100, 3, 99};
    solution.rotate(nums, 2);
    vector<int> expected{3, 99, -1, -100};
    EXPECT_EQ(nums, expected);
}
```

## 总结

1. 轮转等价于尾段前置；
2. 取模处理 k >= n；
3. 三次翻转是原地标准做法。
