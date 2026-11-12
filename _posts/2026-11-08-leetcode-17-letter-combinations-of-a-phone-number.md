---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.17: 电话号码的字母组合"
categories: LeetCode
tags: [中等, 回溯, 字符串]
---

> 电话键盘把英文字母按字母顺序分组放在 2–9 键上，7 和 9 各对应四个字母。一个数字串对应的全部字母组合，就是这些字母集合的笛卡尔积。

## 题目

LeetCode 17. Letter Combinations of a Phone Number（电话号码的字母组合）

Difficulty: **Medium**

给定一个仅包含数字 `2`-`9` 的字符串 `digits`，返回它能表示的**所有**字母组合。答案可以按任意顺序返回。

电话按键上数字到字母的映射如下（与九宫格键盘一致）：

- `2` → `"abc"`，`3` → `"def"`
- `4` → `"ghi"`，`5` → `"jkl"`
- `6` → `"mno"`，`7` → `"pqrs"`
- `8` → `"tuv"`，`9` → `"wxyz"`

注意数字 `0` 和 `1` 不对应任何字母（题目保证输入不含它们）。

约束：

- `0 <= digits.length <= 4`
- `digits[i]` 是范围 `['2', '9']` 内的一个数字

### 示例

```text
输入：digits = "23"
输出：["ad","ae","af","bd","be","bf","cd","ce","cf"]
解释：数字 2 对应 "abc"，数字 3 对应 "def"，两两配对得到 3 x 3 = 9 种组合。
```

```text
输入：digits = ""
输出：[]
解释：没有输入数字，对应空组合列表（注意不是 [""]）。
```

```text
输入：digits = "2"
输出：["a","b","c"]
```

## 解题思路

### 一棵「逐位选择」的决策树

本题属于 top150 回溯（backtracking）分类，是组合枚举最朴素的入门形态：把 `digits` 的每一位看作树的一层，每一层从当前数字对应的字母集合里**恰好选一个**向下走——不同于子集型问题的「选或不选」，这里没有跳过分支，只有「选哪个」。路径长度凑齐 `len(digits)` 时收集一条完整组合；整棵树展开后恰好是各键字母集合的笛卡尔积（`itertools.product` 的手工展开）。

实现维护一条共享的 `path`：选择字母时追加，递归处理下一位，返回后弹出。只在叶子处 `join` 生成结果字符串，避免逐层保存后缀的全部组合。

### 分支因子由映射表决定

`7 → "pqrs"`、`9 → "wxyz"` 各 4 个字母，其余 6 个键各 3 个。组合总数是各键字母数的乘积：`"23"` 是 3 × 3 = 9 条，`"79"` 是 4 × 4 = 16 条，最坏 `4^n` 条——分支因子最大为 4，这正是复杂度里那个 4 的由来。

### 空串：挡在递归之外

`digits == ""` 时必须直接返回 `[]`。若放任进入回溯，「路径长度 == 0 == len(digits)」会在根节点立刻命中收集条件，错误地交出 `[""]`——一条空路径。空输入的语义是「没有组合」，不是「一条空组合」。

### 复杂度分析

- 时间复杂度：`O(4^n * n)`——最坏每位 4 个字母，共 `4^n` 条组合，每条收集时拼接/拷贝需要 `O(n)`；
- 空间复杂度：`O(n)`——递归栈与共享路径（不计 `O(n·4^n)` 的输出）。

## 代码实现

```python
class Solution:
    def letterCombinations(self, digits: str) -> list[str]:
        if not digits:
            return []

        letters = ("", "", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz")
        ret: list[str] = []
        path: list[str] = []

        def backtrack(index: int) -> None:
            if index == len(digits):
                ret.append("".join(path))
                return
            for letter in letters[int(digits[index])]:
                path.append(letter)
                backtrack(index + 1)
                path.pop()

        backtrack(0)
        return ret
```

### 代码解析

- 空串直接返回 `[]`，避免收集一条空字符串；
- `letters[int(digits[index])]` 取得当前数字的候选字母，映射表只创建一次；
- `path.append` 与 `path.pop` 成对出现，兄弟分支复用同一条路径；
- 叶子处 `"".join(path)` 创建独立字符串，之后回溯不会影响已经收集的答案。

## 测试用例

覆盖三个官方示例与四个补充用例（"234" 三键计数、"7"/"9" 四字母键单独枚举、"79" 两个四字母键相邻——计数、逐条长度、无重复三重校验）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：2 x 3 两两配对，9 种组合 ----
    assert sorted(solution.letterCombinations("23")) == sorted(["ad", "ae", "af", "bd", "be", "bf", "cd", "ce", "cf"])

    # ---- 官方示例 2：空串是关键边界，返回 [] 而非 [""] ----
    assert solution.letterCombinations("") == []

    # ---- 官方示例 3：单个数字 3 选 1 ----
    assert sorted(solution.letterCombinations("2")) == sorted(["a", "b", "c"])

    # ---- "234"：2/3/4 各 3 个字母，共 3*3*3 = 27 条组合，每条长 3 ----
    result = solution.letterCombinations("234")
    assert len(result) == 27
    assert all(len(comb) == 3 for comb in result)
    assert len(set(result)) == 27  # 无重复

    # ---- "7"：含 4 个字母的键单独枚举 ----
    assert sorted(solution.letterCombinations("7")) == sorted(["p", "q", "r", "s"])

    # ---- "9"：4 个字母 ----
    result = solution.letterCombinations("9")
    assert len(result) == 4
    assert sorted(result) == sorted(["w", "x", "y", "z"])

    # ---- "79"：两个 4 字母键相邻，4*4 = 16 条组合，每条长 2 ----
    result = solution.letterCombinations("79")
    assert len(result) == 16
    assert all(len(comb) == 2 for comb in result)
    assert len(set(result)) == 16
```

`uv run pytest top150/backtracking/top150_17.py` 全部通过。

## 总结

- 电话号码的字母组合 = 各键字母集合的笛卡尔积：每位一层、每层恰选一个字母，回溯与递归分解都是这棵决策树的遍历；
- 空串必须挡在递归之外返回 `[]`——否则收集条件被空路径命中，交出 `[""]`；
- 共享路径配合叶子处拼接，辅助空间为 O(n)，无需保存中间层的全部子组合。
