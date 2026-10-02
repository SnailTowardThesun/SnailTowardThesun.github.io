---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.84: 柱状图中最大的矩形"
categories: LeetCode
---

> 单调递增栈存下标，遇到更矮的柱子就弹栈结算——弹出柱左右两侧第一个更矮的位置，就是它能扩展的宽度边界。

## 题目

LeetCode 84. Largest Rectangle in Histogram（柱状图中最大的矩形）

Difficulty: **Hard**

给定 n 个非负整数表示柱状图各柱高度，每柱宽 1，求能勾勒出的最大矩形面积。

### 示例

```
输入：heights = [2,1,5,6,2,3]
输出：10
解释：高度 2、宽度 5 的矩形面积最大。

输入：heights = [2,4]
输出：4
```

## 解题思路

### 单调递增栈

栈中存下标，对应高度保持单调递增。对每个位置 i（末尾额外补一个高度 0 的哨兵位置）：

1. 当前高度小于栈顶高度时，弹栈并以弹出柱的高度 h 结算面积。
2. 弹出后，新栈顶是左侧第一个比 h 矮的位置，i 是右侧第一个比 h 矮的位置。
3. 宽度 = `i - st.top() - 1`（栈空则宽度为 i，说明左侧没有更矮柱）。
4. 面积 = h × 宽度，更新最大值。

哨兵 0 保证循环结束时栈中所有柱子都被弹出结算，不用单独处理残余栈。

### 复杂度分析

- **时间复杂度**：O(n)，每根柱子入栈出栈各一次。
- **空间复杂度**：O(n)。

## 代码实现

```cpp
class Solution {
public:
    int largestRectangleArea(vector<int>& heights) {
        stack<int> st;
        int maxArea = 0;
        int n = heights.size();

        for (int i = 0; i <= n; i++) {
            int curHeight = (i == n) ? 0 : heights[i];
            while (!st.empty() && heights[st.top()] > curHeight) {
                int h = heights[st.top()];
                st.pop();
                int width = st.empty() ? i : i - st.top() - 1;
                maxArea = max(maxArea, h * width);
            }
            st.push(i);
        }
        return maxArea;
    }
};
```

### 代码解析

- 等号不弹（条件是 `>`）：等高柱留到最后一起结算，宽度能正确覆盖。
- 栈空时宽度取 i，对应从最左边界开始的矩形。

## 测试用例

```cpp
TEST(Daily, 84) {
    Solution s;
    vector<int> heights1 = {2, 1, 5, 6, 2, 3};
    EXPECT_EQ(s.largestRectangleArea(heights1), 10);
    vector<int> heights4 = {5, 4, 3, 2, 1};
    EXPECT_EQ(s.largestRectangleArea(heights4), 9);
}
```

## 总结

1. 单调递增栈定位每个柱子左右第一个更矮位置；
2. 弹栈即结算，宽 = 右界 - 左界 - 1；
3. 末尾补 0 哨兵清空栈，O(n) 时间 O(n) 空间。
