---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.17: 电话号码的字母组合"
categories: LeetCode
tags: [中等, 回溯, 字符串]
---

> 老式手机九宫格键盘上，字母按使用频率高到低排在 2-9 键位，T9 联想输入法靠这张映射表把按键序列猜成单词——本题要枚举的，正是这张表展开出的全部字母组合。

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

实现上有两种等价写法：经典回溯维护一条 path，进层追加、退层撤销；或者把「后面所有位的组合」交给递归子问题，用「首字母 × 子组合」拼接出答案。本文实现取后者——字符串拼接天然产生新对象，连显式撤销都省了。

### 分支因子由映射表决定

`7 → "pqrs"`、`9 → "wxyz"` 各 4 个字母，其余 6 个键各 3 个。组合总数是各键字母数的乘积：`"23"` 是 3 × 3 = 9 条，`"79"` 是 4 × 4 = 16 条，最坏 `4^n` 条——分支因子最大为 4，这正是复杂度里那个 4 的由来。

### 空串：挡在递归之外

`digits == ""` 时必须直接返回 `[]`。若放任进入回溯，「路径长度 == 0 == len(digits)」会在根节点立刻命中收集条件，错误地交出 `[""]`——一条空路径。空输入的语义是「没有组合」，不是「一条空组合」。

### 复杂度分析

- 时间复杂度：`O(4^n * n)`——最坏每位 4 个字母，共 `4^n` 条组合，每条收集时拼接/拷贝需要 `O(n)`；
- 空间复杂度：`O(n)`——递归栈深度加上单层临时结构（不计输出；`n <= 4`，栈深最多 4 层）。

## 代码实现

```python
class Solution:
    def letterCombinations(self, digits: str) -> list[str]:
        if len(digits) == 0:
            return []

        number_char_dict = {
            "2": ["a", "b", "c"],
            "3": ["d", "e", "f"],
            "4": ["g", "h", "i"],
            "5": ["j", "k", "l"],
            "6": ["m", "n", "o"],
            "7": ["p", "q", "r", "s"],
            "8": ["t", "u", "v"],
            "9": ["w", "x", "y", "z"],
        }

        input = list(digits)
        if len(input) == 1:
            return number_char_dict[input[0]]

        ret = []
        subs = self.letterCombinations("".join(input[1:]))
        for k in number_char_dict[input[0]]:
            for s in subs:
                ret.append(k + s)

        return ret
```

### 代码解析

- 空串特判放在最前：`len(digits) == 0` 直接返回 `[]`，把 `[""]` 的坑挡在递归之外（对应示例 2 的边界）；
- 映射表用字典一字排开：键是单字符字符串，值直接存**字母列表**——单数字输入可以把列表原样返回，省掉一层循环拼接；
- `if len(input) == 1` 单数字短路：它既是递归的 base case，也让一位输入零拼接直接出结果；
- 递归分解「首字母 × 子问题」：`subs = self.letterCombinations("".join(input[1:]))` 先递归求出后面所有位的组合，双重循环再把当前位的每个字母前缀到每条子组合上——组合串是在**归途**上自底向上拼出来的：最深层返回裸字母列表，每退一层补上自己那一位；
- `k + s` 拼接替代「path 追加 + 撤销」：新串是不可变的新对象，不碰上一层的状态，回溯的 undo 步骤被字符串不可变性吸收。

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
    assert len(set(result)) == 16  # 无重复
```

`uv run pytest top150/backtracking/top150_17.py` 全部通过。

## 总结

- 电话号码的字母组合 = 各键字母集合的笛卡尔积：每位一层、每层恰选一个字母，回溯与递归分解都是这棵决策树的遍历；
- 空串必须挡在递归之外返回 `[]`——否则收集条件被空路径命中，交出 `[""]`；
- 「首字母 × 子组合」的写法用字符串拼接替代显式撤销，不可变性替我们做了 undo——回溯的心智模型不变，代码更短。
