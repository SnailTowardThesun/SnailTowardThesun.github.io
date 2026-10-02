---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.16: 最接近的三数之和"
categories: LeetCode
---

> 三数之和的变体：不收集答案，只维护与 target 差值最小的和，一旦差值为 0 可立即返回。

## 题目

LeetCode 16. 3Sum Closest（最接近的三数之和）

Difficulty: **Medium**

给定整数数组 nums 和目标值 target，找出三个整数使它们的和最接近 target，返回这个和。假设每组输入只有唯一答案。

### 示例

```
输入：nums = [-1,2,1,-4], target = 1
输出：2
解释：-1 + 2 + 1 = 2，与 target 差值最小。
```

## 解题思路

### 排序 + 双指针

1. 排序后固定 nums[pos]，双指针扫描剩余区间。
2. 每次计算三数之和 tmp，用 `abs(tmp - target) < abs(ret - target)` 更新答案。
3. tmp < target 移动左指针，否则移动右指针。
4. `ret == target` 时差值已为 0，不可能更优，直接结束。

### 复杂度分析

- **时间复杂度**：O(n²)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int threeSumClosest(vector<int>& nums, int target) {
        int ret = nums[0] + nums[1] + nums[2];
        sort(nums.begin(), nums.end());

        for (int pos = 0; pos < nums.size(); pos++) {
            int left = pos + 1, right = nums.size() - 1;
            while (left < right) {
                int tmp = nums[pos] + nums[left] + nums[right];
                if (abs(tmp - target) < abs(ret - target)) ret = tmp;
                if (ret == target) return ret;
                if (tmp < target) left++;
                else right--;
            }
        }
        return ret;
    }
};
```

### 代码解析

- 博客版用前三个元素之和作为初始值（比源文件中的 INT_MAX 写法更简洁安全）。
- 命中 target 立即返回，是本题最常用的剪枝。

## 测试用例

```cpp
TEST(Daily, 16) {
    Solution s;
    vector<int> nums1 = {-1, 2, 1, -4};
    EXPECT_EQ(s.threeSumClosest(nums1, 1), 2);
    vector<int> nums3 = {1, 1, 1, 0};
    EXPECT_EQ(s.threeSumClosest(nums3, -100), 2);
}
```

## 总结

1. 框架与三数之和完全相同，区别只在更新条件；
2. 用绝对差值比较接近程度；
3. 差值为 0 立即返回。
