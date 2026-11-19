---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.73: 矩阵置零"
categories: LeetCode
tags: [中等, 矩阵, 哈希表]
---

> 用第一行记录哪些列要置零，用第一列记录哪些行要置零。因为两者共用左上角，再用两个布尔值单独记录首行和首列原本是否含零。

## 题目

LeetCode 73. Set Matrix Zeroes（矩阵置零）

Difficulty: **Medium**

给定 m × n 矩阵，若某元素为 0，则将其所在行和列全部置零。直接在输入矩阵上完成修改，进阶要求使用常数额外空间。

### 示例

```
输入：[[1,1,1],[1,0,1],[1,1,1]]
输出：[[1,0,1],[0,0,0],[1,0,1]]
```

## 解题思路

### 首行首列标记法

1. 确定首行、首列原本是否含零，用两个布尔值保存。
2. 对其余单元格，若 `matrix[i][j]` 原本为零，则将行首 `matrix[i][0]` 和列首 `matrix[0][j]` 写成零。首行与首列原有的零可以直接作为标记。
3. 根据标记处理其余单元格，最后按两个布尔值决定是否将首行和首列置零。

标记期间只向首行和首列写零，其余单元格还保留原值。所有标记完成后，才能按标记批量置零。

### 复杂度分析

两种实现都只遍历矩阵常数次，时间为 O(mn)，额外空间为 O(1)。

## 代码实现

C++ 将首行首列的判断并入标记遍历，Python 先单独读取首行和首列。两个版本都使用常数额外空间。

<div class="lang-tabs">
  <input type="radio" id="lt73-cpp" name="lt73" checked>
  <input type="radio" id="lt73-py" name="lt73">
  <div class="lang-tab-nav">
    <label for="lt73-cpp">C++</label>
    <label for="lt73-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    void setZeroes(vector<vector<int>>& matrix) {
        if (matrix.empty()) return;
        int m = matrix.size();
        int n = matrix[0].size();
        bool row = false, col = false;
        for (int i = 0; i < m; ++i)
            for (int j = 0; j < n; j++)
                if (matrix[i][j] == 0) {
                    if (i == 0) row = true;
                    if (j == 0) col = true;
                    matrix[i][0] = 0;
                    matrix[0][j] = 0;
                }
        for (int i = 1; i < m; ++i)
            for (int j = 1; j < n; j++)
                if (matrix[i][0] == 0 || matrix[0][j] == 0) matrix[i][j] = 0;
        if (row)
            for (int j = 0; j < n; ++j) matrix[0][j] = 0;
        if (col)
            for (int i = 0; i < m; ++i) matrix[i][0] = 0;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def setZeroes(self, matrix: list[list[int]]) -> None:
        m, n = len(matrix), len(matrix[0])
        first_row_zero = 0 in matrix[0]
        first_col_zero = any(row[0] == 0 for row in matrix)

        for i in range(1, m):
            for j in range(1, n):
                if matrix[i][j] == 0:
                    matrix[i][0] = matrix[0][j] = 0

        for i in range(1, m):
            for j in range(1, n):
                if matrix[i][0] == 0 or matrix[0][j] == 0:
                    matrix[i][j] = 0

        if first_row_zero:
            for j in range(n):
                matrix[0][j] = 0
        if first_col_zero:
            for i in range(m):
                matrix[i][0] = 0
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- C++ 按行扫描，先访问首行，每一行也先访问第一列。因此读取原有的首行、首列状态时，后面单元格产生的标记还没有覆盖它们。
- Python 在写入任何标记前计算 `first_row_zero` 和 `first_col_zero`，随后只扫描从 `(1,1)` 开始的区域。
- 首行和首列要最后处理，提前清零会抹掉用来判断其他行列的标记。

## 测试用例

C++ 侧：

{% raw %}
```cpp
TEST(Daily, 73) {
    Solution s;
    vector<vector<int>> matrix1 = {{1,1,1},{1,0,1},{1,1,1}};
    s.setZeroes(matrix1);
    EXPECT_EQ(matrix1[1], vector<int>({0,0,0}));
}
```
{% endraw %}

Python 用例覆盖原有零出现在内部、首行或首列，以及矩阵全零或无零的情况。

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    m1 = [[1, 1, 1], [1, 0, 1], [1, 1, 1]]
    solution.setZeroes(m1)
    assert m1 == [[1, 0, 1], [0, 0, 0], [1, 0, 1]]

    m2 = [[0, 1, 2, 0], [3, 4, 5, 2], [1, 3, 1, 5]]
    solution.setZeroes(m2)
    assert m2 == [[0, 0, 0, 0], [0, 4, 5, 0], [0, 3, 1, 0]]

    # ---- 首行/首列含 0 ----
    m3 = [[0, 2], [3, 4]]
    solution.setZeroes(m3)
    assert m3 == [[0, 0], [0, 4]]

    # ---- 无 0 / 全 0 ----
    m4 = [[1, 2], [3, 4]]
    solution.setZeroes(m4)
    assert m4 == [[1, 2], [3, 4]]

    m5 = [[0, 0], [0, 0]]
    solution.setZeroes(m5)
    assert m5 == [[0, 0], [0, 0]]

    first_row_only = [[1, 0, 3], [4, 5, 6]]
    solution.setZeroes(first_row_only)
    assert first_row_only == [[0, 0, 0], [4, 0, 6]]

    first_col_only = [[1, 2], [0, 4], [5, 6]]
    solution.setZeroes(first_col_only)
    assert first_col_only == [[0, 2], [0, 0], [0, 6]]
```

## 总结

1. 用首行、首列保存标记，并独立记录它们原本是否含零。
2. 先完成标记，再处理其余单元格，最后处理首行和首列。
