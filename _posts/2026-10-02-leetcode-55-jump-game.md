---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.55: 跳跃游戏"
categories: LeetCode
---

> 不关心怎么跳，只关心最远能到哪——维护一个 right_most 最远可达位置，走不到的位置会提前暴露死局。

## 题目

LeetCode 55. Jump Game（跳跃游戏）

Difficulty: **Medium**

给定非负整数数组，初始在第一个下标，nums[i] 为该位置可跳跃的最大长度。判断能否到达最后一个下标。

### 示例

```
输入：nums = [2,3,1,1,4]   输出：true
输入：nums = [3,2,1,0,4]   输出：false
解释：总会被困在下标 3（值为 0），无法越过。
```

## 解题思路

### 贪心维护最远可达位置

1. right_most 初始为 nums[0]，表示目前能到达的最远下标。
2. 从 i = 1 开始遍历：
   - i > right_most：当前位置本身不可达，后面也都到不了，返回 false。
   - 用 `i + nums[i]` 尝试扩展 right_most。
3. 遍历结束说明每个位置都可达，终点自然可达，返回 true。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    bool canJump(vector<int>& nums) {
        int right_most = nums[0];
        for (int i = 1; i < (int)nums.size(); i++) {
            if (i > right_most) return false;
            right_most = max(right_most, i + nums[i]);
        }
        return true;
    }
};
```

### 代码解析

- 关键不是「跳不跳」而是「可达边界扩到哪」；每个可达点都能用来扩展边界。
- right_most 一旦 >= n-1 实际可提前返回 true。

## 测试用例

```cpp
TEST(TOP150, No55_CanJump) {
    Solution solution;
    vector<int> nums{2, 3, 1, 1, 4};
    EXPECT_TRUE(solution.canJump(nums));
    vector<int> nums2{3, 2, 1, 0, 4};
    EXPECT_FALSE(solution.canJump(nums2));
}
```

## 总结

1. 维护可达右边界，遇可达点就尝试扩展；
2. 当前下标超过边界即死局；
3. 与跳跃游戏 II 的「边界扩展」模型一脉相承。
