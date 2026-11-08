---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.462: 最小操作次数使数组元素相等 II"
categories: LeetCode
tags: [中等, 数组, 排序, 中位数, 脑筋急转弯]
---

> 中位数最小化绝对偏差、均值最小化平方偏差——这条统计学结论正是本题与 453 题的分水岭。均值对离群值敏感，中位数稳如泰山，这也是鲁棒统计的起点。

## 题目

LeetCode 462. Minimum Moves to Equal Array Elements II（最小操作次数使数组元素相等 II）

Difficulty: **Medium**

给你一个长度为 `n` 的整数数组 `nums`，返回使所有数组元素相等需要的最小操作数。在一次操作中，你可以使数组中的一个元素**加 1 或者减 1**。测试用例经过设计以使答案在 32 位整数范围内。

约束：

- `1 <= n <= 10^5`
- `-10^9 <= nums[i] <= 10^9`

### 示例

```text
输入：nums = [1,2,3]
输出：2
解释：[1,2,3] => [2,2,3] => [2,2,2]，先将 1 加 1，再将 3 减 1。
```

```text
输入：nums = [1,10,2,9]
输出：16
```

## 解题思路

### 与 453 题一字之差，答案天差地别

姊妹题 453 是"每次给 **n-1 个**元素 +1"，补集转化后等价于"每次给一个元素 -1"，最优目标被迫落在最小值上，答案 `sum - n*min`。本题是"每次给**任一个**元素 +1 **或** -1"——目标值可以自由选择，问题变成：**选哪个目标，让所有元素到它的绝对偏差和最小？**

### 为什么是中位数而不是均值

设目标为 `t`，代价 `f(t) = Σ|x_i - t|`。把 `t` 向右挪动一格：右侧每个元素省 1，左侧每个元素费 1。设 `t` 右侧有 `r` 个元素：

- `r > n - r`（目标在中位数左侧）：净省，继续右移；
- `r < n - r`：净亏，不该右移；
- 平衡点恰在中位数——**偶数个元素时，两个中位之间任意点等价**。

所以排序取 `nums[n/2]`，答案 = `Σ|x_i - 中位数|`。

**均值为什么错**：均值最小化的是平方偏差 `Σ(x_i - t)²`（对 t 求导即为均值），离群值会以平方权重把它拉偏。反例 `[2,2,2,2,100]`：中位数路线 `98` 步；朝均值 21.6 靠拢要 `158` 步。这组数字值得背下来。

### Rust 移植小记

Python/C++ 版照公式直写即可，Rust 初版翻了几个典型的车（记录在此供后来者绕行）：

- `nums.size()` / `nums.length()`——Rust 里是 `nums.len()`；
- `nums[mid]`——`mid` 已经是**中位数的值**，再拿它当下标是"值/下标"混淆（小数组上碰巧不崩，负数或大中位数直接 panic）；
- `abs(x)`——Rust 的取绝对值是方法 `(x - mid).abs()`，没有自由函数；
- `Solution()`——本仓库 Rust 题解是自由函数风格（`pub fn min_moves2(...)`），不定义 `Solution` 结构体，新文件记得在 `questions/mod.rs` 里加 `#[path = "462.rs"] pub mod q462;` 注册。

### 复杂度分析

- 时间复杂度：`O(n log n)`（排序主导；快速选择可做到平均 O(n)）
- 空间复杂度：`O(1)`（原地排序）

## 代码实现

三语言同构：排序 → 取中位数 → 绝对偏差求和。注意官方只保证**答案**在 int32 内——本题每项偏差与总和都不超过答案，`int` 安全。点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt462-cpp" name="lt462" checked>
  <input type="radio" id="lt462-py" name="lt462">
  <input type="radio" id="lt462-rust" name="lt462">
  <div class="lang-tab-nav">
    <label for="lt462-cpp">C++</label>
    <label for="lt462-py">Python</label>
    <label for="lt462-rust">Rust</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
int minMoves2(vector<int>& nums) {
    sort(nums.begin(), nums.end());
    int mid = nums[nums.size() / 2];  // 中位数（偶数个时取上中位，两者等价）
    int ret = 0;
    for (auto i : nums) {
        ret += abs(i - mid);
    }

    return ret;
}
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def minMoves2(self, nums: list[int]) -> int:
        nums.sort()
        mid = nums[len(nums) // 2]
        return sum(abs(i - mid) for i in nums)
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight rust %}
pub fn min_moves2(mut nums: Vec<i32>) -> i32 {
    nums.sort();
    let mid = nums[nums.len() / 2];
    nums.iter().map(|&x| (x - mid).abs()).sum()
}
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 三语言同构：排序 → 取 `n/2` 位置的中位数 → 绝对偏差求和，没有分支、没有特判；
- 偶数个元素取上中位或下中位结果相同（两中位之间代价函数是平的），不必纠结 `n/2` 还是 `n/2 - 1`；
- `nums.sort()` 原地修改入参——LeetCode 语境无害；工程代码里介意副作用可先 `sorted(nums)`；
- 大值用例答案 `2×10^9` 贴近 `INT_MAX`（2147483647）：官方"答案在 32 位内"的保证让逐项累加也安全，但换一道题时这个推理不能照搬（453 的中间量就会溢出）。

## 测试用例

覆盖官方示例、单元素/全相等、两元素相遇、偶数个中位等价、反均值陷阱、负数、大值上界；期望值经"枚举每个目标值求绝对偏差和"的暴力实现与中位数公式双实现交叉验证（300 组随机零分歧）：

```python
def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.minMoves2([1, 2, 3]) == 2  # 示例 1：1 加 1、3 减 1
    assert solution.minMoves2([1, 10, 2, 9]) == 16  # 示例 2
    # 边界：单元素 / 全相等（零成本）
    assert solution.minMoves2([5]) == 0
    assert solution.minMoves2([7, 7, 7]) == 0
    # 两个元素：中间任意点相遇
    assert solution.minMoves2([1, 9]) == 8
    # 偶数个元素：两个中位之间任意目标等价
    assert solution.minMoves2([1, 2, 4, 5]) == 6
    # 陷阱：离群值会把均值拉偏——朝均值靠拢要 158 步，正确答案 98
    assert solution.minMoves2([2, 2, 2, 2, 100]) == 98
    # 负数与小规模混合（期望值经枚举目标值暴力验证）
    assert solution.minMoves2([1, 0, 0, 8, 6]) == 14
    assert solution.minMoves2([-5, -1, -3]) == 4
    # 大值：答案贴近 int32 上界（官方保证答案在 32 位内，中间求和需注意宽度）
    assert solution.minMoves2([-1000000000, 1000000000]) == 2000000000
    assert solution.minMoves2([-1000000000, -1000000000, 1000000000]) == 2000000000
    assert solution.minMoves2([999999999, -999999999, 0]) == 1999999998
```

## 总结

- "任一元素 ±1"的最优目标是中位数：右移一格的"费/省"翻转点，反均值陷阱 `[2,2,2,2,100]`（98 vs 158）一例定音；
- 与 453 对比着记：那边目标被操作语义锁死在最小值（`sum - n*min`），这边目标自由选（中位数），两题共用"统计量选目标"的框架；
- 多语言同构题是练移植的好机会：Rust 的 `len()`、方法调用 `abs()`、值/下标区分，都是跨语言惯性思维最容易踩的坑。
