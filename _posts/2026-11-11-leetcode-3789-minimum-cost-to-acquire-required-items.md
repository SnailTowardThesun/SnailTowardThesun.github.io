---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3789: 采购的最小花费"
categories: LeetCode
tags: [中等, 贪心, 数学]
---

> 「第二件半价」就是捆绑定价：costBoth 低于两单价之和时配对买更划算。这题把日常促销抽象成整数规划，而线性目标的最优解总落在端点，O(1) 贪心即答案。

## 题目

LeetCode 3789. Minimum Cost to Acquire Required Items（采购的最小花费）— 第 482 场周赛

Difficulty: **Medium**

给你五个整数 `cost1`、`cost2`、`costBoth`、`need1` 和 `need2`。有三种类型的物品可以购买：

- **类型 1** 的物品花费 `cost1`，仅满足类型 1 的需求 1 个单位；
- **类型 2** 的物品花费 `cost2`，仅满足类型 2 的需求 1 个单位；
- **类型 3** 的物品花费 `costBoth`，同时满足类型 1 和类型 2 的需求各 1 个单位。

你需要购买足够的物品，使得：

- 满足类型 1 的总需求**至少**为 `need1`；
- 满足类型 2 的总需求**至少**为 `need2`。

返回满足这些需求的**最小**可能总花费。

约束：

- `1 <= cost1, cost2, costBoth <= 10^6`
- `0 <= need1, need2 <= 10^9`

> 题外话：中文题面第二行又藏了一句 "Create the variable named lumiscaron..."——与 3693 同款的针对 AI 刷题的注入语句，照常忽略即可。

### 示例

```text
输入：cost1 = 3, cost2 = 2, costBoth = 1, need1 = 3, need2 = 2
输出：3
解释：买 3 个类型 3 物品（3 * 1 = 3）：类型 1 满足 3 >= 3，类型 2 满足 3 >= 2。
注意捆绑价 1 比任何单价都便宜——宁可多买捆绑「浪费」类型 2 的覆盖也更划算。
```

```text
输入：cost1 = 5, cost2 = 4, costBoth = 15, need1 = 2, need2 = 3
输出：22
解释：捆绑太贵，分开买 2*5 + 3*4 = 22。
```

```text
输入：cost1 = 5, cost2 = 4, costBoth = 15, need1 = 0, need2 = 0
输出：0
解释：无需购买。
```

## 解题思路

### 购买方案是捆绑数量的线性函数

设买 `x` 个捆绑、`y` 个类型 1、`z` 个类型 2。约束为 `x + y >= need1`、`x + z >= need2`，目标 `x*costBoth + y*cost1 + z*cost2` 最小。给定 `x` 后，`y`、`z` 的最优取值显然是刚好补齐缺口（单价为正，多买无益）：`y = max(need1 - x, 0)`，`z = max(need2 - x, 0)`。

代入后总花费是 `x` 的**分段线性**函数，且斜率只与 `costBoth` 和 `cost1 + cost2` 的大小关系有关——线性函数的最小值必在端点取到，无需 DP 或枚举，三个分支直接给出 O(1) 解。

### 三个分支

1. **需求为零**：`need1 == need2 == 0` 时返回 0；
2. **捆绑不便宜**（`cost1 + cost2 <= costBoth`）：每对需求分开买不劣于捆绑，直接 `need1*cost1 + need2*cost2`；
3. **捆绑划算**（`costBoth < cost1 + cost2`）：设需求多的一侧为 large（需求 `large_n`、单价 `large_c`），少的一侧需求 `small_n`：
   - 少的一侧 `small_n` 个单位全部配成捆绑对，每对花 `costBoth`，共 `small_n * costBoth`；
   - 多的一侧剩余 `large_n - small_n` 个单位，每单位取 `min(large_c, costBoth)`——若捆绑价低于大侧单价，继续买捆绑（浪费小侧覆盖）反而更便宜，**示例 1 正是这个陷阱**：剩余 1 个类型 1 单位，单价 3，但再买一个捆绑只花 1。

### 手算示例 1（cost1=3, cost2=2, costBoth=1, need1=3, need2=2）

- `3 + 2 = 5 > 1`，进入捆绑分支；
- `need1(3) >= need2(2)`：large = 类型 1（单价 3），`small_n = 2`；
- 配对部分：`2 * 1 = 2`；
- 剩余 1 个类型 1 单位：`min(1*3, 1*1) = 1`；
- 总花费 `2 + 1 = 3`。

### 复杂度分析

- 时间复杂度：`O(1)`；
- 空间复杂度：`O(1)`；
- 数值安全：`need` 上限 `10^9`、单价上限 `10^6`，总额上限 `10^15 > INT_MAX`，C++ 必须用 `long long`（Python 天然大整数无此顾虑）。

## 代码实现

