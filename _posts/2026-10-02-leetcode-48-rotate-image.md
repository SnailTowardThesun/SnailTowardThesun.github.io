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

1. **转置**：沿主对角线交换 matrix[i][j] 与 matrix[j][i]（只遍历下三角，避免交换两次还原）。
2. **行反转**：每行元素左右翻转，等价于水平镜像。

两个操作组合后，矩阵恰好顺时针旋转 90 度。

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
                swap(matrix[i][j], matrix[j][i]);
            }
        }

        for (int i = 0; i < n; i++) {
            reverse(matrix[i].begin(), matrix[i].end());
        }
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def rotate(self, matrix: list[list[int]]) -> None:
        """
        Do not return anything, modify matrix in-place instead.
        """
        m, n = len(matrix), len(matrix[0])

        # 1. 主对角线转置：j 从 i 起只走上三角，每对元素只交换一次
        for i in range(m):
            for j in range(i, n):
                matrix[i][j], matrix[j][i] = matrix[j][i], matrix[i][j]

        # 2. 逐行左右反转（水平镜像），组合后即顺时针旋转 90°
        for i in range(m):
            for j in range(n // 2):
                matrix[i][j], matrix[i][n - j - 1] = matrix[i][n - j - 1], matrix[i][j]
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 转置循环用 `j < i` 只处理下三角；`j < n` 会每个元素交换两次回到原状。
- Python 版转置从 `j = i` 出发走「上三角」——对角线元素自交换是 no-op，与 C++ 的下三角写法等价，核心都是每对 (i,j)/(j,i) 恰好交换一次。
- 方阵下 m == n，两个变量取其一即可；Python 没有内置二维 reverse，用 `j` 与 `n-1-j` 对调实现行反转。
- 另一条路线：按圈四点轮转，直接用下标公式 `(i,j) → (j, n-1-i)` 一圈圈转，同样是 O(1) 空间。

## 测试用例

C++ 侧：

{% raw %}
```cpp
TEST(Daily, 48) {
    Solution s;
    auto matrix = vector<vector<int>>{{1,2,3},{4,5,6},{7,8,9}};
    s.rotate(matrix);
    EXPECT_EQ(matrix[0][0], 7);
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

1. 旋转 90° = 转置 + 行反转；
2. 转置只遍历一个三角（上/下皆可，对角线是 no-op）；
3. 全程原地，O(1) 空间；
4. 逆时针 90° 则是转置 + 上下镜像，两次翻转的组合方向决定旋转方向。
