---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1524: 和为奇数的子数组数目"
categories: LeetCode
tags: [中等, 数组, 数学, 前缀和]
---

> 「和为奇数」翻译成前缀和语言就是「两个前缀奇偶性不同」——不用记前缀和本身，只记奇偶两个计数器，配对计数 O(n) 收工，与 560 是同款套路。

## 题目

LeetCode 1524. Number of Sub-arrays With Odd Sum（和为奇数的子数组数目）

Difficulty: **Medium**

给你一个整数数组 `arr`，返回其中和为**奇数**的子数组的数目。由于答案可能很大，请返回它对 `10^9 + 7` 取余的结果。

约束：

- `1 <= arr.length <= 10^5`
- `1 <= arr[i] <= 100`

### 示例

```text
输入：arr = [1,3,5]
输出：4
解释：奇数和的子数组为 [1]、[3]、[5]、[1,3,5]。

输入：arr = [2,4,6]
输出：0

输入：arr = [1,2,3,4,5,6,7]
输出：16
```

## 解题思路

### 前缀和奇偶配对

子数组 `arr[i..j]` 的和 = 前缀和之差 `s[j+1] - s[i]`（`s[0] = 0`）。「差为奇数」当且仅当两个前缀和**奇偶性不同**。于是扫描每个前缀和，只维护两个计数器：

- 当前前缀为**偶**：它与此前每个**奇**前缀配出一段奇和子数组 → `ret += odd`，`even++`；
- 当前前缀为**奇**：对称地 `ret += even`，`odd++`。

两个细节：

1. **`even` 初值 1**：空前缀 `s[0] = 0` 是偶数。漏掉它，「从下标 0 开始的奇和子数组」就永远配不上对——这与 560 题 `s[0]` 必须入哈希表是同一个坑；
2. **溢出**：答案上限约 `n²/2 ≈ 5×10^9`，超过 `INT_MAX`，C++ 必须用 `int64_t` 累计、最后取模；Python 大整数无忧但同样最后取模。

### 手算示例 1（arr = [1,3,5]）

前缀和序列 `s = [0, 1, 4, 9]`，逐个处理非空前缀：

| 前缀和 | 奇偶 | 配对（对面奇偶的更早前缀） | ret | odd | even |
|--------|------|---------------------------|-----|-----|------|
| s1=1 | 奇 | 与 s0=0 配出 [1] | 1 | 1 | 1 |
| s2=4 | 偶 | 与 s1=1 配出 [3] | 2 | 1 | 2 |
| s3=9 | 奇 | 与 s0=0 配出 [1,3,5]；与 s2=4 配出 [5] | 4 | 2 | 2 |

答案 4 ✓：`[1]`、`[3]`、`[5]`、`[1,3,5]`（注意 `[3,5]` 和为 8 是偶数，不在内）。

### 复杂度分析

- 时间复杂度：`O(n)`，一趟扫描；
- 空间复杂度：`O(1)`，三个计数器。

## 代码实现

C++ 与 Python 逐行对应（唯一差异是 C++ 的 `int64_t` 溢出防护），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt1524-cpp" name="lt1524" checked>
  <input type="radio" id="lt1524-py" name="lt1524">
  <div class="lang-tab-nav">
    <label for="lt1524-cpp">C++</label>
    <label for="lt1524-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int numOfSubarrays(vector<int>& arr) {
        const int64_t MODULO = 1000000007;

        int64_t result = 0;
        int64_t prefix = 0;
        int64_t odd = 0, even = 1;  // even 初值 1：空前缀 s[0]=0 计为偶

        for (auto i : arr) {
            prefix += i;
            if (prefix % 2 == 0) {
                result += odd;  // 偶前缀 - 奇前缀 = 奇和子数组
                even += 1;
            } else {
                result += even;  // 奇前缀 - 偶前缀 = 奇和子数组
                odd += 1;
            }
        }

        return static_cast<int>(result % MODULO);
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def numOfSubarrays(self, arr: list[int]) -> int:
        prefix = 0
        odd, even = 0, 1  # even 初值 1：空前缀 s[0]=0 计为偶
        ret = 0
        for x in arr:
            prefix += x
            if prefix % 2 == 0:
                ret += odd  # 偶前缀 - 奇前缀 = 奇和子数组
                even += 1
            else:
                ret += even  # 奇前缀 - 偶前缀 = 奇和子数组
                odd += 1

        return ret % (10**9 + 7)
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 只记前缀和的**奇偶**而不存前缀和本身——配对条件是「奇偶不同」，两个计数器就是全部状态；
- `even` 初值 1 对应空前缀 `s[0] = 0`，是本题最易错的一格；
- `ret` 在循环里**不取模**（Python 无忧；C++ `int64_t` 承载 `5×10^9` 上限绰绰有余），最后一次取模——每步取模反而拖慢；
- `prefix` 只为判奇偶存在，`arr[i] <= 100` 且 `n <= 10^5`，前缀和上限 `10^7`，`int64_t` 乃至 `int` 都安全。

## 测试用例

覆盖三个官方示例、单奇/单偶、混合奇偶与 1e5 大数取模（期望值 500049986 由暴力与奇数长度计数公式双重核对——手算曾两次算错，一律机器复核）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.numOfSubarrays([1, 3, 5]) == 4
    assert solution.numOfSubarrays([2, 4, 6]) == 0
    assert solution.numOfSubarrays([1, 2, 3, 4, 5, 6, 7]) == 16

    # ---- 最小规模：单个奇数 / 单个偶数 ----
    assert solution.numOfSubarrays([1]) == 1
    assert solution.numOfSubarrays([2]) == 0

    # ---- 混合奇偶：[1] 与 [1,2]（和 3）两段 ----
    assert solution.numOfSubarrays([1, 2]) == 2
    assert solution.numOfSubarrays([2, 1]) == 2

    # ---- 大数取模：1e5 个 1，奇数长度子数组总数 ----
    assert solution.numOfSubarrays([1] * 100000) == 500049986
```

C++ 侧在 `TEST(Daily, 1524)` 里用同样的 8 组用例断言，`./tests --gtest_filter='Daily.1524*'` 通过；提交前用 O(n²) 朴素版随机对照 2000 组，与配对计数版结果全部一致。

## 总结

- 「和为奇数」⟺「两前缀和奇偶不同」，配对计数把问题压到两个计数器、O(n) 时间 O(1) 空间；
- `even` 初值 1（空前缀）是最常见的失分点，与 560 的 `s[0]` 入表同源；
- 计数上限 `n²/2` 超 `INT_MAX`，C++ 全程 `int64_t`、最后一次取模。
