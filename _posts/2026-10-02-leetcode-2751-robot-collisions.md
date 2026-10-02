---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2751: 机器人碰撞"
categories: LeetCode
---

> 只有「向右的机器人」入栈，「向左的机器人」触发碰撞。按位置排序后用栈模拟，碰撞规则与 Asteroid Collision 如出一辙。

## 题目

LeetCode 2751. Robot Collisions（机器人碰撞）

Difficulty: **Hard**

数轴上有 n 个机器人，每个有位置 `positions[i]`、健康值 `healths[i]`、方向 `directions[i]`（'L' 或 'R'）。所有机器人以相同速度同时移动，相遇时发生碰撞：
- 健康值低的被移除，高的健康值 -1，继续原方向移动
- 健康值相同则两者都被移除

返回所有存活机器人的健康值，按原始输入顺序排列。

### 示例

```
示例 1：
输入：positions = [3,5,2,6], healths = [10,10,15,12], directions = "RLRL"
输出：[14]
解释：位置2(R)和位置6(L)碰撞，6的健康值12<15被移除，位置2健康值变为14。
```

## 解题思路

### 栈模拟碰撞

1. 创建索引数组 `idx`，按 `positions` 排序，得到从左到右的机器人顺序。
2. 用栈存储**向右移动**的机器人。
3. 遍历排序后的机器人：
   - 方向为 'R'：直接入栈。
   - 方向为 'L'：与栈顶的 'R' 机器人碰撞，循环处理直到栈空或当前机器人被摧毁：
     - 栈顶健康 > 当前：当前被摧毁（health=0），栈顶健康 -1。
     - 栈顶健康 < 当前：栈顶出栈被摧毁，当前健康 -1，继续碰撞。
     - 相等：两者都被摧毁。
4. 收集所有 `health > 0` 的值（按原始顺序遍历 `healths`）。

### 复杂度分析

- **时间复杂度**：O(n log n)，排序为主。
- **空间复杂度**：O(n)，索引数组和栈。

## 代码实现

```cpp
class Solution {
public:
    vector<int> survivedRobotsHealths(vector<int>& positions, vector<int>& healths, string directions) {
        int n = positions.size();
        vector<int> idx(n);
        iota(idx.begin(), idx.end(), 0);
        sort(idx.begin(), idx.end(), [&](int a, int b) {
            return positions[a] < positions[b];
        });

        vector<int> stk;
        for (int i : idx) {
            if (directions[i] == 'R') {
                stk.push_back(i);
                continue;
            }
            // 向左移动：与栈中向右的机器人碰撞
            while (!stk.empty() && healths[i] > 0) {
                int j = stk.back();
                if (healths[j] > healths[i]) {
                    healths[i] = 0;
                    healths[j]--;
                } else if (healths[j] < healths[i]) {
                    stk.pop_back();
                    healths[j] = 0;
                    healths[i]--;
                } else {
                    healths[i] = 0;
                    healths[j] = 0;
                    stk.pop_back();
                    break;
                }
            }
        }

        vector<int> ans;
        for (int h : healths) {
            if (h > 0) ans.push_back(h);
        }
        return ans;
    }
};
```

### 代码解析

- `iota` 生成 `[0,1,...,n-1]`，排序索引而非原数组，便于保留原始顺序。
- 只有 'R' 入栈，'L' 触发碰撞，与「小行星碰撞」题思路一致。
- 遍历原始 `healths` 收集结果，自然保持原始输入顺序。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2751) {
    Solution s;
    vector<int> positions{3, 5, 2, 6};
    vector<int> healths{10, 10, 15, 12};
    string directions{"RLRL"};
    auto ret = s.survivedRobotsHealths(positions, healths, directions);
    EXPECT_EQ(vector<int>{14}, ret);
}
```
{% endraw %}

## 总结

本题是「小行星碰撞」的变体，核心技巧：

1. 按位置排序，用索引数组保留原始顺序；
2. 栈只存向右的机器人，向左的触发碰撞；
3. 三种碰撞结果（大于/小于/等于）分别处理，循环直到一方被消灭。
