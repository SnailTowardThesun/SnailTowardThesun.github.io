---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.169: 多数元素"
categories: LeetCode
---

> 当前实现是哈希表计数；本题最优雅的解法是摩尔投票法——不同元素两两抵消，最后剩下的必是多数元素，O(1) 空间。

## 题目

LeetCode 169. Majority Element（多数元素）

Difficulty: **Easy**

给定大小为 n 的数组，返回出现次数大于 n/2 的元素。数组非空且多数元素必然存在。

### 示例

```
输入：[3,2,3]             输出：3
输入：[2,2,1,1,1,2,2]     输出：2
```

## 解题思路

### 哈希计数（当前实现）

逐元素计数，某元素计数超过 n/2 立即返回。

### 摩尔投票法（最优）

1. candidate 为候选值，count 为其净票数。
2. count == 0 时把当前元素选为新候选。
3. 当前元素等于候选则 count++，否则 count--。
4. 多数元素的票数超过其余所有元素之和，抵消结束后 candidate 必然是它。

本题保证多数元素存在，投票结束无需二次验证；不保证时需再扫一遍确认计数。

### 复杂度分析

- 哈希（当前）：时间 O(n)，空间 O(n)。
- 摩尔投票：时间 O(n)，空间 O(1)。

## 代码实现

```cpp
// 当前实现
class Solution {
public:
    int majorityElement(vector<int>& nums) {
        unordered_map<int, int> candidate;
        for (int i : nums) {
            candidate[i]++;
            if (candidate[i] > (int)nums.size() / 2) return i;
        }
        return -1;
    }
};
```

摩尔投票参考实现：

```cpp
class SolutionVoting {
public:
    int majorityElement(vector<int>& nums) {
        int candidate = nums[0], count = 1;
        for (int i = 1; i < (int)nums.size(); i++) {
            if (count == 0) {
                candidate = nums[i];
                count = 1;
            } else if (nums[i] == candidate) {
                count++;
            } else {
                count--;
            }
        }
        return candidate;
    }
};
```

## 测试用例

```cpp
TEST(TOP150, No169_MajorityElement) {
    Solution solution;
    vector<int> nums{3, 2, 3};
    EXPECT_EQ(3, solution.majorityElement(nums));
}
```

## 总结

1. 哈希计数直观，提前返回；
2. 摩尔投票利用「票数过半」的抵消性质，空间最优；
3. 无多数元素保证时投票结果需要二次核验。
