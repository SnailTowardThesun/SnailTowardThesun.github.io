---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.657: 机器人能否返回原点"
categories: LeetCode
---

> 上下抵消、左右抵消——只要 U 和 D 次数相等、L 和 R 次数相等，机器人就回到原点。

## 题目

LeetCode 657. Robot Return to Origin（机器人能否返回原点）

Difficulty: **Easy**

在二维平面上，机器人从原点 `(0, 0)` 出发。给出移动字符串 `moves`，字符 `U/D/L/R` 分别表示上/下/左/右移动。判断机器人完成所有移动后是否回到原点。

### 示例

```
示例 1：
输入："UD"
输出：true
解释：上移一步再下移一步，回到原点。

示例 2：
输入："LL"
输出：false
解释：左移两步，停在 (-2, 0)。
```

## 解题思路

### 计数法

只需统计四个方向的移动次数：
- `up == down`：垂直方向抵消
- `left == right`：水平方向抵消

两者同时成立则回到原点。

### 复杂度分析

- **时间复杂度**：O(n)，单次遍历。
- **空间复杂度**：O(1)，仅用 4 个计数器。

## 代码实现

```cpp
class Solution {
   public:
    bool judgeCircle(string moves) {
        int up = 0, down = 0, left = 0, right = 0;

        for (char move : moves) {
            if (move == 'U') up++;
            else if (move == 'D') down++;
            else if (move == 'L') left++;
            else if (move == 'R') right++;
        }

        return up == down && left == right;
    }
};
```

## 测试用例

```cpp
TEST(Daily, 657) {
    Solution s;
    EXPECT_TRUE(s.judgeCircle("UD"));
    EXPECT_TRUE(s.judgeCircle("LR"));
    EXPECT_FALSE(s.judgeCircle("LL"));
    EXPECT_TRUE(s.judgeCircle("UDLR"));
    EXPECT_TRUE(s.judgeCircle(""));
}
```

## 总结

本题只需统计相反方向的次数是否相等，是最简单的计数判断题。
