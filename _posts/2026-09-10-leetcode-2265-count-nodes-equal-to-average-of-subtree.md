---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2265: 统计值等于子树平均值的节点数"
categories: LeetCode
---

> 子树求和与计数是树形聚合的经典场景，类似公司组织架构中逐级汇总部门人数与薪资总额，而后序遍历正是这类自底向上统计的利器。

## 题目

LeetCode 2265. Count Nodes Equal to Average of Subtree（统计值等于子树平均值的节点数）

Difficulty: **Medium**

给你一棵二叉树的根节点 `root`，找出并返回满足要求的节点数：要求节点的值等于其子树中所有节点值的**平均值**（平均值向下取整）。

- `n` 个元素的平均值 = 这 `n` 个元素之和 / `n`，并**向下取整**到最近的整数。
- 节点的子树由该节点本身及其所有后代节点组成。

### 示例

```
示例 1：
输入：root = [4,8,5,0,1,null,6]
输出：5
解释：
- 值为 4 的节点：子树平均值 (4+8+5+0+1+6)/6 = 24/6 = 4，相等
- 值为 8 的节点：子树平均值 (8+0+1)/3 = 9/3 = 3，不相等
- 值为 5 的节点：子树平均值 (5+6)/2 = 11/2 = 5，相等
- 值为 0、1、6 的节点：子树平均值恰好等于自身，均相等
共 5 个节点满足要求。

示例 2：
输入：root = [1]
输出：1
解释：叶子节点的子树只含自身，平均值一定等于自身值。
```

## 解题思路

### 核心思路：逐节点统计子树和与节点数

对每个节点，需要回答两个问题：

1. 以它为根的子树所有节点值之和 `sum` 是多少？
2. 这棵子树一共有多少个节点 `count`？

若 `sum / count == node->val`（C++ 整数除法自动截断小数、向下取整，正好符合题意），就把该节点计入答案。

实现拆成两个递归：

- `dfs(node, sum, count)`：深度优先遍历一棵子树，通过**引用参数**累加节点值之和与节点数。空节点直接返回，不产生贡献。
- `helper(root, ans)`：先序遍历整棵树的每个节点：调一次 `dfs` 拿到该子树的 `sum / count` 做判定，再递归处理左右孩子。

### 样例手算

以 `[4,8,5,0,1,null,6]` 为例，逐个节点核对：

| 节点 | 子树和 | 节点数 | 平均值（向下取整） | 是否等于节点值 |
|------|--------|--------|--------------------|----------------|
| 0 | 0 | 1 | 0 | ✓ |
| 1 | 1 | 1 | 1 | ✓ |
| 8 | 9 | 3 | 3 | ✗ |
| 6 | 6 | 1 | 6 | ✓ |
| 5 | 11 | 2 | 5 | ✓ |
| 4 | 24 | 6 | 4 | ✓ |

只有值为 8 的节点不满足（9/3=3），答案为 5。

> 易错点：统计子树和的递归必须继续深入左右子树。若只累加当前节点就返回，每个节点都会得到「和 = 自身值、数量 = 1」的假象，导致全部节点被误判为满足，样例会错误地输出 6。

### 复杂度分析

- **时间复杂度**：O(n²)，共 n 个节点，每个节点都重新遍历一次自己的子树；树退化成链时总代价为 n+(n-1)+…+1。
- **空间复杂度**：O(n)，最坏情况（单链）为递归栈深度。
- **进阶优化**：改为一次后序遍历，让每个节点向父节点返回 `{子树和, 节点数}`，即可在 O(n) 时间内完成。

## 代码实现

{% raw %}
```cpp
class Solution {
   public:
    // 后序遍历一棵子树，累加其全部节点的值之和 sum 与节点数 count
    void dfs(TreeNode* node, int& sum, int& count) {
        if (node == nullptr) {
            return;
        }
        sum += node->val;
        count++;
        dfs(node->left, sum, count);
        dfs(node->right, sum, count);
    }

    // 遍历每个节点，判定其值是否等于自身子树的平均值，满足则 ans 加一
    void helper(TreeNode* root, int& ans) {
        if (root == nullptr) {
            return;
        }

        // 统计以 root 为根的子树的节点值之和与节点数
        int sum = 0;
        int count = 0;
        dfs(root, sum, count);
        // 整数除法自动向下取整，与题目对平均值的定义一致
        if (count > 0 && sum / count == root->val) {
            ans++;
        }
        helper(root->left, ans);
        helper(root->right, ans);
    }

    int averageOfSubtree(TreeNode* root) {
        int ans = 0;
        helper(root, ans);
        return ans;
    }
};
```
{% endraw %}

### 代码解析

- `dfs` 用 `int&` 引用把整棵子树的和与节点数带回调用方，省去额外定义返回结构体。
- `count > 0` 是防止对空树做除法的防御性判断，使判定逻辑更稳妥。
- 平均值比较直接依赖 C++ 整数除法向零取整的特性，无需调用 `floor`；本题节点值均为非负数，向零取整与向下取整等价。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2265) {
    Solution s;
    // create [4,8,5,0,1,null,6]
    TreeNode* root = new TreeNode(4);
    root->left = new TreeNode(8);
    root->right = new TreeNode(5);
    root->left->left = new TreeNode(0);
    root->left->right = new TreeNode(1);
    root->right->right = new TreeNode(6);
    EXPECT_EQ(s.averageOfSubtree(root), 5);
}
```
{% endraw %}

## 总结

这道 Medium 题思路本身很直接：对每个节点统计子树的「总和 / 数量」，再与节点值做一次整数比较。真正容易踩坑的地方在于子树统计递归必须深入左右孩子，否则会出现「每个节点平均都等于自身」的错误假象，样例输出从 5 变成 6。朴素写法每个节点重算子树，是 O(n²)；一旦理解「子树信息可以自底向上一次性汇总」，用一次后序遍历让每个节点返回 `{sum, count}` 即可优化到 O(n)——这正是树形 DP「后序返回子树信息」思想的入门模板。
