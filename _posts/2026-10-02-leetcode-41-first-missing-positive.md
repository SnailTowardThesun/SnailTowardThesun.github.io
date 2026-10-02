---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.41: 缺失的第一个正数"
categories: LeetCode
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

理想状态下 nums[i] == i + 1。把范围内的数字逐一交换到正确位置：

1. 对每个位置，当 nums[i] 在 [1, n] 内且不在自己的位置，就与 `nums[nums[i]-1]` 交换。
2. 用 tmp 记录上一次的值，防止两个相同数字造成死循环。
3. 归位完成后，第一个 `nums[i] != i+1` 的位置返回 i+1；全部正确则返回 n+1。

负数、零、大于 n 的数都不影响，它们会自然占据缺失数字的位置。

### 复杂度分析

- **时间复杂度**：O(n)，每个数字归位后不会再移动。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int firstMissingPositive(int A[], int n) {
        for (int i = 0, tmp = -1; i < n; i++) {
            while (A[i] - 1 >= 0 && A[i] - 1 < n && A[i] - 1 != i) {
                swap(A, i, A[i] - 1);
                if (A[i] == tmp) break;  // 防止重复值死循环
                else tmp = A[i];
            }
        }
        for (int i = 0; i < n; i++) {
            if (A[i] - 1 != i) return i + 1;
        }
        return n + 1;
    }

    void swap(int A[], int idx1, int idx2) {
        A[idx1] ^= A[idx2];
        A[idx2] ^= A[idx1];
        A[idx1] ^= A[idx2];
    }
};
```

### 代码解析

- 源文件用异或实现交换，不借助临时变量；现代写法直接用 `std::swap` 更安全（异或交换在位置相同时会清零）。

## 测试用例

```cpp
TEST(Daily, 41) {
    Solution s;
    int A2[] = {3, 4, -1, 1};
    EXPECT_EQ(s.firstMissingPositive(A2, 4), 2);
    int A4[] = {1, 1};
    EXPECT_EQ(s.firstMissingPositive(A4, 2), 2);
}
```

## 总结

1. 答案只可能在 [1, n+1] 中，用数组自身做哈希；
2. 交换归位，注意重复值导致的死循环；
3. 遍历找第一个不满足 nums[i] == i+1 的位置。
