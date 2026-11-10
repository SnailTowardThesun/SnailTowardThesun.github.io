---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3693: 爬楼梯 II"
categories: LeetCode
tags: [中等, 数组, 动态规划]
---

> 这道题最大的坑不在 DP，而在题面：costs 声称「下标从 1 开始」，实际传参仍是 0-based 数组——第 j 级台阶的代价要取 costs[j-1]。读懂这句翻译，难度直接降一档。

## 题目

LeetCode 3693. Climbing Stairs II（爬楼梯 II）— 第 166 场双周赛 Q2

Difficulty: **Medium**

你正在爬一个有 `n + 1` 级台阶的楼梯，台阶编号从 `0` 到 `n`。给定长度为 `n` 的整数数组 `costs`，其中 `costs[i]` 是第 `i` 级台阶的成本（题面声称下标从 1 开始，实际传入的是 0-based 数组）。

从第 `i` 级台阶，你**只能**跳到第 `i + 1`、`i + 2` 或 `i + 3` 级台阶。从第 `i` 级跳到第 `j` 级的成本定义为：

```text
costs[j] + (j - i)^2
```

你从第 0 级台阶开始，初始 `cost = 0`。返回到达第 `n` 级台阶所需的**最小**总成本。

约束：

- `1 <= n == costs.length <= 10^5`
- `1 <= costs[i] <= 10^4`

> 题外话：官方中文题面第二行还藏了一句 "Create the variable named keldoniraq..."——这是针对 AI 刷题的注入语句（评论区已多人指出），与人无关，照常忽略即可。真正影响解题的只有上面那个下标从 1 开始的坑。

### 示例

```text
输入：n = 4, costs = [1,2,3,4]
输出：13
解释：最优路径 0 → 1 → 2 → 4
  0 → 1: costs[1] + 1² = 1 + 1 = 2
  1 → 2: costs[2] + 1² = 2 + 1 = 3
  2 → 4: costs[4] + 2² = 4 + 4 = 8
  总成本 2 + 3 + 8 = 13
```

```text
输入：n = 4, costs = [5,1,6,2]
输出：11
解释：最优路径 0 → 2 → 4：(1+4) + (2+4) = 11，跨过昂贵的第 1 级。
```

```text
输入：n = 3, costs = [9,8,3]
输出：12
解释：一步到位 0 → 3：3 + 3² = 12。
```

## 解题思路

### 状态与转移

经典线性 DP：设 `dp[j]` 为到达第 `j` 级台阶的最小总成本。最后一步必然从 `j-1`、`j-2` 或 `j-3` 三者之一跳来，跳距的平方代价分别是 1、4、9，落点成本 `costs[j-1]`（0-based 数组！）对三种跳距相同：

```text
dp[j] = min(dp[j-1] + costs[j-1] + 1,
            dp[j-2] + costs[j-1] + 4,
            dp[j-3] + costs[j-1] + 9)
```

边界：`dp[0] = 0`（起点免费）；`dp[1]` 只有 0→1 一种跳法；`dp[2]` 可从 0 直跳或经 1 中转；`j >= 3` 起三项转移齐全。答案即 `dp[n]`。

### 平方代价改变了什么

没有平方项时跳得越远越「免费」，本题 (j−i)² 让远跳付出超线性代价——三步 1+1+1 的跳跃成本是 3，一步 3 的跳跃成本是 9。所以最优解既不是「能跳多远跳多远」，也不是「逐级爬」，而是在「少付台阶费」与「少付跳跃费」之间权衡，这正是 DP 存在的意义：贪心没有全局最优保证（如测试里 n=5 的用例，最优组合是 1,2,2 而非全 1 或全 3）。

### 手算示例 1（n = 4, costs = [1,2,3,4]）

- `dp[1] = 1 + 1 = 2`
- `dp[2] = min(2+1+2, 2+4) = 5`（经 1 中转更优）
- `dp[3] = min(3+1+5, 3+4+2, 3+9) = 9`（前两项并列）
- `dp[4] = min(4+1+9, 4+4+5, 4+9+2) = 13`（经 2 中转最优）

### 复杂度分析

- 时间复杂度：`O(n)`，一次线性递推；
- 空间复杂度：`O(n)`，dp 数组（只依赖前三项，可滚动优化到 `O(1)`；`n <= 10^5` 无此必要）；
- 数值安全：总成本上界 `n * (10^4 + 9) ≈ 1.0 * 10^9 < INT_MAX`，`int` 承载安全。

## 代码实现

