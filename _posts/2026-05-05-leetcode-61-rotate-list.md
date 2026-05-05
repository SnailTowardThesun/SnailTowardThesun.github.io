---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.61: 旋转链表"
categories: LeetCode
---

> 链表旋转在轮询调度、循环队列中常用，实现资源的循环分配。

## 题目

LeetCode 61. Rotate List（旋转链表）

Difficulty: **Medium**

给定一个链表，旋转链表，将链表每个节点向右移动 k 个位置，其中 k 是非负数。

### 示例

```
示例 1：
输入：head = [1,2,3,4,5], k = 2
输出：[4,5,1,2,3]
解释：
向右旋转 1 步：[5,1,2,3,4]
向右旋转 2 步：[4,5,1,2,3]

示例 2：
输入：head = [0,1,2], k = 4
输出：[2,0,1]
解释：
向右旋转 1 步：[2,0,1]
向右旋转 2 步：[1,2,0]
向右旋转 3 步：[0,1,2]
向右旋转 4 步：[2,0,1]
```

链表旋转操作在轮询调度、循环队列等场景中经常使用，可以用来实现资源的循环分配。

## 解题思路

这道题可以使用数组辅助法来解决，简单直观。

### 核心思路

1. 将链表节点的值存储到数组中
2. 计算实际需要旋转的步数：k % 数组长度（避免重复旋转）
3. 将数组从位置 (数组长度 - 实际步数) 处分割，然后重新拼接
4. 根据新的数组创建新的链表

### 算法详解

以示例 1 的链表 [1,2,3,4,5]，k = 2 为例：

```
步骤 1：将链表值存入数组
container = [1,2,3,4,5]

步骤 2：计算实际旋转步数
数组长度 = 5
实际旋转步数 = 2 % 5 = 2
分割位置 = 5 - 2 = 3

步骤 3：重新拼接数组
前半部分 = [1,2,3]
后半部分 = [4,5]
新数组 = 后半部分 + 前半部分 = [4,5,1,2,3]

步骤 4：根据新数组创建链表
结果 = 4 -> 5 -> 1 -> 2 -> 3
```

这样就得到了旋转后的链表！

### 为什么这个方法有效？

- 当 k 大于链表长度时，旋转 k 次等同于旋转 k % 长度次
- 向右旋转 k 步，相当于把链表最后 k 个节点移到最前面
- 使用数组辅助可以方便地进行分割和重新拼接操作

## 代码实现

{% raw %}
```cpp
struct ListNode {
    int val;
    ListNode *next;

    ListNode() : val(0), next(nullptr) {
    }

    ListNode(int x) : val(x), next(nullptr) {
    }

    ListNode(int x, ListNode *next) : val(x), next(next) {
    }
};

class Solution {
public:
    ListNode *rotateRight(ListNode *head, int k) {
        if (head == nullptr) {
            return head;
        }
        vector<int> container;
        for (auto it = head; it != nullptr; it = it->next) {
            container.push_back(it->val);
        }

        auto steps = container.size() - k % container.size();

        vector<int> ret_container;
        ret_container.reserve(container.size());
        ret_container.insert(ret_container.begin(), container.begin() + steps, container.end());
        ret_container.insert(ret_container.end(), container.begin(), container.begin() + steps);

        ListNode *ret = new ListNode();
        ListNode *pos = ret;
        for (auto i: ret_container) {
            pos->next = new ListNode(i);
            pos = pos->next;
        }

        return ret->next;
    }
};
```
{% endraw %}

### 代码解析

1. **处理边界情况**：如果链表为空，直接返回
2. **收集链表值**：遍历链表，将所有节点值存入 vector 中
3. **计算分割位置**：steps = 数组长度 - k % 数组长度
4. **重新拼接数组**：将数组从 steps 位置分割，后半部分在前，前半部分在后
5. **创建新链表**：根据新数组创建新的链表并返回

### 复杂度分析

- **时间复杂度**: O(n)，需要遍历链表两次（一次收集值，一次创建新链表）
- **空间复杂度**: O(n)，需要额外的数组存储节点值

## 测试用例

{% raw %}
```cpp
TEST(Daily, 61) {
    // head = [1,2,3,4,5], k = 2
    ListNode head = ListNode(1);
    head.next = new ListNode(2);
    head.next->next = new ListNode(3);
    head.next->next->next = new ListNode(4);
    head.next->next->next->next = new ListNode(5);

    Solution s;
    auto ret = s.rotateRight(&head, 2);
    EXPECT_EQ(4, ret->val);
}
```
{% endraw %}

## 总结

这道题的数组辅助法简单直观，容易理解和实现。虽然需要额外的 O(n) 空间，但代码清晰易读。对于链表旋转问题，还有一种更高效的原地旋转方法（O(1) 空间），感兴趣的读者可以进一步研究。
