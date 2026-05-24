---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1340: 跳跃游戏 V"
categories: LeetCode
---

> 跳跃游戏系列是经典的动态规划问题，这道题引入了高度限制，增加了问题的复杂度。理解跳跃规则是解决问题的关键。

## 题目

LeetCode 1340. 跳跃游戏 V（Jump Game V）

Difficulty: **Hard**

给你一个整数数组 arr 和一个整数 d。每一步你可以从下标 i 跳到：
- i + x，其中 i + x < arr.length 且 0 < x <= d
- i - x，其中 i - x >= 0 且 0 < x <= d

除此以外，你从下标 i 跳到下标 j 需要满足：
- arr[i] > arr[j]
- 对于所有满足 i < k < j 或 j < k < i 的下标 k，都有 arr[i] > arr[k]

你可以选择数组的任意下标开始跳跃。请你返回你最多可以访问多少个下标。

### 示例

```
示例 1：
输入: arr = [6,4,14,6,8,13,9,7,10,6,12], d = 2
输出: 4
解释: 可以从下标 10 出发，跳跃路径为 10 -> 8 -> 6 -> 7

示例 2：
输入: arr = [3,3,3,3,3], d = 3
输出: 1
解释: 任意两个相邻位置的高度相同，无法跳跃

示例 3：
输入: arr = [7,6,5,4,3,2,1], d = 1
输出: 7
解释: 可以从下标 0 出发，依次跳跃到每个位置
```

## 解题思路

### 记忆化搜索 + 动态规划

这道题的关键在于理解跳跃规则：
1. 只能跳到比当前位置矮的位置
2. 中间不能有比当前位置更高的障碍物

### 核心思路

1. **定义状态**：dfs(i) 表示从位置 i 开始跳跃能访问的最大下标数
2. **状态转移**：枚举所有可能的跳跃目标 j，更新最大值
3. **跳跃条件**：
   - 距离限制：|i - j| <= d
   - 高度限制：arr[i] > arr[j]
   - 障碍物限制：i 和 j 之间没有比 arr[i] 更高的位置
4. **记忆化**：使用 memo 数组避免重复计算

### 算法详解

以 arr = [6,4,14,6,8,13,9,7,10,6,12], d = 2 为例：

```
从位置 10 (值=6) 开始：
- 向左：位置 9 (值=10) >= 6，不能跳
- 向右：位置 11 (值=12) >= 6，不能跳
- dfs(10) = 1

从位置 8 (值=13) 开始：
- 向左：位置 7 (值=7) < 13，可以跳
- 向右：位置 9 (值=10) < 13，可以跳
- dfs(8) = max(dfs(7), dfs(9)) + 1

最终找到最长路径：10 -> 8 -> 6 -> 7
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int maxJumps(vector<int>& arr, int d) {
        int n = static_cast<int>(arr.size());
        vector<int> memo(n, -1);
        int result = 0;
        
        for (int i = 0; i < n; ++i) {
            result = max(result, dfs(arr, memo, d, i, n));
        }
        
        return result;
    }
    
private:
    int dfs(vector<int>& arr, vector<int>& memo, int d, int pos, int n) {
        if (memo[pos] != -1) {
            return memo[pos];
        }
        
        int maxLen = 1;
        
        // 向左跳跃
        for (int i = pos - 1; i >= max(0, pos - d); --i) {
            if (arr[i] >= arr[pos]) {
                break;  // 遇到障碍物，停止
            }
            maxLen = max(maxLen, dfs(arr, memo, d, i, n) + 1);
        }
        
        // 向右跳跃
        for (int i = pos + 1; i <= min(n - 1, pos + d); ++i) {
            if (arr[i] >= arr[pos]) {
                break;  // 遇到障碍物，停止
            }
            maxLen = max(maxLen, dfs(arr, memo, d, i, n) + 1);
        }
        
        memo[pos] = maxLen;
        return maxLen;
    }
};
```
{% endraw %}

### 代码解析

1. **初始化**：创建 memo 数组，初始化为 -1
2. **遍历所有起点**：从每个位置开始尝试跳跃
3. **记忆化搜索**：
   - 如果已经计算过，直接返回结果
   - 否则，向左右两个方向搜索
   - 遇到障碍物立即停止（break）
4. **更新结果**：记录从每个位置开始的最大跳跃次数

### 复杂度分析

- **时间复杂度**: O(n * d)，每个位置最多被计算一次，每次计算需要 O(d) 时间
- **空间复杂度**: O(n)，记忆化数组的大小

## 测试用例

{% raw %}
```cpp
TEST(Daily, 1340) {
    Solution s;

    vector<int> arr1{6, 4, 14, 6, 8, 13, 9, 7, 10, 6, 12};
    EXPECT_EQ(s.maxJumps(arr1, 2), 4);

    vector<int> arr2{3, 3, 3, 3, 3};
    EXPECT_EQ(s.maxJumps(arr2, 3), 1);

    vector<int> arr3{7, 6, 5, 4, 3, 2, 1};
    EXPECT_EQ(s.maxJumps(arr3, 1), 7);

    vector<int> arr4{1};
    EXPECT_EQ(s.maxJumps(arr4, 1), 1);
}
```
{% endraw %}

## 总结

这道题的核心在于理解跳跃规则和正确实现记忆化搜索：

1. **跳跃规则**：只能跳到更矮的位置，且中间不能有障碍物
2. **记忆化搜索**：避免重复计算，提高效率
3. **障碍物处理**：遇到障碍物立即停止，不再继续搜索

这道题是跳跃游戏系列的一个变体，引入了高度限制，使得问题更加复杂。通过记忆化搜索，我们可以高效地解决这个问题。关键是要正确理解跳跃规则，并在搜索过程中正确处理障碍物。
