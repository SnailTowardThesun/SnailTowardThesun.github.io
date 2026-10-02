---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.11: 盛最多水的容器"
categories: LeetCode
---

> 双指针从两端向中间收缩，每次移动较矮的一侧——这是双指针贪心最经典的入门题。

## 题目

LeetCode 11. Container With Most Water（盛最多水的容器）

Difficulty: **Medium**

给你 n 个非负整数 height，每个数代表坐标中的一条垂直线。找出两条线，使它们与 x 轴构成的容器能容纳最多的水，返回最大面积。不能倾斜容器。

### 示例

```
输入：[1,8,6,2,5,4,8,3,7]
输出：49

输入：[1,1]
输出：1
```

## 解题思路

### 双指针贪心

面积 = `min(height[left], height[right]) × (right - left)`。

1. 两指针分别指向首尾，此时宽度最大。
2. 每次移动高度较小的一侧：移动较高侧时宽度减小、高度上限不变，面积不可能增大；只有移动较矮侧才可能找到更高的线。
3. 记录过程中最大面积，两指针相遇即结束。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int maxArea(vector<int>& height) {
        int i = 0;
        int j = height.size() - 1;
        int result = 0;
        while (i < j) {
            int area = (j - i) * min(height[i], height[j]);
            result = max(result, area);
            if (height[i] <= height[j]) i++;
            else j--;
        }
        return result;
    }
};
```

### 代码解析

- `height[i] <= height[j]` 时移动左指针，否则移动右指针，相等时移哪一侧均可。

## 测试用例

```cpp
TEST(Daily, 11) {
    Solution s;
    vector<int> height1 = {1, 8, 6, 2, 5, 4, 8, 3, 7};
    EXPECT_EQ(s.maxArea(height1), 49);
    vector<int> height3 = {4, 3, 2, 1, 4};
    EXPECT_EQ(s.maxArea(height3), 16);
}
```

## 总结

1. 首尾双指针保证从最大宽度开始；
2. 只移动较矮侧，因为较高侧不可能带来更优解；
3. O(n) 时间 O(1) 空间。
