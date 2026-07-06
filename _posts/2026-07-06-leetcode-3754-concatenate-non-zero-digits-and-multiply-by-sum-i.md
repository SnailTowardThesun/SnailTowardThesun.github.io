---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3754: 连接非零数字并乘以其数字和 I"
categories: LeetCode
---

> 数字操作是编程中常见的基础问题，处理数字的每一位需要注意边界条件和类型转换。

## 题目

LeetCode 3754. Concatenate Non-Zero Digits and Multiply by Sum I（连接非零数字并乘以其数字和 I）

Difficulty: **Easy**

给你一个整数 `n`。

将 `n` 中所有的 **非零数字** 按照它们的原始顺序连接起来，形成一个新的整数 `x`。如果不存在 **非零数字**，则 `x = 0`。

`sum` 为 `x` 中所有数字的 **数字和**。

返回一个整数，表示 `x * sum` 的值。

### 示例

```
示例 1：
输入：n = 10203004
输出：12340
解释：
- 非零数字是 1、2、3 和 4。因此，x = 1234。
- 数字和为 sum = 1 + 2 + 3 + 4 = 10。
- 因此，答案是 x * sum = 1234 * 10 = 12340。

示例 2：
输入：n = 1000
输出：1
解释：
- 非零数字是 1，因此 x = 1 且 sum = 1。
- 因此，答案是 x * sum = 1 * 1 = 1。
```

## 解题思路

这道题的核心是处理数字的每一位，提取非零数字并进行计算。

### 核心思路

1. **字符串处理**：将整数转换为字符串，遍历每个字符
2. **筛选非零数字**：如果字符不是 '0'，将其添加到结果字符串中，并累加到数字和中
3. **计算结果**：将结果字符串转换为整数，返回其与数字和的乘积

### 算法详解

以示例 1 的 n = 10203004 为例：

```
步骤 1：转换为字符串
num_str = "10203004"

步骤 2：遍历每个字符
字符 '1' -> 非零，fin_str = "1"，sum = 1
字符 '0' -> 跳过
字符 '2' -> 非零，fin_str = "12"，sum = 3
字符 '0' -> 跳过
字符 '3' -> 非零，fin_str = "123"，sum = 6
字符 '0' -> 跳过
字符 '0' -> 跳过
字符 '4' -> 非零，fin_str = "1234"，sum = 10

步骤 3：计算结果
x = 1234，sum = 10
答案 = 1234 * 10 = 12340
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    long long sumAndMultiply(int n) {
        if (n == 0) {
            return 0;
        }
        string fin_str = "";
        long long step = 0;
        string num_str = to_string(n);
        for (auto& c : num_str) {
            if (c != '0') {
                fin_str += c;
                step += c - '0';
            }
        }
        return stoll(fin_str) * step;
    }
};
```
{% endraw %}

### 代码解析

1. **特殊情况处理**：当 n = 0 时，直接返回 0
2. **字符串转换**：将整数 n 转换为字符串便于逐位处理
3. **遍历字符**：
   - 如果字符不是 '0'，添加到 fin_str 中
   - 同时累加到 step（数字和）
4. **结果计算**：将 fin_str 转换为 long long 类型，乘以数字和返回

### 复杂度分析

- **时间复杂度**: O(log n)，n 的十进制位数
- **空间复杂度**: O(log n)，存储结果字符串

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3754) {
    Solution s;

    // 测试用例 1
    int n = 10203004;
    long long ret = s.sumAndMultiply(n);
    EXPECT_EQ(12340, ret);

    // 测试用例 2
    n = 1000;
    ret = s.sumAndMultiply(n);
    EXPECT_EQ(1, ret);

    // 测试用例 3：边界条件
    n = 0;
    ret = s.sumAndMultiply(n);
    EXPECT_EQ(0, ret);
}
```
{% endraw %}

## 总结

这道题是一道简单的数字处理题目，核心在于正确提取非零数字并计算数字和。需要注意的是：
- n = 0 时的特殊处理
- 使用 long long 类型避免溢出
- 字符到数字的转换（c - '0'）

通过字符串处理可以直观地解决这道题，代码简洁易懂。
