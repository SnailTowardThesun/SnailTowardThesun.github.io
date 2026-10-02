---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.76: 最小覆盖子串"
categories: LeetCode
---

> 用「需要满足的字符种类数 need」和「已达标种类数 matched」配对，窗口何时该扩、何时该缩就变得非常清晰。

## 题目

LeetCode 76. Minimum Window Substring（最小覆盖子串）

Difficulty: **Hard**

给定字符串 s 和 t，返回 s 中覆盖 t 所有字符（重复字符也要满足相应次数）的最短子串；不存在返回空串。

### 示例

```
输入：s = "ADOBECODEBANC", t = "ABC"
输出："BANC"

输入：s = "a", t = "aa"
输出：""
```

## 解题思路

### 滑动窗口

1. lookup 记录 t 中每个字符需求量，need 为不同字符的种类数。
2. 右指针逐个纳入字符：该字符窗口内数量恰好等于需求时 matched++。
3. `matched == need` 时窗口已覆盖 t，进入收缩：记录当前最短窗口，然后左指针移出字符；某字符数量跌破需求时 matched--，停止收缩。
4. 遍历结束，best_left 未更新过说明无覆盖。

### 复杂度分析

- **时间复杂度**：O(m + n)，每个字符最多被左右指针各处理一次。
- **空间复杂度**：O(k)，k 为字符种类数。

## 代码实现

```cpp
class Solution {
public:
    string minWindow(string s, string t) {
        int m = s.size(), n = t.size();
        if (m < n) return "";

        unordered_map<char, int> lookup;
        for (char i : t) lookup[i]++;

        unordered_map<char, int> window;
        int need = lookup.size();
        int matched = 0;
        int best_len = INT_MAX;
        int best_left = -1;
        int left = 0;

        for (int right = 0; right < m; right++) {
            char c = s[right];
            if (lookup.count(c)) {
                window[c]++;
                if (window[c] == lookup[c]) matched++;
            }

            while (matched == need) {
                if (right - left + 1 < best_len) {
                    best_len = right - left + 1;
                    best_left = left;
                }
                char lc = s[left];
                if (lookup.count(lc)) {
                    window[lc]--;
                    if (window[lc] < lookup[lc]) matched--;
                }
                left++;
            }
        }
        return best_left == -1 ? "" : s.substr(best_left, best_len);
    }
};
```

### 代码解析

- 只在数量「恰好」达标时计数，多纳入同字符不会重复 matched++。
- 收缩时数量「跌破」需求才 matched--，保证边界精确。

## 测试用例

```cpp
TEST(top150, 76) {
    Solution s;
    EXPECT_EQ(s.minWindow("ADOBECODEBANC", "ABC"), "BANC");
    EXPECT_EQ(s.minWindow("a", "aa"), "");
    EXPECT_EQ(s.minWindow("a", "a"), "a");
}
```

## 总结

1. need/matched 两个计数器管理覆盖条件；
2. 右扩左缩，收缩阶段产出所有候选最优窗口；
3. O(m+n) 时间，是滑动窗口的标杆题目。
