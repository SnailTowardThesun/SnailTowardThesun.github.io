---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.219: 存在重复元素 II"
categories: LeetCode
---

> "最近重复元素"检测是风控系统识别短时间重复操作的简化模型，哈希表一维化是标准手法。

## 题目

LeetCode 219. Contains Duplicate II（存在重复元素 II）

Difficulty: **Easy**

给你一个整数数组 `nums` 和一个整数 `k`，判断数组中是否存在两个**不同的索引** `i` 和 `j`，满足 `nums[i] == nums[j]` 且 `abs(i - j) <= k`。如果存在，返回 `true`；否则，返回 `false`。

### 示例

```
输入：nums = [1,2,3,1], k = 3
输出：true

输入：nums = [1,0,1,1], k = 1
输出：true

输入：nums = [1,2,3,1,2,3], k = 2
输出：false
```

## 解题思路

### 哈希表记录最近下标

朴素做法是双重循环枚举所有下标对，O(n²) 在大数据量下不可接受。哈希表可以把内层循环变成 O(1) 查询：

1. 用哈希表 `container` 记录**每个值最后一次出现的下标**；
2. 遍历数组，若当前值已在表中：
   - 计算当前下标与记录下标的差值；
   - 差值 ≤ k → 找到满足条件的重复对，返回 true；
   - 差值 > k → 把表中该值的下标更新为当前下标。

**为什么只保留最近下标就够了？** 若旧下标与当前下标的差距已超过 k，那么旧下标与更后面的元素的差距只会更大——它永远不可能再参与满足条件的配对，可以安全丢弃。

以 `[1,2,3,1,2,3], k = 2` 为例：第二个 `1`（下标 3）与第一个 `1`（下标 0）差 3 > 2，更新记录；第二个 `2`（下标 4）与下标 1 差 3 > 2，更新……全部更新后遍历结束，返回 false。

### 复杂度分析

- **时间复杂度**：O(n)，每个元素处理一次，哈希操作均摊 O(1)。
- **空间复杂度**：O(n)，哈希表最多存 n 个不同的值。

## 代码实现

```cpp
class Solution {
   public:
    bool containsNearbyDuplicate(vector<int> &nums, int k) {
        unordered_map<int, int> container;
        for (auto i = 0; i < nums.size(); i++) {
            if (container.find(nums[i]) != container.end()) {
                auto diff = abs(i - container[nums[i]]);
                if (diff <= k) {
                    return true;
                }
            }
            container[nums[i]] = i;
        }

        return false;
    }
};
```

### 代码解析

- **命中即返回**：找到第一对满足 `diff <= k` 的就短路返回，后面的无需再看。
- **无脑覆盖**：无论差值是否满足，当前下标都会写回哈希表——这保证了表里永远是"最近"下标，逻辑统一无分支。
- **`abs` 求差**：遍历方向固定（从左到右），其实 `i - container[nums[i]]` 恒为正，`abs` 是防御性写法。

## 测试用例

```cpp
TEST(top150, 219) {
    Solution s;
    // 经典用例：距离 3 <= k=3
    vector<int> nums{1, 2, 3, 1};
    auto k = 3;
    auto ret = s.containsNearbyDuplicate(nums, k);
    EXPECT_TRUE(ret);
}
```

## 总结

1. 哈希表存"值 → 最近下标"，内层枚举降为 O(1) 查询；
2. 差值超 k 时覆盖旧下标：旧下标不可能再配对成功；
3. 一次遍历 O(n) 时间、O(n) 空间。
