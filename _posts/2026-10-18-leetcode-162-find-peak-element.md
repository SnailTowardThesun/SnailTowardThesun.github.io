---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.162: 寻找峰值"
categories: LeetCode
tags: [中等, 数组, 二分查找]
---

> 山脉数组中只要一直往“上坡”走，即使不知道山顶在哪，也一定会遇到一个峰值。

## 题目

LeetCode 162. Find Peak Element（寻找峰值）

Difficulty: **Medium**

给你一个整数数组 `nums`，相邻两个元素互不相同。峰值元素是严格大于其左右相邻值的元素。数组边界视为 `-∞`，因此边界元素只需要大于相邻一侧元素。返回任意一个峰值下标，算法必须达到 `O(log n)`。

### 示例

```
输入：nums = [1,2,3,1]
输出：2
解释：3 是峰值，它的下标是 2。

输入：nums = [1,2,1,3,5,6,4]
输出：1 或 5
解释：2 和 6 都是峰值，返回任意一个下标即可。
```

## 解题思路

### 二分攀爬

比较 `nums[mid]` 与 `nums[mid + 1]`，可以判断当前位置是在上坡还是下坡：

1. 若 `nums[mid] < nums[mid + 1]`，当前位置向右上升。沿着上升方向走，且右边界外是 `-∞`，右侧闭区间内必定存在峰值，因此令 `left = mid + 1`。
2. 否则当前位置向右下降或 `mid` 本身就是峰值。`mid` 不能被排除，因此令 `right = mid`。
3. 当 `left == right` 时，区间收缩到一个必然包含峰值的下标，直接返回。

### 复杂度分析

- **时间复杂度**：`O(log n)`，每次淘汰一半区间。
- **空间复杂度**：`O(1)`。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int findPeakElement(vector<int>& nums) {
        int left = 0;
        int right = static_cast<int>(nums.size()) - 1;

        while (left < right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] < nums[mid + 1]) {
                left = mid + 1;  // 上升方向必有峰值。
            } else {
                right = mid;  // mid 可能是峰值，不能丢掉。
            }
        }

        return left;
    }
};
```
{% endraw %}

### 代码解析

- `left < right` 保证 `mid + 1` 不会越界。
- 上坡时丢弃 `mid` 及其左侧；下坡时保留 `mid`，因此答案始终留在闭区间内。
- 题目允许返回任意峰值，所以无需比较左右两侧峰值谁更大。

## 测试用例

{% raw %}
```cpp
TEST(Top150, 162) {
    Solution s;
    vector<int> nums1{1, 2, 3, 1};
    EXPECT_EQ(s.findPeakElement(nums1), 2);

    vector<int> nums2{1, 2, 1, 3, 5, 6, 4};
    int peak = s.findPeakElement(nums2);
    EXPECT_TRUE(peak == 1 || peak == 5);

    vector<int> nums3{1};
    EXPECT_EQ(s.findPeakElement(nums3), 0);
}
```
{% endraw %}

## 总结

1. 峰值不要求全局最大，只需局部最大。
2. 相邻元素不相等保证中点必然处于明确的上坡或下坡。
3. 二分的正确性来自“保留的区间内一定仍有峰值”这个循环不变量。
