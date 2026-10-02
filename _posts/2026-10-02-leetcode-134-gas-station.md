---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.134: 加油站"
categories: LeetCode
---

> 从 i 出发开到 j 发现油不够，那么 [i, j] 之间的站全都不能作为起点——这个「失败区间整体跳过」的性质保证了线性时间。

## 题目

LeetCode 134. Gas Station（加油站）

Difficulty: **Medium**

环路上 n 个加油站，gas[i] 为可加油量，cost[i] 为开到下一站的油耗。油箱容量无限、出发时空箱。存在解则唯一，返回出发站编号，否则 -1。

### 示例

```
输入：gas = [1,2,3,4,5], cost = [3,4,5,1,2]
输出：3

输入：gas = [2,3,4], cost = [3,4,3]
输出：-1
```

## 解题思路

### 模拟绕行 + 失败区间跳跃

1. 从候选起点 i 出发，逐站累计 tmp_total（总加油量）与 tmp_cost（总油耗），任一站累计加油小于累计油耗即失败。
2. 成功走完 n 站且总油量足够，返回 i。
3. 失败于第 j 站时，直接令 `i += j + 1`：区间内任意起点 k 都不可能成功（从 i 到 k 时油箱有盈余仍失败，空箱从 k 出发只会更早断油）。
4. 循环走完仍无起点，返回 -1。

### 复杂度分析

- **时间复杂度**：O(n)，失败区间被整体跳过，所有站最多被模拟常数次。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int canCompleteCircuit(vector<int>& gas, vector<int>& cost) {
        int n = gas.size();
        for (int i = 0; i < n; ) {
            int tmp_total = 0, tmp_cost = 0;
            int j = 0;
            for (; j < n; j++) {
                tmp_total += gas[(j + i) % n];
                tmp_cost += cost[(j + i) % n];
                if (tmp_total < tmp_cost) break;
            }

            if (j == n && tmp_total >= tmp_cost) return i;
            i += j + 1;
        }
        return -1;
    }
};
```

### 代码解析

- 下标 `(j + i) % n` 模拟从 i 开始的环形顺序。
- 判定条件在每站都检查累计值，油在中途（不只是终点）不足也算失败。

## 测试用例

```cpp
TEST(TOP150, No134_CanCompleteCircuit) {
    Solution solution;

    vector<int> gas{1, 2, 3, 4, 5, 5, 70};
    vector<int> cost{2, 3, 4, 3, 9, 6, 2};
    EXPECT_EQ(6, solution.canCompleteCircuit(gas, cost));

    vector<int> gas1{1, 2, 3, 4, 5};
    vector<int> cost1{3, 4, 5, 1, 2};
    EXPECT_EQ(3, solution.canCompleteCircuit(gas1, cost1));

    vector<int> gas3{2, 2};
    vector<int> cost3{2, 2};
    EXPECT_EQ(0, solution.canCompleteCircuit(gas3, cost3));  // 中途油量为0合法
}
```

## 总结

1. 逐站累计油与油耗，任意时刻断油即失败；
2. 失败区间内所有站都不可作起点，整体跳过保证 O(n)；
3. 经典替代写法先判总油量是否够总耗，再单次扫描找起点。
