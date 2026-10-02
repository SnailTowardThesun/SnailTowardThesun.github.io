---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3653: 执行查询后的异或和"
categories: LeetCode
---

> 对区间内步长为 k 的元素做乘法更新并取模，最后求全数组异或和，是一道 straightforward 的模拟题。

## 题目

LeetCode 3653. XOR Sum After Queries（执行查询后的异或和）

Difficulty: **Medium**

给定一个整数数组 `nums` 和一个查询数组 `queries`，其中 `queries[i] = [l, r, k, v]`。
对于每个查询，对 `nums` 数组执行以下操作：将区间 `[l, r]` 中步长为 `k` 的元素都乘以 `v`，并对结果取模 `10^9 + 7`。执行完所有查询后，计算并返回数组中所有元素的异或结果。

### 示例

```
示例 1：
输入：nums = [1, 1, 1], queries = [[0, 2, 1, 4]]
输出：4
解释：执行查询后，nums 变为 [4, 4, 4]，异或结果为 4 ^ 4 ^ 4 = 4。
```

## 解题思路

### 暴力模拟 + 异或求和

1. 遍历每个查询，对区间 `[l, r]` 内步长为 `k` 的元素执行乘法并取模。
2. 所有查询完成后，遍历数组求异或和。
3. 使用 `int64_t` 存储查询参数，避免乘法溢出。

### 复杂度分析

- **时间复杂度**：O(q × (r-l)/k)。
- **空间复杂度**：O(1)，原地修改。

## 代码实现

```cpp
class Solution {
   public:
    int xorAfterQueries(std::vector<int>& nums, std::vector<std::vector<int> >& queries) {
        int mod = 1e9 + 7;
        // 处理每个查询
        for (auto query : queries) {
            int64_t l = query[0], r = query[1], k = query[2], v = query[3];
            // 对区间 [l, r] 中步长为 k 的元素执行乘法操作
            for (int i = l; i <= r; i += k) {
                nums[i] = (nums[i] * v) % mod;
            }
        }

        // 计算所有元素的异或结果
        int ret = nums[0];
        for (int i = 1; i < nums.size(); i++) {
            ret ^= nums[i];
        }
        return ret;
    }
};
```

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3653) {
    Solution s;
    std::vector<int> nums{1, 1, 1};
    std::vector<std::vector<int> > queries{{0, 2, 1, 4}};

    auto ret = s.xorAfterQueries(nums, queries);
    EXPECT_EQ(ret, 4);
}
```
{% endraw %}

## 总结

本题与 No.3655 思路一致，直接模拟查询并求异或和，注意乘法取模与数据类型溢出即可。
