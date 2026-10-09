---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.106: 从中序与后序遍历序列构造二叉树"
categories: LeetCode
---

> 由遍历序列重建树是序列化与反序列化的理论基础，数据库索引恢复就依赖这类重建。

## 题目

LeetCode 106. Construct Binary Tree from Inorder and Postorder Traversal（从中序与后序遍历序列构造二叉树）

Difficulty: **Medium**

给定两个整数数组 `inorder` 和 `postorder`，其中 `inorder` 是二叉树的中序遍历，`postorder` 是同一棵树的**后序遍历**，请你构造并返回这颗二叉树。

### 示例

{% raw %}
```
输入：inorder = [9,3,15,20,7], postorder = [9,15,7,20,3]
输出：[3,9,20,null,null,15,7]

输入：inorder = [-1], postorder = [-1]
输出：[-1]
```
{% endraw %}

## 解题思路

### 递归分治

两种遍历各提供一半信息：

- **后序遍历**：`[左子树后序, 右子树后序, 根]` —— 最后一个元素是根；
- **中序遍历**：`[左子树中序, 根, 右子树中序]` —— 根的位置分割左右子树。

递归步骤：

1. 后序的最后一个元素就是根节点的值；
2. 在中序中找到根值的位置：左侧全部是左子树节点，右侧全部是右子树节点；
3. **关键对齐**：后序的左子树段与中序的左子树段长度相同且顺序对应——`postorder[i]` 对应 `inorder[i]`（`i` 小于左子树大小）；右子树段位于左段之后、根之前；
4. 分别切分出左右子树的中序与后序数组，递归构建后挂到根上；
5. 空数组返回 `nullptr`，单元素直接返回叶节点。

以 `inorder = [9,3,15,20,7]`、`postorder = [9,15,7,20,3]` 为例：根为 3；中序中 3 的左边 `[9]` 是左子树，右边 `[15,20,7]` 是右子树；后序中 `[9]` 是左段，`[15,7,20]` 是右段；递归构建后得到目标树。

### 复杂度分析

- **时间复杂度**：O(n²)，每层递归线性查找根位置并复制数组。
- **空间复杂度**：O(n²)，递归栈 O(h) 加上每层切分数组的开销。

> 进阶：用哈希表预存"值→中序下标"、用下标区间代替数组复制，可优化到 O(n)。

## 代码实现

```cpp
class Solution {
   public:
    TreeNode *buildTree(vector<int> &inorder, vector<int> &postorder) {
        if (postorder.size() == 0) {
            return nullptr;
        }

        int root_val = postorder.back();
        TreeNode *root = new TreeNode(root_val);
        if (postorder.size() == 1) {
            return root;
        }

        vector<int> inorder_left_nodes;
        vector<int> postorder_left_nodes;
        for (auto i = 0; i < inorder.size(); i++) {
            if (inorder[i] == root_val) {
                break;
            }
            inorder_left_nodes.emplace_back(inorder[i]);
            postorder_left_nodes.emplace_back(postorder[i]);
        }

        vector<int> inorder_right_nodes;
        vector<int> postorder_right_nodes;
        for (auto i = inorder_left_nodes.size() + 1; i < inorder.size(); i++) {
            inorder_right_nodes.emplace_back(inorder[i]);
            postorder_right_nodes.emplace_back(postorder[i - 1]);
        }

        root->left = buildTree(inorder_left_nodes, postorder_left_nodes);
        root->right = buildTree(inorder_right_nodes, postorder_right_nodes);

        return root;
    }
};
```

### 代码解析

- **`postorder.back()` 取根**：后序的根在末尾，与 105 题（根在前序开头）互为镜像。
- **左段天然对齐**：循环里同步收集 `inorder[i]` 与 `postorder[i]`——中序左段与后序左段下标一致，这是后序特有的便利。
- **右段下标偏移**：后序右段比中序右段"整体前移一位"（后序末尾是根），所以是 `postorder[i - 1]` 对应 `inorder[i]`。

## 测试用例

```cpp
TEST(top150, 106) {
    vector<int> inorder{9, 3, 15, 20, 7};
    vector<int> postorder{9, 15, 7, 20, 3};
    Solution s;
    auto ret = s.buildTree(inorder, postorder);
    EXPECT_EQ(ret->val, 3);
    EXPECT_EQ(ret->left->val, 9);
    EXPECT_EQ(ret->right->val, 20);
    EXPECT_EQ(ret->right->left->val, 15);
    EXPECT_EQ(ret->right->right->val, 7);
}
```

## 总结

1. 后序末尾定根，中序找根分左右；
2. 左段下标对齐直取，右段后序要前移一位；
3. O(n²) 朴素版清晰易写，哈希 + 区间可优化到 O(n)。
