---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2161: 根据给定的枢轴分割数组"
categories: LeetCode
---

> 双指针法是数组分割问题的常用技巧，可以在一次遍历中完成多种操作。

## 题目

LeetCode 2161. Partition Array According to Given Pivot（根据给定的枢轴分割数组）

Difficulty: **Medium**

给你一个下标从 0 开始的整数数组 nums 和一个整数 pivot。
请你将 nums 重新排列，使得以下条件均成立：

1. 所有小于 pivot 的元素都出现在所有大于 pivot 的元素之前。
2. 所有等于 pivot 的元素都出现在小于和大于 pivot 的元素之间。
3. 小于 pivot 的元素之间和大于 pivot 的元素之间的相对顺序保持不变。

请你返回重新排列后的数组。

### 示例

```
示例 1：
输入：nums = [9,12,5,10,14,3,10], pivot = 10
输出：[9,5,3,10,10,12,14]
解释：
小于 10 的元素是 [9,5,3]，它们按原顺序出现在数组开头。
等于 10 的元素是 [10,10]，它们出现在中间。
大于 10 的元素是 [12,14]，它们按原顺序出现在数组末尾。

示例 2：
输入：nums = [-3,4,3,2], pivot = 2
输出：[-3,2,4,3]
```

## 解题思路

这道题可以使用双指针法来解决，高效且直观。

### 核心思路

1. 创建一个结果数组，初始值全为 pivot
2. 使用两个指针：pre 从前往后填充小于 pivot 的元素，
   last 从后往前填充大于 pivot 的元素
3. 最后将大于 pivot 的部分反转，保持相对顺序

### 算法详解

以示例 1 为例：

```
输入：nums = [9,12,5,10,14,3,10], pivot = 10

步骤 1：初始化结果数组
ret = [10,10,10,10,10,10,10]
pre = 0, last = 6

步骤 2：遍历原数组
处理 9：小于 pivot，放入 ret[0]，pre = 1
处理 12：大于 pivot，放入 ret[6]，last = 5
处理 5：小于 pivot，放入 ret[1]，pre = 2
处理 10：等于 pivot，跳过
处理 14：大于 pivot，放入 ret[5]，last = 4
处理 3：小于 pivot，放入 ret[2]，pre = 3
处理 10：等于 pivot，跳过

此时 ret = [9,5,3,10,14,12,10]

步骤 3：反转大于 pivot 的部分
反转从 last+1 = 5 到末尾的部分：[12,10] → [10,12]

最终结果：[9,5,3,10,10,12,14]
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    vector<int> pivotArray(vector<int> &nums, int pivot) {
        int pre = 0;
        int last = nums.size() - 1;
        vector<int> ret(nums.size(), pivot);
        for (int i = 0; i < nums.size(); i++) {
            if (nums[i] > pivot) {
                ret[last--]=nums[i];
            } else if (nums[i] < pivot) {
                ret[pre++]=nums[i];
            }
        }

        // reverse last
        std::reverse(ret.begin() + last+1, ret.end());

        return ret;
    }
};
```
{% endraw %}

### 代码解析

1. **初始化结果数组**：大小与 nums 相同，初始值全为 pivot
2. **双指针遍历**：
   - pre 指针从 0 开始，last 指针从 nums.size()-1 开始
   - 小于 pivot 的元素放入 pre 位置，pre 后移
   - 大于 pivot 的元素放入 last 位置，last 前移
3. **反转大于 pivot 的部分**：保持相对顺序

### 复杂度分析

- **时间复杂度**: O(n)，需要遍历数组两次（一次构建，一次反转）
- **空间复杂度**: O(n)，需要额外的数组存储结果

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2161) {
    Solution s;
    vector<int> nums{9, 12, 5, 10, 14, 3, 10};
    int pivot = 10;
    auto ret = s.pivotArray(nums, pivot);
    EXPECT_EQ(ret[0], 9);
}
```
{% endraw %}

## 总结

这道题是一道经典的数组分割问题。通过使用双指针法，可以高效地完成数组的重新排列。关键点在于：
1. 初始化结果数组为 pivot，省去了单独处理等于 pivot 元素的步骤
2. 使用两个指针分别从两端填充小于和大于 pivot 的元素
3. 最后反转大于 pivot 的部分，保持相对顺序

这种方法逻辑清晰，容易理解，时间复杂度为 O(n)，适合处理此类数组分割问题。
