---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.45: 跳跃游戏 II"
categories: LeetCode
---

> 当前源文件用 DP 求每个位置的最小跳跃数，思路直观但为 O(n²)；本题最优解是「边界 + 最远点」的 O(n) 贪心，文末一并给出。

## 题目

LeetCode 45. Jump Game II（跳跃游戏 II）

Difficulty: **Medium**

给定长度 n 的 0 索引数组 nums，nums[i] 表示从位置 i 能向前跳的最大长度。初始在 nums[0]，返回到达最后一个下标的最小跳跃次数。测试用例保证可达。

### 示例

```
输入：nums = [2,3,1,1,4]
输出：2
解释：下标 0 跳到 1（1 次），再跳 3 步到终点（共 2 次）。
```

## 解题思路

### 动态规划（当前实现）

dp[i] 表示到达位置 i 的最小跳跃次数：
1. dp[0] = 0，其余初始化为 INT_MAX。
2. 对每个 i，枚举所有 j < i：若 j + nums[j] >= i（j 能跳到 i），dp[i] = min(dp[i], dp[j])。
3. 内层循环结束后 dp[i] += 1（最后一跳）。

### 贪心最优解（O(n)，推荐）

维护两个变量：
- end：当前这一跳能覆盖的最远边界
- max_pos：边界内所有位置能跳到的最远点

遍历到 end 时，必须再跳一次：end 更新为 max_pos，步数 +1。每跳一次覆盖范围就扩展到 max_pos，第一次扩展到终点时的跳跃数即最小值。

### 复杂度分析

- DP（当前）：时间 O(n²)，空间 O(n)。
- 贪心（最优）：时间 O(n)，空间 O(1)。

## 代码实现

```cpp
// 当前实现：DP
class Solution {
public:
    int jump(vector<int>& nums) {
        int n = nums.size();
        vector<int> dp(n, INT_MAX);
        dp[0] = 0;
        for (int i = 1; i < n; i++) {
            for (int j = 0; j < i; j++) {
                if (nums[j] + j >= i) {
                    dp[i] = min(dp[i], dp[j]);
                }
            }
            dp[i] += 1;
        }
        return dp[n - 1];
    }
};
```

贪心参考实现：

```cpp
class SolutionGreedy {
public:
    int jump(vector<int>& nums) {
        int end = 0, max_pos = 0, steps = 0;
        for (int i = 0; i < (int)nums.size() - 1; i++) {
            max_pos = max(max_pos, i + nums[i]);
            if (i == end) {
                end = max_pos;
                steps++;
            }
        }
        return steps;
    }
};
```

### 代码解析

- DP 中 `dp[i] = min(dp[i], dp[j])` 后统一 +1，dp[j] 是到 j 的次数，最后一跳才到 i。
- 贪心循环不包含最后一个元素：到终点不需要再起跳。

## 测试用例

```cpp
TEST(TOP150, No45_JumpGameII) {
    Solution solution;
    vector<int> nums{2, 3, 1, 1, 4};
    EXPECT_EQ(solution.jump(nums), 2);
}
```

## 总结

1. DP 定义清晰：可达前驱中取最小跳跃数再加一；
2. 最优解是按「覆盖边界」批量扩展的贪心，O(n) 时间 O(1) 空间；
3. 本题源文件可后续替换为贪心版本。
