---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2126: 摧毁小行星"
categories: LeetCode
---

> 贪心算法是面试中常见的算法思想，它通过每一步的最优选择来期望达到全局最优。理解何时使用贪心以及如何证明其正确性是掌握贪心算法的关键。

## 题目

LeetCode 2126. 摧毁小行星（Destroying Asteroids）

Difficulty: **Medium**

给你一个整数 mass 表示行星的质量，以及一个整数数组 asteroids 表示行星带中小行星的质量。

每个 asteroids[i] 是小行星的质量。

如果满足以下条件，你可以选择下标 i 并摧毁第 i 个小行星：
- mass >= asteroids[i]

摧毁一个小行星后，你获得它全部的质量，并加入到你的行星 mass 中。

如果你能通过按任意顺序摧毁小行星来摧毁所有小行星，则返回 true；否则返回 false。

### 示例

```
示例 1：
输入: mass = 10, asteroids = [3,9,15]
输出: true
解释: 
可以按以下顺序摧毁：
- 摧毁质量为 3 的小行星，mass 变为 13
- 摧毁质量为 9 的小行星，mass 变为 22
- 摧毁质量为 15 的小行星，mass 变为 37

示例 2：
输入: mass = 5, asteroids = [4,9,23,4]
输出: false
解释: 
行星最终质量最多能达到 5 + 4 + 4 + 9 = 22，无法摧毁质量为 23 的小行星。
```

## 解题思路

### 贪心算法

这道题的核心在于理解贪心策略的正确性。

### 核心思路

1. **为什么要先摧毁最小的小行星？**
   - 为了使行星的质量增长得尽可能快
   - 只有先摧毁小的小行星，才能获得足够的质量去摧毁大的小行星
   
2. **排序 + 顺序处理**
   - 将小行星按质量从小到大排序
   - 从小到大依次尝试摧毁每个小行星
   - 如果当前质量 >= 小行星质量，则摧毁它；否则返回 false

### 算法详解

以 mass = 10, asteroids = [3, 9, 15] 为例：

```
排序后: [3, 9, 15]

步骤 1: mass = 10 >= 3 ✓，摧毁它，mass = 13
步骤 2: mass = 13 >= 9 ✓，摧毁它，mass = 22
步骤 3: mass = 22 >= 15 ✓，摧毁它，mass = 37

返回 true
```

### 贪心正确性证明

假设我们有一个最优的摧毁顺序。如果这个顺序不是从小到大排序的，那么必然存在相邻的两个小行星 x 和 y，满足 x > y 但 x 在 y 之前被摧毁。

考虑交换 x 和 y 的顺序：
- 先摧毁 y：质量从小到大增长
- 再摧毁 x：最终质量相同

由于 mass_x >= mass_y，交换后不会变得更差。因此，总存在一个最优解是按照从小到大的顺序摧毁的。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    bool asteroidsDestroyed(int mass, const vector<int>& asteroids) {
        int64_t currentMass = mass;
        vector<int> sortedAsteroids = asteroids;
        sort(sortedAsteroids.begin(), sortedAsteroids.end());
        
        for (int asteroid : sortedAsteroids) {
            if (currentMass < asteroid) {
                return false;
            }
            currentMass += asteroid;
        }
        
        return true;
    }
};
```
{% endraw %}

### 代码解析

1. **排序**：将小行星按质量从小到大排序
2. **初始化**：使用 int64_t 存储质量，避免溢出
3. **遍历摧毁**：从小到大依次检查每个小行星
4. **判断条件**：如果当前质量 < 小行星质量，返回 false
5. **成功返回**：所有小行星都被摧毁，返回 true

### 复杂度分析

- **时间复杂度**: O(n log n)，排序需要 O(n log n)，遍历需要 O(n)
- **空间复杂度**: O(n)，需要复制数组进行排序

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2126) {
    Solution s;

    EXPECT_TRUE(s.asteroidsDestroyed(10, vector<int>{3, 9, 15}));
    EXPECT_TRUE(s.asteroidsDestroyed(10, vector<int>{4, 9, 23}));
    EXPECT_TRUE(s.asteroidsDestroyed(5, vector<int>{4, 9, 23, 5}));
    
    EXPECT_TRUE(s.asteroidsDestroyed(1, vector<int>{1}));
    EXPECT_TRUE(s.asteroidsDestroyed(100, vector<int>{1, 2, 3, 4, 5}));
}
```
{% endraw %}

## 总结

这道题的核心在于理解贪心策略：

1. **贪心选择**：优先摧毁最小的小行星，使质量增长最快
2. **最优性证明**：通过交换论证证明贪心策略的正确性
3. **实现简单**：排序后顺序处理即可

关键点是理解为什么要先处理小的小行星，以及如何证明这个贪心策略是正确的。这道题是学习贪心算法的一个很好的例子。
