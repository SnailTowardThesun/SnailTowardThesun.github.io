---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.154: 寻找旋转排序数组中的最小值 II"
categories: LeetCode
---

> 重复元素的存在会影响二分查找的效率，这道题展示了如何在存在重复元素的情况下进行有效的二分搜索。

## 题目

LeetCode 154. Find Minimum in Rotated Sorted Array II（寻找旋转排序数组中的最小值 II）

Difficulty: **Hard**

已知一个长度为 n 的数组，预先按照升序排列，经由 1 到 n 次旋转后，得到旋转后的数组 nums。

数组中可能包含重复元素。

请你找出并返回数组中的最小元素。

### 示例

```
示例 1：
输入：nums = [1,3,5]
输出：1

示例 2：
输入：nums = [2,2,2,0,1]
输出：0
```

## 解题思路

这道题是第 153 题的进阶版本，数组中可能包含重复元素。使用二分查找来解决。

### 核心思路

1. **二分查找原理**：
   - 比较 nums[mid] 和 nums[right]
   - 如果 nums[mid] < nums[right]，说明右半部分是有序的，最小值在左半部分（包括 mid）
   - 如果 nums[mid] > nums[right]，说明左半部分是有序的，最小值在右半部分（不包括 mid）
   - 如果 nums[mid] == nums[right]，无法确定最小值位置，需要缩小搜索范围（right--）

2. **为什么需要特殊处理重复元素**：
   - 当 nums[mid] == nums[right] 时，无法判断最小值在左半部分还是右半部分
   - 例如：[3,3,1,3] 和 [3,1,3,3]，mid=1, nums[mid]=3, nums[right]=3
   - 只能通过 right-- 逐步缩小范围

### 算法详解

以示例 2 的 nums = [2,2,2,0,1] 为例：

```
步骤 1：初始化
left = 0, right = 4

步骤 2：第一次循环
mid = 0 + (4 - 0) / 2 = 2
nums[2] = 2, nums[4] = 1
因为 2 > 1，最小值在右半部分
left = mid + 1 = 3

步骤 3：第二次循环
left = 3, right = 4
mid = 3 + (4 - 3) / 2 = 3
nums[3] = 0, nums[4] = 1
因为 0 < 1，最小值在左半部分（包括 mid）
right = mid = 3

步骤 4：循环结束
left = 3, right = 3，循环结束
返回 nums[3] = 0

最终结果：0
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int findMin(vector<int> &nums) {
        int left = 0, right = nums.size() - 1;
        while (left < right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == nums[right]) {
                right--;
            } else if (nums[mid] < nums[right]) {
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
   - 如果 nums[mid] == nums[right]，无法确定最小值位置，right--
   - 如果 nums[mid] < nums[right]，最小值在左半部分（right = mid）
   - 否则最小值在右半部分（left = mid + 1）
5. **返回结果**：循环结束时 left == right，指向最小值

### 复杂度分析

- **时间复杂度**: 平均 O(log n)，最坏 O(n)（当所有元素都相同时）
- **空间复杂度**: O(1)，只需要常数级别额外空间

## 测试用例

{% raw %}
```cpp
TEST(Daily, 154) {
    Solution s;

    // 测试用例 1
    auto eg1 = vector<int>{2, 2, 2, 0, 1};
    EXPECT_EQ(s.findMin(eg1), 0);

    // 测试用例 2
    auto eg2 = vector<int>{1, 3, 5};
    EXPECT_EQ(s.findMin(eg2), 1);

    // 测试用例 3
    auto eg3 = vector<int>{3, 3, 1, 3};
    EXPECT_EQ(s.findMin(eg3), 1);

    // 测试用例 4
    auto eg4 = vector<int>{1, 1, 1, 1};
    EXPECT_EQ(s.findMin(eg4), 1);
}
```
{% endraw %}

## 总结

这道题是经典的二分查找变形问题。当数组中存在重复元素时，我们需要特殊处理 nums[mid] == nums[right] 的情况。虽然最坏情况下时间复杂度会退化为 O(n)，但平均情况下仍然是高效的 O(log n)。这道题展示了二分查找在处理边界情况时的灵活性。
