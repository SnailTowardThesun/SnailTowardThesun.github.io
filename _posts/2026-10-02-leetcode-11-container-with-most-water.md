---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.11: 盛最多水的容器"
categories: LeetCode
tags: [中等, 数组, 双指针]
---

> 双指针从两端向中间收缩，每次移动较矮的一侧——这是双指针贪心最经典的入门题。

## 题目

LeetCode 11. Container With Most Water（盛最多水的容器）

Difficulty: **Medium**

给你 n 个非负整数 height，每个数代表坐标中的一条垂直线。找出两条线，使它们与 x 轴构成的容器能容纳最多的水，返回最大面积。不能倾斜容器。

### 示例

```
输入：[1,8,6,2,5,4,8,3,7]
输出：49

输入：[1,1]
输出：1
```

## 解题思路

### 双指针贪心

面积 = `min(height[left], height[right]) × (right - left)`。

1. 两指针分别指向首尾，此时宽度最大。
2. 每次移动高度较小的一侧：移动较高侧时宽度减小、高度上限不变，面积不可能增大；只有移动较矮侧才可能找到更高的线。
3. 记录过程中最大面积，两指针相遇即结束。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

C++ 与 Python 逻辑一致（对撞双指针、只移短板），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt11-cpp" name="lt11" checked>
  <input type="radio" id="lt11-py" name="lt11">
  <div class="lang-tab-nav">
    <label for="lt11-cpp">C++</label>
    <label for="lt11-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
public:
    int maxArea(vector<int>& height) {
        int i = 0;
        int j = height.size() - 1;
        int result = 0;
        while (i < j) {
            int area = (j - i) * min(height[i], height[j]);
            result = max(result, area);
            if (height[i] <= height[j]) i++;
            else j--;
        }
        return result;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def maxArea(self, height: list[int]) -> int:
        left, right = 0, len(height) - 1
        ret = 0
        while left < right:
            # 先记面积再收缩；面积受短板限制，宽度为两指针间距
            ret = max(ret, min(height[left], height[right]) * (right - left))
            # 只移动短板：移动高板不可能得到更大面积
            if height[left] > height[right]:
                right -= 1
            else:
                left += 1
        return ret
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- `height[i] <= height[j]` 时移动左指针，否则移动右指针，相等时移哪一侧均可（两个版本在等高时都选择移动左侧，行为一致）。
- **先记面积再收缩**：当前指针位置的面积必须先算——收缩之后这组「宽度」就再也没有了。
- 贪心正确性一句话：被移动走的短板，它与之间任何线的组合都不可能超过当前面积（宽度更小、高上限不变），排除它是安全的。

## 测试用例

C++ 侧：

```cpp
TEST(Daily, 11) {
    Solution s;
    vector<int> height1 = {1, 8, 6, 2, 5, 4, 8, 3, 7};
    EXPECT_EQ(s.maxArea(height1), 49);
    vector<int> height3 = {4, 3, 2, 1, 4};
    EXPECT_EQ(s.maxArea(height3), 16);
}
```

Python 侧（hot100 版）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：高 8 与高 7 的两条线 ----
    assert solution.maxArea([1, 8, 6, 2, 5, 4, 8, 3, 7]) == 49

    # ---- 官方示例 2：最小规模 ----
    assert solution.maxArea([1, 1]) == 1

    # ---- 补充示例：两端等高 ----
    assert solution.maxArea([4, 3, 2, 1, 4]) == 16

    # ---- 补充示例：中间高不如两端宽 ----
    assert solution.maxArea([1, 2, 1]) == 2

    # ---- 含 0 高度：短板为 0 的容器存不了水 ----
    assert solution.maxArea([0, 5]) == 0

    # ---- 递减序列：宽高折中，min(5,3)*2 = 6 ----
    assert solution.maxArea([5, 4, 3, 2, 1]) == 6
```

## 总结

1. 首尾双指针保证从最大宽度开始；
2. 只移动较矮侧，因为较高侧不可能带来更优解；
3. O(n) 时间 O(1) 空间。
