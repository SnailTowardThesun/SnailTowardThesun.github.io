---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.122: 买卖股票的最佳时机 II"
categories: LeetCode
---

> 当前实现用「持有 / 不持有」两状态 DP；本题还有更简洁的贪心视角：把每一段上涨的利润全部累加。

## 题目

LeetCode 122. Best Time to Buy and Sell Stock II（买卖股票的最佳时机 II）

Difficulty: **Medium**

每天可买入和/或卖出，任何时候最多持有一股，可当天买卖。返回最大利润。

### 示例

```
输入：[7,1,5,3,6,4]   输出：7
解释：1 买 5 卖赚 4，3 买 6 卖赚 3，共 7。

输入：[1,2,3,4,5]     输出：4（持续上涨，1 买 5 卖）
输入：[7,6,4,3,1]     输出：0
```

## 解题思路

### 两状态 DP（当前实现）

- dp[i][0]：第 i 天结束不持有股票的最大利润
- dp[i][1]：第 i 天结束持有股票的最大利润

转移：
- `dp[i][0] = max(dp[i-1][0], dp[i-1][1] + prices[i])`：继续空仓或今天卖出
- `dp[i][1] = max(dp[i-1][1], dp[i-1][0] - prices[i])`：继续持有或今天买入

最终答案取不持有状态（最后一天持股没有意义）。

### 贪心视角

总利润等于所有相邻上涨差值之和：`sum(max(0, prices[i] - prices[i-1]))`。任何跨越多天的上涨，其利润都等于各日上涨之和，所以逐日「昨天买今天卖」即可，O(1) 空间。

### 复杂度分析

- DP（当前）：时间 O(n)，空间 O(n)（可滚动数组优化到 O(1)）。
- 贪心：时间 O(n)，空间 O(1)。

## 代码实现

```cpp
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        vector<vector<int>> dp(prices.size(), vector<int>(2, 0));
        dp[0][0] = 0;
        dp[0][1] = -prices[0];
        for (int i = 1; i < (int)prices.size(); i++) {
            dp[i][0] = max(dp[i - 1][0], dp[i - 1][1] + prices[i]);
            dp[i][1] = max(dp[i - 1][1], dp[i - 1][0] - prices[i]);
        }
        return dp[prices.size() - 1][0];
    }
};
```

贪心参考实现：

```cpp
class SolutionGreedy {
public:
    int maxProfit(vector<int>& prices) {
        int profit = 0;
        for (int i = 1; i < (int)prices.size(); i++) {
            profit += max(0, prices[i] - prices[i - 1]);
        }
        return profit;
    }
};
```

## 测试用例

```cpp
TEST(TOP150, No122_MaxProfitII) {
    Solution solution;
    vector<int> prices{7, 1, 5, 3, 6, 4};
    EXPECT_EQ(7, solution.maxProfit(prices));
}
```

## 总结

1. 两状态 DP 覆盖「今天买卖持币」的全部选择；
2. 本题因无交易次数限制，贪心累加相邻上涨差值即可；
3. 这是股票系列 DP 的基础模型，后续题目在此状态上加约束。
