---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.153: 寻找旋转排序数组中的最小值"
categories: LeetCode
---

> 二分查找是计算机科学中最基础也最重要的算法之一，它在有序数据上的查找效率远超线性扫描，广泛应用于数据库索引、编译器设计等场景。

## 题目

LeetCode 153. Find Minimum in Rotated Sorted Array（寻找旋转排序数组中的最小值）

Difficulty: **Medium**

已知一个长度为 n 的数组，预先按照升序排列，经由 1 到 n 次旋转后，得到旋转后的数组 nums。

请你找出并返回数组中的最小元素。

你必须设计一个时间复杂度为 O(log n) 的算法解决此问题。

### 示例

```
示例 1：
输入：nums = [3,4,5,1,2]
输出：1
解释：原数组为 [1,2,3,4,5]，旋转 3 次得到。最小元素是 1。

示例 2：
输入：nums = [4,5,6,7,0,1,2]
输出：0
解释：原数组为 [0,1,2,4,5,6,7]，旋转 4 次得到。最小元素是 0。

示例 3：
输入：nums = [11,13,15,17]
输出：11
解释：原数组为 [11,13,15,17]，旋转 4 次得到。最小元素是 11。
```

## 解题思路

这道题要求使用 O(log n) 的时间复杂度，因此需要使用二分查找来解决。

### 核心思路

1. **二分查找原理**：
   - 比较 nums[mid] 和 nums[right]
   - 如果 nums[mid] < nums[right]，说明右半部分是有序的，最小值在左半部分（包括 mid）
   - 如果 nums[mid] >= nums[right]，说明左半部分是有序的，最小值在右半部分（不包括 mid）

2. **算法步骤**：
   - 初始化 left = 0, right = nums.size() - 1
   - 当 left < right 时：
     - 计算 mid = left + (right - left) / 2
     - 如果 nums[mid] < nums[right]，right = mid
     - 否则 left = mid + 1
   - 返回 nums[left]

### 算法详解

以示例 2 的 nums = [4,5,6,7,0,1,2] 为例：

```
步骤 1：初始化
left = 0, right = 6

步骤 2：第一次循环
mid = 0 + (6 - 0) / 2 = 3
nums[3] = 7, nums[6] = 2
因为 7 >= 2，最小值在右半部分
left = mid + 1 = 4

步骤 3：第二次循环
left = 4, right = 6
mid = 4 + (6 - 4) / 2 = 5
nums[5] = 1, nums[6] = 2
因为 1 < 2，最小值在左半部分（包括 mid）
right = mid = 5

步骤 4：第三次循环
left = 4, right = 5
mid = 4 + (5 - 4) / 2 = 4
nums[4] = 0, nums[5] = 1
因为 0 < 1，最小值在左半部分（包括 mid）
right = mid = 4

步骤 5：循环结束
left = 4, right = 4，循环结束
返回 nums[4] = 0

最终结果：0
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int findMin(vector<int>& nums) {
        int left = 0, right = nums.size() - 1;
        while (left < right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] < nums[right]) {
                right = mid;
            } else {
                left = mid + 1;
            }
        }

        return nums[left];
    }
};
```
{% endraw %}

### 代码解析

1. **初始化**：left = 0, right = nums.size() - 1
2. **循环条件**：当 left < right 时继续循环
3. **中间位置计算**：mid = left + (right - left) / 2（防止整数溢出）
4. **分支判断**：
   - 如果 nums[mid] < nums[right]，说明右半部分有序，最小值在左半部分（right = mid）
   - 否则最小值在右半部分（left = mid + 1）
5. **返回结果**：循环结束时 left == right，指向最小值

### 复杂度分析

- **时间复杂度**: O(log n)，每次将搜索区间减半
- **空间复杂度**: O(1)，只需要常数级别额外空间

## 测试用例

{% raw %}
```cpp
TEST(Daily, 153) {
    Solution s;

    // 测试用例 1
    auto nums1 = vector<int>{3, 4, 5, 1, 2};
    EXPECT_EQ(s.findMin(nums1), 1);

    // 测试用例 2
    auto nums2 = vector<int>{4, 5, 6, 7, 0, 1, 2};
    EXPECT_EQ(s.findMin(nums2), 0);

    // 测试用例 3
    auto nums3 = vector<int>{11, 13, 15, 17};
    EXPECT_EQ(s.findMin(nums3), 11);

    // 测试用例 4
    auto nums4 = vector<int>{5, 1, 2, 3, 4};
    EXPECT_EQ(s.findMin(nums4), 1);
}
```
{% endraw %}

## 总结

这道题是二分查找的经典应用。关键在于理解旋转数组的性质，以及如何利用 mid 和 right 的大小关系来判断最小值的位置。这种二分查找的变形技巧在面试中经常出现，值得熟练掌握。
