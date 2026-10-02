---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.874: 模拟行走机器人"
categories: LeetCode
---

> 方向向量 + 障碍物哈希集合，一步一步模拟移动，遇到障碍就停。用方向数组替代冗长的 if-else 转向逻辑更优雅。

## 题目

LeetCode 874. Walking Robot Simulation（模拟行走机器人）

Difficulty: **Medium**

机器人在无限网格上从 `(0, 0)` 出发，面向北方。命令有三种：
- `-2`：左转 90 度
- `-1`：右转 90 度
- `1 <= x <= 9`：向前移动 `x` 个单位

网格上有障碍物，如果机器人试图走到障碍物上，它会停在障碍物前的最后一个有效位置。

返回从原点到机器人**所有经过的路径点**的最大欧式距离的平方。

### 示例

```
示例 1：
输入：commands = [4, -1, 3], obstacles = []
输出：25
解释：向北走 4 步到 (0,4)，右转，向东走 3 步到 (3,4)，最大距离平方 = 3²+4² = 25。
```

## 解题思路

### 方向数组 + 哈希集合模拟

1. 用方向数组表示北、东、南、西，顺时针排列，右转即下标加一。
2. 用 `dir_idx` 表示当前方向下标，右转 `+1`，左转 `+3`（即 -1，避免负数）。
3. 障碍物存入 `unordered_set`，将二维坐标转为字符串键以快速查找。
4. 逐条命令模拟：转向更新 `dir_idx`；移动时逐步检查下一格是否为障碍物，不是则前进并更新最大距离。

### 复杂度分析

- **时间复杂度**：O(n × m)，n 为命令数，m 为单次最大步数。
- **空间复杂度**：O(k)，k 为障碍物数量。

## 代码实现

{% raw %}
```cpp
class Solution {
   public:
    int robotSim(vector<int>& commands, vector<vector<int>>& obstacles) {
        int max_distance = 0;

        // 方向数组：北、东、南、西（顺时针）
        vector<pair<int, int>> directions = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
        int dir_idx = 0;  // 初始方向：北

        unordered_set<string> obstacle_set;
        for (auto& obs : obstacles) {
            obstacle_set.insert(to_string(obs[0]) + "," + to_string(obs[1]));
        }

        int x = 0, y = 0;
        for (int cmd : commands) {
            if (cmd == -1) {
                dir_idx = (dir_idx + 1) % 4;  // 右转
            } else if (cmd == -2) {
                dir_idx = (dir_idx + 3) % 4;  // 左转
            } else {
                auto& dir = directions[dir_idx];
                for (int i = 0; i < cmd; i++) {
                    int new_x = x + dir.first;
                    int new_y = y + dir.second;
                    string key = to_string(new_x) + "," + to_string(new_y);
                    if (obstacle_set.find(key) == obstacle_set.end()) {
                        x = new_x;
                        y = new_y;
                        max_distance = max(max_distance, x * x + y * y);
                    } else {
                        break;  // 遇到障碍物，停止
                    }
                }
            }
        }
        return max_distance;
    }
};
```
{% endraw %}

### 代码解析

- 方向数组顺时针排列，右转即下标 `+1`，左转 `+3` 等价于 `-1`。
- 障碍物用字符串键存入 `unordered_set`，O(1) 查找。
- 每走一步更新最大距离，题目要求的是路径上的最大值而非终点值。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 874) {
    vector<int> commands1 = {4, -1, 3};
    vector<vector<int>> obstacles1 = {};
    Solution s1;
    EXPECT_EQ(s1.robotSim(commands1, obstacles1), 25);

    vector<int> commands2 = {6, -1, -1, 6};
    vector<vector<int>> obstacles2 = {{0, 0}};
    Solution s2;
    EXPECT_EQ(s2.robotSim(commands2, obstacles2), 36);
}
```
{% endraw %}

## 总结

本题是典型的**方向模拟**题，记忆要点：

1. 方向数组顺时针 `{北,东,南,西}`，右转 `+1`、左转 `+3`；
2. 障碍物哈希集合，O(1) 碰撞检测；
3. 逐步移动，遇障即停，实时更新最大距离平方。
