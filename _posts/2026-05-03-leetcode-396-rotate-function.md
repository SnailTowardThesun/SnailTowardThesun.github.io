---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.396: 旋转函数"
categories: LeetCode
---

## 题目

LeetCode 396. Rotate Function (旋转函数)

Difficulty: **Medium**

给定一个整数数组 nums，长度为 n，假设数组 nums 在 0 索引处的旋转函数为 F(0)，在 1 索引处的旋转函数为 F(1)，...，在 n-1 索引处的旋转函数为 F(n-1)。

旋转函数的计算规则如下：
F(k) = 0 * Bk[0] + 1 * Bk[1] + ... + (n-1) * Bk[n-1]
其中，Bk 是数组 nums 顺时针旋转 k 个位置后的数组。

请计算 F(0), F(1), ..., F(n-1) 中的最大值。

### 示例

```
示例 1：
输入：nums = [4,3,2,6]
输出：26
解释：
F(0) = (0 * 4) + (1 * 3) + (2 * 2) + (3 * 6) = 0 + 3 + 4 + 18 = 25
F(1) = (0 * 6) + (1 * 4) + (2 * 3) + (3 * 2) = 0 + 4 + 6 + 6 = 16
F(2) = (0 * 2) + (1 * 6) + (2 * 4) + (3 * 3) = 0 + 6 + 8 + 9 = 23
F(3) = (0 * 3) + (1 * 2) + (2 * 6) + (3 * 4) = 0 + 2 + 12 + 12 = 26
最大值是 F(3) = 26
```

这道题展示了一个经典的算法优化思想：数学推导 + 递推关系，这种思想在财务计算、信号处理、机器学习等领域都有广泛应用。

## 解题思路

这道题的关键是找到 F(k) 和 F(k-1) 之间的递推关系，避免重复计算。

### 核心思路（完整数学推导）

**定义：**
- 原数组：nums[0], nums[1], ..., nums[n-1]
- totalSum = nums[0] + nums[1] + ... + nums[n-1]
- F(0) = 0*nums[0] + 1*nums[1] + 2*nums[2] + ... + (n-1)*nums[n-1]

**顺时针旋转 1 次后（相当于将最后一个元素移到最前面）：**
F(1) = 0*nums[n-1] + 1*nums[0] + 2*nums[1] + ... + (n-1)*nums[n-2]

**推导 F(1) - F(0)：**

```
F(1) = 0*nums[n-1] + 1*nums[0] + 2*nums[1] + 3*nums[2] + ... + (n-1)*nums[n-2]
F(0) = 0*nums[0] + 1*nums[1] + 2*nums[2] + ... + (n-2)*nums[n-2] + (n-1)*nums[n-1]

F(1) - F(0) = [1*nums[0]+2*nums[1]+...+(n-1)*nums[n-2]] - [1*nums[1]+...+(n-2)*nums[n-2]+(n-1)*nums[n-1]]
            = nums[0] + nums[1] + nums[2] + ... + nums[n-2] - (n-1)*nums[n-1]
            = (totalSum - nums[n-1]) - (n-1)*nums[n-1]
            = totalSum - nums[n-1] - n*nums[n-1] + nums[n-1]
            = totalSum - n*nums[n-1]
```

**因此得到递推公式：**
F(1) = F(0) + totalSum - n*nums[n-1]

**同理可推导出：**
F(k) = F(k-1) + totalSum - n*nums[n-k]

**步骤：**
1. 计算 F(0) 和 totalSum
2. 利用递推公式依次计算 F(1), F(2), ..., F(n-1)
3. 记录最大值

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int maxRotateFunction(vector<int>& nums) {
        int totalSum = 0;
        int helper = 0;
        for (int i = 0; i < nums.size(); i++) {
            totalSum += nums[i];
            helper += i * nums[i];
        }

        int ret = helper;
        for (int i = nums.size()-1; i >= 0; i--) {
            helper += totalSum - nums.size() * nums[i];
            ret = max(ret, helper);
        }

        return ret;
    }
};
```
{% endraw %}

### 代码解析

1. **计算初始值**（第63-68行）：
   - totalSum：数组所有元素的和
   - helper：F(0) 的值，即 0*nums[0] + 1*nums[1] + ... + (n-1)*nums[n-1]

2. **递推计算**（第70-74行）：
   - 从最后一个元素开始倒序遍历
   - 使用公式：helper += totalSum - n*nums[i]
   - 每次更新后记录最大值 ret

### 复杂度分析

- **时间复杂度**：O(n)，只需遍历数组两次
- **空间复杂度**：O(1)，只使用了几个额外变量

## 测试用例

{% raw %}
```cpp
TEST(Daily, 396) {
    Solution s;
    auto nums = vector<int>{4,3,2,6};
    auto ret = s.maxRotateFunction(nums);
    EXPECT_EQ(26, ret);
}
```
{% endraw %}

## 总结

这道题的关键在于通过数学推导找到递推关系，将原本O(n²)的暴力解法优化到O(n)。这种「数学推导 + 递推关系」的思想在算法优化中非常重要，展示了如何通过巧妙的数学思考来大幅提升算法效率。
