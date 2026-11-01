---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.72: 编辑距离"
categories: LeetCode
tags: [中等, 动态规划, 双序列, 字符串, top150]
---

> 编辑距离是拼写检查、DNA 序列比对、diff 工具背后的同一个数字——1965 年 Levenshtein 提出它时用的就是"插入、删除、替换"三种原子操作，六十年没变过。

## 题目

LeetCode 72. Edit Distance（编辑距离）

Difficulty: **Medium**

给你两个单词 `word1` 和 `word2`，请返回将 `word1` 转换成 `word2` 所使用的最少操作数。可以对一个单词进行如下三种操作：

- 插入一个字符
- 删除一个字符
- 替换一个字符

约束：

- `0 <= word1.length, word2.length <= 500`
- `word1` 和 `word2` 由小写英文字母组成

### 示例

```text
输入：word1 = "horse", word2 = "ros"
输出：3
解释：horse -> rorse (将 'h' 替换为 'r') -> rose (删除 'r') -> ros (删除 'e')
```

```text
输入：word1 = "intention", word2 = "execution"
输出：5
```

## 解题思路

### 状态：把"整串变形"拆成"前缀变形"

`dp[i][j]` = `word1` 前 `i` 个字符变成 `word2` 前 `j` 个字符的最少操作数。答案 `dp[n1][n2]`。

边界：`dp[i][0] = i`（把 `i` 个字符删光），`dp[0][j] = j`（从空串插入 `j` 个字符）——空串参与时答案就是另一串的长度。

### 转移：三种操作各自盯着一个邻居

关键问题是"`word1` 的第 `i` 个字符如何对齐 `word2` 的第 `j` 个字符"。三种操作各对应 `dp` 表中的一个邻居：

| 操作 | 含义 | 转移 |
| ---- | ---- | ---- |
| 插入 | 在 word1 末尾补 word2[j-1]，消耗 word2 一个字符 | `dp[i][j-1] + 1` |
| 删除 | 删掉 word1[i-1]，消耗 word1 一个字符 | `dp[i-1][j] + 1` |
| 替换/保留 | 两末字符对齐，各消耗一个字符 | `dp[i-1][j-1] + (word1[i-1] != word2[j-1])` |

三者取最小。注意第三行的代价是**条件式**的：末字符相同则代价 0（保留，走对角线免费），不同则代价 1（替换）——正是这个"免费对角线"让编辑距离能远低于串长（`"same"` → `"same"` 全程免费，答案 0）。

### 手算走一遍 `"horse" → "ros"` 的表

按行填表（行 = word1 前缀，列 = word2 前缀），关键几格：

```text
        ""  r   o   s
    ""   0  1   2   3
    h    1  1   2   3      h≠r：min(替换1, 左2, 上2)=1
    o    2  2   1   2      o=o 对角免费：dp[h][r]=1 + 0
    r    3  2   2   2      r=r 免费：对角 1+0=2
    s    4  3   3   2      s=s 免费：对角 2+0=2
    e    5  4   4   3      e≠s：对角 2+1=3 ← 答案
```

三处"免费对角线"（o、r、s 三次字符匹配）把答案从 5 压到了 3。

### 复杂度分析

- 时间复杂度：`O(n1 * n2)`——每格一次三元素取最小
- 空间复杂度：`O(n1 * n2)`；逐行滚动（只保留两行）可压到 `O(n2)`

## 代码实现

```python
class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        n1, n2 = len(word1), len(word2)
        if n1 == 0 or n2 == 0:
            return n1 + n2  # 一为空串：答案即另一串长度（插入或删除整串）

        # dp[i][j]：word1 前 i 个字符变成 word2 前 j 个字符的最少操作数
        dp = [[0] * (n2 + 1) for _ in range(n1 + 1)]
        for i in range(n1 + 1):
            dp[i][0] = i  # 删除 i 次
        for j in range(n2 + 1):
            dp[0][j] = j  # 插入 j 次

        for i in range(1, n1 + 1):
            for j in range(1, n2 + 1):
                ins = dp[i][j - 1] + 1  # 插入 word2[j-1]
                dele = dp[i - 1][j] + 1  # 删除 word1[i-1]
                rep = dp[i - 1][j - 1] + (word1[i - 1] != word2[j - 1])  # 末字符对齐（同则保留）
                dp[i][j] = min(ins, dele, rep)

        return dp[n1][n2]
```

### 代码解析

- 三种操作的代价计算拆成三个具名变量 `ins / dele / rep`，与转移表一一对应，比塞进一个嵌套 `min` 可读得多；
- `(word1[i-1] != word2[j-1])` 用布尔值当 0/1 用，"保留免费、替换花一块"一行表达；
- 开头空串早退 `n1 + n2` 与边界行列语义一致（其实有边界填表后可省，写出来省一圈循环）；
- 滚动版把 `dp` 压成两行：注意 `dp[i][j-1]` 是本行新值、`dp[i-1][j]` 是上一行旧值，行内从左到右更新恰好两者都在。

## 测试用例

覆盖官方示例、空串三方向、同串零成本、全替换、单操作（替换/插入/删除各一）、字符交换（两步才够）、以及暴力验证的经典长例：

```python
def test_solution() -> None:
    solution = Solution()
    # 官方示例
    assert solution.minDistance("horse", "ros") == 3
    assert solution.minDistance("intention", "execution") == 5
    # 边界：空串（三个方向各自的基础操作）
    assert solution.minDistance("", "") == 0
    assert solution.minDistance("", "abc") == 3  # 纯插入
    assert solution.minDistance("abc", "") == 3  # 纯删除
    # 相同串零成本；全不同则整串替换
    assert solution.minDistance("same", "same") == 0
    assert solution.minDistance("abc", "xyz") == 3
    # 单操作：替换 / 插入 / 删除各一
    assert solution.minDistance("a", "b") == 1  # 替换
    assert solution.minDistance("b", "ab") == 1  # 插入
    assert solution.minDistance("ab", "b") == 1  # 删除
    # 交换两字符 = 2（无法一步完成）
    assert solution.minDistance("ab", "ba") == 2
    # 经典长例（期望值经自顶向下递归参考验证）
    assert solution.minDistance("dinitrophenylhydrazine", "benzalphenylhydrazone") == 7
```

## 总结

- 三种原子操作各自映射到 dp 表的一个邻居：插入看左、删除看上、替换/保留看对角，代价 1/1/条件——转移表可直接默写；
- "末字符相等走对角免费"是编辑距离的灵魂：字符匹配不是操作，免费对齐正是答案低于串长的原因；
- 测试至少留三种单操作用例和一个长例：单操作钉住三种转移各自的代价 +1，长例（本例 7）能暴露边界行列或下标偏移的细小错误。
