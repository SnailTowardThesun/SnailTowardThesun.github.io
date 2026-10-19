---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2089: 找出数组排序后的目标下标"
categories: LeetCode
tags: [简单, 数组, 排序]
---

> 排序会让相等元素聚成连续区间：只需知道「小于目标值的个数」和「等于目标值的个数」，答案区间便直接确定，连排序都可以省掉。

## 题目

LeetCode 2089. Find Target Indices After Sorting Array（找出数组排序后的目标下标）

Difficulty: **Easy**

给你一个下标从 0 开始的整数数组 `nums` 以及一个目标元素 `target`。

「目标下标」是一个满足 `nums[i] == target` 的下标 `i`。

将 `nums` 按**非递减**顺序排序后，返回由 `nums` 中目标下标组成的数组。如果不存在目标下标，返回一个**空**数组。返回的数组必须按**递增**顺序排列。

### 示例

```
输入：nums = [1,2,5,2,3], target = 2
输出：[1,2]
解释：排序后 nums 变成 [1,2,2,3,5]，满足 nums[i] == 2 的下标是 1 和 2。

输入：nums = [1,2,5,2,3], target = 3
输出：[3]

输入：nums = [1,2,5,2,3], target = 5
输出：[4]
```

## 解题思路

### 排序 + 线性扫描

数组排序后，与目标值相等的元素必然聚成一段连续区间：

1. 先将数组按非递减顺序排序；
2. 从头线性扫描，遇到等于 `target` 的元素就记录其下标；
3. 一旦当前元素大于 `target`，后面只会更大，不可能再出现目标值，提前退出循环。

### 优化：计数法，免排序

进一步观察：答案其实只取决于两个计数——

- `less`：严格小于 `target` 的元素个数，它就是第一个目标下标；
- `equal`：等于 `target` 的元素个数，它决定区间长度。

答案即为区间 `[less, less + equal - 1]` 内的所有下标。一次遍历统计即可，无需真正排序。

### 复杂度分析

| 解法 | 时间复杂度 | 空间复杂度 |
|------|-----------|-----------|
| 排序 + 扫描 | `O(n log n)` | `O(log n)`（排序栈空间） |
| 计数法 | `O(n)` | `O(1)`（不计返回数组） |

## 代码实现

```cpp
class Solution {
public:
    vector<int> targetIndices(vector<int> &nums, int target) {
        vector<int> ret;

        sort(nums.begin(), nums.end());
        for (int i = 0; i < nums.size(); i++) {
            if (nums[i] == target) {
                ret.emplace_back(i);
            }

            if (nums[i] > target) {
                break;
            }
        }

        return ret;
    }
};
```

### 代码解析

- **提前退出**：`nums[i] > target` 时直接 `break`，排序后数组非递减，后续元素不可能再等于目标值；
- **顺序保证**：扫描方向从头到尾，返回的下标天然递增，满足题目要求；
- **空结果**：没有任何元素等于 `target` 时，`ret` 保持为空数组，符合题意。

## 测试用例

```cpp
TEST(Daily, 2089) {
    Solution s;
    vector<int> nums{1, 2, 5, 2, 3};
    int target = 2;
    auto ret = s.targetIndices(nums, target);
    EXPECT_EQ(ret.size(), 2);
}
```

## 总结

- 排序使相等元素聚成连续区间，「找目标下标」退化为「找区间起点和长度」；
- 计数法（小于目标个数 + 等于目标个数）把 `O(n log n)` 降到 `O(n)`，是不需要改动原数组顺序时的更优选择；
- 有序数组中「大于目标即退出」的剪枝是个小但实用的习惯。
