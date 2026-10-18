---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2778: 特殊元素平方和"
categories: LeetCode
tags: 简单
---

> 因数总是成对出现，"下标整除长度"这道门槛恰好把数组切出了除数序列，平方和让每个因子都留下印记。

## 题目

LeetCode 2778. Sum of Squares of Special Elements（特殊元素平方和）

Difficulty: **Easy**

给你一个下标从 **1** 开始、长度为 `n` 的整数数组 `nums`。如果某个下标 `i` 满足 `n % i == 0`（即 `i` 能整除 `n`），则称 `nums[i]` 为一个**特殊元素**。返回 `nums` 中所有**特殊元素**的平方和。

### 示例

```
输入：nums = [1,2,3,4]
输出：21
解释：n = 4，下标 1、2、4 能整除 4，对应元素 1、2、4，
     平方和 = 1*1 + 2*2 + 4*4 = 21

输入：nums = [2,7,1,19,18,3]
输出：63
解释：n = 6，下标 1、2、3、6 能整除 6，对应元素 2、7、1、3，
     平方和 = 2*2 + 7*7 + 1*1 + 3*3 = 63
```

## 解题思路

这是一道直接模拟定义的题目，核心是把"下标从 1 开始"翻译成代码里正确的数组访问。

1. 取 `n = nums.size()`，从 `i = 1` 遍历到 `i = n`；
2. 若 `n % i == 0`，说明下标 `i`（1-indexed）是特殊下标，对应 0-indexed 的 `nums[i-1]`；
3. 把 `nums[i-1] * nums[i-1]` 累加到结果；
4. 遍历结束返回累加和。

以 `nums = [1,2,3,4]` 为例，`n = 4`：

```
i = 1: 4 % 1 == 0 ✓ → 1*1 = 1
i = 2: 4 % 2 == 0 ✓ → 2*2 = 4
i = 3: 4 % 3 != 0 ✗
i = 4: 4 % 4 == 0 ✓ → 4*4 = 16
结果 = 1 + 4 + 16 = 21
```

### 复杂度分析

- **时间复杂度**：O(n)，只需遍历数组一次。
- **空间复杂度**：O(1)，只使用常数额外空间。

## 代码实现

```cpp
class Solution {
public:
    int sumOfSquares(vector<int>& nums) {
        int n = nums.size();
        int ret = 0;
        for (int i = 1; i <= n; i++) {
            if (n % i == 0) {
                ret += nums[i-1] * nums[i-1];
            }
        }

        return ret;
    }
};
```

### 代码解析

- **1-indexed 与 0-indexed 的换算**：循环变量 `i` 表示题目中的 1-based 下标，访问数组时要减一，写成 `nums[i-1]`，这是本题唯一容易出错的地方。
- **取模判断**：`n % i == 0` 即"下标整除长度"，逐个判断即可，无需真的求出所有因数。
- **平方累加**：`n` 最大 50、元素最大 50，平方和上限约 50 * 2500 = 125000，`int` 完全够用。

## 测试用例

```cpp
TEST(Daily, 2778) {
    Solution s;

    // n = 3，特殊下标为 1、3：1*1 + 3*3 = 10
    vector<int> nums1 = {1, 2, 3};
    EXPECT_EQ(s.sumOfSquares(nums1), 10);

    // 官方示例：n = 4，特殊下标为 1、2、4：1 + 4 + 16 = 21
    vector<int> nums2 = {1, 2, 3, 4};
    EXPECT_EQ(s.sumOfSquares(nums2), 21);

    // 官方示例：n = 6，特殊下标为 1、2、3、6：4 + 49 + 1 + 9 = 63
    vector<int> nums3 = {2, 7, 1, 19, 18, 3};
    EXPECT_EQ(s.sumOfSquares(nums3), 63);
}
```

## 总结

1. 按定义模拟即可：`n % i == 0` 的下标 `i` 对应元素计入平方和；
2. 注意 1-indexed 下标与 `nums[i-1]` 的换算；
3. 时间 O(n)、空间 O(1)，`int` 足以容纳最大平方和。
