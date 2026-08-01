---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.486: 预测赢家"
categories: LeetCode
---

> 博弈论中的零和博弈与 minimax 思想广泛用于棋类 AI 与对局决策，核心是假设对手总采取最优策略来反推自身的最大收益。

## 题目

LeetCode 486. Predict the Winner（预测赢家）

Difficulty: **Medium**

给你一个整数数组 `nums`。玩家 1 和玩家 2 基于数组中的数字轮流转弯取数，每次只能从数组的任意一端（左端或右端）取一个数字。

玩家 1 先手，两人都采用最优策略。当所有数字被取完后，得分高者获胜；如果得分相等，视为玩家 1 获胜。返回 `true` 表示玩家 1 能获胜，否则返回 `false`。

### 示例

```
示例 1：
输入：nums = [1, 5, 2]
输出：false
解释：玩家 1 先手。
  - 若取 1，剩 [5, 2]，玩家 2 取 5，玩家 1 取 2，得分 3 < 7；
  - 若取 2，剩 [1, 5]，玩家 2 取 5，玩家 1 取 1，得分 3 < 7。
玩家 1 必败。

示例 2：
输入：nums = [1, 5, 233, 7]
输出：true
解释：玩家 1 先取 1，剩 [5, 233, 7]。无论玩家 2 取 5 还是 7，
      玩家 1 都能取到 233，最终得分 234，玩家 2 得分 12，玩家 1 获胜。
```

## 解题思路

这道题是经典的博弈型 DP，可用记忆化搜索（Minimax 思路）解决。

### 核心思路

定义 `dfs(l, r)` 为**当前玩家**在子数组 `nums[l..r]` 上能取得的最大「分数差」（当前玩家得分 − 对手得分）。

1. **边界**：`l == r` 时只剩一个数，当前玩家取走，分差为 `nums[l]`。
2. **转移**：当前玩家有两种选择：
   - 取左端 `nums[l]`：对手在 `[l+1, r]` 上作为先手获得 `dfs(l+1, r)` 的分差，所以当前玩家的净分差为 `nums[l] - dfs(l+1, r)`。
   - 取右端 `nums[r]`：同理净分差为 `nums[r] - dfs(l, r-1)`。
   - 两者取较大值：
     `dfs(l, r) = max(nums[l] - dfs(l+1, r), nums[r] - dfs(l, r-1))`。
3. 玩家 1 作为全局先手，能获胜当且仅当 `dfs(0, n-1) >= 0`。

### 关键点：减号而非加号

> 递推式中必须用「减号」，因为对手在子问题里也是「先手」，其获得的分差要从当前玩家得分中扣除。若误用加号，会把对手的优势算成自己的，导致结果错误。

以 `nums = [1, 5, 2]` 为例验证：

```
dfs(1, 2) = max(5 - dfs(2,2), 2 - dfs(1,1)) = max(5-2, 2-5) = max(3, -3) = 3
dfs(0, 1) = max(1 - dfs(1,1), 5 - dfs(0,0)) = max(1-5, 5-1) = max(-4, 4) = 4
dfs(0, 2) = max(1 - dfs(1,2), 2 - dfs(0,1)) = max(1-3, 2-4) = max(-2, -2) = -2
-2 >= 0 为 false，玩家 1 必败 ✓
```

### 复杂度分析

- **时间复杂度**：O(n²)，共有 n(n+1)/2 个子问题，每个 O(1) 转移。
- **空间复杂度**：O(n²)，记忆化数组大小为 n×n。

## 代码实现

{% raw %}
```cpp
class Solution {
   public:
    int dfs(vector<int>& nums, int l, int r, vector<vector<int>>& memory) {
        auto& ret = memory[l][r];

        if (ret != -1) {
            return ret;
        }

        if (l == r) {
            ret = nums[l];
            return ret;
        }
        ret = max(nums[l] - dfs(nums, l + 1, r, memory), nums[r] - dfs(nums, l, r - 1, memory));
        return ret;
    }

    bool predictTheWinner(vector<int>& nums) {
        int n = nums.size();
        vector<vector<int>> memory(n, vector<int>(n, -1));

        return dfs(nums, 0, n - 1, memory) >= 0;
    }
};
```
{% endraw %}

### 代码解析

1. **dfs 函数**：返回当前玩家在 `[l, r]` 上能拿到的最大分差。
   - 命中记忆化直接返回。
   - 单元素边界返回 `nums[l]`。
   - 否则在「取左 / 取右」中取 max，注意用减号把对手的分差扣除。
2. **predictTheWinner 函数**：建立 n×n 的 `-1` 记忆化数组，返回 `dfs(0, n-1) >= 0`。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 486) {
    Solution s;

    // 基本用例
    auto nums1 = vector<int>{1, 5, 2};
    EXPECT_FALSE(s.predictTheWinner(nums1));
    auto nums2 = vector<int>{1, 5, 233, 7};
    EXPECT_TRUE(s.predictTheWinner(nums2));

    // 边界用例
    auto nums3 = vector<int>{0};
    EXPECT_TRUE(s.predictTheWinner(nums3));  // 单元素
    auto nums4 = vector<int>{1, 1};
    EXPECT_TRUE(s.predictTheWinner(nums4));  // 平局，玩家 1 获胜
    auto nums5 = vector<int>{1, 2};
    EXPECT_TRUE(s.predictTheWinner(nums5));  // 两元素，玩家 1 取较大值 2
    auto nums6 = vector<int>{2, 1};
    EXPECT_TRUE(s.predictTheWinner(nums6));  // 玩家 1 取较大值 2
}
```
{% endraw %}

## 总结

这道题是博弈 DP 的入门经典。难点不在于代码本身，而在于状态定义——把「双方得分」转化为「当前玩家视角下的分差」，从而把双人博弈压缩成单函数递推。一个常见的坑是把转移式写成 `nums[l] + dfs(...)`，误把对手分数叠加给自己；正确做法是 `nums[l] - dfs(...)`，体现「对手最优 = 自己最差」的零和博弈本质。掌握了这种分差化归，类似的「石头游戏」系列问题都可迎刃而解。
