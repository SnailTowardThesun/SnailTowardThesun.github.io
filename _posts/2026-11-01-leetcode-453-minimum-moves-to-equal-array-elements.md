---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.453: 最小操作次数使数组元素相等"
categories: LeetCode
tags: [中等, 数组, 数学, 脑筋急转弯]
---

> 「给 n−1 个元素加一」与「给 1 个元素减一」对元素间差值的影响完全相同——换个参照系，看似需要模拟的操作题变成一行公式。补集转化是这类操作题的万能钥匙。

## 题目

LeetCode 453. Minimum Moves to Equal Array Elements（最小操作次数使数组元素相等）

Difficulty: **Medium**

给你一个长度为 `n` 的整数数组 `nums`，每次操作将会使 `n - 1` 个元素增加 `1`。返回让数组所有元素相等的最小操作次数。

约束：

- `n == nums.length`
- `1 <= n <= 10^5`
- `-10^9 <= nums[i] <= 10^9`
- 答案保证符合 32-bit 整数范围

### 示例

```text
输入：nums = [1,2,3]
输出：3
解释：[1,2,3] => [2,3,3] => [3,4,3] => [4,4,4]（每次操作增加两个元素）。
```

```text
输入：nums = [1,1,1]
输出：0
```

## 解题思路

### 第一步：正向模拟为什么走不通

最直觉的写法是每轮给除最大值外的 n-1 个元素 +1，重复到全等。但答案的量级是 `sum - n * min`，即使答案被限制在 int32 内，仍可能需要约 20 亿次操作——模拟必然超时，这题一定有数学结构。

### 第二步：补集转化——「加 n-1 个」=「减 1 个」

关键观察：给 n-1 个元素各 +1，与给**没被加的那 1 个**元素 -1，对所有**元素间差值**的影响完全相同——其余元素相对它都抬高了一格。反过来，任何「全体减去公共常数」不改变差值，所以两种操作视角可以互相换算：一段操作序列在「加 n-1」世界里把数组变全等，当且仅当对应序列在「减 1」世界里也把数组变全等，且步数相同。

于是问题换轨成：**每次选一个元素 -1，让全部相等的最少次数**。

### 第三步：一眼看出答案

每次操作恰好让一个元素减少 1，所以总次数 = 所有元素总共被减掉的量。全部相等时公共值取多少最优？只能取到 `min(nums)`——想取更低的值，最小值元素也被迫继续下降，白白多花步数。因此每个元素 `nums[i]` 都降到 `min`，总代价：

```text
answer = sum(nums) - n * min(nums)
```

这也解释了官方示例：`[1,2,3]` → `6 - 3*1 = 3`；`[1,1,1]` → `3 - 3*1 = 0`。

### 第四步：溢出——本题真正的陷阱

约束里有两句容易被忽略的话：`nums[i]` 可达 `±10^9`，而「**答案**保证符合 32-bit 整数」。注意保证的是**答案**，不是**中间量**：

- `sum(nums)` 量级可达 `10^5 × 10^9 = 10^14`；
- `n * min(nums)` 同样可达 `-10^14`。

都远超 int32（约 ±2.1×10^9）。C++ 里 `int sum` 会在中途溢出（UB），即使最终答案落在 int32 内。所以求和与乘积必须全程 `long long`。一个容易漏看的次级坑：`mn * nums.size()` 是 `int × size_t` 的带符号/无符号混算——本例 64 位模运算下结果碰巧正确，但显式转成 `long long` 再乘才是稳妥写法。Python 天然大整数，一行完事。

### 复杂度分析

- 时间复杂度：`O(n)`——一次遍历同时求 `sum` 与 `min`
- 空间复杂度：`O(1)`

## 代码实现

C++ 版单趟遍历同时攒出 `sum` 与 `mn`；Python 版本就是公式本身，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt453-cpp" name="lt453" checked>
  <input type="radio" id="lt453-py" name="lt453">
  <div class="lang-tab-nav">
    <label for="lt453-cpp">C++</label>
    <label for="lt453-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int minMoves(vector<int>& nums) {
        long long sum = 0;
        int mn = nums[0];
        for (auto i : nums) {
            mn = min(mn, i);
            sum += i;
        }

        // mn * size() 显式走 long long：避免 int×size_t 的带符号/无符号混算
        return sum - mn * (long long)nums.size();
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def minMoves(self, nums: list[int]) -> int:
        return sum(nums) - min(nums) * len(nums)
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 一次遍历同时累计 `sum` 与 `mn`，无需 `accumulate` + `min_element` 两趟；
- `sum` 声明为 `long long`：元素逐个累加的过程就已经会溢出 int32，不是只有最后乘法才危险；
- `(long long)nums.size()` 的显式转换把整个表达式拉回带符号 64 位运算，杜绝无符号混算的隐患；
- 返回值回到 `int` 安全：官方保证答案在 32-bit 内（如 `[-10^9, -10^9, 10^9]` 答案恰为 `2×10^9`，贴近但不超 `INT_MAX`）。

## 测试用例

覆盖官方示例、单元素、全相等、负数、以及专门钉 int32 中间量溢出的用例（期望值经 BFS 全状态枚举暴力验证——每步枚举"哪个元素不 +1"，逐状态搜到全相等）：

```cpp
TEST(Daily, 453) {
    Solution s;
    auto check = [&s](vector<int> nums, int expect) { EXPECT_EQ(s.minMoves(nums), expect); };
    // 官方示例
    check({1, 2, 3}, 3);  // 示例 1：三次操作后全等
    check({1, 1, 1}, 0);  // 示例 2：初始已全等
    // 边界：单元素 / 全相等
    check({5}, 0);  // n=1 时每次操作加 0 个元素，天然全等
    check({7, 7, 7, 7}, 0);
    // 负数（约束允许 -1e9）
    check({-1, -5}, 4);
    check({-5, -3, -1}, 6);
    // 小规模混合（期望值经 BFS 全状态枚举暴力验证）
    check({1, 2}, 1);
    check({1, 0, 2}, 3);
    check({5, 1, 3, 2}, 7);
    // 大值与溢出：三个 -1e9 的和为 -3e9 超出 int32——中间量必须用 long long，
    // 而最终答案 2000000000 仍在 int32 内（官方保证）
    check({1, 1000000000}, 999999999);
    check({-1000000000, 1000000000}, 2000000000);
    check({-1000000000, -1000000000, 1000000000}, 2000000000);
}
```

## 总结

- 「给 n-1 个加一」与「给 1 个减一」对差值的影响等价——补集转化后，最优策略（全部降到最小值）与答案公式 `sum - n*min` 一眼可见；
- 官方只保证**答案**在 32-bit 内，`sum` 与 `n*min` 的中间量可达 10^14：C++ 必须全程 `long long`，`int × size_t` 的无符号混算也要显式规避；
- 期望值拿不准时，小规模用"每步枚举不 +1 的元素"的 BFS 全状态枚举当独立裁判，公式和暴力交叉验证后再定案。
