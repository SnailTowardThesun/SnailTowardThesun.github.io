---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.105: 从前序与中序遍历序列构造二叉树"
categories: LeetCode
---

> 前序 + 中序重建二叉树是序列化的经典命题，笔试面试出场率极高，务必掌握到能徒手推导。

## 题目

LeetCode 105. Construct Binary Tree from Preorder and Inorder Traversal（从前序与中序遍历序列构造二叉树）

Difficulty: **Medium**

给定两个整数数组 `preorder` 和 `inorder`，其中 `preorder` 是二叉树的**先序遍历**，`inorder` 是同一棵树的**中序遍历**，请构造二叉树并返回其根节点。

### 示例

{% raw %}
```
输入：preorder = [3,9,20,15,7], inorder = [9,3,15,20,7]
输出：[3,9,20,null,null,15,7]

输入：preorder = [-1], inorder = [-1]
输出：[-1]
```
{% endraw %}

## 解题思路

### 递归分治

两种遍历各提供一半信息：

- **前序遍历**：`[根, 左子树前序, 右子树前序]` —— 第一个元素是根；
- **中序遍历**：`[左子树中序, 根, 右子树中序]` —— 根的位置给出左子树大小。

递归步骤：

1. 前序的第一个元素就是根节点的值；
2. 在中序中定位根值：根左侧是左子树的全部节点（数量记为 `left_size`），右侧是右子树；
3. 前序跳过根之后，紧接的 `left_size` 个元素是左子树的前序，其余是右子树的前序；
4. 中序按根的位置切成左段与右段；
5. 分别递归构建左右子树并挂到根上。

以 `preorder = [3,9,20,15,7]`、`inorder = [9,3,15,20,7]` 为例：根为 3；中序左段 `[9]`（left_size=1），右段 `[15,20,7]`；前序去掉根后 `[9,20,15,7]`，前 1 个 `[9]` 给左子树，其余 `[20,15,7]` 给右子树；递归完成构建。

### 复杂度分析

- **时间复杂度**：O(n²)，每层递归线性查找根位置并复制数组。
- **空间复杂度**：O(n²)，递归栈 O(h) 加上切分数组开销。

> 进阶：哈希表预存"值→中序下标" + 下标区间代替复制，可优化到 O(n)。

## 代码实现

```cpp
class Solution {
   public:
    TreeNode *buildTree(vector<int> &preorder, vector<int> &inorder) {
        if (preorder.empty()) {
            return nullptr;
        }

        TreeNode *root = new TreeNode(preorder[0]);
        if (preorder.size() == 1) {
            return root;
        }

        // 在中序中定位根，求左子树边界
        int inorder_left_end = 0;
        for (int i = 0; i < inorder.size(); i++) {
            if (inorder[i] == preorder[0]) {
                inorder_left_end = i - 1;
                break;
            }
        }
        vector<int> inorder_left_nodes;
        for (int i = 0; i <= inorder_left_end; i++) {
            inorder_left_nodes.emplace_back(inorder[i]);
        }

        vector<int> preorder_left_nodes;
        for (auto i = 1; i < 1 + inorder_left_nodes.size(); i++) {
            preorder_left_nodes.emplace_back(preorder[i]);
        }

        // 中序根右侧为右子树，前序左段之后为右子树
        int inorder_right_start = inorder_left_end + 2;
        vector<int> inorder_right_nodes;
        for (int i = inorder_right_start; i < inorder.size(); i++) {
            inorder_right_nodes.emplace_back(inorder[i]);
        }

        vector<int> preorder_right_nodes;
        for (int i = 1 + preorder_left_nodes.size(); i < preorder.size(); i++) {
            preorder_right_nodes.emplace_back(preorder[i]);
        }

        root->left = buildTree(preorder_left_nodes, inorder_left_nodes);
        root->right = buildTree(preorder_right_nodes, inorder_right_nodes);

        return root;
    }
};
```

### 代码解析

- **`preorder[0]` 定根**：前序根在最前，与 106 题（后序根在末尾）互为镜像。
- **`inorder_left_end = i - 1`**：找到根在下标 `i` 后，左段是 `[0, i-1]`；右段起点是 `i + 1`（代码里写作 `inorder_left_end + 2`，等价）。
- **前序切分按长度**：左子树前序是根后面紧接的 `left_size` 个元素，右子树前序从 `1 + left_size` 开始。

## 测试用例

```cpp
TEST(Top150, 105) {
    Solution s;

    TreeNode *root = new TreeNode(3);
    root->left = new TreeNode(9);
    root->right = new TreeNode(20);
    root->right->left = new TreeNode(15);
    root->right->right = new TreeNode(7);

    vector<int> preorder{3, 9, 20, 15, 7};
    vector<int> inorder{9, 3, 15, 20, 7};
    auto ret = s.buildTree(preorder, inorder);
    EXPECT_EQ(ret->val, 3);
    EXPECT_EQ(ret->left->val, 9);
    EXPECT_EQ(ret->right->val, 20);
    EXPECT_EQ(ret->right->left->val, 15);
    EXPECT_EQ(ret->right->right->val, 7);
}
```

## 总结

1. 前序首元素定根，中序找根切左右；
2. 前序左段 = 根后 left_size 个，右段紧随其后；
3. O(n²) 朴素版，哈希 + 双指针区间是标准优化方向。
