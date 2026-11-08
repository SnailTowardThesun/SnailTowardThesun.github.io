---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.52: N 皇后 II"
categories: LeetCode
tags: [困难, 回溯]
---

> 八皇后问题是 1848 年提出的国际象棋谜题，高斯也曾研究；1970 年代它成为回溯算法的经典教学范本——8×8 棋盘共 92 个解（含镜像对称）。

## 题目

LeetCode 52. N-Queens II（N 皇后 II）

Difficulty: **Hard**

n 皇后问题研究的是如何将 n 个皇后放置在 n×n 的棋盘上，并且使皇后彼此之间不能相互攻击：任意两个皇后不同行、不同列、也不同斜线。

给你一个整数 `n`，返回 n 皇后问题**不同的解决方案的数量**。

约束：

- `1 <= n <= 9`

### 示例

```text
输入：n = 4
输出：2
解释：4 皇后问题存在两个不同的解法，皇后 'Q' 的位置如下（互为镜像）：

.Q..    ..Q.
...Q    Q...
Q...    ...Q
..Q.    .Q..
```

```text
输入：n = 1
输出：1
```

## 解题思路

### 按行放置，天然消灭行冲突

本题属面试经典 150 题（top150）的**回溯**分类，与 51（N 皇后）同题族，但只数解的数量、不需要输出棋盘——是回溯计数的最纯样板。

n 个皇后放进 n 行，每行恰好一个：递归参数就是行号 `row`，从 `0` 逐行推进。同行的皇后根本不会出现，行冲突从结构上不存在，剩下要管的只有列和两条斜线。

### 三个集合，O(1) 判列与斜线

用三个集合记录已占用位置，候选列 `i` 三者全空才可放置：

- `columns`：已占用的**列号** `i`；
- `diagonal1`：主对角线（左上-右下方向）标识 `row - i`——同一条斜线上该**差**恒定；
- `diagonal2`：副对角线（右上-左下方向）标识 `row + i`——同一条斜线上该**和**恒定。

4×4 棋盘上两组标识的分布一目了然（同值即同线）：

```text
主对角线标识 row-col：        副对角线标识 row+col：

 0  -1  -2  -3                0   1   2   3
 1   0  -1  -2                1   2   3   4
 2   1   0  -1                2   3   4   5
 3   2   1   0                3   4   5   6
```

主对角线方向每走一格 `row+1、col+1`，差不变；副对角线方向 `row+1、col-1`，和不变。于是「是否同斜线」被压成一次整数集合查询，与判列完全同构。

### 只数不存棋盘

与 51 不同，本题不维护棋盘路径：行指针走到 `n` 即 n 行全部合法放置，方案数 +1。放置后标记、递归下一行、回溯撤销，仅此而已。

### 复杂度分析

- 时间复杂度：`O(n!)` 级（第一行 `n` 种选择、第二行至多 `n-1` 种……剪枝后实际搜索树远小于满排列）
- 空间复杂度：`O(n)`（递归深度 + 三个集合）

## 代码实现

```python
class Solution:
    def totalNQueens(self, n: int) -> int:
        def backtrack(row: int) -> int:
            if row == n:
                return 1
            else:
                count = 0
                for i in range(n):
                    if i in columns or row - i in diagonal1 or row + i in diagonal2:
                        continue
                    columns.add(i)
                    diagonal1.add(row - i)
                    diagonal2.add(row + i)
                    count += backtrack(row + 1)
                    columns.remove(i)
                    diagonal1.remove(row - i)
                    diagonal2.remove(row + i)
                return count

        columns = set()
        diagonal1 = set()
        diagonal2 = set()
        return backtrack(0)
```

### 代码解析

- 对角线为何用差/和刻画：`diagonal1` 收 `row - i`，`diagonal2` 收 `row + i`——同一条主对角线上差恒定、同一条副对角线上和恒定，一个整数就是一条斜线的 id，判占用与判列一样是集合 `in`；
- 计数时机在递归返回处：`row == n` 时 `return 1` 记一个完整方案，父层 `count += backtrack(row + 1)` 把每棵子树的解数逐层向上累加——返回值即子树解数，不用全局变量；
- 撤销与放置完全对称：三个 `add` 之后紧跟递归，返回后三个 `remove`，同一 `for` 层的兄弟分支互不污染；循环开头那个三条件 `if ... continue` 就是剪枝——冲突列在进入递归前被直接跳过。

## 测试用例

覆盖两个官方示例与已知答案表（n=1..6、8、9；n=2/3 无解、n=8 经典 92、n=9 上界 352——序列 1,0,0,2,10,4,40,92,352 即 OEIS A000170，其中 n=9=352 已用三集合回溯与全排列暴力两个独立脚本交叉验证）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 2：1×1 棋盘唯一摆法 ----
    assert solution.totalNQueens(1) == 1

    # ---- n=2 / n=3 无解（皇后互相攻击无法避免） ----
    assert solution.totalNQueens(2) == 0
    assert solution.totalNQueens(3) == 0

    # ---- 官方示例 1：4 皇后恰有两个解 ----
    assert solution.totalNQueens(4) == 2

    # ---- n=5 / n=6：10 / 4 ----
    assert solution.totalNQueens(5) == 10
    assert solution.totalNQueens(6) == 4

    # ---- n=8 经典八皇后：92 ----
    assert solution.totalNQueens(8) == 92

    # ---- n=9 上界：352（注意：不是 10，已双脚本独立验证） ----
    assert solution.totalNQueens(9) == 352
```

`uv run pytest top150/backtracking/top150_52.py` 全部通过。

## 总结

- 按行放置让行冲突从结构上消失，剩余约束交给三个集合：列 `col`、主对角线 `row-col`、副对角线 `row+col`，全部 O(1) 查询；
- 与 51（N 皇后）相比只数不存：`row == n` 返回 1、逐层累加，n<=9 的答案序列 1,0,0,2,10,4,40,92,352 正是 OEIS A000170；
- 放置与撤销对称（三 `add` 对三 `remove`），返回值本身携带子树解数——回溯计数不需要全局变量。
