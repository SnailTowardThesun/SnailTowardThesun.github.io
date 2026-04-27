---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1391: 网格中是否存在有效路径"
categories: LeetCode
---

## 题目

LeetCode 1391. Check if There is a Valid Path in a Grid (网格中是否存在有效路径)

Difficulty: **Medium**

给定一个 `m x n` 网格，网格中每个单元格代表一种街道类型（1~6），街道类型决定了当前格子的连通方向：

| 街道类型 | 连通方向 |
|---------|---------|
| 1 | 左 ↔ 右 |
| 2 | 上 ↔ 下 |
| 3 | 左 ↔ 下 |
| 4 | 右 ↔ 下 |
| 5 | 左 ↔ 上 |
| 6 | 右 ↔ 上 |

判断是否存在一条从左上角 `(0, 0)` 到右下角 `(m-1, n-1)` 的**有效路径**。有效路径要求路径上的相邻格子必须**双向兼容**——一个格子有方向 A 的连接，相邻格子在相反方向 A 上也必须有连接。

## 解题思路

这是一道经典的**网格图遍历**问题，可以使用 DFS（深度优先搜索）来解决。

### 核心思路

1. **预处理街道方向映射**：预先定义每种街道类型的两个连通方向。
2. **兼容检查**：从一个格子往某个方向走到邻居，要求当前格子在该方向有连接，且邻居格子在相反方向也有连接（双向匹配）。
3. **DFS 搜索**：从 `(0, 0)` 开始，沿着兼容的方向逐步扩展，看能否到达 `(m-1, n-1)`。

### 关键设计

#### 方向表的设计

每种方向用 `{dx, dy}` 表示：
- `dx = 1, dy = 0` → 下
- `dx = -1, dy = 0` → 上
- `dx = 0, dy = 1` → 右
- `dx = 0, dy = -1` → 左

#### 兼容性检查

核心难点在于如何判断两个相邻格子是否"双向兼容"。做法是检查**邻居格子**在**来向的反方向**是否有连接。从当前位置走到邻居的方向取负号 `(-dx, -dy)` 就是从邻居回到当前位置的方向，只有邻居在这个反方向也有连接才算双向兼容。

### 复杂度分析

- **时间复杂度**：O(m × n)，每个格子最多被访问一次
- **空间复杂度**：O(m × n)，DFS 递归栈深度最多为 m × n

## 代码实现

```cpp
class Solution {
public:
     // 每种街道类型的连通方向
    vector<vector<vector<int>>> dirs = {
         {},
         {{0, 1}, {0, -1}},      // 1: 左↔右
         {{-1, 0}, {1, 0}},      // 2: 上↔下
         {{0, -1}, {1, 0}},      // 3: 左↔下
         {{0, 1}, {1, 0}},       // 4: 右↔下
         {{-1, 0}, {0, -1}},     // 5: 上↔左
         {{0, 1}, {-1, 0}}       // 6: 右↔上
     };

     // 检查街道 street 是否在方向 (dx, dy) 的反方向有连接
    bool contains(int street, int dx, int dy) {
        auto dir = dirs[street];
        return (dir[0][0] == -dx && dir[0][1] == -dy) 
             || (dir[1][0] == -dx && dir[1][1] == -dy);
     }

     // DFS 从 (x, y) 出发搜索路径
    bool dfs(vector<vector<int>>& grid, vector<vector<int>>& vis, int x, int y) {
        int m = grid.size();
        int n = grid[0].size();

         // 到达终点
        if (x == m - 1 && y == n - 1) {
            return true;
         }

        vis[x][y] = 1;
        
         // 遍历当前格子的所有连通方向
        for (auto it : dirs[grid[x][y]]) {
            int nx = x + it[0];
            int ny = y + it[1];
            
             // 边界检查
            if (nx >= 0 && nx < m && ny >= 0 && ny < n) {
                 // 未访问过 且 双向兼容
                if (!vis[nx][ny] && contains(grid[nx][ny], it[0], it[1])) {
                    if (dfs(grid, vis, nx, ny)) {
                        return true;
                     }
                 }
             }
         }

        return false;
     }

    bool hasValidPath(vector<vector<int>>& grid) {
        int m = grid.size();
        int n = grid[0].size();
        vector<vector<int>> vis(m, vector<int>(n, 0));
        return dfs(grid, vis, 0, 0);
     }
};
```

## 总结

这道题的关键在于**方向映射的巧妙设计**和**双向兼容性的判断逻辑**。通过预处理每种街道类型的方向，利用 DFS 逐格遍历，可以在 O(m × n) 的时间复杂度内完成判断。
