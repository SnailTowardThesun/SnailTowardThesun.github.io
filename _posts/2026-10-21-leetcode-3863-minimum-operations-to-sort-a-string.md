---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3863: 将字符串排序的最小操作次数"
categories: LeetCode
tags: [中等, 字符串, 分类讨论, 排序]
---

> 本题答案上界是 3：只要长度超过 2，任何串都能在三步「真子串排序」内变得有序。分类讨论正是证明这类常数上界的常用手段——先排除 0 与 -1，再按最值所在位置层层收敛。

## 题目

LeetCode 3863. Minimum Operations to Sort a String（将字符串排序的最小操作次数）

Difficulty: **Medium**

给你一个由小写英文字母组成的字符串 `s`。

一次操作中，你可以选择 `s` 的任意**子字符串**（但不能是整个字符串），并将其按**非降序**字母顺序排序。

返回使 `s` 变为非降序有序的**最少**操作次数；如果不可能，返回 `-1`。

### 示例

```
输入：s = "dog"
输出：1
解释：对子串 "og" 排序得 "go"，s 变为 "dgo"，已经有序。

输入：s = "card"
输出：2
解释：先排序 "car" 得 "acrd"，再排序 "rd" 得 "acdr"。

输入：s = "gf"
输出：-1
解释：长度为 2 时只能选单个字符的子串，排序不产生任何变化，不可能有序。
```

## 解题思路

### 分类讨论

字符串一旦无序，答案只可能是 `1`、`2`、`3` 或 `-1`，按最值（最小字符 `mn`、最大字符 `mx`）的位置逐层判断：

1. **0**：串已非降序，无需操作；
2. **-1**：长度为 2 且无序——真子串只剩单个字符，排序是无效操作，永远无法有序；
3. **1**：`s[0] == mn` 或 `s[n-1] == mx`。前者排序后缀 `s[1..n-1]`：全局最小值垫底，后面排好后整体必有序；后者对称地排序前缀 `s[0..n-2]`；
4. **2**：`mn` 或 `mx` 出现在中间位置 `s[1..n-2]`。第一次操作把它换到端点，第二次操作排序剩余部分；
5. **3**：其余情况，即 `s[0] == mx` 且 `s[n-1] == mn`（如 `"cba"`）。一次操作无法同时安置两个方向相反的最值，需要三次：先整理中段，再各自归位。

### 手算示例：`"card"`

- 目标是 `"acdr"`；一次操作只能重排一段连续区间，区间外的字符必须原位保留，而 `"card"` 与 `"acdr"` 没有公共的前后缀，故一次不够；
- 排序 `"car"` → `"acrd"`，再排序 `"rd"` → `"acdr"`，两步完成，答案为 `2`。

### 复杂度分析

- 时间复杂度：`O(n)`，有序性检查、求最值、中间扫描各遍历一次（Python 版用排序检查有序性，为 `O(n log n)`，取舍见下文代码解析）；
- 空间复杂度：`O(1)`（Python 版的 `join(sorted(s))` 需 `O(n)` 辅助空间）。

## 代码实现

C++ 与 Python 的分类讨论一一对应（`max(s)` / `min(s)` 对字符串同样按字典序取最值），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt3863-cpp" name="lt3863" checked>
  <input type="radio" id="lt3863-py" name="lt3863">
  <div class="lang-tab-nav">
    <label for="lt3863-cpp">C++</label>
    <label for="lt3863-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
public:
    int minOperations(string s) {
        int n = s.size();

        if (ranges::is_sorted(s.begin(), s.end())) {
            return 0;
        }

        if (n == 2) {
            return -1;
        }

        auto [mn, mx] = ranges::minmax(s);
        if (s.at(0) == mn || s.at(n - 1) == mx) {
            return 1;
        }

        for (int i = 1; i < n - 1; i++) {
            if (s.at(i) == mn || s.at(i) == mx) {
                return 2;
            }
        }

        return 3;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def minOperations(self, s: str) -> int:
        n = len(s)
        if s == "".join(sorted(s)):  # sorted(s) 是 list，需 join 回 str 再比较
            return 0
        if n == 2:
            return -1

        mx = max(s)
        mn = min(s)
        if s[0] == mn or s[n - 1] == mx:
            return 1
        for i in range(1, n - 1):
            if s[i] == mx or s[i] == mn:
                return 2
        return 3
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- **C++20 ranges**：`ranges::is_sorted` 直接判断有序；`ranges::minmax` 一次遍历同时拿到最小/最大字符，配合结构化绑定 `auto [mn, mx]` 写法非常紧凑；
- **边界安全**：访问用 `s.at()` 而非 `s[]`，越界会抛异常而非未定义行为，刷题时更易定位错误；
- **判断顺序**：`n == 2` 的检查必须放在求最值之后不影响正确性，但放在循环之前可以避免无意义的中间扫描；
- **Python 的类型陷阱**：判断有序时直觉写下的 `s == sorted(s)` 恒为 `False`——`sorted(s)` 返回**列表**而 `s` 是字符串，Python 比较两者既不报错也不转换，只是安静地返回假值。于是「已有序返回 0」成了永远走不到的死代码，连 `"klo"` 这样的有序串都会漏判并跌落到后面的分类讨论，没有异常、没有警告，只有测试挂掉时才现形。修正方法是让两边类型一致：`"".join(sorted(s))` 拼回字符串（本文采用），或 `list(s) == sorted(s)` 拆成列表。取舍提示：join 写法的有序性检查要付出 O(n log n) 排序代价，C++ 的 `ranges::is_sorted` 是纯线性；追求严格线性可换成相邻比较 `all(s[i] <= s[i + 1] for i in range(n - 1))`，还能在第一处逆序处短路。

## 测试用例

```cpp
TEST(Daily, 3863) {
    Solution s;
    auto ss = "dog";
    auto ret = s.minOperations(ss);
    EXPECT_EQ(ret, 1);   // 官方示例 1：排序 "og" 一次到位
    EXPECT_EQ(s.minOperations("card"), 2);  // 官方示例 2
    EXPECT_EQ(s.minOperations("gf"), -1);   // 官方示例 3
    EXPECT_EQ(s.minOperations("abc"), 0);   // 已有序
    EXPECT_EQ(s.minOperations("bdac"), 2);  // 最值出现在中间
    EXPECT_EQ(s.minOperations("cba"), 3);   // 最大在首、最小在尾
}
```

## 总结

- 「不能选整个字符串」是本题题眼：长度为 2 直接无解，其余情况答案被压缩到 `1~3` 的常数区间；
- 一次操作能重排一段连续区间，区间外字符必须原位——所以「公共前后缀」决定了一次操作的天花板；
- 分类讨论的关键锚点是**最值的位置**：最小值在首位或最大值在末位时一步搞定，否则逐步升级到两步、三步。
