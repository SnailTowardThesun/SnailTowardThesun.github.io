---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1306: 跳跃游戏 III"
categories: LeetCode
---

> 跳跃游戏问题在路径规划和图搜索算法中有广泛应用，理解这类问题有助于解决更复杂的网络遍历挑战。

## 题目

LeetCode 1306. Jump Game III（跳跃游戏 III）

Difficulty: **Medium**

给定一个整数数组 arr，以及一个起始位置 start。

对于 arr 中的每个元素，可以跳转到索引 start + arr[start] 或 start - arr[start]。

判定是否能够跳转到某个索引值为 0 的位置。如果可以返回 true，否则返回 false。

### 示例

```
示例 1：
输入：arr = [4,2,3,0,3,1,2], start = 5
输出：true
解释：
起始位置 5 -> 索引 4 (5 - 1) -> 索引 0 (4 - 4) -> 到达值为 0 的位置

示例 2：
输入：arr = [4,2,3,0,3,1,2], start = 0
输出：true
解释：
起始位置 0 -> 索引 4 (0 + 4) -> 索引 0 (4 - 4) -> 到达值为 0 的位置

示例 3：
输入：arr = [3,0,2,1,2], start = 2
输出：false
```

## 解题思路

这道题可以使用深度优先搜索（DFS）+ 记忆化搜索来解决。

### 核心思路

1. **DFS 递归搜索**：
   - 从起始位置 start 开始
   - 尝试跳转到 start + arr[start] 和 start - arr[start]
   - 如果跳转到值为 0 的位置，返回 true
   - 如果跳转到已访问过的位置，返回 false

2. **记忆化搜索**：
   - 使用 visited 数组记录已访问的位置
   - 避免重复访问导致无限循环

### 算法详解

以示例 1 的 arr = [4,2,3,0,3,1,2], start = 5 为例：

```
步骤 1：初始化
visited = [false, false, false, false, false, false, false]

步骤 2：从位置 5 开始
arr[5] = 1，可以跳转到 6 (5+1) 和 4 (5-1)
访问位置 5，visited[5] = true
检查 arr[5] = 1 ≠ 0

步骤 3：尝试跳转到位置 6
6 >= 7，无效

步骤 4：尝试跳转到位置 4
arr[4] = 3，可以跳转到 7 (4+3) 和 1 (4-3)
访问位置 4，visited[4] = true
检查 arr[4] = 3 ≠ 0

步骤 5：从位置 4 跳转到位置 1
arr[1] = 2，可以跳转到 3 (1+2) 和 -1 (1-2)
访问位置 1，visited[1] = true
检查 arr[1] = 2 ≠ 0

步骤 6：从位置 1 跳转到位置 3
arr[3] = 0，找到目标位置！

最终结果：true
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    bool dfs(vector<int> &arr, int start, vector<bool> &visited) {
        if (start < 0 || start >= arr.size() || visited[start]) {
            return false;
        }

        if (arr[start] == 0) {
            return true;
        }
        visited[start] = true;
        if (start + arr[start] < arr.size()) {
            if (dfs(arr, start + arr[start], visited)) {
                return true;
            }
        }

        if (start - arr[start] < arr.size() && start - arr[start] >= 0) {
            if (dfs(arr, start - arr[start], visited)) {
                return true;
            }
        }

        return false;
    }

    bool canReach(vector<int> &arr, int start) {
        vector<bool> visited(arr.size(), false);
        return dfs(arr, start, visited);
    }
};
```
{% endraw %}

### 代码解析

1. **dfs 函数**：
   - 参数：arr 数组、当前位置 start、visited 访问标记数组
   - 基准情况：位置越界或已访问过，返回 false
   - 找到目标：arr[start] == 0，返回 true
   - 标记访问：将当前位置标记为已访问
   - 递归搜索：尝试左右两个方向跳跃

2. **canReach 函数**：
   - 初始化 visited 数组
   - 调用 dfs 开始搜索

### 复杂度分析

- **时间复杂度**: O(n)，每个位置最多访问一次
- **空间复杂度**: O(n)，用于 visited 数组和递归栈

## 测试用例

{% raw %}
```cpp
TEST(Daily, 1306) {
    Solution s;

    // 测试用例 1
    auto arr1 = vector<int>{4, 2, 3, 0, 3, 1, 2};
    EXPECT_TRUE(s.canReach(arr1, 5));

    // 测试用例 2
    auto arr2 = vector<int>{4, 2, 3, 0, 3, 1, 2};
    EXPECT_TRUE(s.canReach(arr2, 0));

    // 测试用例 3
    auto arr3 = vector<int>{3, 0, 2, 1, 2};
    EXPECT_FALSE(s.canReach(arr3, 2));
}
```
{% endraw %}

## 总结

这道题是跳跃游戏系列的第三道题，相比前两题，这道题增加了左右两个方向的跳跃。关键点在于使用 visited 数组避免重复访问，导致无限循环。DFS + 记忆化搜索是解决这类问题的经典方法。
