---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3488: 环形数组中最近的相同元素"
categories: LeetCode
---

> 环形数组上的最近距离 = min(直接距离, 数组长度 - 直接距离)。配合「值→位置列表」+ 二分查找即可高效求解。

## 题目

LeetCode 3488. Closest Element in Circular Array（环形数组中最近的相同元素）

Difficulty: **Medium**

给你一个整数数组 `nums`（视为**环形数组**，首尾相连）和一个查询数组 `queries`。对于每个查询 `queries[i]`，表示数组中的一个下标，请你找到与该下标处元素值**相同**的最近元素的距离（沿环顺时针或逆时针）。若该值在数组中只出现一次，返回 `-1`。

### 示例

```
输入：nums = [1, 3, 1, 4, 1, 3, 2], queries = [0, 3, 5]
输出：[2, -1, 3]
解释：
- queries[0]=0，nums[0]=1，最近的 1 在位置 2，环形距离 min(2, 7-2)=2。
- queries[1]=3，nums[3]=4，只出现一次，返回 -1。
- queries[2]=5，nums[5]=3，最近的 3 在位置 1，环形距离 min(4, 7-4)=3。
```

## 解题思路

### 哈希表分组 + 二分查找

1. 预处理：用哈希表 `container` 记录每个值对应的所有出现位置（递增有序）。
2. 对每个查询位置 `query_pos`：
   - 取出该值的位置列表 `positions`；若长度 < 2，返回 `-1`。
   - 用 `lower_bound` 找到 `query_pos` 在 `positions` 中的插入点 `current_pos`。
   - 候选最近元素为 `current_pos` 的**前一个**和**后一个**位置；边界处回绕到列表另一端。
3. 对每个候选位置 `pos`，计算环形距离 `min(|pos - query_pos|, n - |pos - query_pos|)`，取最小值。

### 复杂度分析

- **时间复杂度**：预处理 O(n)，单次查询 O(log k)（k 为该值出现次数），总 O(n + q log k)。
- **空间复杂度**：O(n)，哈希表存储所有位置。

## 代码实现

```cpp
class Solution {
   public:
    vector<int> solveQueries(vector<int>& nums, vector<int>& queries) {
        vector<int> ret(queries.size(), -1);
        unordered_map<int, std::vector<int>> container;

        for (int i = 0; i < nums.size(); i++) {
            container[nums[i]].push_back(i);
        }

        int n = nums.size();
        for (auto i = 0; i < queries.size(); i++) {
            int query_pos = queries[i];
            int t = nums[query_pos];
            auto it = container.find(t);
            if (it->second.size() < 2) {
                continue;
            }

            int tmp_ret = INT_MAX;
            const auto& positions = it->second;
            auto current_pos = lower_bound(positions.begin(), positions.end(), query_pos);

            // 计算环形最小距离的辅助函数
            auto calculate_min_distance = [&](int pos) {
                int dir = abs(pos - query_pos);
                int cir = n - dir;
                return min(cir, dir);
            };

            // 检查前一个元素
            if (current_pos != positions.begin()) {
                tmp_ret = min(tmp_ret, calculate_min_distance(*(current_pos - 1)));
            } else if (positions.size() > 1) {
                // 环形情况：检查最后一个元素
                tmp_ret = min(tmp_ret, calculate_min_distance(positions.back()));
            }

            // 检查后一个元素
            if (current_pos != positions.end() - 1) {
                tmp_ret = min(tmp_ret, calculate_min_distance(*(current_pos + 1)));
            } else if (positions.size() > 1) {
                // 环形情况：检查第一个元素
                tmp_ret = min(tmp_ret, calculate_min_distance(positions.front()));
            }

            ret[i] = tmp_ret;
        }

        return ret;
    }
};
```

### 代码解析

- `container[nums[i]].push_back(i)`：同一值的位置天然递增，便于二分。
- `lower_bound` 定位查询位置在有序位置列表中的位置，只需检查前后相邻位置即可（最近元素必在相邻位置中）。
- `calculate_min_distance` 同时考虑顺时针（直接距离）和逆时针（`n - 直接距离`）两种方向。

## 测试用例

```cpp
TEST(Daily, 3488) {
    Solution s;
    auto nums = vector<int>{1, 3, 1, 4, 1, 3, 2};
    auto queries = vector<int>{0, 3, 5};

    auto ret = s.solveQueries(nums, queries);
    EXPECT_EQ(ret.size(), 3);
}
```

## 总结

本题的关键技巧：

1. **按值分组**：相同值的位置存入有序列表，把「找最近相同值」转化为「在有序列表中找相邻位置」；
2. **二分定位**：`lower_bound` 快速找到查询位置的相邻候选；
3. **环形距离**：`min(|i-j|, n - |i-j|)` 统一处理首尾相连。
