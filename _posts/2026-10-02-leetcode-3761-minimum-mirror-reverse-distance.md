---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3761: 最小镜像对距离"
categories: LeetCode
---

> 数字反转（mirror）问题要注意前导零：120 反转后是 21，而不是 021。哈希表记录「反转值→位置」即可一次扫描求最小配对距离。

## 题目

LeetCode 3761. Minimum Mirror Reverse Distance（最小镜像对距离）

Difficulty: **Easy**

给定一个整数数组 `nums`，找到两个元素 `nums[i]` 和 `nums[j]`，使得 `nums[i]` 是 `nums[j]` 的镜像（即 `nums[i]` 的数字反转后等于 `nums[j]`），且 `|i - j|` 最小。返回这个最小距离。如果不存在这样的镜像对，返回 `-1`。

### 示例

```
示例 1：
输入：nums = [12, 21, 45, 33, 54]
输出：1
解释：12 和 21 互为镜像，下标差为 1。

示例 2：
输入：nums = [120, 21]
输出：1
解释：120 反转后是 21，与下标 1 的 21 配对，距离为 1。

示例 3：
输入：nums = [12, 34, 56]
输出：-1
解释：不存在镜像对。
```

## 解题思路

### 哈希表一次扫描

1. 定义 `reverseNum(x)`：数学方法逐位反转数字，自然丢弃前导零。
2. 维护哈希表 `prev`，存储「数字反转值 → 最近一次出现的下标」。
3. 遍历数组，对当前元素 `x = nums[i]`：
   - 若 `prev` 中已存在 `x`，说明之前出现过 `reverseNum(prev_x) = x` 的元素，二者互为镜像，更新 `ans = min(ans, i - prev[x])`；
   - 将 `reverseNum(x)` 及其下标 `i` 存入 `prev`。
4. 遍历结束，若 `ans` 仍为初始值 `n + 1`，返回 `-1`，否则返回 `ans`。

**关键点**：`prev` 的键是「反转值」，所以当扫描到 `x` 时，`prev[x]` 存在意味着之前有元素的反转值等于 `x`，即该元素是 `x` 的镜像。

### 复杂度分析

- **时间复杂度**：O(n)，一次扫描，哈希表操作为 O(1)。
- **空间复杂度**：O(n)，哈希表存储每个元素的反转值。

## 代码实现

```cpp
class Solution {
   public:
    int minMirrorPairDistance(vector<int>& nums) {
        // 定义反转数字的函数
        auto reverseNum = [](int x) {
            int y = 0;
            while (x > 0) {
                y = y * 10 + x % 10;
                x /= 10;
            }
            return y;
        };

        int n = nums.size();
        unordered_map<int, int> prev;
        int ans = n + 1;

        for (int i = 0; i < n; ++i) {
            int x = nums[i];
            // 检查当前数字是否在prev中（即之前是否出现过其镜像数字）
            if (prev.count(x)) {
                ans = min(ans, i - prev[x]);
            }
            // 将当前数字的反转结果存入prev，记录当前位置
            prev[reverseNum(x)] = i;
        }

        return ans == n + 1 ? -1 : ans;
    }
};
```

### 代码解析

- `reverseNum` 用 `y = y * 10 + x % 10` 逐位反转，前导零被自然丢弃。
- `prev[reverseNum(x)] = i` 每次覆盖最新下标，保证后续配对取到最小距离。
- `ans` 初始化为 `n + 1`（不可能达到的距离），用于判断是否找到镜像对。

## 测试用例

```cpp
TEST(Daily, 3761) {
    Solution s;

    // 基本情况
    auto nums1 = vector<int>{12, 21, 45, 33, 54};
    EXPECT_EQ(s.minMirrorPairDistance(nums1), 1);

    // 包含前导零：120 反转后是 21
    auto nums2 = vector<int>{120, 21};
    EXPECT_EQ(s.minMirrorPairDistance(nums2), 1);

    // 不存在镜像对
    auto nums3 = vector<int>{12, 34, 56};
    EXPECT_EQ(s.minMirrorPairDistance(nums3), -1);

    // 多个相同数字，取最近
    auto nums4 = vector<int>{12, 45, 21, 54, 12};
    EXPECT_EQ(s.minMirrorPairDistance(nums4), 2);
}
```

## 总结

本题的核心是**哈希表记录反转值**，一次扫描完成镜像对的最小距离查找：

1. `reverseNum` 用数学反转，前导零自然消失；
2. `prev` 存「反转值→下标」，扫描时检查当前值是否是某历史元素的镜像；
3. 每次覆盖最新下标，保证距离最小。
