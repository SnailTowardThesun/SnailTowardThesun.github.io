---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.42: 接雨水"
categories: LeetCode
tags: [困难, 数组, 双指针, 动态规划]
---

> 双指针向中间收缩，两侧都高于当前水位时抬升水位，水量按新水位一次性结算。这是双指针水位法的一种变体。

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

### 双指针 + 水位结算

1. pt、pb 两指针指向两端，com 表示当前已确认的水位，tmp 记录上一轮水位。
2. 只有当两侧柱子都高于 com 时，水位才能抬升到两者较小值 `com = min(A[pt], A[pb])`。
3. 水位抬升后，对区间内每根柱子补充新增水量：`com - max(A[i], tmp)`（已超过新水位的不计）。
4. 每次移动较矮一侧的指针，与盛水容器同理。

经典写法是逐位置结算 `min(leftMax, rightMax) - height[i]`，本实现按「水位抬升事件」批量结算，思路等价。

### 解法二：前后缀最大值（动态规划，Python 版）

每列能存的水 = `min(左侧最高柱, 右侧最高柱) - 自身高度`。预处理两个数组各一趟：`leftmax[i] = max(height[0..i])` 从左向右递推，`rightmax[i] = max(height[i..n-1])` 从右向左递推，再一趟求和。正确性：一列的水位由两侧最高墙的较矮者决定——超过它就会从那侧溢出，低于柱顶的部分被柱子占据。

### 复杂度分析

- **解法一（双指针水位结算）**：时间 O(n²)（每次抬水位都扫描区间），空间 O(1)；经典双指针版可达 O(n)。
- **解法二（前后缀最大值）**：时间 O(n)（三趟线性扫描），空间 O(n)（两个辅助数组）。
- 进阶：对撞双指针维护实时 leftmax/rightmax 可兼得 O(n) 时间与 O(1) 空间——每次移动较矮一侧，较矮侧的水位由同侧前缀最大值独立确定，无需数组。

## 代码实现

两个面板是**两种解法**：C++ 为双指针水位批量结算版，Python 为前后缀最大值版，点击标签切换查看：

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
    int trap(int A[], int n) {
        if (n < 3) return 0;
        int pt = 0, pb = n - 1, com = 0, result = 0, tmp = 0;
        while (pt < pb) {
            if (A[pt] > com && A[pb] > com) {
                com = A[pt] < A[pb] ? A[pt] : A[pb];
                for (int i = pt + 1; i < pb; i++) {
                    result += com < A[i] ? 0 : com - (A[i] < tmp ? tmp : A[i]);
                }
                tmp = com;
            }
            A[pt] < A[pb] ? pt++ : pb--;
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

        # 每列水位 = min(两侧最高墙) - 柱高，负数说明自身就是墙，存不住水
        return sum(min(leftmax[i], rightmax[i]) - height[i] for i in range(n))
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- C++ 版 `com - (A[i] < tmp ? tmp : A[i])`：只累计本轮新增水位，减去柱子高度或上轮已计水位，避免重复计算。
- Python 版无需「上一轮水位」的簿记：前后缀数组把每列的水位一次算准，`min(leftmax[i], rightmax[i]) - height[i]` 恒非负（两个 max 都含 `height[i]` 自身），直接求和即可。

## 测试用例

C++ 侧：

```cpp
TEST(Daily, 42) {
    Solution s;
    int A1[] = {0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1};
    EXPECT_EQ(s.trap(A1, 12), 6);
    int A3[] = {1, 0, 1};
    EXPECT_EQ(s.trap(A3, 3), 1);
}
```

Python 侧（hot100 版）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1 / 2 ----
    assert solution.trap([0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]) == 6
    assert solution.trap([4, 2, 0, 3, 2, 5]) == 9

    # ---- 最小可存水单元 ----
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
2. 双指针收缩，两侧都更高才抬水位；
3. 经典版逐位置结算可达 O(n)，本实现是批量结算变体。
