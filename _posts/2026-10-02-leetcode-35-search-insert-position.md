---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.35: 搜索插入位置"
categories: LeetCode
---

> 本质是找第一个 >= target 的位置（lower_bound）。二分写法 O(log n)，循环结束时 left 就是答案。

## 题目

LeetCode 35. Search Insert Position（搜索插入位置）

Difficulty: **Easy**

给定排序数组（无重复）和目标值，找到则返回索引，否则返回应插入的位置。

### 示例

```
输入：nums = [1,3,5,6], target = 5    输出：2
输入：nums = [1,3,5,6], target = 2    输出：1
输入：nums = [1,3,5,6], target = 7    输出：4
```

## 解题思路

### 二分查找 lower_bound

找「第一个大于等于 target 的位置」：
1. nums[mid] < target：答案在右侧，`left = mid + 1`。
2. nums[mid] >= target：答案可能是 mid 或更左，`right = mid - 1`。
3. 循环结束时 left 指向插入位置；target 大于所有元素时 left 自然等于数组长度。

源文件采用线性扫描，二分是其 O(log n) 优化版。

### 复杂度分析

- **时间复杂度**：O(log n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int searchInsert(vector<int>& nums, int target) {
        int left = 0, right = nums.size() - 1;
        while (left <= right) {
            int mid = (left + right) / 2;
            if (nums[mid] < target) left = mid + 1;
            else right = mid - 1;
        }
        return left;
    }
};
```

### 代码解析

- 与标准库 `lower_bound` 语义完全一致，可直接调用但面试中建议手写。

## 测试用例

```cpp
TEST(Daily, 35) {
    Solution s;
    vector<int> nums = {1, 3, 5, 6};
    EXPECT_EQ(s.searchInsert(nums, 5), 2);
    EXPECT_EQ(s.searchInsert(nums, 2), 1);
    EXPECT_EQ(s.searchInsert(nums, 7), 4);
    EXPECT_EQ(s.searchInsert(nums, 0), 0);
}
```

## 总结

1. 插入位置即 lower_bound；
2. 二分收缩后 left 即答案，自动覆盖插在尾部的情况；
3. O(log n) 时间 O(1) 空间。
