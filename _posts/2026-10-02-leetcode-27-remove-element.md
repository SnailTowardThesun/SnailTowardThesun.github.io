---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.27: 移除元素"
categories: LeetCode
---

> 元素顺序可以改变，就不必用快慢指针整体搬移——把等于 val 的元素和末尾交换，相当于把垃圾统一扔到数组尾部。

## 题目

LeetCode 27. Remove Element（移除元素）

Difficulty: **Easy**

给定数组 nums 和值 val，原地移除所有等于 val 的元素，返回新长度。O(1) 额外空间，元素顺序可以改变。

### 示例

```
输入：nums = [3,2,2,3], val = 3
输出：2，前两个元素为 2,2

输入：nums = [0,1,2,2,3,0,4,2], val = 2
输出：5，前五个元素包含 0,1,3,0,4（任意顺序）
```

## 解题思路

### 对尾交换

1. target 记录已发现的 val 个数（等于已扔到尾部的垃圾数）。
2. 扫描有效区间 `[0, size-target)`：当前元素等于 val 时，把它与 `size-target` 位置（有效区间末尾）交换，target++；当前位置不前进（交换来的新值也要检查）。
3. 不等于 val 则指针前进。
4. 最终 `size - target` 即新长度。

### 复杂度分析

- **时间复杂度**：O(n)，每次交换有效区间都缩短。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int removeElement(vector<int>& nums, int val) {
        int target = 0;
        for (int i = 0; i < (int)nums.size() - target; ) {
            if (nums[i] == val) {
                target += 1;
                swap(nums[i], nums[nums.size() - target]);
            } else {
                i++;
            }
        }
        return nums.size() - target;
    }
};
```

### 代码解析

- 交换后 i 不自增：尾部换来的元素可能恰好也是 val，必须重新检查。
- 循环上界 `size - target` 随垃圾数增加而缩小。

## 测试用例

```cpp
TEST(TOP150, No27_RemoveElement) {
    Solution solution;
    vector<int> nums{3, 2, 2, 3};
    int k = solution.removeElement(nums, 3);
    EXPECT_EQ(k, 2);
}
```

## 总结

1. 顺序允许改变时，对尾交换比覆盖式搬移更直接；
2. 交换后检查位置不变，防止漏网；
3. O(n) 时间 O(1) 空间。
