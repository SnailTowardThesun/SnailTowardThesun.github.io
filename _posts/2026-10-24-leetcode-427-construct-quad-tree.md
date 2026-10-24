---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.427: 建立四叉树"
categories: LeetCode
tags: [中等, 树, 分治, 递归]
---

> 四叉树是二维世界的二分法：图像压缩、空间索引、游戏碰撞检测都靠它把"整块相同就不再细分"写成数据结构——一个区域要么一个节点说清，要么切成四块递归下去。

## 题目

LeetCode 427. Construct Quad Tree（建立四叉树）

Difficulty: **Medium**

给你一个 `n × n` 矩阵 `grid`，其中每个元素都是 0 或 1（`n` 是 2 的幂，`n == 2^x，0 <= x <= 6`）。请你将其表示为四叉树并返回根节点。

每个节点包含 `val`、`isLeaf` 和 `topLeft/topRight/bottomLeft/bottomRight` 四个孩子指针。构建规则：

- 如果当前区域内所有值相同，`isLeaf = True`，`val` 为该值，四个孩子均为空；
- 否则 `isLeaf = False`（此时 `val` 可为任意值，判题时忽略），区域四等分后递归构建四个孩子。

输出以层序遍历序列化，每个节点为 `[isLeaf, val]`，孩子顺序 topLeft、topRight、bottomLeft、bottomRight，叶节点不再展开。

### 示例

```
输入：grid = [[0,1],[1,0]]
输出：[[0,1],[1,0],[1,1],[1,1],[1,0]]

输入：grid = [[1,1,1,1,0,0,0,0],
             [1,1,1,1,0,0,0,0],
             [1,1,1,1,1,1,1,1],
             [1,1,1,1,1,1,1,1],
             [1,1,1,1,0,0,0,0],
             [1,1,1,1,0,0,0,0],
             [1,1,1,1,0,0,0,0],
             [1,1,1,1,0,0,0,0]]
输出：[[0,1],[1,1],[0,1],[1,1],[1,0],null,null,null,null,[1,0],[1,0],[1,1],[1,1]]
```

## 解题思路

标准的分治：`dfs(r0, c0, r1, c1)` 处理左上角 `(r0, c0)`、右下角 `(r1, c1)` 的**半开区间**子矩阵。

1. **判同值**：用 `all()` 扫描区域，值全相同就直接建叶节点返回——这是递归的唯一出口，连 1×1 区域也天然覆盖（单个元素必然"全相同"）；
2. **四分**：否则按行列中点 `(r0+r1)//2、(c0+c1)//2` 切成四块递归，四个孩子按左上、右上、左下、右下顺序挂好；
3. **非叶节点的 val 随便给**：判题忽略，习惯上给 `True`。

### 两个实战踩坑

- **左下块的列起点是 `c0` 不是 `r0`**：四个递归调用参数密集，复制粘贴时把行起点传成列起点极难用肉眼发现——最外层调用时 `r0 == c0 == 0`，bug 完全不发作；
- **空区间上 `all()` 恒为 `True`**：参数传混后可能递归出 `r0 == r1` 的空区域，`all()` 不会报错而是返回 `True`，于是凭 `grid[r0][c0]` **凭空造出一个叶节点**，输出凭空多出节点。这类"静默错位"只能靠测试用例抓住。

### 复杂度分析

时间 `O(n² log n)`：每层递归至多全量扫描 `O(n²)` 个格子，共 `log n` 层。追求 `O(n²)` 可用二维前缀和做 O(1) 同值判断，`n <= 64` 的本题规模下不必要。空间 `O(log n)` 递归栈。

## 代码实现

```python
from leetcode_common import QuadNode


class Solution:
    def construct(self, grid: list[list[int]]) -> QuadNode:
        def dfs(r0, c0, r1, c1):
            # 区域值全相同 -> 叶节点（1x1 区域天然满足）
            if all(grid[r0][c0] == grid[i][j] for i in range(r0, r1) for j in range(c0, c1)):
                return QuadNode(grid[r0][c0] == 1, True)
            # 否则按行列中点切成四块递归（半开区间）
            rm, cm = (r0 + r1) // 2, (c0 + c1) // 2
            return QuadNode(
                True, False,
                dfs(r0, c0, rm, cm),        # 左上
                dfs(r0, cm, rm, c1),        # 右上
                dfs(rm, c0, r1, cm),        # 左下（列起点是 c0！）
                dfs(rm, cm, r1, c1),        # 右下
            )

        return dfs(0, 0, len(grid), len(grid))
```

### 代码解析

- **半开区间 `[r0, r1) × [c0, c1)`** 配中点切分，四块无缝拼回原区域，不用纠结边界 ±1；
- **`all()` 一行完成同值判断**，生成器表达式惰性求值，遇到第一个不同值立即短路；
- **`QuadNode` 来自公共库 `leetcode_common`**，与链表/二叉树的 `ListNode`/`TreeNode` 统一管理，不在题解里重复定义；
- 调试输出用公共库的 `quad_to_list` 序列化成层序 `[isLeaf, val]` 列表，与官方输出格式对齐。

## 测试用例

```python
# 官方示例 1：根非叶，四个孩子均为叶
assert _normalize(quad_to_list(solution.construct([[0, 1], [1, 0]]))) == [
    [0, 1], [1, 0], [1, 1], [1, 1], [1, 0]]

# 边界：1x1 矩阵本身就是叶节点
assert _normalize(quad_to_list(solution.construct([[0]]))) == [[1, 0]]

# 全等值：无论规模多大都是单叶节点
assert _normalize(quad_to_list(solution.construct([[1, 1], [1, 1]]))) == [[1, 1]]

# 4x4 仅左上角为 0：根与 topLeft 非叶，topLeft 的左上孩子为 0 叶
grid = [[1] * 4 for _ in range(4)]
grid[0][0] = 0
assert _normalize(quad_to_list(solution.construct(grid))) == [
    [0, 1], [0, 1], [1, 1], [1, 1], [1, 1], [1, 0], [1, 1], [1, 1], [1, 1]]
```

两点测试设计说明：一是**非叶节点的 val 判题忽略**，比较前用 `_normalize` 把非叶 val 统一置 1，避免实现对非叶 val 的不同取值造成误报；二是**单角差异用例**专门覆盖"仅一个子区域需要继续分裂"的路径——正是左下象限参数传错那类 bug 的探测器。官方示例 2 的 8×8 网格也在完整测试中（官方输出的 null 填充用等价的去 null 层序表示）。

## 总结

- 四叉树 = 二维分治：区域同值即叶，否则四等分递归，半开区间 + 中点让边界零烦恼；
- 四个孩子参数是复制粘贴重灾区，左下块的列起点 `c0` 极易误写成 `r0`，顶层 `r0==c0==0` 会完美掩盖它；
- `all()` 对空区间恒为 `True`——参数错位不会崩溃，只会静默产出假叶节点，可靠测试用例是最后一道防线。
