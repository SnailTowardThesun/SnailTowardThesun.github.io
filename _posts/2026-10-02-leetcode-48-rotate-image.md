---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.48: 旋转图像"
categories: LeetCode
tags: [中等, 矩阵, 模拟]
---

> 原地旋转 90 度拆成两个可逆操作：先沿主对角线转置，再逐行反转，不需要任何额外矩阵。

## 题目

LeetCode 48. Rotate Image（旋转图像）

Difficulty: **Medium**

给定 n × n 矩阵，将其原地顺时针旋转 90 度。

### 示例

```
输入：[[1,2,3],[4,5,6],[7,8,9]]
输出：[[7,4,1],[8,5,2],[9,6,3]]
```

## 解题思路

### 转置 + 行反转

1. **转置**：沿主对角线交换 matrix[i][j] 与 matrix[j][i]（只遍历上三角或下三角中的一侧，避免交换两次还原）。
2. **逐行反转**。把该行第 `i` 个位置的元素移到第 `n-1-i` 个位置。

原坐标 `(i,j)` 经过转置变为 `(j,i)`，再经逐行反转变为 `(j,n-1-i)`，恰好对应顺时针旋转 90 度。

### 复杂度分析

- **时间复杂度**：O(n²)。
- **空间复杂度**：O(1)。

## 代码实现

C++ 与 Python 均为转置 + 行反转，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt48-cpp" name="lt48" checked>
  <input type="radio" id="lt48-py" name="lt48">
  <div class="lang-tab-nav">
    <label for="lt48-cpp">C++</label>
    <label for="lt48-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    void rotate(vector<vector<int>>& matrix) {
        int n = matrix.size();

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < i; j++) {
                std::swap(matrix[i][j], matrix[j][i]);
            }
        }

        for (int i = 0; i < n; i++) {
            std::reverse(matrix[i].begin(), matrix[i].end());
        }
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def rotate(self, matrix: list[list[int]]) -> None:
        n = len(matrix)

        # 只遍历严格上三角，避免重复交换
        for i in range(n):
            for j in range(i + 1, n):
                matrix[i][j], matrix[j][i] = matrix[j][i], matrix[i][j]

        for row in matrix:
            row.reverse()
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- C++ 遍历严格下三角，Python 遍历严格上三角。两者都让每对非对角线元素只交换一次，对角线元素保持原位。
- `std::reverse` 和 `row.reverse()` 都直接反转当前行。两种实现都使用常数额外空间。
- 若要逆时针旋转，可先转置，再反转行的排列顺序，也就是交换顶行和底行，并依次向中间处理。

## 测试用例

C++ 侧：

{% raw %}
```cpp
TEST(Daily, 48) {
    Solution s;
    auto matrix = vector<vector<int>>{{1,2,3},{4,5,6},{7,8,9}};
    s.rotate(matrix);
    const vector<vector<int>> expected{{7, 4, 1}, {8, 5, 2}, {9, 6, 3}};
    EXPECT_EQ(matrix, expected);
}
```
{% endraw %}

Python 侧（hot100 版，含两条不变量检查）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    m1 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    solution.rotate(m1)
    assert m1 == [[7, 4, 1], [8, 5, 2], [9, 6, 3]]

    m2 = [[5, 1, 9, 11], [2, 4, 8, 10], [13, 3, 6, 7], [15, 14, 12, 16]]
    solution.rotate(m2)
    assert m2 == [[15, 13, 2, 5], [14, 3, 4, 1], [12, 6, 8, 9], [16, 7, 10, 11]]

    # ---- 不变量：旋转 4 次（360°）回到原矩阵（5×5）----
    m5 = [[i * 5 + j for j in range(5)] for i in range(5)]
    origin = [row[:] for row in m5]
    for _ in range(4):
        solution.rotate(m5)
    assert m5 == origin

    # ---- 不变量：旋转 2 次（180°）等于整体倒序 ----
    m6 = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    solution.rotate(m6)
    solution.rotate(m6)
    assert m6 == [[9, 8, 7], [6, 5, 4], [3, 2, 1]]
```

## 总结

1. 顺时针旋转 90° 可以拆成沿主对角线转置和逐行反转。
2. 转置只处理严格上三角或严格下三角，每对元素交换一次。
3. 两步都直接修改矩阵。时间为 O(n²)，额外空间为 O(1)。
