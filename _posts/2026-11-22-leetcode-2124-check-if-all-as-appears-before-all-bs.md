---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2124: 检查是否所有 A 都在 B 之前"
categories: LeetCode
tags: [简单, 字符串, 单次遍历]
---

> 「所有 a 在所有 b 前」有个漂亮的等价形式：字符串里不出现相邻的 "ba"——字符只有两种，任何违规必然在某处留下一个紧挨着的 b 与 a。

## 题目

LeetCode 2124. Check if All A's Appears Before All B's（检查是否所有 A 都在 B 之前）

Difficulty: **Easy**

给你一个仅由字符 `'a'` 和 `'b'` 组成的字符串 `s`。如果 `s` 中**每个 `'a'` 都出现在每个 `'b'` 之前**（即不存在某个 `'b'` 出现在某个 `'a'` 前面），返回 `true`；否则返回 `false`。

约束：

- `1 <= s.length <= 100`
- `s[i]` 为 `'a'` 或 `'b'`

### 示例

```text
输入：s = "aaabbb"
输出：true
解释：所有 'a' 都在所有 'b' 之前。

输入：s = "abab"
输出：false

输入：s = "bbb"
输出：true
解释：没有 'a'，条件自然满足。
```

## 解题思路

### 定位最后一个 'a'

1. 从右向左扫，找到**最后一个 'a'** 的下标 `last_a`——它是 'a' 阵营的「压轴」；
2. 检查 `s[0..last_a]` 中不能出现 `'b'`：若有 `'b'` 出现在最后一个 'a' 之前，说明存在「b 在 a 前」的违规；
3. 没有 `'a'`（`last_a == -1`）时条件自然满足，直接返回 true；没有 `'b'` 同样平凡成立。

### 等价视角：不含相邻的 "ba"

字符只有 a/b 两种，「存在 b 在 a 前」⟺ 某个 'b' 后面（不一定要紧邻）还有 'a' ⟺ 序列中必然出现一次 **a 与 b 的交界**，而交界处恰好是相邻的 `"ba"` 对。于是：

```python
return "ba" not in s
```

一句话完成判定。实现版仍写显式扫描，便于看清结构。

### 复杂度分析

- 时间复杂度：`O(n)`，至多两趟扫描（等价版一趟子串查找）；
- 空间复杂度：`O(1)`。

## 代码实现

C++ 与 Python 逐行对应（右扫找 last_a、左扫查 'b'），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt2124-cpp" name="lt2124" checked>
  <input type="radio" id="lt2124-py" name="lt2124">
  <div class="lang-tab-nav">
    <label for="lt2124-cpp">C++</label>
    <label for="lt2124-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    bool checkString(string s) {
        int last_a = -1;
        for (int i = s.size() - 1; i >= 0; i--) {  // 从右向左找最后一个 'a'
            if (s.at(i) == 'a') {
                last_a = i;
                break;
            }
        }

        for (int i = last_a; i >= 0; i--) {  // 最后一个 'a' 之前不得出现 'b'
            if (s.at(i) == 'b') {
                return false;
            }
        }

        return true;  // last_a == -1（无 'a'）时循环不执行，同样走到这里
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def checkString(self, s: str) -> bool:
        last_a = -1
        for i in range(len(s) - 1, -1, -1):  # 从右向左找最后一个 'a'
            if s[i] == "a":
                last_a = i
                break

        if last_a == -1:  # 没有 'a'，条件自然满足
            return True

        return "b" not in s[: last_a + 1]  # 最后一个 'a' 之前不得出现 'b'
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- 两版对「无 a」的处理方式不同但殊途同归：Python 显式提前返回，C++ 靠 `i = last_a = -1` 的循环条件自然跳过——负数起点让第二个 for 直接不执行；
- 只需检查 `s[0..last_a]` 这一段：`last_a` 之后的 'b' 天然在「最后的 a」之后，不违规；
- 等价一行版 `"ba" not in s` 是本题最短解，显式扫描版胜在结构清晰、易于举一反三（比如改成「所有 a 在所有 c 前」时思路可直接迁移）。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.checkString("aaabbb") is True
    assert solution.checkString("abab") is False
    assert solution.checkString("bbb") is True

    # ---- 最小规模（期望值由参考实现机器核对）----
    assert solution.checkString("a") is True
    assert solution.checkString("b") is True
    assert solution.checkString("ab") is True
    assert solution.checkString("ba") is False

    # ---- 尾部违规：'a' 出现在 'b' 之后 ----
    assert solution.checkString("bbba") is False
    assert solution.checkString("aabbb") is True
```

C++ 侧在 `TEST(Daily, 2124)` 里用同样的 9 组用例断言，`./tests --gtest_filter='Daily.2124*'` 通过；提交前用 `"ba" not in s` 参考实现随机对照 2000 组（长度 1..12 的随机 a/b 串），与扫描版结果全部一致。

## 总结

- 「所有 a 在所有 b 前」⟺ 最后一个 'a' 之前无 'b' ⟺ 不含相邻 "ba"——三种视角层层等价；
- 无 'a' / 无 'b' 的平凡情形由扫描结构自然覆盖，无需特判分支（Python 版保留一个早退只是表达清晰）；
- 字符集只有两种时，任何「顺序违规」都必然留下相邻的交界对——这个观察常能把整类判定压成一行。
