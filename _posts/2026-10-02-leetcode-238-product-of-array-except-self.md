---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.238: 除自身以外数组的乘积"
categories: LeetCode
tags: [中等, 数组, 前缀和]
---

> 当前位置两侧的乘积相乘，就是除自身以外所有元素的乘积。空的一侧用乘法单位元 1，首尾位置也适用。

## 题目

LeetCode 238. Product of Array Except Self（除自身以外数组的乘积）

Difficulty: **Medium**

给定整数数组 nums，answer[i] 为除 nums[i] 外所有元素乘积。要求 O(n) 时间且不使用除法。进阶要求 O(1) 额外空间，不计输出数组。

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
            ret[i] = left
            left *= nums[i]

        right = 1  # 位置 i 右侧全体元素之积（不含自身）
        for i in range(n - 1, -1, -1):
            ret[i] *= right
            right *= nums[i]

        return ret
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- right 数组是按逆序累积的，访问时下标映射为 n-i-2。
- Python 版没有第二个数组：前缀积先写入答案，后缀积以变量形式「边乘边走」——答案数组被复用为中间载体，额外空间 O(1)。
- 某个位置的前缀或后缀包含零时，对应乘积为零。若输入恰有一个零，只有零所在位置的答案非零。
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

    # ---- 官方示例----
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
