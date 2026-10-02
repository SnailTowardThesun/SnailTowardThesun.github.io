---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.26: 删除有序数组中的重复项"
categories: LeetCode
---

> 快慢指针的经典场景：慢指针写、快指针探，发现不同值就把它复制到慢指针后一格。

## 题目

LeetCode 26. Remove Duplicates from Sorted Array（删除有序数组中的重复项）

Difficulty: **Easy**

给定有序数组，原地删除重复元素使每个值只出现一次，返回新长度。O(1) 额外空间。

### 示例

```
输入：nums = [1,1,2]
输出：2，前两个元素为 1,2

输入：nums = [0,0,1,1,1,2,2,3,3,4]
输出：5，前五个元素为 0,1,2,3,4
```

## 解题思路

### 快慢双指针

- i 是慢指针，标记当前已保留区间的末尾。
- j 是快指针，扫描数组。
- nums[i] == nums[j]：重复，j 继续前进。
- 不同：把 nums[j] 复制到 i+1，两指针各进一步。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int removeDuplicates(int A[], int n) {
        if (n <= 1) return n;
        int i = 0, j = 1;
        while (j < n) {
            if (A[i] == A[j]) j++;
            else A[++i] = A[j++];
        }
        return i + 1;
    }
};
```

### 代码解析

- 长度 0 或 1 直接返回，新长度是 `i + 1`（下标转个数）。

## 测试用例

```cpp
TEST(Daily, 26) {
    Solution s;
    int A2[] = {0, 0, 1, 1, 1, 2, 2, 3, 3, 4};
    EXPECT_EQ(s.removeDuplicates(A2, 10), 5);
    int A4[] = {1, 2};
    EXPECT_EQ(s.removeDuplicates(A4, 2), 2);
}
```

## 总结

1. 有序数组的相邻重复，用读写双指针一次扫完；
2. 值不同才写入慢指针后一格；
3. 返回慢指针位置加一。
