---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.123: 买卖股票的最佳时机 III"
categories: LeetCode
tags: [困难, 数组, 动态规划, 状态机]
---

> 股票系列是 DP 状态机的教科书：121 一笔交易用单变量贪心，122 无限笔拼所有上坡，123 至多两笔则用 buy/sell × 2 四状态滚动——推广到「至多 k 笔」只需 2k 个状态。

## 题目

LeetCode 123. Best Time to Buy and Sell Stock III（买卖股票的最佳时机 III）

Difficulty: **Hard**

给定一个数组 `prices`，它的第 `i` 个元素 `prices[i]` 表示某支股票第 `i` 天的价格。

设计算法计算所能获取的**最大利润**：最多可以完成**两笔**交易（买入并卖出算一笔），同时最多只能持有一支股票（卖出后才能再次买入）。

数据范围：`1 <= prices.length <= 10^5`，`0 <= prices[i] <= 10^5`。

### 示例

```
输入：prices = [3,3,5,0,0,3,1,4]
输出：6
解释：第 4 天（价格 0）买入、第 6 天（价格 3）卖出，第一笔利润 3；
     第 7 天（价格 1）买入、第 8 天（价格 4）卖出，第二笔利润 3，总计 6。

输入：prices = [1,2,3,4,5]
输出：4
解释：第 1 天买入、第 5 天卖出，利润 4，一笔交易已是最优。

输入：prices = [7,6,4,3,1]
输出：0
解释：单调递减，不交易即最优。
```

## 解题思路

**状态机 DP**（O(n) 时间、O(1) 空间），四个状态滚动维护：

- `buy1`：完成第 1 次买入后（持有）的最大收益
- `sell1`：完成第 1 次卖出后的最大收益
- `buy2`：完成第 2 次买入后（持有）的最大收益
- `sell2`：完成第 2 次卖出后的最大收益

第 `i` 天按依赖顺序转移（`max(维持原状, 今天操作)`）：

1. `buy1 = max(buy1, -prices[i])`——今天第一次买入；
2. `sell1 = max(sell1, buy1 + prices[i])`——今天卖出第一笔；
3. `buy2 = max(buy2, sell1 - prices[i])`——今天第二次买入；
4. `sell2 = max(sell2, buy2 + prices[i])`——今天卖出第二笔。

初始 `buy1 = buy2 = -prices[0]`、`sell1 = sell2 = 0`，答案为 `sell2`。

**两个正确性要点**：
- 「至多两笔」意味着 `sell2 >= sell1 >= 0`——状态里的"少做一笔"天然被包含，不交易时答案为 0；
- 同一天先买后卖收益为 0，等价于少做一笔交易，因此转移直接用**当天新值**更新也不影响正确性，还省去了分两天讨论的麻烦。

以 `prices = [3,3,5,0,0,3,1,4]` 为例，手算如下：

| i | price | buy1 | sell1 | buy2 | sell2 |
|---|-------|------|-------|------|-------|
| 0 | 3 | -3 | 0 | -3 | 0 |
| 1 | 3 | -3 | 0 | -3 | 0 |
| 2 | 5 | -3 | 2 | -3 | 2 |
| 3 | 0 | **0** | 2 | **2** | 2 |
| 4 | 0 | 0 | 2 | 2 | 2 |
| 5 | 3 | 0 | **3** | 2 | **5** |
| 6 | 1 | 0 | 3 | 2 | 5 |
| 7 | 4 | 0 | **4** | 2 | **6** |

最终 `sell2 = 6`：正是「0 买 3 卖 + 1 买 4 卖」两笔交易。

### 复杂度分析

- **时间复杂度**：O(n)，一次遍历；
- **空间复杂度**：O(1)，四个滚动变量。

## 代码实现

