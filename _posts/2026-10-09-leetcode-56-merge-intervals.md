---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.56: 合并区间"
categories: LeetCode
tags: [中等, 数组, 排序]
---

> 区间合并广泛应用于会议日程整理、基因组序列比对和数据库查询优化，是扫描线算法的入门基石。

## 题目

LeetCode 56. Merge Intervals（合并区间）

Difficulty: **Medium**

以数组 `intervals` 表示若干个区间的集合，其中单个区间为 `intervals[i] = [start_i, end_i]`。合并所有重叠的区间，并返回一个不重叠的区间数组，该数组需恰好覆盖输入中的所有区间。

### 示例

{% raw %}
```
输入：intervals = [[1,3],[2,6],[8,10],[15,18]]
输出：[[1,6],[8,10],[15,18]]
解释：区间 [1,3] 和 [2,6] 重叠，将它们合并为 [1,6]。

输入：intervals = [[1,4],[4,5]]
输出：[[1,5]]
解释：区间 [1,4] 和 [4,5] 可被视为重叠区间。
```
{% endraw %}

## 解题思路

### 排序 + 一次线性合并

关键洞察：**按起点排序后，所有可以合并的区间在数组中一定是连续的一段**。因此只需一次遍历。

1. **排序**：将区间按起点升序排列（`sort` 默认按 `vector` 字典序，正好满足）；
2. **遍历合并**：维护结果列表 `ret`：
   - 若 `ret` 为空，或当前区间起点 **大于** `ret` 最后一个区间的终点 → 无重叠，直接加入当前区间；
   - 否则 → 有重叠，把 `ret` 最后一个区间的终点更新为两者终点的较大值。

为什么比较起点和上一个终点就够？因为排序后当前区间起点 ≥ 上一区间起点，重叠只需看"起点是否落在上一区间终点之前（含相等）"。

以示例 1 为例：排序后仍为 `[1,3],[2,6],[8,10],[15,18]`；`[2,6]` 的起点 2 ≤ 3，合并为 `[1,6]`；`[8,10]` 起点 8 > 6，新开一段；`[15,18]` 同理。

### 复杂度分析

- **时间复杂度**：O(n log n)，排序为主导，合并遍历是 O(n)。
- **空间复杂度**：O(n)，用于存储结果（不含排序的 O(log n) 栈空间）。

## 代码实现

C++ 与 Python 逐行对应（原地排序 vs 新列表排序），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt56-cpp" name="lt56" checked>
  <input type="radio" id="lt56-py" name="lt56">
  <div class="lang-tab-nav">
    <label for="lt56-cpp">C++</label>
    <label for="lt56-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    vector<vector<int> > merge(vector<vector<int> > &intervals) {
        vector<vector<int> > ret;

        if (intervals.empty()) {
            return ret;
        }

        sort(intervals.begin(), intervals.end());
        for (int i = 0; i < intervals.size(); ++i) {
            int left = intervals[i][0];
            int right = intervals[i][1];
            if (ret.empty() || ret.back()[1] < left) {
                ret.push_back({left, right});
            } else {
                ret.back()[1] = max(ret.back()[1], right);
            }
        }

        return ret;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def merge(self, intervals: list[list[int]]) -> list[list[int]]:
        intervals = sorted(intervals)  # 新列表，按左端点排序；可合并者必相邻

        ret: list[list[int]] = []
        for left, right in intervals:
            if not ret or left > ret[-1][1]:  # 严格大于才分开；相触（==）也算重叠
                ret.append([left, right])
            else:
                ret[-1][1] = max(right, ret[-1][1])  # max 保证嵌套区间右端点不回缩

        return ret
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- **`ret.back()` 复用**：不重叠时 `push_back` 新区间，重叠时直接改 `ret.back()[1]`，避免额外的临时区间变量。
- **`max` 不能省**：排序只保证起点有序，终点可能"前大后小"（如 `[1,10]` 与 `[2,3]`），必须取两者较大值。
- **边界相接也算重叠**：`[1,4]` 与 `[4,5]` 中 `4 < 4` 不成立，走合并分支，符合题目"相接即重叠"的定义。
- **Python 版**：`sorted()` 返回新列表、不改调用方原数组；判定与 C++ 镜像（`left > ret[-1][1]` 开新段，等号落入合并分支）；空输入由循环自然返回空列表，无需特判。

## 测试用例

C++ 侧：

{% raw %}
```cpp
TEST(top150, 56) {
    Solution s;
    // 经典合并
    vector<vector<int> > intervals{{1, 3}, {2, 6}, {8, 10}, {15, 18}};
    auto ret = s.merge(intervals);
    EXPECT_EQ(ret.size(), 3);
    EXPECT_EQ(ret[0][0], 1);
    EXPECT_EQ(ret[0][1], 6);
    // 边界相接
    vector<vector<int> > touching{{1, 4}, {4, 5}};
    auto ret2 = s.merge(touching);
    EXPECT_EQ(ret2.size(), 1);
    EXPECT_EQ(ret2[0][1], 5);
}
```
{% endraw %}

Python 侧（hot100 版）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.merge([[1, 3], [2, 6], [8, 10], [15, 18]]) == [[1, 6], [8, 10], [15, 18]]
    assert solution.merge([[1, 4], [4, 5]]) == [[1, 5]]  # 相触视为重叠

    # ---- 输入无序：排序后正常合并（期望值由暴力对照机器算出）----
    assert solution.merge([[1, 3], [2, 6], [15, 18], [8, 10]]) == [[1, 6], [8, 10], [15, 18]]
    assert solution.merge([[5, 6], [1, 2]]) == [[1, 2], [5, 6]]

    # ---- 嵌套区间：右端点取 max 不回缩 ----
    assert solution.merge([[1, 4], [2, 3]]) == [[1, 4]]

    # ---- 单区间 / 重复区间 ----
    assert solution.merge([[1, 1]]) == [[1, 1]]
    assert solution.merge([[2, 2], [2, 2]]) == [[2, 2]]
```

## 总结

1. 排序后可合并区间必然连续，一次遍历即可；
2. 判定条件：当前起点 > 上一终点 → 新区间，否则合并终点；
3. 合并时终点取 `max`，防止前区间终点覆盖后区间。

## 补充：Top 150 C++ 实现

以下是当前 Top 150 源码中的实现，已同步到 `cplusplus/questions/56.cpp`。

{% raw %}
```cpp
using namespace std;

class Solution {
   public:
    vector<vector<int> > merge(vector<vector<int> >& intervals) {
        vector<vector<int> > ret;

        if (intervals.empty()) {
            return ret;
        }

        sort(intervals.begin(), intervals.end());
        for (int i = 0; i < intervals.size(); ++i) {
            int left = intervals[i][0];
            int right = intervals[i][1];
            if (ret.empty() || ret.back()[1] < left) {
                ret.push_back({left, right});
            } else {
                ret.back()[1] = max(ret.back()[1], right);
            }
        }

        return ret;
    }
};
```
{% endraw %}

### 补充说明

- 该实现与 Top 150 源码保持一致；若与前文旧实现不同，以本节当前版本为准。
- 代码保留源码中的关键注释（如有），便于对照变量含义和边界处理。
