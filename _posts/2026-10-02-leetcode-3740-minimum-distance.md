---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3740: 最小距离"
categories: LeetCode
---

> 相同元素的位置按值分组后，对位置列表做「间隔一位」的差分再乘 2，即可得到题目定义的最小距离。

## 题目

LeetCode 3740. Minimum Distance（最小距离）

Difficulty: **Easy**

给定一个整数数组 `nums`，计算数组中相同元素之间的最小距离。具体来说，对于数组中每一个元素，找到与其值相同的其他元素的位置，计算它们之间的距离，然后取所有距离中的最小值。如果数组中没有重复元素，返回 `-1`。

### 示例

```
示例 1：
输入：nums = [1, 2, 1, 1, 3]
输出：6
```

## 解题思路

### 哈希表分组 + 间隔取差

1. 用哈希表记录每个元素值对应的所有出现下标（递增有序）。
2. 对每个值的下标列表 `values`，遍历 `j` 从 2 开始，计算 `(values[j] - values[j - 2]) * 2`。
3. 维护全局最小值 `ret`。
4. 若 `ret` 仍为 `INT_MAX`，返回 `-1`，否则返回 `ret`。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(n)，哈希表存储位置。

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

## 测试用例

```cpp
TEST(Daily, 3740) {
    Solution s;
    vector<int> nums{1,2,1,1,3};
    auto ret = s.minimumDistance(nums);
    EXPECT_EQ(ret, 6);
}
```

## 总结

本题与 No.3741 思路一致：按值分组位置列表，取 `(values[j] - values[j-2]) * 2` 的最小值。