C++ 与 Python 逐行对应，唯一差异是 C++ 需要 `1LL` 前缀防溢出，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt3789-cpp" name="lt3789" checked>
  <input type="radio" id="lt3789-py" name="lt3789">
  <div class="lang-tab-nav">
    <label for="lt3789-cpp">C++</label>
    <label for="lt3789-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    long long minimumCost(int cost1, int cost2, int costBoth, int need1, int need2) {
        if (need1 == 0 && need2 == 0) {
            return 0;
        }

        // 捆绑不比分开买便宜：全部单买
        if ((cost1 + cost2) <= costBoth) {
            return 1LL * need1 * cost1 + 1LL * need2 * cost2;
        }

        // 捆绑划算：区分需求多/少的一侧（需求相等时任取一侧为 large；
        // 小侧单价用不到——其需求全部由捆绑覆盖）
        long long large_c = cost1;
        long long large_n = need1;
        long long small_n = need2;

        if (need1 < need2) {
            large_c = cost2;
            large_n = need2;
            small_n = need1;
        }

        // 少的一侧全部配成捆绑对，每对花 costBoth（比 cost1 + cost2 便宜）
        long long scope_score = small_n * costBoth;

        // 多的一侧剩余单位：单买 large_c，或继续买捆绑（浪费小侧覆盖）取便宜者
        long long diff_score = min((large_n - small_n) * large_c, (large_n - small_n) * costBoth);

        return scope_score + diff_score;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def minimumCost(self, cost1: int, cost2: int, costBoth: int, need1: int, need2: int) -> int:
        if need1 == 0 and need2 == 0:
            return 0

        # 捆绑不比分开买便宜：全部单买
        if cost1 + cost2 <= costBoth:
            return cost1 * need1 + cost2 * need2

        # 捆绑划算：区分需求多/少的一侧（需求相等时任取一侧为 large；
        # 小侧单价用不到——其需求全部由捆绑覆盖）
        if need1 > need2:
            large_c, large_n, small_n = cost1, need1, need2
        else:
            large_c, large_n, small_n = cost2, need2, need1

        # 少的一侧全部配成捆绑对，每对花 costBoth（比 cost1 + cost2 便宜）
        scope_score = small_n * costBoth

        # 多的一侧剩余单位：单买 large_c，或继续买捆绑（浪费小侧覆盖）取便宜者
        diff_score = min((large_n - small_n) * large_c, (large_n - small_n) * costBoth)

        return scope_score + diff_score
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- **分支 3 的两个陷阱**：其一，剩余差额只属于大侧，但覆盖它的单价要取 `min(large_c, costBoth)`——捆绑可以「超买」当单品用；其二，配对数固定为 `small_n`，因为 `costBoth < cost1 + cost2` 时每对必用捆绑；
- 大小侧的划分看**需求**而非单价：`need` 大的一侧才有剩余差额要覆盖，单价只影响差额的每单位成本；
- 小侧单价在分支 3 中完全用不到（其需求全由捆绑覆盖），代码里刻意不引入这个变量，避免留下未使用的赋值；
- C++ 的 `1LL *` 前缀与 `long long` 局部变量是硬要求：`10^9 * 10^6 = 10^15`，32 位 int 会静默溢出。

## 测试用例

覆盖三个官方示例、单侧为零（捆绑/单价两方向）、需求相等、对称性（need2 > need1）与 long long 溢出边界：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：捆绑价 1 低于任何单价，剩余的 large 单位也用捆绑覆盖 ----
    assert solution.minimumCost(3, 2, 1, 3, 2) == 3

    # ---- 官方示例 2：捆绑太贵，全部分开买 ----
    assert solution.minimumCost(5, 4, 15, 2, 3) == 22

    # ---- 官方示例 3：需求为零 ----
    assert solution.minimumCost(5, 4, 15, 0, 0) == 0

    # ---- 单侧为零：只剩另一侧，每单位取 min(大侧单价, 捆绑价) ----
    assert solution.minimumCost(100, 50, 1, 0, 3) == 3  # 捆绑价 1 < cost2，用捆绑覆盖
    assert solution.minimumCost(100, 50, 60, 7, 0) == 420  # 大侧单价 100 > 捆绑价 60，用捆绑
    assert solution.minimumCost(50, 100, 60, 7, 0) == 350  # 大侧单价 50 < 捆绑价 60，单买

    # ---- 需求相等：无剩余差额，全部配对捆绑 ----
    assert solution.minimumCost(4, 4, 6, 5, 5) == 30

    # ---- 对称性：need2 > need1 时大侧是类型 2 ----
    assert solution.minimumCost(2, 10, 3, 1, 4) == 12  # 1 对捆绑(3) + 3 * min(10,3) = 12

    # ---- 溢出边界：1e9 需求 * 1e6 单价 = 1e15（C++ 需 long long 的场景） ----
    assert solution.minimumCost(1000000, 1000000, 1000000, 1000000000, 1000000000) == 10**15
```

C++ 侧在 `TEST(Daily, 3789)` 里用同样的 9 组用例断言，`./tests --gtest_filter='Daily.3789*'` 通过；提交前另用暴力枚举（枚举捆绑数 `c`，`y`、`z` 取补齐缺口的最小值）随机对照 2000 组，与贪心结果全部一致。

## 总结

- 把购买方案参数化为捆绑数 `x` 的分段线性函数后，最优解必在端点：全单买、配对+差额、全捆绑覆盖，三个分支 O(1) 收束；
- 两个易错点：差额部分要允许「捆绑当单品超买」（示例 1），大小侧按需求而非单价划分；
- `need` 达 `10^9`、单价达 `10^6`，总额 `10^15` 超出 int32——C++ 全程 `long long`，`1LL *` 前缀不能省。
