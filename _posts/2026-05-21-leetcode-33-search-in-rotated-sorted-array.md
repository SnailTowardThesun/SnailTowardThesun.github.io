---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.33: 搜索旋转排序数组"
categories: LeetCode
---

> 二分查找是面试中最常考的算法之一，理解其变体对于应对各种场景至关重要。旋转排序数组是二分查找的重要扩展。

## 题目

LeetCode 33. 搜索旋转排序数组（Search in Rotated Sorted Array）

Difficulty: **Medium**

整数数组 nums 按升序排列，数组中的值互不相同。

给你一个整数数组 nums 和一个整数 target，nums 在预先未知的某个下标 k（0 <= k < nums.length）上进行了旋转。

给你旋转后的数组 nums 和整数 target，请你搜索 target 并返回其下标。如果 target 不存在于 nums 中，返回 -1。

你必须设计一个时间复杂度为 O(log n) 的算法解决此问题。

### 示例

```
示例 1：
输入: nums = [4,5,6,7,0,1,2], target = 0
输出: 4

示例 2：
输入: nums = [4,5,6,7,0,1,2], target = 3
输出: -1

示例 3：
输入: nums = [1], target = 0
输出: -1
```

## 解题思路

### 二分查找法

这道题的关键在于：虽然数组被旋转了，但仍然有一半是有序的。

### 核心思路

1. **判断哪一半是有序的**：比较 nums[0] 和 nums[mid] 的大小
2. **确定 target 的范围**：根据哪一半是有序的，以及 target 是否在有序范围内，来决定搜索方向
3. **递归/迭代**：不断缩小搜索范围，直到找到目标或确定不存在

### 算法详解

以 nums = [4,5,6,7,0,1,2], target = 0 为例：

```
初始: left=0, right=6
mid = (0+6)/2 = 3, nums[3]=7

判断: nums[0]=4 <= nums[3]=7，说明左半边 [4,5,6,7] 是有序的
target=0 不在 [4,7) 范围内，所以搜索右半边
left = mid + 1 = 4

left=4, right=6
mid = (4+6)/2 = 5, nums[5]=1

判断: nums[4]=0 <= nums[5]=1，说明左半边 [0,1] 是有序的
target=0 在 [0,1) 范围内，所以搜索左半边
right = mid - 1 = 4

left=4, right=4
mid = (4+4)/2 = 4, nums[4]=0

找到目标！返回 4
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int search(vector<int>& nums, int target) {
        if (nums.empty()) {
            return -1;
        }

        auto left = 0;
        auto right = nums.size() - 1;
        while (left <= right) {
            auto mid = (left + right) / 2;
            if (nums[mid] == target) {
                return mid;
            }
            if (nums[0] <= nums[mid]) {
                if (nums[0] <= target && target < nums[mid]) {
                    right = mid - 1;
                } else {
                    left = mid + 1;
                }
            } else {
                if (nums[mid] < target && target <= nums[nums.size() - 1]) {
                    left = mid + 1;
                } else {
                    right = mid - 1;
                }
            }
        }

        return -1;
    }
};
```
{% endraw %}

### 代码解析

1. **特殊情况处理**：如果数组为空，直接返回 -1
2. **二分查找主循环**：
   - 计算中点 mid
   - 如果找到 target，直接返回
   - 如果左半边有序，判断 target 是否在左半边范围内
   - 否则，target 一定在右半边
3. **未找到**：返回 -1

### 复杂度分析

- **时间复杂度**: O(log n)，每次搜索范围缩小一半
- **空间复杂度**: O(1)，只使用了常数个变量

## 测试用例

{% raw %}
```cpp
TEST(Daily, 33) {
    Solution s;

    auto nums1 = vector<int>{4, 5, 6, 7, 0, 1, 2};
    EXPECT_EQ(s.search(nums1, 0), 4);
    EXPECT_EQ(s.search(nums1, 3), -1);

    auto nums2 = vector<int>{1};
    EXPECT_EQ(s.search(nums2, 0), -1);
    EXPECT_EQ(s.search(nums2, 1), 0);

    auto nums3 = vector<int>{5, 1, 2, 3, 4};
    EXPECT_EQ(s.search(nums3, 3), 3);
    EXPECT_EQ(s.search(nums3, 1), 1);
}
```
{% endraw %}

## 总结

这道题的核心在于理解旋转排序数组的特性：

1. **旋转数组的特性**：虽然数组被旋转，但总有一半是有序的
2. **判断哪半边有序**：通过比较首元素和中点元素的大小来确定
3. **确定搜索范围**：根据 target 是否在有序范围内来决定搜索方向

关键点是：无论数组如何旋转，二分查找的思想始终适用。只需要多一步判断来确定 target 可能存在的范围。这道题是二分查找思想的重要扩展，理解后可以应对各种变体问题。
