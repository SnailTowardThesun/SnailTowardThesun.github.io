---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.121: 买卖股票的最佳时机"
categories: LeetCode
---

> 每天只需要回答两个问题：历史最低价是多少？今天卖出能赚多少？答案天然是一次线性扫描。

## 题目

LeetCode 121. Best Time to Buy and Sell Stock（买卖股票的最佳时机）

Difficulty: **Easy**

给定价格数组，只能某一天买入、之后某天卖出，返回最大利润；无利可图返回 0。

### 示例

```
输入：[7,1,5,3,6,4]   输出：5（1 买 6 卖）
输入：[7,6,4,3,1]     输出：0
```

## 解题思路

### 一次扫描维护最低价

- preMin：扫描到当前位置之前的最低价格。
- 当天价格高于 preMin：计算当天卖出利润并更新最大值。
- 否则：当天价是新的最低价，更新 preMin。

卖出一定在买入之后，最低价只从「过去」的价格中取。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int ret = 0;
        int preMin = prices[0];
        for (int i = 1; i < (int)prices.size(); i++) {
            if (prices[i] > preMin) {
                ret = max(ret, prices[i] - preMin);
            } else {
                preMin = prices[i];
            }
        }
        return ret;
    }
};
```

### 代码解析

- 利润初值 0，全程单调不增的价格数组自然返回 0。

## 测试用例

```cpp
TEST(TOP150, No121_MaxProfit) {
    Solution solution;
    vector<int> prices{7, 1, 5, 3, 6, 4};
    EXPECT_EQ(5, solution.maxProfit(prices));
}
```

## 总结

1. 当天卖出利润 = 当天价 - 历史最低价；
2. 扫描中同步维护最低价与最大利润；
3. O(n) 时间 O(1) 空间。
