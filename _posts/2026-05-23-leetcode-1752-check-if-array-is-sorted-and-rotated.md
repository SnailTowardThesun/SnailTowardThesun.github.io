---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1752: 检查数组是否经排序和轮转得到"
categories: LeetCode
---

> 数组轮转是一个常见的操作，在循环队列、轮询调度等场景中经常用到。理解轮转数组的特性有助于解决相关问题。

## 题目

LeetCode 1752. 检查数组是否经排序和轮转得到（Check if Array Is Sorted and Rotated）

Difficulty: **Easy**

给你一个数组 nums 。nums 的源数组中，所有元素与 nums 相同，但按非递减顺序排列。

如果 nums 能够由源数组轮转若干位置（包括 0 个位置）得到，则返回 true ；否则，返回 false 。

源数组中可能存在重复项。

注意：我们称数组 A 在轮转 x 个位置后得到长度相同的数组 B ，当它们满足 B[i] == A[(i+x) mod n] 。

### 示例

```
示例 1：
输入: nums = [3,4,5,1,2]
输出: true
解释: [1,2,3,4,5] 为有序的源数组。可以轮转 x=3 个位置，使新数组从值为 3 的元素开始。

示例 2：
输入: nums = [2,1,3,4]
输出: false
解释: 源数组无法经轮转得到 nums 。

示例 3：
输入: nums = [1,2,3,4]
输出: true
解释: 源数组为 [1,2,3,4]，轮转 0 个位置得到 nums 。
```

## 解题思路

### 统计逆序对法

这道题的关键在于理解轮转排序数组的特性。

### 核心思路

1. **轮转数组的特性**：一个排序后轮转的数组最多只有一个"断点"，即 nums[i] > nums[i+1] 的位置
2. **循环检查**：需要考虑数组是循环的，即 nums[n-1] > nums[0] 也需要检查
3. **判断条件**：如果逆序对数量 <= 1，则返回 true

### 算法详解

以 nums = [3,4,5,1,2] 为例：

```
遍历数组：
3 <= 4 ✓
4 <= 5 ✓
5 > 1 ✗ （找到一个断点）
1 <= 2 ✓
2 <= 3 ✓ （循环检查）

总共有 1 个断点，返回 true
```

以 nums = [2,1,3,4] 为例：

```
遍历数组：
2 > 1 ✗ （找到一个断点）
1 <= 3 ✓
3 <= 4 ✓
4 > 2 ✗ （找到第二个断点）

总共有 2 个断点，返回 false
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    bool check(vector<int>& nums) {
        int n = static_cast<int>(nums.size());
        int count = 0;
        
        for (int i = 0; i < n; ++i) {
            if (nums[i] > nums[(i + 1) % n]) {
                ++count;
            }
        }
        
        return count <= 1;
    }
};
```
{% endraw %}

### 代码解析

1. **初始化**：获取数组长度 n，初始化计数器 count 为 0
2. **遍历检查**：对于每个位置 i，检查 nums[i] > nums[(i+1) % n]
3. **循环检查**：使用取模运算实现数组的循环特性
4. **判断结果**：如果断点数量 <= 1，返回 true；否则返回 false

### 复杂度分析

- **时间复杂度**: O(n)，只需要遍历数组一次
- **空间复杂度**: O(1)，只使用了常数个变量

## 测试用例

{% raw %}
```cpp
TEST(Daily, 1752) {
    Solution s;

    // 测试用例 1：轮转后的数组
    auto nums1 = vector<int>{3, 4, 5, 1, 2};
    EXPECT_TRUE(s.check(nums1));

    // 测试用例 2：不是轮转后的数组
    auto nums2 = vector<int>{2, 1, 3, 4};
    EXPECT_FALSE(s.check(nums2));

    // 测试用例 3：完全有序（轮转 0 次）
    auto nums3 = vector<int>{1, 2, 3, 4};
    EXPECT_TRUE(s.check(nums3));

    // 测试用例 4：包含重复元素
    auto nums4 = vector<int>{2, 2, 2, 3, 1};
    EXPECT_TRUE(s.check(nums4));

    // 测试用例 5：只有一个元素
    auto nums5 = vector<int>{1};
    EXPECT_TRUE(s.check(nums5));

    // 测试用例 6：只有两个元素
    auto nums6 = vector<int>{1, 2};
    EXPECT_TRUE(s.check(nums6));
    auto nums7 = vector<int>{2, 1};
    EXPECT_TRUE(s.check(nums7));
}
```
{% endraw %}

## 总结

这道题的核心在于理解轮转排序数组的特性：

1. **断点概念**：轮转后的数组只有一个断点（nums[i] > nums[i+1]）
2. **循环特性**：需要检查 nums[n-1] > nums[0]
3. **判断条件**：断点数量 <= 1

这道题是一个很好的练习，可以帮助我们理解数组轮转和排序的关系。代码虽然简单，但思路很巧妙，需要仔细思考才能想到。
