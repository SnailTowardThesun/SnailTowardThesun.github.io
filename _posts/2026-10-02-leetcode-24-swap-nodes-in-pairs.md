---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.24: 两两交换链表中的节点"
categories: LeetCode
---

> 交换一对节点需要同时改动三处指针，pre 指针负责把上一轮和本轮接起来。画一张三节点图最清晰。

## 题目

LeetCode 24. Swap Nodes in Pairs（两两交换链表中的节点）

Difficulty: **Medium**

给定链表，两两交换相邻节点，返回交换后的头节点。必须实际交换节点而非只改值。

### 示例

```
输入：head = [1,2,3,4]
输出：[2,1,4,3]

输入：head = []     输出：[]
输入：head = [1]    输出：[1]
```

## 解题思路

### 迭代指针操作

对当前 cur、next 一对节点：
1. `pre->next = next`：前驱指向交换后的新头部
2. `tmp = next->next`：暂存下一对的起点
3. `next->next = cur`：next 反转指向 cur
4. `cur->next = tmp`：cur 接到下一对
5. 更新 `pre = cur`、`cur = tmp` 进入下一轮

第一轮没有前驱，交换后头节点变为第二个节点，需在循环前单独设置。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
struct ListNode {
    int val;
    ListNode* next;
};

ListNode* swapPairs(ListNode* head) {
    ListNode *cur = head, *next = NULL, *tmp = NULL, *pre = NULL;
    if (cur != NULL && cur->next != NULL) head = cur->next;

    while (cur != NULL) {
        if (cur->next == NULL) return head;
        next = cur->next;
        if (pre != NULL) pre->next = next;
        tmp = next->next;
        next->next = cur;
        cur->next = tmp;
        pre = cur;
        cur = cur->next;
    }
    return head;
}
```

### 代码解析

- `cur->next == NULL` 表示剩余奇数个节点，无法再交换，直接返回。

## 测试用例

```cpp
TEST(Daily, 24) {
    ListNode* result1 = swapPairs(buildList({1, 2, 3, 4}));
    EXPECT_EQ(result1->val, 2);
    EXPECT_EQ(result1->next->next->val, 4);
    EXPECT_EQ(swapPairs(NULL), nullptr);
}
```

## 总结

1. 每轮交换改三处指针，pre 负责前后衔接；
2. 新头节点是原第二个节点，需单独处理；
3. 剩余单节点直接保留。
