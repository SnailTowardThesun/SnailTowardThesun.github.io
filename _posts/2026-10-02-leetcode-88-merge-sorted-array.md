---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.88: 合并两个有序数组"
categories: LeetCode
---

> 本题的「正统」做法是从后往前填充，原地完成不占额外空间；当前实现借助临时容器归并，逻辑更直观。

## 题目

LeetCode 88. Merge Sorted Array（合并两个有序数组）

Difficulty: **Easy**

nums1、nums2 均按非递减排列，长度分别为 m+n（后 n 位为占位 0）和 n。把 nums2 并入 nums1，结果存在 nums1 中。

### 示例

```
输入：nums1 = [1,2,3,0,0,0], m = 3, nums2 = [2,5,6], n = 3
输出：[1,2,2,3,5,6]

输入：nums1 = [0], m = 0, nums2 = [1], n = 1
输出：[1]
```

## 解题思路

### 归并到临时容器（当前实现）

1. i、j 分别指向两数组有效部分开头，取较小值放入 container。
2. 任一数组耗尽，把另一数组剩余部分全部追加。
3. 用 move 把结果赋值回 nums1。

### 从后往前（O(1) 空间的标准做法）

三指针 p1 = m-1、p2 = n-1、p = m+n-1：比较 nums1[p1] 与 nums2[p2]，较大者放到 p 位置。nums1 尾部的空位正好是写入区，不会覆盖未处理数据；p2 先耗尽则前半部分天然就位。

### 复杂度分析

- **时间复杂度**：O(m + n)。
- **空间复杂度**：当前 O(m+n)；从后往前为 O(1)。

## 代码实现

```cpp
class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        vector<int> container;
        int i = 0, j = 0;

        while (i < m && j < n) {
            if (nums1[i] < nums2[j]) {
                container.emplace_back(nums1[i++]);
            } else {
                container.emplace_back(nums2[j++]);
            }
        }
        for (; i < m; i++) container.emplace_back(nums1[i]);
        for (; j < n; j++) container.emplace_back(nums2[j]);

        nums1 = move(container);
    }
};
```

### 代码解析

- 三个收尾阶段（主归并、剩余1、剩余2）覆盖所有情况。
- move 避免 container 的二次拷贝。

## 测试用例

```cpp
TEST(TOP150, No88_MergeTwoSortedLists) {
    Solution solution;
    vector<int> nums1{1, 3, 5};
    vector<int> nums2{2, 4, 6};
    solution.merge(nums1, 3, nums2, 3);
    vector<int> expected{1, 2, 3, 4, 5, 6};
    EXPECT_EQ(nums1, expected);
}
```

## 总结

1. 有序序列合并用双指针逐个取小；
2. 当前实现用临时容器，直观但 O(m+n) 空间；
3. 面试标准解法从后向前写，原地 O(1)。
