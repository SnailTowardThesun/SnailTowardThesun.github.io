---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.238: 除自身以外数组的乘积"
categories: LeetCode
tags: [中等, 数组, 前缀和]
---

> 答案天然是「左侧前缀积 × 右侧后缀积」，不用除法也能线性完成——与 2609 构造乘积矩阵是同一套思路的一维版本。

## 题目

LeetCode 238. Product of Array Except Self（除自身以外数组的乘积）

Difficulty: **Medium**

给定整数数组 nums，answer[i] 为除 nums[i] 外所有元素乘积。禁止用除法，O(n) 时间。

### 示例

```
输入：nums = [1,2,3,4]
输出：[24,12,8,6]

输入：nums = [-1,1,0,-3,3]
输出：[0,0,9,0,0]
```

## 解题思路

### 前缀积 × 后缀积

C++ 双数组实现：

1. left 数组：从左到右累积前缀积，left[i] 包含 nums[i]。
2. right 数组：从右到左累积后缀积。
3. 首位置取 right[n-2]，末位置取 left[n-2]，中间位置取 left[i-1] × right[n-i-2]。

更省空间的写法：把前缀积直接写入答案数组，再从右向左用一个变量维护后缀积、边乘边走，不计输出即 O(1) 空间。

### 复杂度分析

- C++ 双数组版：时间 O(n)，额外空间 O(n)。
- Python 答案数组复用版：时间 O(n)，额外空间 O(1)（不计输出）。

## 代码实现

C++ 是双数组版（left/right 前后缀积），Python 是更省空间的「答案数组复用」版（前缀积写入答案、后缀积用变量边乘边走），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt238-cpp" name="lt238" checked>
  <input type="radio" id="lt238-py" name="lt238">
  <div class="lang-tab-nav">
    <label for="lt238-cpp">C++</label>
    <label for="lt238-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        int n = nums.size();
        vector<int> left, right;
        left.push_back(nums[0]);
        right.push_back(nums[n - 1]);

        for (int i = 1; i < n; i++) {
            left.push_back(nums[i] * left.back());
        }
        for (int i = n - 2; i >= 0; i--) {
            right.push_back(nums[i] * right.back());
        }

        vector<int> ret;
        ret.push_back(right[n - 2]);
        for (int i = 1; i < n - 1; i++) {
            ret.push_back(left[i - 1] * right[n - i - 2]);
        }
        ret.push_back(left[n - 2]);
        return ret;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def productExceptSelf(self, nums: list[int]) -> list[int]:
        n = len(nums)
        ret = [1] * n

        left = 1  # 位置 i 左侧全体元素之积（不含自身）
        for i in range(n):
            ret[i] = left  # 先写前缀积
            left *= nums[i]

        right = 1  # 位置 i 右侧全体元素之积（不含自身）
        for i in range(n - 1, -1, -1):
            ret[i] *= right  # 再乘后缀积
            right *= nums[i]

        return ret
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- right 数组是按逆序累积的，访问时下标映射为 n-i-2。
- Python 版没有第二个数组：前缀积先写入答案，后缀积以变量形式「边乘边走」——答案数组被复用为中间载体，额外空间 O(1)。
- 含零场景由前后缀自动处理：零两侧的前/后缀积为 0，无需任何特判——这正是「不用除法」路线的优势。
- 「总乘积除以当前值」违反题目的禁止除法要求，还需要单独处理零。本文与仓库 hot100 目录的 Python 实现均使用前后缀乘积，避免这两个问题。

## 测试用例

C++ 侧：

```cpp
TEST(TOP150, No238_ProductExceptSelf) {
    Solution solution;
    vector<int> nums{1, 2, 3, 4};
    auto ret = solution.productExceptSelf(nums);
    vector<int> expected{24, 12, 8, 6};
    EXPECT_EQ(ret, expected);
}
```

Python 侧（hot100 版）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例（期望值经暴力对照机器核对）----
    assert solution.productExceptSelf([1, 2, 3, 4]) == [24, 12, 8, 6]
    assert solution.productExceptSelf([-1, 1, 0, -3, 3]) == [0, 0, 9, 0, 0]

    # ---- 两个零：全零输出 ----
    assert solution.productExceptSelf([0, 4, 0]) == [0, 0, 0]

    # ---- 唯一的零位于首端或末端，检验空前缀与空后缀 ----
    assert solution.productExceptSelf([0, 2, 3]) == [6, 0, 0]
    assert solution.productExceptSelf([2, 3, 0]) == [0, 0, 6]

    # ---- 最小规模 ----
    assert solution.productExceptSelf([2, 3]) == [3, 2]

    # ---- 负数 ----
    assert solution.productExceptSelf([-2, 3]) == [3, -2]
```

可用「逐位枚举其余元素连乘」作为参考算法，对照检查前后缀版；测试应覆盖负数、首尾的零和多个零。

## 总结

1. 不用除法，答案拆成左右两段乘积；
2. C++ 双数组版使用 O(n) 额外空间，Python 复用输出数组实现 O(1) 额外空间；
3. 含零场景由前后缀自动处理，无需特判。

## 补充：Top 150 C++ 实现

以下是当前 Top 150 源码中的实现，已同步到 `cplusplus/questions/238.cpp`。

{% raw %}
```cpp
#include <vector>

using namespace std;

class Solution {
   public:
    vector<int> productExceptSelf(vector<int>& nums) {
        vector<int> left;
        vector<int> right;
        int n = nums.size();

        left.push_back(nums[0]);
        right.push_back(nums[n - 1]);
        for (int i = 1; i < n; i++) {
            left.push_back(nums[i] * left[left.size() - 1]);
        }

        for (int i = n - 2; i >= 0; i--) {
            right.push_back(nums[i] * right[right.size() - 1]);
        }

        vector<int> ret;
        ret.push_back(right[n - 2]);
        for (int i = 1; i < n - 1; i++) {
            ret.push_back(left[i - 1] * right[n - i - 2]);
        }
        ret.push_back(left[n - 2]);
        return ret;
    }
};
```
{% endraw %}

### 补充说明

- 该实现与 Top 150 源码保持一致；若与前文旧实现不同，以本节当前版本为准。
- 代码保留源码中的关键注释（如有），便于对照变量含义和边界处理。
