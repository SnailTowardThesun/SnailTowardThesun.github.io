---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.80: 删除有序数组中的重复项 II"
categories: LeetCode
---

> 在去重双指针上加一个「是否已重复」开关：同值第二次出现仍保留，第三次开始跳过。逻辑推广到保留 k 次只需换成计数器。

## 题目

LeetCode 80. Remove Duplicates from Sorted Array II（删除有序数组中的重复项 II）

Difficulty: **Medium**

给定有序数组，原地删除使每个元素最多出现两次，返回新长度。O(1) 额外空间。

### 示例

```
输入：nums = [1,1,1,2,2,3]
输出：5，前五个元素为 1,1,2,2,3

输入：nums = [0,0,1,1,1,1,2,3,3]
输出：7，前七个元素为 0,0,1,1,2,3,3
```

## 解题思路

### 双指针 + 重复标记

- startPosition：保留区间末尾；isRepeated：当前值是否已出现两次。
- 遇到新值：写入下一位置，重置标记。
- 遇到相同值且标记为 false：这是第二次出现，仍写入并置标记为 true。
- 再遇到相同值：第三次及以后，跳过。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    int removeDuplicates(int A[], int n) {
        if (n == 0) return 0;
        int startPosition = 0;
        bool isRepeated = false;
        for (int i = 1; i < n; i++) {
            if (A[i] != A[startPosition]) {
                isRepeated = false;
                startPosition++;
                A[startPosition] = A[i];
            } else {
                if (isRepeated == false) {
                    startPosition++;
                    A[startPosition] = A[i];
                    isRepeated = true;
                }
            }
        }
        return startPosition + 1;
    }
};
```

### 代码解析

- 更通用的写法是直接判断 `nums[start-2] != nums[i]`：保留区间末尾前两个位置不同即可写入，可推广为保留 k 次。

## 测试用例

```cpp
TEST(Daily, 80) {
    Solution s;
    int A1[] = {1, 1, 1, 2, 2, 3};
    EXPECT_EQ(s.removeDuplicates(A1, 6), 5);
    int A2[] = {0, 0, 1, 1, 1, 1, 2, 3, 3};
    EXPECT_EQ(s.removeDuplicates(A2, 9), 7);
}
```

## 总结

1. 双指针写探分离，标记位控制同值最多两次；
2. 第二次出现保留并标记，之后跳过；
3. 推广到 k 次可用「与倒数第 k 个保留值比较」的写法。
