---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.42: 接雨水"
categories: LeetCode
tags: [困难, 数组, 双指针, 动态规划]
---

> 每一列能接的水由两侧最高墙中较矮的一侧决定。双指针用已确认的边界逐列结算，可省去前后缀数组，达到 O(n) 时间、O(1) 辅助空间。

## 题目

LeetCode 42. Trapping Rain Water（接雨水）

Difficulty: **Hard**

给定 n 个非负整数表示柱子高度，计算下雨后能接住的雨水量。

### 示例

```
输入：height = [0,1,0,2,1,0,1,3,2,1,2,1]
输出：6

输入：height = [4,2,0,3,2,5]
输出：9
```

## 解题思路

### 解法一：双指针逐列结算（C++ 版）

1. 左右指针从两端出发，分别维护已经经过的最高柱 `left_max`、`right_max`。
2. 若 `height[left] <= height[right]`，右侧已有足够高的边界，更新 `left_max` 后累计 `left_max - height[left]`，再移动左指针；否则对称处理右侧。
3. 指针相遇时结束，每一列至多结算一次。每侧指针只有在另一侧边界足够高时才推进，因此同侧历史最高墙不会导致多算。

旧版在每次抬升水位后重新扫描内部区间，最坏 O(n²)；这里与当前仓库实现一致，改为逐列结算。

### 解法二：前后缀最大值（动态规划，Python 版）

每列能存的水 = `min(左侧最高柱, 右侧最高柱) - 自身高度`。预处理两个数组各一趟：`leftmax[i] = max(height[0..i])` 从左向右递推，`rightmax[i] = max(height[i..n-1])` 从右向左递推，再一趟求和。正确性：一列的水位由两侧最高墙的较矮者决定——超过它就会从那侧溢出，低于柱顶的部分被柱子占据。

### 复杂度分析

- **解法一（双指针逐列结算）**：时间 O(n)，空间 O(1)。
- **解法二（前后缀最大值）**：时间 O(n)（三趟线性扫描），空间 O(n)（两个辅助数组）。
- 进阶：对撞双指针维护实时 leftmax/rightmax 可兼得 O(n) 时间与 O(1) 空间——每次移动较矮一侧，较矮侧的水位由同侧前缀最大值独立确定，无需数组。

## 代码实现

两个面板是**两种解法**：C++ 为双指针逐列结算版，Python 为前后缀最大值版，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt42-cpp" name="lt42" checked>
  <input type="radio" id="lt42-py" name="lt42">
  <div class="lang-tab-nav">
    <label for="lt42-cpp">C++</label>
    <label for="lt42-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    int trap(vector<int>& height) {
        const int n = static_cast<int>(height.size());
        if (n < 3) return 0;
        int left = 0, right = n - 1;
        int left_max = 0, right_max = 0, result = 0;
        while (left < right) {
            // 较低一侧的水位由本侧最大高度决定，每个位置只结算一次。
            if (height[left] <= height[right]) {
                left_max = max(left_max, height[left]);
                result += left_max - height[left++];
            } else {
                right_max = max(right_max, height[right]);
                result += right_max - height[right--];
            }
        }
        return result;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def trap(self, height: list[int]) -> int:
        n = len(height)

        # leftmax[i] = height[0..i] 的最大值（含自身），从左向右递推
        leftmax = [0] * n
        leftmax[0] = height[0]
        for i in range(1, n):
            leftmax[i] = max(leftmax[i - 1], height[i])

        # rightmax[i] = height[i..n-1] 的最大值（含自身），从右向左递推
        rightmax = [0] * n
        rightmax[n - 1] = height[n - 1]
        for i in range(n - 2, -1, -1):
            rightmax[i] = max(rightmax[i + 1], height[i])

        # 每列水位 = min(两侧最高墙) - 柱高，两侧最大值均含自身，差值非负
        return sum(min(leftmax[i], rightmax[i]) - height[i] for i in range(n))
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- C++ 版每次只处理较矮边界所在列，更新同侧最大值后计算差值，左右指针总共移动 O(n) 次。
- Python 版无需「上一轮水位」的簿记：前后缀数组把每列的水位一次算准，`min(leftmax[i], rightmax[i]) - height[i]` 恒非负（两个 max 都含 `height[i]` 自身），直接求和即可。

## 测试用例

C++ 侧：

```cpp
TEST(Daily, 42) {
    Solution s;
    vector<int> A1 = {0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1};
    EXPECT_EQ(s.trap(A1), 6);
    vector<int> A3 = {1, 0, 1};
    EXPECT_EQ(s.trap(A3), 1);
}
```

Python 侧（hot100 版）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1 ----
    assert solution.trap([0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]) == 6

    # ---- 官方示例 2 ----
    assert solution.trap([4, 2, 0, 3, 2, 5]) == 9

    # ---- 最小可存水单元：两侧夹一根矮柱 ----
    assert solution.trap([1, 0, 1]) == 1

    # ---- 碗形：中间低四周高 ----
    assert solution.trap([3, 2, 1, 2, 3]) == 4

    # ---- 单调（升/降）存不住水 ----
    assert solution.trap([1, 2, 3, 4]) == 0
    assert solution.trap([4, 3, 2, 1]) == 0

    # ---- 边界：单柱 / 双柱 ----
    assert solution.trap([5]) == 0
    assert solution.trap([2, 5]) == 0
```

提交前用「每列独立扫两侧最高墙」的 O(n²) 朴素版随机对照 1500 组，与前后缀版结果全部一致。

## 总结

1. 水量取决于两侧的较小最高值；
2. 双指针每次结算一列，O(n) 时间、O(1) 辅助空间；
3. 前后缀数组版同样 O(n) 时间，以 O(n) 空间保存各列边界信息。
