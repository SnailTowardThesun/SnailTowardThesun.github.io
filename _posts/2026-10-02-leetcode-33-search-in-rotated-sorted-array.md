---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.33: 搜索旋转排序数组"
categories: LeetCode
---

> 旋转数组二分的关键：每次中点都能保证至少一半是完全有序的，先判断有序区间是否包含 target，再决定往哪边走。

## 题目

LeetCode 33. Search in Rotated Sorted Array（搜索旋转排序数组）

Difficulty: **Medium**

升序数组在下标 k 处被旋转，元素互不相同。给定旋转后的数组和 target，返回其下标，不存在返回 -1。要求 O(log n)。

### 示例

```
输入：nums = [4,5,6,7,0,1,2], target = 0
输出：4

输入：nums = [5,1,2,3,4], target = 3
输出：3
```

## 解题思路

### 改进二分查找

取中点 mid 后，`[left, mid]` 和 `[mid, right]` 中至少有一半保持有序：

1. 若 `nums[0] <= nums[mid]`：左半有序。
   - target 在 `[nums[0], nums[mid])` 区间则搜左半，否则搜右半。
2. 否则：右半有序。
   - target 在 `(nums[mid], nums[n-1]]` 区间则搜右半，否则搜左半。

### 复杂度分析

- **时间复杂度**：O(log n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int search(vector<int>& nums, int target) {
        if (nums.empty()) return -1;

        int left = 0, right = nums.size() - 1;
        while (left <= right) {
            int mid = (left + right) / 2;
            if (nums[mid] == target) return mid;

            if (nums[0] <= nums[mid]) {  // 左半有序
                if (nums[0] <= target && target < nums[mid]) right = mid - 1;
                else left = mid + 1;
            } else {  // 右半有序
                if (nums[mid] < target && target <= nums[nums.size() - 1]) left = mid + 1;
                else right = mid - 1;
            }
        }
        return -1;
    }
};
```

### 代码解析

- 边界用严格/非严格不等号区分，保证 mid 自身不会被重复纳入。

## 测试用例

```cpp
TEST(Daily, 33) {
    Solution s;
    auto nums3 = vector<int>{5, 1, 2, 3, 4};
    EXPECT_EQ(s.search(nums3, 3), 3);
    EXPECT_EQ(s.search(nums3, 1), 1);
}
```

## 总结

1. 旋转不破坏「至少一半有序」，这是二分的前提；
2. 先识别有序半，再判断 target 是否落在其中；
3. 全程保持 O(log n)。

## 补充：Top 150 动态区间实现

Top 150 源文件将有序区间判断改为使用当前区间的 `nums[left]` 与 `nums[right]`，而不是固定比较 `nums[0]` 与 `nums[n - 1]`。二者算法思想相同，但动态端点让每次判断直接描述当前闭区间，收缩后的边界更直观。

{% raw %}
```cpp
class Solution {
public:
    int search(vector<int>& nums, int target) {
        int left = 0;
        int right = static_cast<int>(nums.size()) - 1;

        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) {
                return mid;
            }

            if (nums[left] <= nums[mid]) {
                // 左半 [left, mid] 有序。
                if (nums[left] <= target && target < nums[mid]) {
                    right = mid - 1;
                } else {
                    left = mid + 1;
                }
            } else {
                // 右半 [mid, right] 有序。
                if (nums[mid] < target && target <= nums[right]) {
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

### 补充要点

- `nums[left] <= nums[mid]` 能同时覆盖单元素有序半和数组未旋转的情况。
- 有序半的值域判断必须包含端点；因为 `nums[mid] == target` 已提前返回，左侧可用 `target < nums[mid]` 排除 mid。
- 该版本同样为 `O(log n)` 时间、`O(1)` 空间。
