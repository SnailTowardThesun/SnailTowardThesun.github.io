---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.135: 分发糖果"
categories: LeetCode
---

> 左扫满足「比左边高分就多一颗」，右扫满足「比右边高分就多一颗」，取两者最大值即同时满足双边约束。

## 题目

LeetCode 135. Candy（分发糖果）

Difficulty: **Hard**

n 个孩子站成一排，ratings 为各自评分。每人至少 1 颗糖，相邻孩子中评分更高者必须得到更多糖果。求最少需要准备多少颗糖。

### 示例

```
输入：ratings = [1,0,2]
输出：5（糖果数 2,1,2）

输入：ratings = [1,2,2]
输出：4（糖果数 1,2,1，相等评分不强制多给）
```

## 解题思路

### 两次遍历

1. candies 全部初始化为 1。
2. 从左向右：ratings[i] > ratings[i-1] 时 candies[i] = candies[i-1] + 1。
3. 从右向左：ratings[i] > ratings[i+1] 时 candies[i] = max(candies[i], candies[i+1]+1)，同时累加总数。

右扫取 max 而不是直接覆盖，是为了不破坏左扫已经确定的更大值。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(n)；利用峰谷分段统计可优化到 O(1)。

## 代码实现

```cpp
class Solution {
public:
    int candy(vector<int>& ratings) {
        int n = ratings.size();
        vector<int> candies(n, 1);

        for (int i = 1; i < n; i++) {
            if (ratings[i] > ratings[i - 1]) {
                candies[i] = candies[i - 1] + 1;
            }
        }

        int ret = candies[n - 1];
        for (int i = n - 2; i >= 0; i--) {
            if (ratings[i] > ratings[i + 1]) {
                candies[i] = max(candies[i], candies[i + 1] + 1);
            }
            ret += candies[i];
        }
        return ret;
    }
};
```

### 代码解析

- 递减序列在右扫时形成 k,k-1,...,1 的糖果分布，保证最少。

## 测试用例

```cpp
TEST(TOP150, No135_Candy) {
    Solution solution;
    vector<int> ratings1{1, 0, 2};
    EXPECT_EQ(5, solution.candy(ratings1));
    vector<int> ratings4{4, 3, 2, 1};
    EXPECT_EQ(10, solution.candy(ratings4));
}
```

## 总结

1. 左右约束分开处理，各自线性扫一遍；
2. 右扫取最大值合并两种约束；
3. 相等评分不触发递增，这是容易忽略的细节。
