---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.21: 合并两个有序链表"
categories: LeetCode
tags: [简单, 链表, 双指针, HOT 100]
---

> 两条有序链表的归并也是链表归并排序的合并步骤。调整节点的 next 引用就能把两段有序结果连在一起，额外空间只需常数级。

## 题目

给定两个按非递减顺序排列的单链表，使用两条链表中的原节点组成一条有序链表，返回合并后的头节点。链表可以为空，每条链表最多有 50 个节点，节点值在 −100 到 100 之间。[LeetCode 21. Merge Two Sorted Lists（简单）](https://leetcode.com/problems/merge-two-sorted-lists/description/)

### 示例

```text
list1 = [1, 2, 4]，list2 = [1, 3, 4]  →  [1, 1, 2, 3, 4, 4]
list1 = []，       list2 = []         →  []
list1 = []，       list2 = [0]        →  [0]
```

## 解题思路

每条链表当前的头节点都是该链表剩余节点中的最小值。比较两个头节点，取较小的一个接到结果尾部，就能确定结果中的下一个位置。只移动被选中链表的指针，另一条链表的候选节点留到下一轮。

以示例一为例，用 A、B 标记节点来源。第一轮两个头节点的值都是 1，按本实现的规则先取 A 的 1。此时 A 的候选值是 2，B 的候选值仍为 1，于是第二轮取 B 的 1。后续按同样方式选择，得到以下节点顺序。

```text
1(A) → 1(B) → 2(A) → 3(B) → 4(A) → 4(B)
```

一侧取完时，另一侧的剩余节点本身有序，且都大于或等于刚选出的节点，依次接入即可。如果一开始就有一条空链表，直接返回另一条的头节点。

### 复杂度分析

设两条链表分别有 `m` 和 `n` 个节点。遍历时间为 `O(m+n)`，合并过程中只使用一个哑节点和固定数量的指针，额外空间为 `O(1)`。

## 代码实现

```python
from leetcode_common import ListNode


class Solution:
    def mergeTwoLists(self, list1: ListNode | None, list2: ListNode | None) -> ListNode | None:
        if list1 is None:
            return list2
        if list2 is None:
            return list1

        root = ListNode(0)
        cur_r, cur_1, cur_2 = root, list1, list2
        while cur_1 is not None and cur_2 is not None:
            if cur_1.val > cur_2.val:
                cur_r.next = cur_2
                cur_2 = cur_2.next
            else:
                cur_r.next = cur_1
                cur_1 = cur_1.next
            cur_r = cur_r.next

        while cur_1 is not None:
            cur_r.next = cur_1
            cur_1 = cur_1.next
            cur_r = cur_r.next

        while cur_2 is not None:
            cur_r.next = cur_2
            cur_2 = cur_2.next
            cur_r = cur_r.next

        return root.next
```

### 代码解析

`root` 是结果头部之前的哑节点，`cur_r` 指向当前结果尾部。赋值 `cur_r.next = cur_2` 会把第二条链表的候选节点直接接到尾部。随后先让 `cur_2` 前进，再让 `cur_r` 指向刚接上的节点。选择第一条链表时同理。返回 `root.next` 后，结果中的每个节点都来自输入。

## 测试用例

下面用三次对象身份比较检验交错合并。两个值为 1 的节点各自保留，值为 3 的节点仍作为尾节点。

```python
tail = ListNode(3)
left = ListNode(1, tail)
right = ListNode(1)
head = Solution().mergeTwoLists(left, right)

assert head is left
assert left.next is right
assert right.next is tail
assert tail.next is None
```

## 总结

两个输入指针分别指向各自尚未合并的最小节点。每轮固定一个输出位置，就能在线性时间内把所有原节点连成一条非递减链表。
