---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3741: 最小距离"
categories: LeetCode
---

> 相同元素的「最小距离」可以通过哈希表按值分组、再对位置列表做差来求；本题的特殊在于取间隔一个位置的距离乘 2。

## 题目

LeetCode 3741. Minimum Distance（最小距离）

Difficulty: **Easy**

给定一个整数数组 `nums`，计算数组中相同元素之间的最小距离。具体来说，对于数组中每一个元素，找到与其值相同的其他元素的位置，计算它们之间的距离，然后取所有距离中的最小值。如果数组中没有重复元素，返回 `-1`。

### 示例

```
示例 1：
输入：nums = [1, 2, 1, 1, 3]
输出：6
解释：元素 1 出现在下标 0, 2, 3。取下标 0 和 2，距离为 2，乘以 2 得 4；
      取下标 2 和 3（相邻）距离为 1，但本题取间隔为 2 的位置对 (0,2) 和 (2,3) 中的
      (values[j] - values[j-2]) * 2，即 (3-0)*2 = 6。
```

## 解题思路

### 哈希表分组 + 间隔取差

1. 用哈希表 `container` 记录每个元素值对应的所有出现下标（递增有序）。
2. 对每个值的下标列表 `values`，遍历 `j` 从 2 开始，计算 `(values[j] - values[j - 2]) * 2`。
3. 维护全局最小值 `ret`。
4. 若 `ret` 仍为初始值 `INT_MAX`，返回 `-1`，否则返回 `ret`。

### 复杂度分析

- **时间复杂度**：O(n)，遍历数组和位置列表各一次。
- **空间复杂度**：O(n)，哈希表存储所有位置。

## 代码实现

```cpp
class Solution {
   public:
    int minimumDistance(vector<int>& nums) {
        unordered_map<int, std::vector<int>> container;
        for (int i = 0; i < nums.size(); ++i) {
            container[nums[i]].push_back(i);
        }

        int ret = INT_MAX;
        for (auto i : container) {
            auto values = i.second;
            for (int j = 2; j < values.size(); ++j) {
                ret = min(ret, (values[j] - values[j - 2]) * 2);
            }
        }

        return ret == INT_MAX ? -1 : ret;
    }
};
```

### 代码解析

- `container[nums[i]].push_back(i)`：同一值的位置天然递增。
- `j` 从 2 开始，`values[j] - values[j-2]` 表示间隔一个位置的两个下标之差。
- 乘以 2 是题目定义的距离计算方式。

## 测试用例

```cpp
TEST(Daily, 3741) {
    Solution s;
    vector<int> nums{1, 2, 1, 1, 3};
    auto ret = s.minimumDistance(nums);
    EXPECT_EQ(ret, 6);
}
```

## 总结

本题的关键是**按值分组后对位置列表做间隔差分**：

1. 哈希表把相同值的下标收集到有序列表；
2. 遍历列表，计算 `(values[j] - values[j-2]) * 2`；
3. 取全局最小值，无符合条件则返回 -1。
