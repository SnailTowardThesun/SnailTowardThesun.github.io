---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.57: 插入区间"
categories: LeetCode
---

> 区间插入是日历应用的核心操作，日程合并、航班时刻冲突检测都依赖高效区间处理。

## 题目

LeetCode 57. Insert Interval（插入区间）

Difficulty: **Medium**

给你一个**无重叠**的、按照区间起始端点排序的区间列表 `intervals`，其中 `intervals[i] = [start_i, end_i]` 表示第 `i` 个区间的开始和结束。再给你一个区间 `newInterval`，表示新的区间 `[start, end]`。

将 `newInterval` 插入到 `intervals` 中，使得 `intervals` 依然按照起始端点排序，且区间之间不重叠（如有必要，可以合并区间）。返回插入后的区间列表。

### 示例

{% raw %}
```
输入：intervals = [[1,3],[6,9]], newInterval = [2,5]
输出：[[1,5],[6,9]]
解释：新区间 [2,5] 与 [1,3] 重叠，合并为 [1,5]。

输入：intervals = [[1,2],[3,5],[6,7],[8,10],[12,16]], newInterval = [4,8]
输出：[[1,2],[3,10],[12,16]]
解释：新区间 [4,8] 与 [3,5],[6,7],[8,10] 重叠，合并为 [3,10]。
```
{% endraw %}

## 解题思路

### 定位重叠区间 + 三段拼接

插入后结果可分为三段：**重叠区之前、合并区间、重叠区之后**。难点只在找到与新区间重叠的区间范围。

两个区间 `[a, b]` 与 `[s, e]` 重叠的充要条件是 `a <= e && s <= b`（相交判定）。

1. **排序兜底**：先按起点排序，保证输入有序（题目已保证，此处是防御性处理）；
2. **定位 begin**：从左到右找第一个 `终点 > 新区间起点` 的区间下标，记为 `begin`；
3. **定位 end**：找最后一个 `起点 < 新区间终点` 的区间下标，记为 `end`；
4. **三段拼接**：`begin` 之前的区间直接保留；重叠区间与新区间合并为一个——起点取重叠区间的最小起点，终点取重叠区间终点与新终点的较大值；`end` 之后的区间直接保留。

以示例 2 为例：`[4,8]` 与 `[3,5]`、`[6,7]`、`[8,10]` 重叠，begin 指向 `[3,5]`，end 指向 `[8,10]`；合并为 `[min(3,4), max(10,8)] = [3,10]`。

### 复杂度分析

- **时间复杂度**：O(n log n)，主要是排序开销（若输入已有序，可降至 O(n)）。
- **空间复杂度**：O(n)，用于存储结果。

## 代码实现

```cpp
class Solution {
   public:
    vector<vector<int> > insert(vector<vector<int> > &intervals,
                                vector<int> &newInterval) {
        sort(intervals.begin(), intervals.end(),
             [](const vector<int> &a, const vector<int> &b) {
                 return a[0] < b[0];
             });

        vector<vector<int> > ret;
        int left = newInterval[0];
        int right = newInterval[1];
        int begin = -1;
        int end = -1;
        for (auto i = 0; i < intervals.size(); i++) {
            auto v = intervals[i];
            if (begin == -1 && v[1] > left) {
                begin = i;
            }

            if (v[0] < right) {
                end = i;
            }
        }

        for (auto i = 0; i < begin; i++) {
            ret.push_back(intervals[i]);
        }

        auto ev = intervals[end][1] > right ? intervals[end][1] : right;
        ret.push_back(vector<int>{intervals[begin][0], ev});

        for (auto i = end + 1; i < intervals.size(); i++) {
            ret.push_back(intervals[i]);
        }

        return ret;
    }
};
```

### 代码解析

- **begin 的判定**：`v[1] > left` 即"该区间终点在新起点之后"，第一个满足的区间就可能重叠；配合 `begin == -1` 只记录首个命中。
- **end 的判定**：`v[0] < right` 即"该区间起点在新终点之前"，最后一次满足的区间是重叠段的末尾。
- **合并端点**：起点直接用 `intervals[begin][0]`（排序后它就是最小起点），终点用 `max(intervals[end][1], right)`，两个值分别管左右边界。

## 测试用例

{% raw %}
```cpp
TEST(top150, 57) {
    Solution s;
    // 中间插入并合并
    vector<vector<int> > intervals = {{1, 3}, {6, 9}};
    vector<int> newInterval = {2, 5};
    auto ret = s.insert(intervals, newInterval);
    EXPECT_EQ(ret.size(), 2);
    EXPECT_EQ(ret[0][0], 1);
    EXPECT_EQ(ret[0][1], 5);
    EXPECT_EQ(ret[1][0], 6);
    EXPECT_EQ(ret[1][1], 9);
}
```
{% endraw %}

## 总结

1. 重叠判定：`起点 < 新终点` 且 `终点 > 新起点`；
2. 结果三段式：重叠前原样保留、重叠段合并成一块、重叠后原样保留；
3. 合并端点取 `min(起点)` 与 `max(终点)`，排序后最小起点可直接取 begin 处。
