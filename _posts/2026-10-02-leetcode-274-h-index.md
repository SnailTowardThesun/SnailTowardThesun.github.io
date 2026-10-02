---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.274: H 指数"
categories: LeetCode
---

> 升序排列后，位置 i 后面有 n-i 篇论文，只要第 i 篇引用数 >= n-i，h 指数就至少是 n-i——第一个满足的位置给出最大 h。

## 题目

LeetCode 274. H-Index（H 指数）

Difficulty: **Medium**

给定论文引用次数数组，h 指数表示「至少有 h 篇论文各被引用至少 h 次」中的最大 h。

### 示例

```
输入：citations = [3,0,6,1,5]
输出：3（3 篇论文引用不少于 3 次）

输入：citations = [1,3,1]
输出：1
```

## 解题思路

### 排序后扫描

1. 升序排序。
2. 对位置 i，后缀论文数 target = n - i。
3. citations[i] >= target：这 target 篇论文引用数都 >= target（升序，后面的不小于当前），返回 target。
4. i 从左到右扫描，第一个满足的 target 最大（target 随 i 增大而减小）。

计数排序版本可做到 O(n)：统计引用数分布后从高到低累加论文数。

### 复杂度分析

- **时间复杂度**：O(n log n)。
- **空间复杂度**：O(1)（不计排序栈）。

## 代码实现

```cpp
class Solution {
public:
    int hIndex(vector<int>& citations) {
        int n = citations.size();
        sort(citations.begin(), citations.end());
        for (int i = 0; i < n; i++) {
            int target = n - i;
            if (citations[i] >= target) return target;
        }
        return 0;
    }
};
```

### 代码解析

- 引用数大于 n 的论文在计数法中归入桶 n（超过论文总数的部分无意义）。

## 测试用例

```cpp
TEST(TOP150, No274_HIndex) {
    Solution solution;
    vector<int> citations{3, 0, 6, 1, 5};
    EXPECT_EQ(3, solution.hIndex(citations));
}
```

## 总结

1. 排序把「引用数门槛」和「论文数量」对齐；
2. 从左向右第一个满足的位置即最大 h；
3. 追求线性时间用计数/桶排序。