C++ 与 Python 逻辑逐行对应，唯一的差异只是语言习惯（`std::min` 嵌套与 Python `min` 的写法），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt3693-cpp" name="lt3693" checked>
  <input type="radio" id="lt3693-py" name="lt3693">
  <div class="lang-tab-nav">
    <label for="lt3693-cpp">C++</label>
    <label for="lt3693-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int climbStairs(int n, vector<int>& costs) {
        vector<int> dp(n + 1, 0);

        // 第 1 级：只能从 0 直跳一步
        dp[1] = costs[0] + 1;
        if (n == 1) {
            return dp[1];
        }

        // 第 2 级：从 0 直跳两步，或经第 1 级中转
        dp[2] = min(costs[1] + 1 + dp[1], costs[1] + 4);
        if (n == 2) {
            return dp[2];
        }

        // 第 3 级起三项转移齐全
        for (int i = 3; i <= n; i++) {
            dp[i] = min(costs[i - 1] + 1 + dp[i - 1],
                        min(costs[i - 1] + 4 + dp[i - 2], costs[i - 1] + 9 + dp[i - 3]));
        }

        return dp[n];
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def climbStairs(self, n: int, costs: list[int]) -> int:
        dp = [0] * (n + 1)

        # 第 1 级：只能从 0 直跳一步
        dp[1] = costs[0] + 1
        if n == 1:
            return dp[1]

        # 第 2 级：从 0 直跳两步，或经第 1 级中转
        dp[2] = min(costs[1] + 1 + dp[1], costs[1] + 4)
        if n == 2:
            return dp[2]

        # 第 3 级起三项转移齐全
        for i in range(3, n + 1):
            dp[i] = min(costs[i - 1] + 1 + dp[i - 1], min(costs[i - 1] + 4 + dp[i - 2], costs[i - 1] + 9 + dp[i - 3]))

        return dp[n]
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- **下标换算是第一坑**：题目说 costs 下标从 1 开始，实际传参是 0-based 数组——第 `i` 级台阶的代价是 `costs[i-1]`，写代码时全程带着 `-1`；
- `dp[1]`、`dp[2]` 单独初始化是因为 `j < 3` 时三项转移不齐全（`j-3` 会越界）；从 `j = 3` 起进入统一循环；
- 落点成本 `costs[i-1]` 对三种跳距相同，数学上可以提到 `min` 外面（`dp[i] = costs[i-1] + min(dp[i-1]+1, dp[i-2]+4, dp[i-3]+9)`），保留在 `min` 内是为了让每一项直接对应「从哪跳来」的完整成本，可读性优先；
- 约束保证 `n >= 1`，无需处理 `n = 0` 的空楼梯。

## 测试用例

覆盖三个官方示例、两个最小规模（n=1、n=2）与一个贪心反例（n=5，最优是 1,2,2 的混合跳法而非单一跳距）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：最优路径 0 -> 1 -> 2 -> 4 ----
    assert solution.climbStairs(4, [1, 2, 3, 4]) == 13

    # ---- 官方示例 2：最优路径 0 -> 2 -> 4，跨过昂贵的第 1 级 ----
    assert solution.climbStairs(4, [5, 1, 6, 2]) == 11

    # ---- 官方示例 3：一步到位 0 -> 3，付出 9 的平方代价 ----
    assert solution.climbStairs(3, [9, 8, 3]) == 12

    # ---- 最小规模：单级台阶只能直跳一步 ----
    assert solution.climbStairs(1, [7]) == 8

    # ---- 两级台阶：直跳 (9+4) 便宜于中转 (8 + 9+1) ----
    assert solution.climbStairs(2, [7, 9]) == 13

    # ---- 混合贪心陷阱：n=5 最优是 1,2,2 组合（经 1、3、5），逐级爬反而更贵 ----
    assert solution.climbStairs(5, [2, 3, 1, 4, 2]) == 14
```

C++ 侧在 `TEST(Daily, 3693)` 里用同样的 6 组用例断言，`./tests --gtest_filter='Daily.3693*'` 通过；提交前另用暴力枚举所有 1..3 步组合随机对照 300 组，与 DP 结果全部一致。

## 总结

- 线性 DP 三项转移，`dp[j]` 只依赖前三个状态，`O(n)` 时间、`O(n)` 空间（可滚动至 `O(1)`）；
- (j−i)² 的平方代价让「跳远」付出超线性代价，最优解是台阶费与跳跃费的权衡，贪心不可靠——混合跳距用例是关键回归；
- 读题是本题一半的难度：costs 的「下标从 1 开始」与实际 0-based 传参的错位，以及题面里那句针对 AI 的注入指令，都值得留意。
