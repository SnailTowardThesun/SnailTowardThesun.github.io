---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--Top150双指针专题"
categories: LeetCode
---

> 双指针是一种简单而高效的技巧，广泛应用于数组和字符串处理场景，能够将O(n²)的时间复杂度降低到O(n)，是面试中的常客。

## 什么是双指针

双指针是一种在数组或链表上使用两个指针进行遍历和操作的技巧。根据指针的移动方向和方式，可分为以下几类：

### 1. 对撞指针（左右指针）

两个指针分别从数组的两端向中间移动，常用于有序数组的查找问题。

**适用场景**：
- 查找满足某种条件的两数之和
- 判断回文串
- 查找最大容器

### 2. 快慢指针

两个指针从同一端出发，但移动速度不同，常用于链表操作。

**适用场景**：
- 链表环检测
- 链表倒数第k个节点
- 链表中间节点

### 3. 滑动窗口

两个指针维护一个可变大小的窗口，常用于子串/子数组问题。

**适用场景**：
- 最小覆盖子串
- 字符串排列
- 无重复字符的最长子串

---

## 经典例题讲解

### LeetCode 11. 盛水最多的容器

**题目**：给定 n 个非负整数 a1，a2，...，an，每个数代表坐标中的一个点。画 n 条垂直线，使得两条线 i 和 j 生成的容器可以容纳最多的水。

**解题思路**：使用对撞指针，从数组两端开始。每次移动较短的边，因为面积由最短边决定，移动较长的边不可能找到更大的面积。

{% raw %}
```cpp
class Solution {
public:
    int maxArea(vector<int>& height) {
        int maxArea = 0;
        int i = 0, j = height.size() - 1;

        while (i < j) {
            int area = min(height[i], height[j]) * (j - i);
            maxArea = max(maxArea, area);
            if (height[i] < height[j]) {
                i++;
            } else {
                j--;
            }
        }

        return maxArea;
    }
};
```
{% endraw %}

**复杂度分析**：
- 时间复杂度：O(n)，每个元素最多访问一次
- 空间复杂度：O(1)

---

### LeetCode 15. 三数之和

**题目**：给你一个整数数组 nums，判断是否存在三元组 (a, b, c) 满足 a + b + c = 0，要求不能重复使用数组中同一个元素，且三元组不能重复。

**解题思路**：先对数组排序，然后固定一个数 k，使用双指针在 k 右侧范围内查找两数之和等于 -nums[k]。关键在于跳过重复元素以避免重复三元组。

{% raw %}
```cpp
class Solution {
public:
    vector<vector<int>> threeSum(vector<int>& nums) {
        vector<vector<int>> res;
        sort(nums.begin(), nums.end());
        for (size_t k = 0; k < nums.size(); ++k) {
            if (nums[k] > 0) break;
            if (k > 0 && nums[k] == nums[k - 1]) continue;
            int target = 0 - nums[k];
            int i = k + 1, j = nums.size() - 1;
            while (i < j) {
                if (nums[i] + nums[j] == target) {
                    res.push_back({nums[k], nums[i], nums[j]});
                    while (i < j && nums[i] == nums[i + 1]) ++i;
                    while (i < j && nums[j] == nums[j - 1]) --j;
                    ++i; --j;
                } else if (nums[i] + nums[j] < target) {
                    ++i;
                } else {
                    --j;
                }
            }
        }
        return res;
    }
};
```
{% endraw %}

**复杂度分析**：
- 时间复杂度：O(n²)
- 空间复杂度：O(1)（不计排序额外空间）

---

### LeetCode 125. 验证回文串

**题目**：给定一个字符串，判断它是否是回文串。判断时只考虑字母和数字字符，忽略大小写和所有其他字符。

**解题思路**：先预处理字符串，只保留字母和数字并转为小写。然后使用双指针从两端向中间比较。

{% raw %}
```cpp
class Solution {
public:
    bool isPalindrome(string s) {
        string helper;
        for (auto c : s) {
            if (c >= 'a' && c <= 'z') {
                helper += c;
            } else if (c >= 'A' && c <= 'Z') {
                helper += tolower(c);
            } else if (c >= '0' && c <= '9') {
                helper += c;
            }
        }

        for (size_t i = 0, j = helper.size() - 1; i < j; i++, j--) {
            if (helper[i] != helper[j]) {
                return false;
            }
        }

        return true;
    }
};
```
{% endraw %}

**复杂度分析**：
- 时间复杂度：O(n)
- 空间复杂度：O(n)

---

### LeetCode 167. 两数之和 II

**题目**：给你一个已按升序排列的整数数组 numbers 和一个目标值 target。数组中存在两个数，它们的和等于目标值。返回这两个数的下标（1-indexed）。

**解题思路**：利用数组已排序的特性，使用双指针从两端向中间遍历。如果两数之和小于 target，左指针右移；如果大于 target，右指针左移。

{% raw %}
```cpp
class Solution {
public:
    vector<int> twoSum(vector<int>& numbers, int target) {
        vector<int> result;
        int pre = 0, last = numbers.size() - 1;
        while (pre < last) {
            if (numbers[pre] + numbers[last] == target) {
                return vector<int>{pre, last};
            }
            if (numbers[pre] + numbers[last] < target) {
                pre++;
            } else {
                last--;
            }
        }
        return result;
    }
};
```
{% endraw %}

**复杂度分析**：
- 时间复杂度：O(n)
- 空间复杂度：O(1)

---

### LeetCode 392. 判断子序列

**题目**：给定字符串 s 和 t，判断 s 是否是 t 的子序列。子序列是指通过删除一些（或不删除）字符而不改变剩余字符顺序得到的序列。

**解题思路**：使用双指针同步遍历 s 和 t。如果两个指针指向的字符相同，则 s 指针右移；无论是否匹配，t 指针都右移。

{% raw %}
```cpp
class Solution {
public:
    bool isSubsequence(string s, string t) {
        size_t s_p = 0, t_p = 0;
        while (s_p < s.size() && t_p < t.size()) {
            if (s[s_p] == t[t_p]) {
                s_p++;
            }
            t_p++;
        }
        return s_p == s.size();
    }
};
```
{% endraw %}

**复杂度分析**：
- 时间复杂度：O(n)
- 空间复杂度：O(1)

---

## 双指针技巧总结

### 什么时候使用双指针

1. **有序数组**：当数组有序时，考虑使用对撞指针从两端向中间查找
2. **回文判断**：使用左右指针从两端向中间比较
3. **子序列问题**：两个指针分别遍历两个序列
4. **去重问题**：配合排序，使用跳过重复元素的技巧

### 双指针的通用模式

```cpp
// 对撞指针模式
int left = 0, right = n - 1;
while (left < right) {
    // 根据条件移动指针
    if (condition) {
        left++;
    } else {
        right--;
    }
}

// 快慢指针模式
int slow = 0;
for (int fast = 0; fast < n; fast++) {
    // 处理slow和fast的关系
    if (needMoveSlow) {
        slow++;
    }
}
```

### 注意事项

1. **边界条件**：确保指针移动不会越界
2. **循环终止条件**：明确什么情况下循环应该结束
3. **去重处理**：在需要去重的场景中，注意跳过重复元素
4. **返回值**：明确函数应该返回什么

---

## 练习建议

1. 从简单题开始，如验证回文串、两数之和
2. 逐步过渡到中等难度，如三数之和、盛水最多容器
3. 注意总结每道题的通用模式
4. 尝试用双指针优化暴力解法

双指针是一种非常实用的技巧，掌握它能让你在面试中轻松应对许多数组和字符串问题。
