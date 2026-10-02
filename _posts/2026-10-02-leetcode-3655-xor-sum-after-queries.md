---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3655: 执行查询后的异或和"
categories: LeetCode
---

> 区间内步长为 k 的乘法更新，直接暴力模拟即可；最后对整个数组求异或和。注意乘法取模防止溢出。

## 题目

LeetCode 3655. XOR Sum After Queries（执行查询后的异或和）

Difficulty: **Medium**

给定一个整数数组 `nums` 和一个二维数组 `queries`，其中 `queries[i] = [l, r, k, v]`。
对于每个查询，你需要将 `nums` 中从下标 `l` 到 `r`（包括 `l` 和 `r`）的元素，每隔 `k` 个元素（即 `l, l+k, l+2k, ...`）乘以 `v`，并对结果取模 `10^9 + 7`。
所有操作完成后，返回 `nums` 中所有元素的异或和。

### 示例

```
示例 1：
输入：nums = [1, 1, 1], queries = [[0, 2, 1, 4]]
输出：4
解释：执行查询后，nums 变为 [4, 4, 4]，异或结果为 4 ^ 4 ^ 4 = 4。
```

## 解题思路

### 暴力模拟 + 异或求和

1. 遍历每个查询 `[l, r, k, v]`，从 `l` 开始以步长 `k` 遍历到 `r`，将每个元素乘以 `v` 并取模 `10^9 + 7`。
2. 所有查询处理完后，遍历数组计算所有元素的异或和。

注意使用 `int64_t` 避免乘法溢出。

### 复杂度分析

- **时间复杂度**：O(q × (r-l)/k)，其中 q 是查询次数。
- **空间复杂度**：O(1)，原地修改数组。

## 代码实现

```cpp
class Solution {
private:
    const int mod = 1e9 + 7;

public:
    int xorAfterQueries(vector<int> &nums, vector<vector<int> > &queries) {
        for (auto query: queries) {
            int64_t l = query[0], r = query[1], k = query[2], v = query[3];
            for (int i = l; i <= r; i += k) {
                nums[i] = (nums[i] * v) % mod;
            }
        }

        int ret = nums[0];
        for (int i = 1; i < nums.size(); i++) {
            ret ^= nums[i];
        }
        return ret;
    }
};
```

### 代码解析

- `(nums[i] * v) % mod`：乘法后取模，防止 int 溢出。
- `for (int i = l; i <= r; i += k)`：步长为 k 的区间遍历。
- 最后 `ret ^= nums[i]` 求异或和。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3655) {
    Solution s;
    std::vector<int> nums{1, 1, 1};
    std::vector<std::vector<int> > queries{{0, 2, 1, 4}};

    auto ret = s.xorAfterQueries(nums, queries);
    EXPECT_EQ(ret, 4);
}
```
{% endraw %}

## 总结

本题直接模拟即可，关键点：

1. 步长 `k` 的区间遍历：`for (i = l; i <= r; i += k)`；
2. 乘法取模 `10^9 + 7`，用 `int64_t` 防溢出；
3. 最后求整个数组的异或和。
