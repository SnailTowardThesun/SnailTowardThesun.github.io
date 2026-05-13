---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2784: 检查数组是否良好"
categories: LeetCode
---

> 数组的"良序"概念在计算机科学中有着广泛的应用，比如验证数据的完整性、检查密码强度等场景。

## 题目

LeetCode 2784. Check if Array is Good（检查数组是否良好）

Difficulty: **Easy**

给定一个整数数组 nums，如果数组是 "good" 的，返回 true，否则返回 false。

"good" 数组是指：该数组是 base[n] 的排列。

base[n] = [1, 2, ..., n - 1, n, n]，长度为 n + 1，包含 1 到 n - 1 各一次，n 出现两次。

例如：base[1] = [1, 1]，base[3] = [1, 2, 3, 3]。

### 示例

```
示例 1：
输入：nums = [1, 3, 3, 2]
输出：true
解释：数组的最大元素是 3，所以 n = 3。数组是 base[3] = [1, 2, 3, 3] 的排列。

示例 2：
输入：nums = [2, 1, 3]
输出：false
解释：数组的最大元素是 3，所以 n = 3。但数组长度为 3，而 base[3] 长度为 4，不可能相等。

示例 3：
输入：nums = [1, 1]
输出：true
解释：数组的最大元素是 1，所以 n = 1。数组是 base[1] = [1, 1] 的排列。

示例 4：
输入：nums = [3, 4, 4, 1, 2, 1]
输出：false
解释：数组的最大元素是 4，所以 n = 4。但数组长度为 6，而 base[4] 长度为 5，不可能相等。
```

## 解题思路

这道题可以使用计数法来判断数组是否为 good 数组。

### 核心思路

1. **统计计数**：统计数组中每个元素出现的次数
2. **验证条件**：
   - 最大元素（n）必须出现恰好 2 次
   - 对于所有 i（1 ≤ i < n），每个元素必须恰好出现 1 次
3. **返回结果**：如果以上条件都满足，返回 true；否则返回 false

### 算法详解

以示例 1 的 nums = [1, 3, 3, 2] 为例：

```
步骤 1：确定 n
n = nums.size() - 1 = 4 - 1 = 3

步骤 2：统计计数
cnt[1] = 1
cnt[2] = 1
cnt[3] = 2

步骤 3：验证条件
检查 cnt[3] == 2？是的，cnt[3] = 2 ✓
检查 cnt[1] == 1？是的，cnt[1] = 1 ✓
检查 cnt[2] == 1？是的，cnt[2] = 1 ✓

最终结果：true
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    bool isGood(vector<int>& nums) {
        int n = nums.size() - 1;
        vector<int> cnt(201);

        for (int x : nums) {
            ++cnt[x];
        }

        if (cnt[n] != 2) {
            return false;
        }

        for (int i = 1; i < n; ++i) {
            if (cnt[i] != 1) {
                return false;
            }
        }

        return true;
    }
};
```
{% endraw %}

### 代码解析

1. **确定 n**：n = nums.size() - 1，因为 good 数组长度为 n + 1
2. **初始化计数数组**：创建一个大小为 201 的数组（题目中 num[i] <= 200）
3. **统计计数**：遍历数组，统计每个元素出现的次数
4. **验证最大元素**：检查 cnt[n] 是否等于 2
5. **验证其他元素**：检查所有 i（1 ≤ i < n）是否都恰好出现 1 次

### 复杂度分析

- **时间复杂度**: O(n)，只需要遍历数组一次
- **空间复杂度**: O(n)，需要额外的数组存储计数（大小为 201）

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2784) {
    Solution s;

    EXPECT_TRUE(s.isGood({1, 3, 3, 2}));
    EXPECT_FALSE(s.isGood({2, 1, 3}));
    EXPECT_TRUE(s.isGood({1, 1}));
    EXPECT_FALSE(s.isGood({3, 4, 4, 1, 2, 1}));
}
```
{% endraw %}

## 总结

这道题的关键在于理解 "good" 数组的定义。通过计数法，我们只需要 O(n) 的时间复杂度就能验证数组是否符合要求。题目虽然简单，但涉及到了数组验证的基本技巧，在实际工作中也有广泛的应用场景。
