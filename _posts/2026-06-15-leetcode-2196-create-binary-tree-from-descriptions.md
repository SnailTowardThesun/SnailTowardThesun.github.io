---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2196: 根据描述创建二叉树"
categories: LeetCode
---

> 二叉树是一种重要的数据结构，广泛应用于搜索、排序和表达式解析等场景。根据父子关系描述重建二叉树是面试中的经典问题。

## 题目

**LeetCode 2196. Create Binary Tree From Descriptions（根据描述创建二叉树）**

给你一个二维整数数组 descriptions，其中 descriptions[i] = [parenti, childi, isLefti]，表示 parenti 是 childi 在二叉树中的父节点，二叉树中各节点的值互不相同。

请你根据 descriptions 的描述构造这棵二叉树，并返回二叉树的根节点。

### 示例

**示例 1：**
```
输入：descriptions = [[20,15,1],[20,17,0],[50,20,1],[50,80,0],[80,19,1]]
输出：[50,20,80,15,17,19]
解释：
根节点是值为 50 的节点，因为它没有父节点。
```

**示例 2：**
```
输入：descriptions = [[1,2,1],[2,3,0],[3,4,1]]
输出：[1,2,null,null,3,4]
```

## 解题思路

本题要求根据父子关系描述来重建二叉树。关键在于：
1. 需要快速查找和创建节点
2. 需要确定哪个节点是根节点（没有父节点的节点）

**算法步骤：**
1. 使用哈希表存储节点值到节点对象的映射，便于快速查找
2. 遍历描述数组，创建所有节点并建立父子关系
3. 根据 isLeft 标记确定子节点是左子树还是右子树
4. 找到没有父节点的节点作为根节点

**核心原理：**
- 通过哈希表 O(1) 时间复杂度查找节点
- 通过记录每个节点的父节点信息，最终找到根节点

## 代码实现

{% raw %}
```cpp
#include <vector>
#include <unordered_map>
using namespace std;

struct TreeNode {
    int val;
    TreeNode *left;
    TreeNode *right;
    TreeNode() : val(0), left(nullptr), right(nullptr) {}
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
    TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
};

class Solution {
public:
    TreeNode *createBinaryTree(vector<vector<int> > &descriptions) {
        unordered_map<int, vector<int>> container;
        unordered_map<int, TreeNode*> nodes;
        
        for (auto i : descriptions) {
            int p = i[0];
            int c = i[1];
            int isLeft = i[2];

            if (container.find(p) == container.end()) {
                container[p] = vector<int>{0, 0, 0};
                nodes[p] = new TreeNode(p);
            }

            if (container.find(c) == container.end()) {
                container[c] = vector<int>{0, 0, 0};
                nodes[c] = new TreeNode(c);
            }

            if (isLeft) {
                container[p][1] = c;
                nodes[p]->left = nodes[c];
            } else {
                container[p][2] = c;
                nodes[p]->right = nodes[c];
            }

            container[c] = vector<int>{p, 0, 0};
        }

        int root = 0;
        for (auto i : container) {
            if (i.second[0] == 0) {
                root = i.first;
                break;
            }
        }

        return nodes[root];
    }
};
```
{% endraw %}

## 复杂度分析

- **时间复杂度**: O(n)，其中 n 是描述数组的长度。需要遍历 descriptions 两次（一次构建树，一次找根节点）
- **空间复杂度**: O(n)，需要哈希表存储所有节点，空间与节点数量成正比

## 测试用例

```cpp
{% raw %}
TEST(Daily, 2196) {
    Solution s;
    vector<vector<int> > descriptions = {{20, 15, 1}, {20, 17, 0}, {50, 20, 1}, {50, 80, 0}, {80, 19, 1}};
    auto ret = s.createBinaryTree(descriptions);
    EXPECT_EQ(ret->val, 50);
}
{% endraw %}
```

## 总结

本题通过哈希表实现了高效的二叉树重建。关键技巧在于：
1. 使用哈希表快速定位已创建的节点
2. 通过记录父节点信息找到根节点
3. 根据 isLeft 标记正确建立左右子树关系

这种方法时间复杂度和空间复杂度都是 O(n)，是最优解法之一。类似的哈希表方法也可以应用于其他树结构的重建问题。
