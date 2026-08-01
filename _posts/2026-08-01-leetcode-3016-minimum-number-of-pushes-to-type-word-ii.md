---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3016: 输入单词的最少按键次数 II"
categories: LeetCode
---

> 贪心算法在资源分配问题中广泛应用，将高频资源优先放到最优位置是经典策略。

## 题目

LeetCode 3016. Minimum Number of Pushes to Type Word II（输入单词的最少按键次数 II）

Difficulty: **Medium**

给你一个字符串 `word`，由不同的小写英文字母组成。

电话按键上将一些字母映射到数字键 2-9（共 8 个键），每个键可以映射任意数量的字母。每个键上的字母按顺序排列，第 1 个字母需要按 1 次，第 2 个需要按 2 次，以此类推。

你可以自定义字母到按键的映射方式。返回输入 `word` 所需的最少按键次数。

### 示例

```
示例 1：
输入：word = "abcde"
输出：5
解释：将 a、b、c、d、e 分别映射到不同键的第 1 位，每个字母按 1 次，共 5 次。

示例 2：
输入：word = "xyzxyzxyzxyz"
输出：12
解释：x、y、z 各出现 4 次。将它们映射到 3 个键的第 1 位，每个按 1 次，共 4×3 = 12 次。

示例 3：
输入：word = "aabbccddeeffff"
输出：14
解释：f 出现 4 次映射到第 1 位（4×1=4），a~e 各出现 2 次映射到第 1 位（5×2×1=10），共 14 次。
```

## 解题思路

### 核心思路

贪心算法：频率高的字母优先映射到按键第 1 位（按 1 次），次高的映射到第 2 位（按 2 次），以此类推。

### 算法详解

1. **统计频率**：统计每个字母的出现次数
2. **降序排序**：按频率从高到低排序
3. **分组计算**：
   - 前 8 个字母映射到 8 个键的第 1 位，各按 1 次
   - 第 9-16 个字母映射到第 2 位，各按 2 次
   - 第 17-24 个字母映射到第 3 位，各按 3 次
   - 以此类推
4. **累加结果**：每个字母的频率 × 所需按键次数

以示例 2 的 `word = "xyzxyzxyzxyz"` 为例：

```
步骤 1：统计频率
x: 4, y: 4, z: 4

步骤 2：降序排序
[4, 4, 4, 0, 0, ..., 0]

步骤 3：分组计算
位置 0: 频率 4, 按键 0/8+1 = 1 次 -> 4×1 = 4
位置 1: 频率 4, 按键 1/8+1 = 1 次 -> 4×1 = 4
位置 2: 频率 4, 按键 2/8+1 = 1 次 -> 4×1 = 4
位置 3 及之后: 频率为 0, 跳过

结果: 4 + 4 + 4 = 12
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int minimumPushes(string word) {
        array<int, 26> freq{};
        for (char c : word) {
            freq[c - 'a']++;
        }

        sort(freq.begin(), freq.end(), greater<int>());

        int ret = 0;
        for (int i = 0; i < 26 && freq[i] > 0; i++) {
            ret += (i / 8 + 1) * freq[i];
        }
        return ret;
    }
};
```
{% endraw %}

### 代码解析

1. **频率统计**：使用 `array<int, 26>` 直接索引，比 `unordered_map` 更高效
2. **排序**：对频率数组降序排序，高频字母排在前面
3. **分组计算**：`i / 8` 整数除法实现每 8 个字母一组的分组逻辑
4. **提前终止**：`freq[i] > 0` 条件避免遍历全部分量

### 复杂度分析

- **时间复杂度**: O(n + 26 log 26) ≈ O(n)，n 为 word 长度
- **空间复杂度**: O(1)，固定 26 个字母的数组

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3016) {
    Solution s;

    EXPECT_EQ(s.minimumPushes("abcde"), 5);
    EXPECT_EQ(s.minimumPushes("xyzxyzxyzxyz"), 12);
    EXPECT_EQ(s.minimumPushes("aabbccddeeffff"), 14);
}
```
{% endraw %}

## 总结

这道题是经典的贪心问题。核心洞察是：8 个键每个键的第 1 位共 8 个"1 次"槽位，第 2 位共 8 个"2 次"槽位，以此类推。将高频字母优先放入低按键次数的槽位，即可最小化总按键次数。

实现上有两个优化点：
- 用 `array<int, 26>` 替代 `unordered_map`，避免哈希开销
- 用整数除法 `i / 8` 替代 `floor(i / 8.0)`，避免浮点运算
