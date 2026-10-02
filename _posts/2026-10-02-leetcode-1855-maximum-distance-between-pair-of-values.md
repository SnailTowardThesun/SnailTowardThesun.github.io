---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1855: 下标对中的最大距离"
categories: LeetCode
---

> 两个非递增数组求满足 `nums1[i] <= nums2[j]` 的最大 `j-i`，单调性质天然适合双指针或二分查找。

## 题目

LeetCode 1855. Maximum Distance Between a Pair of Values（下标对中的最大距离）

Difficulty: **Medium**

给你两个下标从 `0` 开始的整数数组 `nums1` 和 `nums2`，两者都是**非递增**数组。请你从 `nums1` 中选 `i`，从 `nums2` 中选 `j`，满足 `i <= j` 且 `nums1[i] <= nums2[j]`。返回满足条件的最大距离 `j - i`。若不存在满足条件的下标对，返回 `0`。

### 示例

```
示例 1：
输入：nums1 = [55,30,5,4,2], nums2 = [100,20,10,10,5]
输出：2
解释：满足条件的下标对为 (2,4)，nums1[2]=5 <= nums2[4]=5，距离 4-2=2。

示例 2：
输入：nums1 = [2,2,2], nums2 = [10,10,1]
输出：1
```

## 解题思路

### 方法一：二分查找（O(n log m)）

`nums2` 非递增，对每个 `nums1[i]`，需要在 `nums2` 中找到最靠右的满足 `nums2[j] >= nums1[i]` 的位置。

- 用 `upper_bound` 配合 `greater<int>{}` 在非递增序列中找到第一个**小于** `nums1[i]` 的位置 `pos`；
- 满足条件的最大 `j = pos - 1`；
- 若 `pos > i`，更新最大距离 `pos - 1 - i`。

### 方法二：双指针（O(n + m)，最优）

利用两数组的非递增性质，用两个指针 `i`、`j` 同步扫描：

1. `nums1[i] <= nums2[j]`：满足条件，更新 `ret = max(ret, j - i)`，然后 `j++`（尝试更大的距离）；
2. `nums1[i] > nums2[j]`：当前 `i` 无法与 `j` 配对，`i++`（换一个更小的 `nums1[i]`）；
3. 直到任一指针越界。

正确性：当 `nums1[i] > nums2[j]` 时，由于 `nums1` 非递增，所有 `i' > i` 都有 `nums1[i'] <= nums1[i]`，所以移动 `i` 不会错过更优解；而 `j` 只会单调前进，保证线性复杂度。

### 复杂度分析

- **二分法**：时间 O(n log m)，空间 O(1)。
- **双指针**：时间 O(n + m)，空间 O(1)。

## 代码实现

```cpp
// 方法一：二分查找
class Solution {
   public:
    int maxDistance(vector<int>& nums1, vector<int>& nums2) {
        int ret = 0;
        for (int i = 0; i < nums1.size(); ++i) {
            auto t = nums1[i];
            auto pos = upper_bound(nums2.begin(), nums2.end(), t, greater<int>{}) - nums2.begin();
            if (pos > i) {
                ret = max(ret, static_cast<int>(pos - 1 - i));
            }
        }
        return ret;
    }
};

// 方法二：双指针
class Solution2 {
   public:
    int maxDistance(vector<int>& nums1, vector<int>& nums2) {
        int ret = 0;
        int i = 0, j = 0;
        while (i < nums1.size() && j < nums2.size()) {
            if (nums1[i] <= nums2[j]) {
                ret = max(ret, j - i);
                ++j;
            } else {
                ++i;
            }
        }
        return ret;
    }
};
```

### 代码解析

- `upper_bound(begin, end, t, greater<int>{})`：在非递增序列中找第一个小于 `t` 的位置。
- 双指针中 `j` 只增不减，是保证 O(n+m) 的关键。

## 测试用例

```cpp
TEST(Daily, 1855) {
    Solution s;
    auto nums1 = vector<int>{55, 30, 5, 4, 2};
    auto nums2 = vector<int>{100, 20, 10, 10, 5};
    auto ret = s.maxDistance(nums1, nums2);
    EXPECT_EQ(ret, 2);
}
```

## 总结

本题的核心是利用数组的**非递增**单调性：

1. 二分法利用 `upper_bound` + `greater` 快速定位最右满足条件的 `j`；
2. 双指针利用「`nums1[i]` 太大就右移 `i`、否则右移 `j` 扩距离」的贪心策略，达到线性复杂度。

双指针是这类「两个有序序列求最优配对」的首选。
