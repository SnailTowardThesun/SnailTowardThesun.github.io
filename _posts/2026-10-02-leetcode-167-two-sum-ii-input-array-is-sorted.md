---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.167: 两数之和 II - 输入有序数组"
categories: LeetCode
---

> 无序版靠哈希表，有序版靠双指针——排序信息把空间从 O(n) 压到 O(1)，且解必然唯一。

## 题目

LeetCode 167. Two Sum II - Input Array Is Sorted（两数之和 II - 输入有序数组）

Difficulty: **Medium**

给定升序数组和目标值，找出和为 target 的两个数，返回 1-indexed 下标。答案唯一。

### 示例

```
输入：numbers = [2,7,11,15], target = 9
输出：[1,2]
```

## 解题思路

### 首尾双指针

- 和等于 target：返回当前两指针（注意题目要求 1-indexed）。
- 和小于 target：左指针右移以增大和。
- 和大于 target：右指针左移以减小和。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    vector<int> twoSum(vector<int>& numbers, int target) {
        int pre = 0, last = numbers.size() - 1;
        while (pre < last) {
            int sum = numbers[pre] + numbers[last];
            if (sum == target) {
                return vector<int>{pre + 1, last + 1};  // 题目要求 1-indexed
            }
            if (sum < target) pre++;
            else last--;
        }
        return {};
    }
};
```

### 代码解析

- 源文件测试使用 0-indexed 返回值；提交 LeetCode 需改为 +1 的 1-indexed 版本。

## 测试用例

```cpp
TEST(top150, 167) {
    Solution s;
    auto numbers = vector<int>{2, 7, 11, 15};
    auto ret = s.twoSum(numbers, 9);
    EXPECT_EQ(ret[0], 1);
    EXPECT_EQ(ret[1], 2);
}
```

## 总结

1. 有序数组上双指针线性逼近目标；
2. 比哈希表版省空间；
3. 提交时注意 1-indexed 的下标要求。
