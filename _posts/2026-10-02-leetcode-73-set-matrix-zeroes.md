---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.73: 矩阵置零"
categories: LeetCode
tags: [中等, 矩阵, 哈希表]
---

> 用第一行第一列本身做标记位，先标记再置零；但两个标记位会互相污染，需额外两个 bool 记录它们自身是否有零。

## 题目

LeetCode 73. Set Matrix Zeroes（矩阵置零）

Difficulty: **Medium**

给定 m × n 矩阵，若某元素为 0，则将其所在行和列全部置零。要求原地算法。

### 示例

```
输入：[[1,1,1],[1,0,1],[1,1,1]]
输出：[[1,0,1],[0,0,0],[1,0,1]]
```

## 解题思路

### 首行首列标记法

1. 遍历矩阵，遇到 0 时把该行首列 `matrix[i][0]`、该列首行 `matrix[0][j]` 标记为 0；同时用 row、col 两个 bool 记录第一行、第一列自身是否出现零。
2. 从下标 (1,1) 开始第二遍遍历，只要行首或列首标记为 0，就把当前元素置零。
3. 最后根据 row、col 决定是否把第一行、第一列整体置零。

顺序很重要：必须先完成标记，再从第二行第二列开始置零，否则标记会被提前污染。

### 复杂度分析

- **C++ 首行首列标记法**：时间 O(mn)，额外空间 O(1)。
- **Python 坐标收集法**：设原矩阵有 k 个零，时间 O(mn + k(m+n))，额外空间 O(k+1)。全零矩阵下，时间达到 O(mn(m+n))、空间达到 O(mn)。

## 代码实现

C++ 用首行首列标记法（O(1) 空间），Python 为先收集后置零的直观实现，点击标签切换查看：

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

        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; j++) {
                if (matrix[i][j] == 0) {
                    if (i == 0) row = true;
                    if (j == 0) col = true;
                    matrix[i][0] = 0;
                    matrix[0][j] = 0;
                }
            }
        }

        for (int i = 1; i < m; ++i) {
            for (int j = 1; j < n; j++) {
                if (matrix[i][0] == 0 || matrix[0][j] == 0) matrix[i][j] = 0;
            }
        }

        if (row) for (int j = 0; j < n; ++j) matrix[0][j] = 0;
        if (col) for (int i = 0; i < m; ++i) matrix[i][0] = 0;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def setZeroes(self, matrix: list[list[int]]) -> None:
        m, n = len(matrix), len(matrix[0])
        zeros = [(i, j) for i in range(m) for j in range(n) if matrix[i][j] == 0]

        # 先收集后置零：新写入的 0 不会再触发置零
        for r, c in zeros:
            for j in range(n):  # 整行置零
                matrix[r][j] = 0
            for i in range(m):  # 整列置零
                matrix[i][c] = 0
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- C++ 版把第一行/第一列复用为标记数组，额外空间只有 row、col 两个 bool，满足进阶的 O(1) 要求。
- Python 版（仓库 hot100 目录）先用列表收集所有 0 的坐标，再统一置零——每个零都要遍历整行、整列，同一行或列可能被反复处理。因此除了保存坐标所需的 O(k+1) 额外空间，还要计入 O(k(m+n)) 的置零时间。
- 两个版本共享同一个关键点：**不能边扫边置零**，否则新写入的 0 会级联触发整行整列置零；C++ 靠「先标记、从 (1,1) 开始置零」避免污染，Python 靠「先收集、后置零」。
- 介于两者之间的等价做法：用两个集合分别记录含 0 的行号和列号，第二遍扫描按集合置零，时间 O(mn)、额外空间 O(m+n)，可避免逐个零重复遍历整行整列。

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

Python 侧（hot100 版，先收集后置零）：

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
```

## 总结

1. 首行首列复用为标记数组，省掉 O(m+n) 空间；
2. 两个 bool 单独记录标记行/列自身的零；
3. 置零从 (1,1) 开始，避免标记被提前覆盖；
4. Python 坐标收集版便于理解，但会重复遍历行列；需要提高效率时，可用行列集合或首行首列标记法。
