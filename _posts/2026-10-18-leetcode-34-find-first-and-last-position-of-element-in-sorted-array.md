---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.34: 在排序数组中查找元素的第一个和最后一个位置"
categories: LeetCode
---

> 二分查找不止能判断“有没有”，还能通过命中后继续向左或向右收缩，精确找到重复元素的边界。

## 题目

LeetCode 34. Find First and Last Position of Element in Sorted Array（在排序数组中查找元素的第一个和最后一个位置）

Difficulty: **Medium**

给定一个非递减整数数组 `nums` 和目标值 `target`。如果 `target` 在数组中存在，返回它的开始位置和结束位置；如果不存在，返回 `[-1, -1]`。算法时间复杂度必须为 `O(log n)`。

### 示例

```
输入：nums = [5,7,7,8,8,10], target = 8
输出：[3,4]

输入：nums = [5,7,7,8,8,10], target = 6
输出：[-1,-1]

输入：nums = [], target = 0
输出：[-1,-1]
```

## 解题思路

### 两次方向不同的二分

普通二分找到任意一个 `target` 后会立即返回，但本题需要左右边界，因此命中后不能停止：

1. **找左边界**：当 `nums[mid] == target` 时记录 `mid`，并令 `right = mid - 1`，继续向左找更小下标。
2. **判断存在性**：若第一轮没有命中，说明 `target` 不存在，直接返回 `[-1, -1]`。
3. **找右边界**：第二轮命中后记录 `mid`，并令 `left = mid + 1`，继续向右找更大下标。

第二轮的初始 `left` 可以直接设为第一轮得到的左边界，因为右边界不可能出现在左边界之前。

### 复杂度分析

- **时间复杂度**：`O(log n)`，两次独立二分。
- **空间复杂度**：`O(1)`，只保存常数个下标。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        if (nums.empty()) {
            return {-1, -1};
        }

        int first = -1;
        int last = -1;
        int left = 0;
        int right = static_cast<int>(nums.size()) - 1;

        // 第一轮：即使命中，也继续向左收缩，最终 first 是最左下标。
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) {
                first = mid;
            }

            if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        if (first == -1) {
            return {-1, -1};
        }

        left = first;
        right = static_cast<int>(nums.size()) - 1;

        // 第二轮：即使命中，也继续向右收缩，最终 last 是最右下标。
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) {
                last = mid;
            }

            if (nums[mid] <= target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return {first, last};
    }
};
```
{% endraw %}

### 代码解析

- 第一轮比较条件是 `nums[mid] < target`；命中或大于 `target` 都向左收缩，因此能找最左位置。
- 第二轮比较条件是 `nums[mid] <= target`；命中时也向右收缩，因此能找最右位置。
- `left + (right - left) / 2` 可避免下标相加溢出。

## 测试用例

{% raw %}
```cpp
TEST(Top150, 34) {
    Solution s;
    vector<int> nums{5, 7, 7, 8, 8, 10};
    EXPECT_EQ(s.searchRange(nums, 8), (vector<int>{3, 4}));
    EXPECT_EQ(s.searchRange(nums, 7), (vector<int>{1, 2}));
    EXPECT_EQ(s.searchRange(nums, 11), (vector<int>{-1, -1}));

    vector<int> allSame{2, 2, 2, 2};
    EXPECT_EQ(s.searchRange(allSame, 2), (vector<int>{0, 3}));
}
```
{% endraw %}

## 总结

1. 重复元素边界问题可以拆成“最左一次”和“最右一次”两个二分。
2. 命中目标只记录答案，不提前返回，才能继续收缩区间。
3. 两轮二分仍保持 `O(log n)`。
