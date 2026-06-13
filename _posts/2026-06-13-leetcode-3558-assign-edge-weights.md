---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3558: Assign Edge Weights"
categories: LeetCode
---

> 树的边权重分配问题在网络路由、分布式系统负载均衡等领域有重要应用。

## 题目

**No.3558: Assign Edge Weights**

难度：困难

给定一棵无向树，树中包含 `n` 个节点和 `n-1` 条边。

需要为每条边分配一个权重，使得从根节点到任意叶子节点的路径上所有边的权重异或和相等。

求满足条件的权重分配方案数，结果对 `10^9+7` 取模。

### 示例

**输入**：
```
edges = [[1,2],[1,3],[1,4]]
```

**输出**：
```
4
```

**解释**：树的最大深度为 2，方案数为 2^(2-1) = 4

## 解题思路

这道题的关键在于理解树的结构特性和异或运算的性质：

1. **构建邻接表**：将边转换为邻接表表示的树结构
2. **计算树的最大深度**：使用深度优先搜索(DFS)遍历树，找到从根节点到叶子节点的最长路径
3. **计算方案数**：答案为 2^(max_depth - 1) mod 1e9+7

**核心原理**：
- 树的最大深度决定了自由变量的数量
- 每个非叶子节点的子树可以独立选择权重
- 异或运算的性质保证了路径和的一致性

## 代码实现

{% raw %}
```cpp
#include <vector>

using namespace std;

class Solution {
    static constexpr int mod = 1e9 + 7;
    
    int quick_pow(int x, int y) {
        int res = 1;
        for (; y; y >>= 1) {
            if (y & 1) {
                res = 1ll * res * x % mod;
            }
            x = 1ll * x * x % mod;
        }
        return res;
    }
    
    int dfs(const vector<vector<int>>& g, int x, int parent) {
        int max_dep = 0;
        for (int y : g[x]) {
            if (y == parent) {
                continue;
            }
            max_dep = max(max_dep, dfs(g, y, x) + 1);
        }
        return max_dep;
    }
    
public:
    int assign_edge_weights(vector<vector<int>>& edges) {
        int n = edges.size() + 1;
        vector<vector<int>> g(n + 1);
        for (const auto& e : edges) {
            int u = e[0];
            int v = e[1];
            g[u].push_back(v);
            g[v].push_back(u);
        }
        int max_dep = dfs(g, 1, 0);
        return quick_pow(2, max_dep - 1);
    }
};
```
{% endraw %}

## 复杂度分析

- **时间复杂度**：O(n)，其中 n 是节点数量，DFS 遍历所有节点一次
- **空间复杂度**：O(n)，用于存储邻接表

## 测试用例

```cpp
TEST(Daily, 3558) {
    Solution s;
    vector<vector<int>> edges1{{1,2}, {1,3}, {1,4}};
    EXPECT_EQ(s.assign_edge_weights(edges1), 4);
    
    vector<vector<int>> edges2{{1,2}, {2,3}, {3,4}};
    EXPECT_EQ(s.assign_edge_weights(edges2), 4);
}
```

## 总结

本题考察了树的遍历和数学建模能力。通过分析异或运算的性质，我们发现问题可以简化为计算树的最大深度，然后利用快速幂计算方案数。这种将复杂问题转化为简单树遍历的思路值得借鉴。
