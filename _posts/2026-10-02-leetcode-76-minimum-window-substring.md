---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.76: 最小覆盖子串"
categories: LeetCode
tags: [困难, 字符串, 滑动窗口, 哈希表]
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

### Python 变体：Counter 超集比较

Python 3.10+ 的 `Counter` 支持 multiset 比较，`cnt_s >= cnt_t` 一步判定「窗口每个字符数量都不少于需求」——不需要 need/matched 计数器，代码减半。代价是每次比较 O(|Σ|)（|Σ| ≤ 52 个英文字母），总复杂度 O(m·|Σ|)，对 n ≤ 1e5 完全够用。覆盖判定外包给标准库后，整个解法只剩「右扩 → 覆盖则记录并左缩」的滑窗骨架。

## 代码实现

C++ 用 need/matched 计数器（O(1) 覆盖判定），Python 用 Counter 超集比较（更简洁），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt76-cpp" name="lt76" checked>
  <input type="radio" id="lt76-py" name="lt76">
  <div class="lang-tab-nav">
    <label for="lt76-cpp">C++</label>
    <label for="lt76-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
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
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
from collections import Counter


class Solution:
    def minWindow(self, s: str, t: str) -> str:
        cnt_s: Counter = Counter()
        cnt_t: Counter = Counter(t)
        ans_left, ans_right = -1, len(s)  # 最优窗口（闭区间），-1 表示未覆盖过

        left = 0
        for right in range(len(s)):
            cnt_s[s[right]] += 1
            while cnt_s >= cnt_t:  # multiset 超集：窗口覆盖 t，收缩左端找更短
                if right - left < ans_right - ans_left:
                    ans_left, ans_right = left, right
                cnt_s[s[left]] -= 1
                left += 1

        return "" if ans_left == -1 else s[ans_left : ans_right + 1]
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 只在数量「恰好」达标时计数，多纳入同字符不会重复 matched++。
- 收缩时数量「跌破」需求才 matched--，保证边界精确。
- Python 版的 `cnt_s` 吐出过头会出现零/负值条目，但零不影响超集判定，负值只出现在 t 不需要的字符上——判定的正确性不受影响。
- Python 版循环内的顺序是「先记录答案再吐出 s[left]」：记录的是收缩前的窗口，吐出后窗口已变短，下一轮 while 再判定是否仍覆盖。

## 测试用例

C++ 侧：

```cpp
TEST(top150, 76) {
    Solution s;
    EXPECT_EQ(s.minWindow("ADOBECODEBANC", "ABC"), "BANC");
    EXPECT_EQ(s.minWindow("a", "aa"), "");
    EXPECT_EQ(s.minWindow("a", "a"), "a");
}
```

Python 侧（hot100 版）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.minWindow("ADOBECODEBANC", "ABC") == "BANC"
    assert solution.minWindow("a", "a") == "a"
    assert solution.minWindow("a", "aa") == ""

    # ---- t 的字符 s 完全没有 ----
    assert solution.minWindow("abc", "d") == ""

    # ---- 重复字符需求：s 恰好两个 a ----
    assert solution.minWindow("aa", "aa") == "aa"

    # ---- 覆盖窗口在中间：b 与两个 a 之间隔着 x，最短覆盖是 "bxaa" ----
    assert solution.minWindow("xxbxaax", "aab") == "bxaa"
    assert solution.minWindow("ab", "b") == "b"

    # ---- 大小写敏感：A 不覆盖 a ----
    assert solution.minWindow("Ab", "a") == ""
```

提交前用「枚举每个起点向后扩到首个覆盖」的朴素版随机对照 1500 组，与 Counter 滑窗版结果全部一致（Counter 超集比较需 Python 3.10+）。

## 总结

1. need/matched 两个计数器管理覆盖条件；
2. 右扩左缩，收缩阶段产出所有候选最优窗口；
3. O(m+n) 时间，是滑动窗口的标杆题目。

## 补充：Top 150 C++ 实现

以下是当前 Top 150 源码中的实现，已同步到 `cplusplus/questions/76.cpp`。

{% raw %}
```cpp
#include <climits>
#include <string>
#include <unordered_map>
#include <vector>

using namespace std;

class Solution {
   public:
    string minWindow(string s, string t) {
        int m = s.size();
        int n = t.size();

        if (m < n) {
            return "";
        }

        // t 中每个字符的需求量
        unordered_map<char, int> lookup;
        for (auto i : t) {
            lookup[i]++;
        }

        unordered_map<char, int> window;
        int need = lookup.size();  // 需要满足的字符种类数
        int matched = 0;           // 当前窗口内已满足的种类数
        int best_len = INT_MAX;
        int best_left = -1;
        int left = 0;

        for (int right = 0; right < m; right++) {
            char c = s[right];
            if (lookup.count(c)) {
                window[c]++;
                // 该字符数量恰好达标时，种类数 +1
                if (window[c] == lookup[c]) {
                    matched++;
                }
            }

            // 窗口已覆盖 t，收缩左边界寻找更短的覆盖
            while (matched == need) {
                if (right - left + 1 < best_len) {
                    best_len = right - left + 1;
                    best_left = left;
                }
                char lc = s[left];
                if (lookup.count(lc)) {
                    window[lc]--;
                    // 移出后不再满足需求，种类数 -1，结束收缩
                    if (window[lc] < lookup[lc]) {
                        matched--;
                    }
                }
                left++;
            }
        }

        return best_left == -1 ? "" : s.substr(best_left, best_len);
    }
};
```
{% endraw %}

### 补充说明

- 该实现与 Top 150 源码保持一致；若与前文旧实现不同，以本节当前版本为准。
- 代码保留源码中的关键注释（如有），便于对照变量含义和边界处理。
