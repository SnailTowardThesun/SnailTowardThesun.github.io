---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2492: 两个城市间路径的最小分数"
categories: LeetCode
---

> 图的连通性问题在网络规划和路径优化中有广泛应用，DFS是遍历连通分量的经典方法。

## 题目

LeetCode 2492. Minimum Score of a Path Between Two Cities（两个城市间路径的最小分数）

Difficulty: **Medium**

给你一个正整数 `n`，表示总共有 `n` 个城市，城市从 `1` 到 `n` 编号。给你一个二维数组 `roads`，其中 `roads[i] = [ai, bi, distancei]` 表示城市 `ai` 和 `bi` 之间有一条 **双向** 道路，道路距离为 `distancei`。城市构成的图不一定是连通的。

两个城市之间一条路径的 **分数** 定义为这条路径中道路的 **最小** 距离。

返回城市 `1` 和城市 `n` 之间的所有路径的 **最小** 分数。

### 注意

- 一条路径指的是两个城市之间的道路序列。
- 一条路径可以 **多次** 包含同一条道路，你也可以沿着路径多次到达城市 `1` 和城市 `n`。
- 测试数据保证城市 `1` 和城市 `n` 之间 **至少** 有一条路径。

### 示例

```
示例 1：
输入：n = 4, roads = [[1,2,9],[2,3,6],[2,4,5],[1,4,7]]
输出：5
解释：城市 1 到城市 4 的路径中，分数最小的一条为：1 -> 2 -> 4。这条路径的分数是 min(9,5) = 5。

示例 2：
输入：n = 4, roads = [[1,2,2],[1,3,4],[3,4,7]]
输出：2
解释：城市 1 到城市 4 分数最小的路径是：1 -> 2 -> 1 -> 3 -> 4。这条路径的分数是 min(2,2,4,7) = 2。
```

## 解题思路

这道题的关键在于理解题目中的路径定义。题目允许路径多次包含同一条道路，也可以多次到达城市 1 和城市 n。因此，只要某条道路在城市 1 所在的连通分量中，就可以被纳入路径中。

### 核心思路

问题转化为：找出城市 1 所在连通分量中的最小边权。

使用深度优先搜索（DFS）：
1. 构建邻接表表示图
2. 从城市 1 开始进行 DFS，遍历所有可达的城市
3. 在遍历过程中记录遇到的最小边权
4. 返回最小边权作为答案

### 算法详解

以示例 1 的 n = 4, roads = [[1,2,9],[2,3,6],[2,4,5],[1,4,7]] 为例：

```
构建邻接表：
1: [(2,9), (4,7)]
2: [(1,9), (3,6), (4,5)]
3: [(2,6)]
4: [(2,5), (1,7)]

步骤 1：从城市 1 开始
visited = [false, false, false, false, false]
当前城市 1，标记 visited[1] = true
边 (1,2,9)：min = 9
边 (1,4,7)：min = 7

步骤 2：访问城市 2
visited[2] = true
边 (2,1,9)：城市 1 已访问，跳过
边 (2,3,6)：min = 6
边 (2,4,5)：min = 5

步骤 3：访问城市 3
visited[3] = true
边 (3,2,6)：城市 2 已访问，跳过

步骤 4：访问城市 4
visited[4] = true
边 (4,2,5)：城市 2 已访问，跳过
边 (4,1,7)：城市 1 已访问，跳过

最终结果：min = 5
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    void dfs(vector<vector<pair<int, int>>>& container, vector<int>& vis, int pos, int& ans) {
        vis[pos] = true;
        for (auto i : container[pos]) {
            ans = min(i.second, ans);
            if (!vis[i.first]) {
                dfs(container, vis, i.first, ans);
            }
        }
    }

    int minScore(int n, vector<vector<int>>& roads) {
        vector<vector<pair<int, int>>> container(n + 1);
        vector<int> visual(n + 1, 0);
        int res = INT_MAX;

        for (auto i : roads) {
            container[i[0]].emplace_back(pair<int, int>{i[1], i[2]});
            container[i[1]].emplace_back(pair<int, int>{i[0], i[2]});
        }

        dfs(container, visual, 1, res);

        return res;
    }
};
```
{% endraw %}

### 代码解析

1. **dfs 函数**：
   - 参数：邻接表 container、访问标记数组 vis、当前位置 pos、最小边权 ans
   - 标记当前城市为已访问
   - 遍历所有相邻城市，更新最小边权
   - 对未访问的相邻城市递归调用 dfs

2. **minScore 函数**：
   - 初始化邻接表和访问标记数组
   - 构建无向图的邻接表
   - 调用 dfs 从城市 1 开始遍历
   - 返回最小边权

### 复杂度分析

- **时间复杂度**: O(n + m)，n 是城市数量，m 是道路数量
- **空间复杂度**: O(n + m)，邻接表和访问标记数组

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2492) {
    Solution s;

    // 测试用例 1
    int n = 4;
    vector<vector<int>> roads{{1, 2, 9}, {2, 3, 6}, {2, 4, 5}, {1, 4, 7}};
    int ret = s.minScore(n, roads);
    EXPECT_EQ(5, ret);

    // 测试用例 2
    n = 4;
    roads = {{1, 2, 2}, {1, 3, 4}, {3, 4, 7}};
    ret = s.minScore(n, roads);
    EXPECT_EQ(2, ret);
}
```
{% endraw %}

## 总结

这道题的关键在于理解路径的定义。由于路径可以多次经过同一条道路，问题就转化为求城市 1 所在连通分量中的最小边权。使用 DFS 遍历连通分量并记录最小边权是最直接的解法。

类似的问题也可以使用 BFS 或并查集来解决：
- BFS：与 DFS 类似，使用队列进行层次遍历
- 并查集：先找出连通分量，再在该分量中找最小边权

DFS 的实现简洁直观，适合处理这类连通性问题。
