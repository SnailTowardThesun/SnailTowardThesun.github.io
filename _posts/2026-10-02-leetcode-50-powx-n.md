---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.50: Pow(x, n)"
categories: LeetCode
---

> 快速幂每次把指数折半、底数平方，O(log n) 完成 n 次幂；负指数先按正指数算再取倒数。

## 题目

LeetCode 50. Pow(x, n)

Difficulty: **Medium**

实现 x 的 n 次幂，n 为整数（可能为负）。

### 示例

```
输入：x = 2.0, n = 10    输出：1024.0
输入：x = 2.1, n = 3     输出：9.261
输入：x = 2.0, n = -2    输出：0.25
```

## 解题思路

### 递归快速幂

1. 底数恒平方：`x → x * x`，指数折半：`n → n / 2`。
2. 指数为奇数时多乘一个 x：`x^n = (x²)^(n/2) × x`。
3. 负指数先按 |n| 计算，最后取倒数。
4. 递归边界 n = 0 返回 1。

### 复杂度分析

- **时间复杂度**：O(log n)。
- **空间复杂度**：O(log n)，递归栈；迭代版为 O(1)。

## 代码实现

```cpp
class Solution {
public:
    double myPow(double x, int n) {
        if (n == 0) return 1;
        if (n == 1) return x;
        int exp = n < 0 ? -n : n;
        double result = exp % 2 == 0
                            ? myPow(x * x, exp / 2)
                            : myPow(x * x, exp / 2) * x;
        return n < 0 ? 1 / result : result;
    }
};
```

### 代码解析

- 注意 INT_MIN 取负会溢出，严格实现可用 long long 或迭代写法处理。

## 测试用例

```cpp
TEST(Daily, 50) {
    Solution s;
    EXPECT_NEAR(s.myPow(2.0, 10), 1024.0, 0.0001);
    EXPECT_NEAR(s.myPow(2.0, -2), 0.25, 0.0001);
}
```

## 总结

1. 折半平方把乘法次数降到 O(log n)；
2. 奇数次幂额外乘 x；
3. 负指数最后取倒数，注意边界溢出。
