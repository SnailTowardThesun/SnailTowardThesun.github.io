---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.42: 接雨水"
categories: LeetCode
---

> 双指针向中间收缩，两侧都高于当前水位时抬升水位，水量按新水位一次性结算。这是双指针水位法的一种变体。

## 题目

LeetCode 42. Trapping Rain Water（接雨水）

Difficulty: **Hard**

给定 n 个非负整数表示柱子高度，计算下雨后能接住的雨水量。

### 示例

```
输入：height = [0,1,0,2,1,0,1,3,2,1,2,1]
输出：6

输入：height = [4,2,0,3,2,5]
输出：9
```

## 解题思路

### 双指针 + 水位结算

1. pt、pb 两指针指向两端，com 表示当前已确认的水位，tmp 记录上一轮水位。
2. 只有当两侧柱子都高于 com 时，水位才能抬升到两者较小值 `com = min(A[pt], A[pb])`。
3. 水位抬升后，对区间内每根柱子补充新增水量：`com - max(A[i], tmp)`（已超过新水位的不计）。
4. 每次移动较矮一侧的指针，与盛水容器同理。

经典写法是逐位置结算 `min(leftMax, rightMax) - height[i]`，本实现按「水位抬升事件」批量结算，思路等价。

### 复杂度分析

- **时间复杂度**：O(n²)，本实现每次抬水位都扫描区间；经典双指针版为 O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int trap(int A[], int n) {
        if (n < 3) return 0;
        int pt = 0, pb = n - 1, com = 0, result = 0, tmp = 0;
        while (pt < pb) {
            if (A[pt] > com && A[pb] > com) {
                com = A[pt] < A[pb] ? A[pt] : A[pb];
                for (int i = pt + 1; i < pb; i++) {
                    result += com < A[i] ? 0 : com - (A[i] < tmp ? tmp : A[i]);
                }
                tmp = com;
            }
            A[pt] < A[pb] ? pt++ : pb--;
        }
        return result;
    }
};
```

### 代码解析

- `com - (A[i] < tmp ? tmp : A[i])`：只累计本轮新增水位，减去柱子高度或上轮已计水位，避免重复计算。

## 测试用例

```cpp
TEST(Daily, 42) {
    Solution s;
    int A1[] = {0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1};
    EXPECT_EQ(s.trap(A1, 12), 6);
    int A3[] = {1, 0, 1};
    EXPECT_EQ(s.trap(A3, 3), 1);
}
```

## 总结

1. 水量取决于两侧的较小最高值；
2. 双指针收缩，两侧都更高才抬水位；
3. 经典版逐位置结算可达 O(n)，本实现是批量结算变体。
