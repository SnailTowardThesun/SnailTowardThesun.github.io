---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3736: 最小操作次数使数组元素相等 III"
categories: LeetCode
tags: [简单, 数组, 数学, 脑筋急转弯]
---

> 453 补齐到最小值、462 聚拢到中位数、3736 顶到最大值——"最小操作次数"三部曲到本题凑齐：操作规则一字之差，最优目标就从三个统计量里各选其一，正好一组对照实验。

## 题目

LeetCode 3736. Minimum Moves to Equal Array Elements III（最小操作次数使数组元素相等 III）

Difficulty: **Easy**

给你一个整数数组 `nums`。一步操作中，你可以将**任意单个元素** `nums[i]` 的值增加 1。返回使数组中所有元素相等所需的最小总操作次数。

约束：

- `1 <= nums.length <= 100`
- `1 <= nums[i] <= 100`

### 示例

```text
输入：nums = [2,1,3]
输出：3
解释：将 nums[0] 从 2 增到 3（1 次），再将 nums[1] 从 1 增到 3（2 次），最终所有元素均为 3。
```

```text
输入：nums = [4,4,5]
输出：2
解释：两个 4 各增加 1 变为 5，共 2 次操作。
```

## 解题思路

### 只能加不能减，目标被锁死在最大值

设所有元素最终相等时的公共值为 `V`：

1. 操作只有 +1，没有任何手段让元素下降——`V` 必须 ≥ 每个元素，即 `V >= max(nums)`，否则比 `V` 大的元素永远够不着目标；
2. 每一步操作让数组总和**恰好**增加 1，所以从 `sum` 补到 `n * V` 总共需要 `n * V - sum` 步，与操作怎么分配到各元素完全无关；
3. `n * V - sum` 随 `V` 严格递增——`V` 取最小可行值 `max` 最优，答案 = `n * max - sum = Σ(max - nums[i])`。

直观版：每个元素到最大值的缺口是几，就补几次 +1，缺口之和即总操作数。`[2,1,3]` 的缺口是 `0 + 2 + 1 = 3`。

### 三部曲对照

| 题号 | 一步操作 | 等价视角 | 最优目标 | 答案 |
|------|----------|----------|----------|------|
| 453  | n−1 个元素 +1 | 补集转化 ≈ 单元素 −1 | 最小值 | `sum - n*min` |
| 462  | 任一元素 ±1 | 目标自由选 | 中位数 | `Σ\|xᵢ - mid\|` |
| 3736 | 任一元素 +1 | 只升不降 | 最大值 | `n*max - sum` |

453 的补集转化（给 n−1 个元素 +1 = 给全体 +1 再给 1 个元素 −1，均匀加不改变相等性）把目标压到最小值；462 双向可调，目标自由落在中位数；本题单向可调，目标被顶到最大值。同一题面家族，规则一字之差，目标统计量各就各位。

顺带一提：453 的答案**绝不能**写成 `n*max - sum`——那是"每次给一个元素 +1"的公式，正是本题。两题公式互为镜像，放在一起记最不容易混。

### 复杂度分析

- 时间复杂度：`O(n)`（求最大值 + 求和，C++ 单趟同时攒两个）
- 空间复杂度：`O(1)`

## 代码实现

Python 用 `max` + 生成器求和，C++ 单趟遍历同时攒出最大值与总和，Rust 用 `iter().max()` + `map(...).sum()` 一行收尾，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt3736-cpp" name="lt3736" checked>
  <input type="radio" id="lt3736-py" name="lt3736">
  <input type="radio" id="lt3736-rust" name="lt3736">
  <div class="lang-tab-nav">
    <label for="lt3736-cpp">C++</label>
    <label for="lt3736-py">Python</label>
    <label for="lt3736-rust">Rust</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
int minMoves(vector<int>& nums) {
    long long total = 0;  // 元素总和
    int mm = 0;           // 最大值（题目保证 nums[i] >= 1，0 起步安全）
    for (auto i : nums) {
        mm = max(mm, i);
        total += i;
    }

    // 答案 = n*max - sum：每个元素补到 max 的缺口之和
    return mm * nums.size() - total;
}
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def minMoves(self, nums: List[int]) -> int:
        mm = max(nums)
        return sum((mm - i) for i in nums)
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight rust %}
pub fn min_moves(nums: Vec<i32>) -> i32 {
    let mm = *nums.iter().max().unwrap();  // 题目保证 n >= 1，unwrap 安全
    nums.iter().map(|&x| mm - x).sum()
}
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- Python 走 `max(nums)` + 生成器两次遍历，C++ 单趟同时攒 `mm`/`total`，都是 O(n)，选顺手的写法即可；
- C++ 的 `mm = 0` 初始值能工作是因为本题保证 `nums[i] >= 1`；若值域含负数或 0，必须改用首元素或 `INT_MIN` 起步——换题照抄要小心；
- `mm * nums.size()` 中 `int` 与 `size_t` 相乘会先提升到无符号 64 位：本题数值 ≤ 9801 毫无压力，`long long` 累加总和也属于余量而非必需，但都是"知道即可"的细节；
- Rust 每一项 `(mm - x)` 非负且部分和不超过总和，`i32` 求和天然安全。

## 测试用例

覆盖官方示例、单元素/全相等零成本、最大值位置、多个最小值/最大值、无序数组与规模上界：

```python
def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.minMoves([2, 1, 3]) == 3  # 示例 1：2→3 一次、1→3 两次
    assert solution.minMoves([4, 4, 5]) == 2  # 示例 2：两个 4 各 +1
    # 边界：单元素 / 全相等（零成本）
    assert solution.minMoves([1]) == 0
    assert solution.minMoves([7, 7, 7]) == 0
    # 最大值在头部/尾部不影响结果
    assert solution.minMoves([100, 1]) == 99
    assert solution.minMoves([1, 100]) == 99
    # 多个最小值同时补齐：三个 1 各缺 99
    assert solution.minMoves([1, 1, 1, 100]) == 297
    # 多个最大值：缺口全在较小元素上
    assert solution.minMoves([5, 5, 3]) == 2
    # 无序小数组
    assert solution.minMoves([3, 1, 2]) == 3
    # 规模上界：99 个 1 + 1 个 100，答案 99*(100-1)=9801
    assert solution.minMoves([1] * 99 + [100]) == 9801
    # 满值域小数组
    assert solution.minMoves(list(range(1, 101))) == sum(range(100))  # 缺口 99+98+...+0
```

## 总结

- 只能 +1 ⇒ 目标被迫取 `max`；每步总和恰好 +1 ⇒ 操作数 = `n*V - sum` 随 `V` 递增 ⇒ `V` 取最小可行值；
- 三部曲一起记：操作规则决定等价视角，等价视角决定目标统计量（min / 中位数 / max），453 与 3736 的公式互为镜像；
- n 与值域都 ≤ 100 的小数据说明本题考推理不考性能，O(n) 直写即可，不必排序。
