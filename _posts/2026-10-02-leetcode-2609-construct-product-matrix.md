---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2609: 构造乘积矩阵"
categories: LeetCode
---

> 二维版「除自身以外数组的乘积」：把矩阵展平，用结果矩阵本身存后缀积，再乘前缀积，O(1) 额外空间。

## 题目

LeetCode 2609. Construct Product Matrix（构造乘积矩阵）

Difficulty: **Medium**

给你一个下标从 0 开始、大小为 m × n 的二维非负整数矩阵 grid。定义矩阵中位置 (i, j) 的「除自身以外的乘积」为矩阵中所有元素除 grid[i][j] 外的乘积，对 12345 取模。返回同样大小的乘积矩阵。

### 示例

```
输入：grid = [[1,2],[3,4]]
输出：每个位置为其余元素乘积 mod 12345 的矩阵
- (0,0): 2×3×4 = 24
- (0,1): 1×3×4 = 12
- (1,0): 1×2×4 = 8
- (1,1): 1×2×3 = 6
```

## 解题思路

### 前缀积 × 后缀积，复用结果矩阵

按行优先顺序把矩阵看作长度 n = m × n 的一维序列，答案 = 前缀积 × 后缀积（均不含当前元素）。

两轮扫描，不需要额外的前后缀数组：
1. **第一轮（右下→左上）**：维护后缀积 suffix，把当前位置的 suffix 先存入 result，再乘上当前元素。遍历结束，result[i][j] 正好是该位置的后缀积。
2. **第二轮（左上→右下）**：维护前缀积 prefix，把 result[i][j] 乘上 prefix，再更新 prefix 乘当前元素。

源文件还保留了基于零个数特判的 V1（暴力）、V2（显式前后缀数组）版本。

### 复杂度分析

- **时间复杂度**：O(m × n)。
- **空间复杂度**：O(1)，不计输出矩阵。

## 代码实现

```cpp
class Solution {
   public:
    vector<vector<int>> constructProductMatrix(vector<vector<int>>& grid) {
        int row = grid.size();
        int col = grid[0].size();
        const int MOD = 12345;

        vector<vector<int>> result(row, vector<int>(col, 0));

        // 第一轮：存后缀积
        long long suffix = 1;
        for (int i = row - 1; i >= 0; i--) {
            for (int j = col - 1; j >= 0; j--) {
                result[i][j] = static_cast<int>(suffix);
                suffix = suffix * grid[i][j] % MOD;
            }
        }

        // 第二轮：乘前缀积
        long long prefix = 1;
        for (int i = 0; i < row; i++) {
            for (int j = 0; j < col; j++) {
                result[i][j] = static_cast<int>(result[i][j] * prefix % MOD);
                prefix = prefix * grid[i][j] % MOD;
            }
        }

        return result;
    }
};
```

### 代码解析

- 先存 suffix 再乘当前元素，保证 result 中不含自身。
- 全程对 12345 取模，乘法用 long long 防溢出。
- 前缀积后缀积天然不含当前位置，无需除法，零元素场景也自动正确。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2609) {
    Solution s;
    auto target = std::vector<std::vector<int>>{{10, 20}, {18, 16}, {17, 14}, {16, 9}, {14, 6}};
    auto ret = s.constructProductMatrix(target);
    EXPECT_EQ(ret.size(), 5);
}
```
{% endraw %}

## 总结

1. 矩阵按行序展平，答案 = 前缀积 × 后缀积；
2. 结果矩阵复用为后缀积存储，省掉 O(n) 额外空间；
3. 不取模会溢出，不含除法也天然处理零。
