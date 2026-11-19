---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2567: 修改两个元素后的最小分数"
categories: LeetCode
tags: [中等, 数组, 排序, 贪心]
---

> 「改成任意值」的最优策略永远是贴住保留元素的边界——于是「修改两个」退化为「删掉两个」，而删两端的三种组合各算一次极差，取最小即答案。

## 题目

LeetCode 2567. Minimum Score by Changing Two Elements（修改两个元素后的最小分数）

Difficulty: **Medium**

给你一个下标从 0 开始的整数数组 `nums`。`nums` 的**分数**是 `nums` 中最大元素和最小元素的差值。

你需要**恰好修改两个元素**（可以改成任意值，包括当前已有的值），返回修改后 `nums` 的**最小分数**。

约束：

- `3 <= nums.length <= 10^5`
- `1 <= nums[i] <= 10^9`

### 示例

```text
输入：nums = [1,4,3]
输出：0
解释：把 1 和 4 改成 3，数组全为 3，极差 0。

输入：nums = [1,4,7,8,5]
输出：3
解释：把 8 和 1 改成 5，数组为 [5,4,7,5,5]，极差 7-4 = 3。
```

## 解题思路

### 转化：修改 = 删除

「改成任意值」给了巨大的自由度：把元素 x 改成「保留元素中的某个值」永远不劣于改成别的数——分数只由保留元素的 min/max 决定，改掉的元素贴住保留值域的边界就不会撑大极差。于是问题等价于：**删掉恰好两个元素，最小化剩余元素的极差**。

### 排序后三种删法取最小

删中间元素不影响 min/max，最优删法只能发生在两端：

| 删法 | 剩余极差 |
|------|---------|
| 删最大的两个 | `nums[n-3] - nums[0]` |
| 删最大 + 最小 | `nums[n-2] - nums[1]` |
| 删最小的两个 | `nums[n-1] - nums[2]` |

三者取最小。排序后 O(1) 直接算出。

### 手算示例 2（nums = [1,4,7,8,5] → 排序 [1,4,5,7,8]）

- 删两个最大（7、8）：极差 `5 - 1 = 4`
- 删一大一小（8、1）：极差 `7 - 4 = 3` ←
- 删两个最小（1、4）：极差 `8 - 5 = 3`

答案 3（两种删法并列，改法：把 8 和 1 改成 5，或把 1、4 改成 5）。

### 复杂度分析

- 时间复杂度：`O(n log n)`，排序主导；
- 空间复杂度：`O(1)`。

## 代码实现

C++ 与 Python 逐行对应（排序 + 三式取最小），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt2567-cpp" name="lt2567" checked>
  <input type="radio" id="lt2567-py" name="lt2567">
  <div class="lang-tab-nav">
    <label for="lt2567-cpp">C++</label>
    <label for="lt2567-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int minimizeSum(vector<int>& nums) {
        int n = nums.size();
        sort(nums.begin(), nums.end());
        // 三种删法：删两个最大 / 删一大一最小 / 删两个最小
        return min(nums[n - 3] - nums[0], min(nums[n - 2] - nums[1], nums[n - 1] - nums[2]));
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def minimizeSum(self, nums: list[int]) -> int:
        nums.sort()
        # 三种删法：删两个最大 / 删一大一最小 / 删两个最小
        return min(nums[-3] - nums[0], nums[-2] - nums[1], nums[-1] - nums[2])
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 三个式子分别对应「抬高下界两次 / 抬下界压上界各一次 / 压低上界两次」——n ≥ 3 保证下标 `n-3`、`[2]` 合法；
- Python 的负下标 `nums[-3]` 与 C++ 的 `nums[n-3]` 等价，`nums.sort()` 原地排序（该方法无返回值，别写进表达式）；
- 「删中间元素不会更优」的直觉论证：中间元素既不是 min 也不是 max，删它等于浪费一次修改名额。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.minimizeSum([1, 4, 3]) == 0
    assert solution.minimizeSum([1, 4, 7, 8, 5]) == 3

    # ---- 全相等：极差本就是 0 ----
    assert solution.minimizeSum([1, 1, 1]) == 0

    # ---- 最小规模 n=3：必可全改成同一个值，答案恒 0 ----
    assert solution.minimizeSum([1, 2, 3]) == 0

    # ---- n=4（期望值由暴力对照机器算出）----
    assert solution.minimizeSum([1, 2, 3, 4]) == 1

    # ---- 两端离群、中间密集：砍掉两端后极差 0 ----
    assert solution.minimizeSum([100, 1, 50]) == 0
```

C++ 侧在 `TEST(Daily, 2567)` 里用同样的 6 组用例断言，`./tests --gtest_filter='Daily.2567*'` 通过；提交前用「枚举所有两元素删除组合取剩余极差最小」的暴力版随机对照 2000 组（n 取 3..9），与三式贪心版结果全部一致。

## 总结

- 「改成任意值」⟹ 改掉元素贴住保留值域边界 ⟹ 问题退化为「删两个元素最小化极差」；
- 删法只有三种端点组合，排序后三个式子取最小，O(n log n)；
- 删中间元素不影响 min/max——两端思维是这类「修改 k 个元素」题的通用切口。
