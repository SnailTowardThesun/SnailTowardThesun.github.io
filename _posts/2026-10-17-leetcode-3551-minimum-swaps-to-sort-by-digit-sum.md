---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3551: 按数位和排序的最少交换次数"
categories: LeetCode
tags: [中等, 排序, 贪心]
---

> 置换环有一个优雅结论：长度为 k 的错位环最少只需 k−1 次交换；排序交换数问题因此变成「数环」，而不是每轮扫描找该归位的元素。

## 题目

LeetCode 3551. Minimum Swaps to Sort by Digit Sum（按数位和排序的最少交换次数）

Difficulty: **Medium**（Weekly Contest 450 Q2）

给你一个由互不相同正整数组成的数组 `nums`。

你需要根据每个数字的**数位和**将数组**升序排序**；如果两个数字的数位和相同，则较小的数字排在前面。

返回将 `nums` 重排成该顺序所需的**最小交换次数**。

一次交换定义为交换数组中两个不同位置上的值。

数据范围：`1 <= nums.length <= 10^5`，`1 <= nums[i] <= 10^9`，且 `nums` 由互不相同的正整数组成。

### 示例

```
输入：nums = [37,100]
输出：1
解释：数位和分别为 [10,1]，目标顺序是 [100,37]，
     交换 37 和 100 即可。

输入：nums = [22,14,33,7]
输出：0
解释：数位和分别为 [4,5,6,7]，原数组已经有序。

输入：nums = [18,43,34,16]
输出：2
解释：数位和分别为 [9,7,7,7]，目标顺序是 [16,34,43,18]；
     交换 18 与 16、43 与 34，共 2 次。
```

## 解题思路

核心是 **排序 + 置换环分解**。

1. 对每个数字计算三元组「数位和、数值、原下标」；
2. 按「数位和升序、数值升序」排序，得到目标排列；
3. 目标排列与原数组之间构成一个置换。把置换拆成若干环，长度为 `k` 的环最少需要 `k-1` 次交换；
4. 用 `visited` 标记访问过的下标，遍历所有环并累加 `len-1`。

以 `nums = [18,43,34,16]` 为例：

```
原数组：18(origin 0), 43(origin 1), 34(origin 2), 16(origin 3)
数位和：9, 7, 7, 7
排序后：16(origin 3), 34(origin 2), 43(origin 1), 18(origin 0)

origin = [3, 2, 1, 0]
环：(0 -> 3 -> 0)、(1 -> 2 -> 1)
每个环长度为 2，各需 1 次交换，答案是 2
```

代码中的 `container[j][2]` 表示目标排名 `j` 上的元素原来所在下标，因此沿它跳转得到的是目标置换的逆置换。置换与逆置换的环分解完全相同，所以统计出的环数量不变。

### 复杂度分析

- **时间复杂度**：O(n log n)，瓶颈是排序；数位计算与环遍历均为 O(n)；
- **空间复杂度**：O(n)，存储三元组和访问标记。

## 代码实现

```cpp
class Solution {
   public:
    int minSwaps(vector<int>& nums) {
        auto digitSum = [](int n) {
            int sum = 0;
            while (n != 0) {
                sum += n % 10;
                n /= 10;
            }
            return sum;
        };

        int n = nums.size();
        vector<array<int, 3>> container;
        container.reserve(n);
        for (int i = 0; i < n; i++) {
            container.emplace_back(array<int, 3>{digitSum(nums[i]), nums[i], i});
        }

        sort(container.begin(), container.end(), [](const array<int, 3>& a, const array<int, 3>& b) {
            if (a[0] == b[0]) {
                return a[1] < b[1];
            }

            return a[0] < b[0];
        });

        int ret = 0;
        vector<bool> visited(n, false);
        for (int i = 0; i < n; i++) {
            if (visited[i]) {
                continue;
            }

            int len = 0;
            for (int j = i; !visited[j]; j = container[j][2]) {
                visited[j] = true;
                ++len;
            }

            ret += len - 1;
        }

        return ret;
    }
};
```

### 代码解析

- **三元组排序**：`digitSum` 决定主顺序，数值作次级排序，正好满足同数位和时小数在前的规则；
- **保留原下标**：排序会打乱元素与位置的对应关系，三元组第三项记录来源下标，随后可用于跳转；
- **环内交换数**：长度为 `len` 的环可以通过 `len-1` 次交换归位，固定点贡献 `0`；
- **初始化答案**：`ret` 必须初始化为 `0`，否则累加行为是未定义的；
- **去调试输出**：正式提交不需要打印排序后的三元组，避免额外 I/O 拖慢最大规模用例。

## 测试用例

```cpp
TEST(Daily, 3551) {
    Solution s;

    // 官方示例 1：数位和 [10,1]，目标顺序 [100,37]
    vector<int> nums1 = {37, 100};
    EXPECT_EQ(1, s.minSwaps(nums1));

    // 官方示例 2：数组已按数位和有序，无需交换
    vector<int> nums2 = {22, 14, 33, 7};
    EXPECT_EQ(0, s.minSwaps(nums2));

    // 官方示例 3：相同数位和按数值排序，交换 18/16、43/34
    vector<int> nums3 = {18, 43, 34, 16};
    EXPECT_EQ(2, s.minSwaps(nums3));

    // 一个长度为 4 的置换环，最少需要 3 次交换
    vector<int> nums4 = {277993448, 416038674, 616955867, 539372283};
    EXPECT_EQ(3, s.minSwaps(nums4));
}
```

## 总结

1. 先把自定义排序规则转化为明确的目标排列，再处理交换成本；
2. 任意交换下的最少排序交换数由置换环决定：每个长度为 `k` 的环需要 `k-1` 次；
3. 比较当前数组与目标数组时，置换和逆置换拥有相同的环结构，二者统计出的答案一致。