C++ 与 Python 的状态机转移逐行对应，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt123-cpp" name="lt123" checked>
  <input type="radio" id="lt123-py" name="lt123">
  <div class="lang-tab-nav">
    <label for="lt123-cpp">C++</label>
    <label for="lt123-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int n = prices.size();
        // 初始：第 0 天买入（一次/两次都视作已买入，同日买卖收益 0）
        int buy1 = -prices[0], buy2 = -prices[0];
        int sell1 = 0, sell2 = 0;

        for (int i = 1; i < n; i++) {
            buy1 = max(buy1, -prices[i]);          // 今天第一次买入
            sell1 = max(sell1, buy1 + prices[i]);  // 今天卖出第一笔
            buy2 = max(buy2, sell1 - prices[i]);   // 今天第二次买入
            sell2 = max(sell2, buy2 + prices[i]);  // 今天卖出第二笔
        }

        return sell2;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def maxProfit(self, prices: list[int]) -> int:
        n = len(prices)
        # 初始：第 0 天买入（一次/两次都视作已买入，同日买卖收益 0）
        buy1 = buy2 = -prices[0]
        sell1 = sell2 = 0

        for i in range(1, n):
            buy1 = max(buy1, -prices[i])  # 今天第一次买入
            sell1 = max(sell1, buy1 + prices[i])  # 今天卖出第一笔
            buy2 = max(buy2, sell1 - prices[i])  # 今天第二次买入
            sell2 = max(sell2, buy2 + prices[i])  # 今天卖出第二笔

        return sell2
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- **转移顺序即依赖顺序**：`buy1 → sell1 → buy2 → sell2` 依次用新值更新，第二笔的买入可以直接建立在"今天刚卖出第一笔"之上（同日买卖收益 0，合法且无损）；
- **初始状态**：`buy1 = buy2 = -prices[0]` 把"第 0 天就买入"视作既成事实，后续 `max` 自然选择更便宜的买点；
- **为什么返回 `sell2`**：至多交易两笔时全程空仓也是合法状态（收益 0），而状态定义保证 `sell2` 单调不降且覆盖"只做一笔/不做"的情形；
- **可推广性**：把 buy/sell 数组开成 2k 个即为 LeetCode 188「至多 k 笔交易」的通解，k = 2 时退化为本文四个变量。

## 测试用例

```cpp
TEST(top150, 123) {
    Solution s;

    // 官方示例 1：两笔交易 3 + 3 = 6
    vector<int> prices1{3, 3, 5, 0, 0, 3, 1, 4};
    EXPECT_EQ(s.maxProfit(prices1), 6);

    // 官方示例 2：单笔即最优 5 - 1 = 4
    vector<int> prices2{1, 2, 3, 4, 5};
    EXPECT_EQ(s.maxProfit(prices2), 4);

    // 官方示例 3：单调递减，不交易
    vector<int> prices3{7, 6, 4, 3, 1};
    EXPECT_EQ(s.maxProfit(prices3), 0);

    // 边界：单天无法交易
    vector<int> prices4{2};
    EXPECT_EQ(s.maxProfit(prices4), 0);

    // 两笔优于一笔：(4-1) + (8-2) = 9 > 单笔最大 8 - 1 = 7
    vector<int> prices5{1, 4, 2, 8};
    EXPECT_EQ(s.maxProfit(prices5), 9);
}
```

```python
def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.maxProfit([3, 3, 5, 0, 0, 3, 1, 4]) == 6
    assert solution.maxProfit([1, 2, 3, 4, 5]) == 4
    assert solution.maxProfit([7, 6, 4, 3, 1]) == 0
    # 边界：单天无法交易
    assert solution.maxProfit([2]) == 0
    # 两笔优于一笔：(4-1) + (8-2) = 9 > 单笔最大 8 - 1 = 7
    assert solution.maxProfit([1, 4, 2, 8]) == 9
    # 两天单调：只能做一笔 3 - 1 = 2
    assert solution.maxProfit([1, 3]) == 2
```

## 总结

1. 「至多 k 笔交易」的股票题可用状态机 DP：每天对每个状态做 `max(不动, 今天操作)`，k = 2 时四个滚动变量即可；
2. 转移按 `buy1 → sell1 → buy2 → sell2` 顺序用当天新值更新，同日先买后卖收益为 0，天然兼容"少做一笔"的情形；
3. 该模式可推广到 188（至多 k 笔，2k 个状态）；冷冻期题需要额外区分状态，手续费题则调整买入或卖出的转移成本。
