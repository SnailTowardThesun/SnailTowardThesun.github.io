---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.19: 删除链表的倒数第N个节点"
categories: LeetCode
---

> 快指针先走 n+1 步，两指针再同步移动——快指针到 null 时，慢指针恰好在待删节点的前一个位置。一次遍历完成。

## 题目

LeetCode 19. Remove Nth Node From End of List（删除链表的倒数第 N 个节点）

Difficulty: **Medium**

给定一个链表，删除倒数第 n 个节点并返回头节点。要求一次遍历完成。

### 示例

```
输入：head = [1,2,3,4,5], n = 2
输出：[1,2,3,5]

输入：head = [1], n = 1
输出：[]
```

## 解题思路

### 快慢双指针 + 虚拟间隔

1. 快指针 pe、慢指针 pr 都从 head 出发。
2. pe 先走 n+1 步，两指针间隔保持 n+1。
3. 再同步移动直到 pe 为 null，此时 pr 正好指向待删节点的前驱。
4. 执行 `pr->next = pr->next->next` 删除。
5. **删除头节点的情况**：先走的过程中 pe 提前变 null，说明删的是头节点，直接返回 `head->next`。

### 复杂度分析

- **时间复杂度**：O(n)，一次遍历。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Solution {
public:
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        if (head == NULL) return head;
        ListNode* pr = head;
        ListNode* pe = head;
        for (int i = 0; i <= n; i++) {
            if (!pe) return head->next;  // 待删的是头节点
            pe = pe->next;
        }
        while (pe != NULL) {
            pe = pe->next;
            pr = pr->next;
        }
        pr->next = pr->next->next;
        return head;
    }
};
```

### 代码解析

- 走 n+1 步而不是 n 步，是为了让 pr 停在前驱节点而非待删节点，才能执行删除。
- 常见替代写法是加 dummy 哨兵节点，可统一头节点删除逻辑。

## 测试用例

```cpp
TEST(Daily, 19) {
    Solution s;
    // 1->2->3->4->5，删除倒数第2个
    ListNode* head1 = buildList({1, 2, 3, 4, 5});
    ListNode* result1 = s.removeNthFromEnd(head1, 2);
    EXPECT_EQ(result1->next->next->next->val, 5);

    ListNode* head2 = new ListNode{1, nullptr};
    EXPECT_EQ(s.removeNthFromEnd(head2, 1), nullptr);
}
```

## 总结

1. 快慢指针间隔 n+1，一次遍历定位前驱；
2. 快指针提前到 null 意味着删除头节点；
3. dummy 哨兵可以消除头节点特判。
