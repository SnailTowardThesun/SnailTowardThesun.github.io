---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2515: 到目标字符串的最短距离"
categories: LeetCode
---

> 环形数组上两点的最短距离 = min(顺时针距离, 逆时针距离)，即 `min(|i-j|, n - |i-j|)`。

## 题目

LeetCode 2515. Shortest Distance to Target String in a Circular Array（到目标字符串的最短距离）

Difficulty: **Easy**

给你一个下标从 `0` 开始的**环形**字符串数组 `words` 和一个字符串 `target`，同时给你一个整数 `startIndex`。环形数组意味着数组首尾相连。请你找到从 `startIndex` 出发到最近的 `target` 字符串的最短距离。如果 `target` 不在 `words` 中，返回 `-1`。

距离是指从 `startIndex` 到目标字符串下标的最小移动步数，可顺时针或逆时针移动。

### 示例

```
示例 1：
输入：words = ["hsdqinnoha","mqhskgeqzr","zemkwvqrww","zemkwvqrww","daljcrktje",
              "fghofclnwp","djwdworyka","cxfpybanhd","fghofclnwp","fghofclnwp"],
     target = "zemkwvqrww", startIndex = 8
输出：4
解释：target 在位置 2 和 3。从位置 8 出发：
- 到位置 2：顺时针 4 步 (8→9→0→1→2)，逆时针 6 步，取 4。
- 到位置 3：顺时针 5 步，逆时针 5 步，取 5。
最小距离为 4。
```

## 解题思路

### 收集目标位置 + 环形距离取最小

1. 遍历 `words`，收集所有等于 `target` 的下标到 `poss`。
2. 若 `poss` 为空，返回 `-1`。
3. 对每个目标位置 `pos`，计算环形距离 `min(|pos - startIndex|, n - |pos - startIndex|)`。
4. 返回所有距离中的最小值。

### 复杂度分析

- **时间复杂度**：O(n)，遍历数组一次收集位置，再遍历目标位置求最小。
- **空间复杂度**：O(k)，k 为 `target` 出现次数。

## 代码实现

```cpp
class Solution {
   public:
    int closestTarget(vector<string>& words, string target, int startIndex) {
        vector<int> poss;
        for (int i = 0; i < words.size(); ++i) {
            if (words[i] == target) {
                poss.push_back(i);
            }
        }

        if (poss.empty()) {
            return -1;
        }

        int ret = INT_MAX;
        int n = words.size();
        for (auto pos : poss) {
            int direct_dist = abs(pos - startIndex);
            int circular_dist = n - direct_dist;
            int tmp = min(direct_dist, circular_dist);
            ret = min(ret, tmp);
        }

        return ret;
    }
};
```

### 代码解析

- `direct_dist = abs(pos - startIndex)`：沿一个方向的直接距离。
- `circular_dist = n - direct_dist`：沿相反方向绕一圈的距离。
- 两者取 `min` 即为环形最短距离。

## 测试用例

```cpp
TEST(Daily, 2515) {
    Solution s;
    auto words = vector<string>{"hsdqinnoha", "mqhskgeqzr", "zemkwvqrww", "zemkwvqrww", "daljcrktje",
                                "fghofclnwp", "djwdworyka", "cxfpybanhd", "fghofclnwp", "fghofclnwp"};
    auto target = "zemkwvqrww";
    auto startIndex = 8;

    auto ret = s.closestTarget(words, target, startIndex);
    EXPECT_EQ(ret, 4);
}
```

## 总结

本题是环形数组距离计算的基础题，核心公式只有一个：

`环形最短距离 = min(|i - j|, n - |i - j|)`

记住这个公式，所有环形数组上的最短距离问题都能迎刃而解。
