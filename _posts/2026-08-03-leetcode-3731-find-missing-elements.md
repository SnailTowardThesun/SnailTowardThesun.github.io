---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3731: 找出缺失的元素"
categories: LeetCode
---

> 找缺失元素是数据处理中的常见任务，如日志序列检查、ID 连续性校验等。排序后用指针扫描值域，能在不引入哈希表的前提下高效定位所有缺口。

## 题目

LeetCode 3731. Find Missing Elements（找出缺失的元素）

Difficulty: **Easy**

给你一个整数数组 `nums`，数组由若干**互不相同**的整数组成。数组 `nums` 原本包含了某个范围内的**所有整数**，但现在可能**缺失**部分整数。该范围内的**最小**整数和**最大**整数仍然存在于 `nums` 中。

返回一个**有序**列表，包含该范围内缺失的所有整数，按从小到大排序。如果没有缺失的整数，返回空列表。

### 示例

```
示例 1：
输入：nums = [1, 4, 2, 5]
输出：[3]
解释：最小整数为 1，最大整数为 5，完整范围为 [1,2,3,4,5]，只有 3 缺失。

示例 2：
输入：nums = [7, 8, 6, 9]
输出：[]
解释：最小整数为 6，最大整数为 9，完整范围为 [6,7,8,9]，无缺失。

示例 3：
输入：nums = [5, 1]
输出：[2, 3, 4]
解释：最小整数为 1，最大整数为 5，缺失 2、3、4。
```

## 解题思路

这道题的关键信息是：**最小值和最大值一定存在**，缺失的只会是它们之间的整数。因此只需扫描 `[min, max)` 范围，逐个判断哪些数不在数组中即可。

### 核心思路：排序 + 指针扫描

1. **排序**：先对 `nums` 升序排序，使 `nums[0]` 为最小值、`nums.back()` 为最大值，同时让存在的数按顺序排列。
2. **扫描值域**：用整数 `i` 从 `nums[0]` 遍历到 `nums.back() - 1`（最大值一定存在，无需检查）。
3. **指针匹配**：维护指针 `pos` 指向排序数组中当前待匹配的位置。
   - 若 `i == nums[pos]`：该数存在，`pos` 前进一步。
   - 若 `i != nums[pos]`：该数缺失，加入结果。
4. 由于题目保证元素**互不相同**，排序后每个 `nums[pos]` 只需匹配一次，指针单调递增不会回退。

### 图解示例

以 `nums = [1, 4, 2, 5]` 为例，排序后为 `[1, 2, 4, 5]`：

```
i=1: nums[0]=1, 匹配, pos→1
i=2: nums[1]=2, 匹配, pos→2
i=3: nums[2]=4, 不匹配, 缺失 3, ret=[3]
i=4: nums[2]=4, 匹配, pos→3
（i=5 不 < 5, 循环结束）
结果: [3] ✓
```

### 复杂度分析

- **时间复杂度**：O(n log n + R)，n 为数组长度，R = max - min 为值域跨度。排序 O(n log n)，扫描 O(R)。题中 n ≤ 100、R ≤ 99，整体高效。
- **空间复杂度**：O(1)（不计输出数组），排序为原地操作。

### 其他解法对比

| 方法 | 时间 | 空间 | 说明 |
|------|------|------|------|
| 排序 + 指针扫描（本解法） | O(n log n + R) | O(1) | 无需额外数据结构 |
| 哈希集合 | O(n + R) | O(n) | 查找 O(1)，但需额外空间 |
| 布尔标记数组 | O(n + R) | O(R) | 值域小时高效，直接下标定位 |

本解法选择排序 + 指针扫描，省去了哈希表的额外空间，在题目约束下性能足够。

## 代码实现

{% raw %}
```cpp
class Solution {
   public:
    vector<int> findMissingElements(vector<int>& nums) {
        vector<int> ret;

        sort(nums.begin(), nums.end());
        int pos = 0;
        for (auto i = nums[0]; i < nums.back(); i++) {
            if (i != nums[pos]) {
                ret.push_back(i);
            } else {
                pos++;
            }
        }

        return ret;
    }
};
```
{% endraw %}

### 代码解析

1. **排序**：`sort` 使数组升序排列，最小值在前、最大值在后。
2. **指针扫描**：`pos` 从 0 开始，`i` 从最小值遍历到最大值前一个数。匹配则推进 `pos`，不匹配则收集缺失值。
3. **边界**：循环条件 `i < nums.back()` 保证不检查最大值（它一定存在），也不越界。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3731) {
    Solution s;

    // 基本用例
    auto nums1 = vector<int>{1, 4, 2, 5};
    auto ans1 = vector<int>{3};
    EXPECT_EQ(s.findMissingElements(nums1), ans1);

    auto nums2 = vector<int>{7, 8, 6, 9};
    EXPECT_TRUE(s.findMissingElements(nums2).empty());  // 无缺失

    auto nums3 = vector<int>{5, 1};
    auto ans3 = vector<int>{2, 3, 4};
    EXPECT_EQ(s.findMissingElements(nums3), ans3);

    // 边界用例
    auto nums4 = vector<int>{1, 2, 3, 4, 5, 6, 7, 10};  // 缺 8, 9
    auto ans4 = vector<int>{8, 9};
    EXPECT_EQ(s.findMissingElements(nums4), ans4);

    auto nums5 = vector<int>{3, 4};  // 相邻两数，无缺失
    EXPECT_TRUE(s.findMissingElements(nums5).empty());
}
```
{% endraw %}

## 总结

这道题的思路很直接：既然最小值和最大值都在，缺失的只会夹在中间。排序后用一个指针顺着值域走一遍，遇到不在数组里的就收集。相比哈希集合法，这种「排序 + 双指针」的方式省下了 O(n) 的额外空间，代码也更简洁。一个容易踩的坑是循环上界——最大值一定存在，所以用 `i < nums.back()` 而非 `<=`，既避免了多余检查，也防止 `pos` 越界。
