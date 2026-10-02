---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3661: 可以被机器人摧毁的最大墙壁数目"
categories: LeetCode
---

> 每个机器人向左或向右发射子弹，子弹会被相邻机器人阻挡。按位置排序后，每个方向的射程被相邻机器人截断，再用二分统计范围内的墙壁数。

## 题目

LeetCode 3661. Maximum Number of Walls Destroyed by Robots（可以被机器人摧毁的最大墙壁数目）

Difficulty: **Hard**

一条无限长直线上分布着机器人和墙壁。给你数组 `robots`、`distance`、`walls`：
- `robots[i]`：第 i 个机器人的位置
- `distance[i]`：第 i 个机器人的射程
- `walls[j]`：第 j 面墙壁的位置

每个机器人有一颗子弹，可向左或向右发射，最远距离为 `distance[i]`。子弹会摧毁射程内路径上的每堵墙，但如果在到达墙壁前击中另一个机器人，则立即停止。返回可摧毁墙壁的最大数量。

### 示例

```
输入：robots = [10, 2], distance = [5, 1], walls = [5, 2, 7]
输出：3
```

## 解题思路

### 排序 + 相邻截断 + 贪心选择

1. 按位置对机器人排序，墙壁排序并去重。
2. 对每个机器人 `i`：
   - 向左射程起点：`max(robots[i] - distance[i], robots[i-1] + 1)`（被左侧相邻机器人阻挡）
   - 向右射程终点：`min(robots[i] + distance[i], robots[i+1] - 1)`（被右侧相邻机器人阻挡）
3. 用二分查找统计左右射程内的墙壁数量。
4. 贪心选择：每个机器人选择能摧毁更多**未被摧毁**墙壁的方向，标记被摧毁的墙壁，累加总数。

### 复杂度分析

- **时间复杂度**：O(n log n + n × k)，排序 + 每个机器人二分与遍历。
- **空间复杂度**：O(n + w)，存储机器人信息和墙壁摧毁状态。

## 代码实现

```cpp
struct Item {
    int position;
    int distance;
};

class Solution {
   public:
    int maxWalls(vector<int>& robots, vector<int>& distance, vector<int>& walls) {
        int n = robots.size();
        vector<Item> container_robots;
        for (int i = 0; i < n; ++i) {
            container_robots.push_back({robots[i], distance[i]});
        }
        sort(container_robots.begin(), container_robots.end(),
             [](const Item& a, const Item& b) { return a.position < b.position; });

        sort(walls.begin(), walls.end());
        walls.erase(unique(walls.begin(), walls.end()), walls.end());

        unordered_map<int, bool> destroyed;
        for (int wall : walls) destroyed[wall] = false;

        vector<vector<int>> left_walls(n), right_walls(n);
        for (int i = 0; i < n; ++i) {
            int pos = container_robots[i].position;
            int dist = container_robots[i].distance;

            int left_start = pos - dist;
            if (i > 0) left_start = max(left_start, container_robots[i - 1].position + 1);

            int right_end = pos + dist;
            if (i < n - 1) right_end = min(right_end, container_robots[i + 1].position - 1);

            if (left_start <= pos) {
                auto l = lower_bound(walls.begin(), walls.end(), left_start);
                auto r = upper_bound(walls.begin(), walls.end(), pos);
                for (auto it = l; it != r; ++it) left_walls[i].push_back(*it);
            }
            if (pos <= right_end) {
                auto l = lower_bound(walls.begin(), walls.end(), pos);
                auto r = upper_bound(walls.begin(), walls.end(), right_end);
                for (auto it = l; it != r; ++it) right_walls[i].push_back(*it);
            }
        }

        int total = 0;
        for (int i = 0; i < n; ++i) {
            int left_count = 0, right_count = 0;
            for (int w : left_walls[i]) if (!destroyed[w]) left_count++;
            for (int w : right_walls[i]) if (!destroyed[w]) right_count++;

            auto& chosen = (left_count > right_count) ? left_walls[i] : right_walls[i];
            for (int w : chosen) {
                if (!destroyed[w]) { destroyed[w] = true; total++; }
            }
        }
        return total;
    }
};
```

### 代码解析

- 相邻机器人的位置决定了射程的截断点：`robots[i-1]+1` 和 `robots[i+1]-1`。
- `lower_bound`/`upper_bound` 在有序墙壁数组中快速定位射程范围。
- 贪心选择摧毁更多未被摧毁墙壁的方向，保证全局总数最大。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3661) {
    Solution s;
    vector<int> robots{10, 2};
    vector<int> distance{5, 1};
    vector<int> walls{5, 2, 7};
    EXPECT_EQ(3, s.maxWalls(robots, distance, walls));
}
```
{% endraw %}

## 总结

本题的关键是**相邻机器人截断射程**：

1. 排序后，每个机器人的左右射程被相邻机器人位置限制；
2. 二分统计射程内的墙壁；
3. 贪心选择摧毁更多墙壁的方向，标记已摧毁墙壁避免重复计数。
