---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.142: 环形链表 II"
categories: LeetCode
tags: [中等, 链表, 双指针, HOT 100]
---

> Floyd 判圈算法还能定位环的入口。第一次相遇时，快指针恰好多走了慢指针已经走过的步数，这段距离一定是环长的整数倍。

## 题目

给定单链表的头节点 `head`，返回从头出发进入环时遇到的第一个节点。如果沿 `next` 可以走到链表末尾，则返回 `None`。查找过程中要保留原有连接关系。链表长度介于 0 和 10000 之间，节点值介于 −100000 和 100000 之间。[LeetCode 142. Linked List Cycle II（中等）](https://leetcode.com/problems/linked-list-cycle-ii/description/)

### 示例

`pos` 是判题器构造链表用的下标。尾节点指向下标为 `pos` 的节点，`-1` 表示尾节点指向 `None`。调用时只传入头节点。

| 节点值 | pos | 返回结果 |
| --- | --- | --- |
| `[3, 2, 0, -4]` | 1 | 下标 1 的节点，值为 2 |
| `[1, 2]` | 0 | 头节点 |
| `[1]` | -1 | `None` |

## 解题思路

先按[第 141 题的快慢指针方法]({% post_url 2026-11-22-leetcode-141-linked-list-cycle %})找出相遇点。两个指针都从头出发，慢指针每轮走一步，快指针走两步。有环时，两者都进入环后，每轮的相对位移为一步，至多再走一圈就会相遇。无环时，快指针最终到达末尾。

接下来让一个指针回到头节点，另一个留在相遇点。两者同时改为每轮走一步。**它们第一次指向同一个节点时，这个节点就是入口。**

以示例一为例，尾节点接回下标 1，环内顺序为 `1 → 2 → 3 → 1`。第一阶段走三轮后，慢指针走了三步，快指针走了六步，都在下标 3。第二阶段从下标 0 和 3 各走一步，两个指针都到达下标 1，返回该节点即可。

### 为什么第二次相遇在入口

设头到入口需要走 `a` 步，环长为 `L`，从入口沿环到第一次相遇处需要走 `b` 步。若慢指针共走了 `s` 步，快指针就走了 `2s` 步。两者从同一点出发并在环内同一点相遇，多走的 `s` 步是 `L` 的倍数。

慢指针先走完前缀，再在环内行走，因此 `s ≡ a + b (mod L)`。这意味着从相遇点继续走 `a` 步，环内总偏移 `b + a` 恰好回到入口。此时从头出发的指针也刚走完前缀。在这之前，它还在环外，两者无法提前相遇。如果头节点本身就是入口，第二阶段开始时两者已经重合。

### 复杂度分析

设可达的不同节点数为 `n`。找相遇点耗时 `O(n)`，找入口最多再走一遍前缀。总时间为 `O(n)`，额外空间为 `O(1)`。

## 代码实现

```python
from leetcode_common import ListNode


class Solution:
    def detectCycle(self, head: ListNode | None) -> ListNode | None:
        slow = fast = head
        while fast is not None and fast.next is not None:
            # 快指针仍能前进两步，走得更慢的 slow 必然还在链表上。
            assert slow is not None
            slow = slow.next
            fast = fast.next.next
            if slow is fast:
                while head is not slow:
                    # 已确认有环，从头节点或环内出发都不会走到 None。
                    assert head is not None and slow is not None
                    head = head.next
                    slow = slow.next
                return head
        return None
```

### 代码解析

循环条件 `fast is not None and fast.next is not None` 保证快指针可以安全执行 `fast.next.next`。单节点无环时，快指针一开始就在尾部，函数直接返回 `None`。单节点自环时，两个指针走完第一轮都回到了头节点，函数返回该节点。

代码中的两个断言写明了指针的位置关系：快指针还能前进两步时，慢指针仍在链表上；确认环存在后，沿 `next` 会一直留在这条有环链表中。类型检查器也能据此确认后续节点访问有效。

两个阶段都使用 `is` 判断节点身份，因此多个节点可以有相同的值。给局部变量 `head` 重新赋值只会移动指针，链表中的 `next` 保持原样。

## 测试用例

用三个值相同的节点构造一个带前缀的环，可以同时验证返回对象的身份和入口的位置。

```python
first, entry, tail = ListNode(7), ListNode(7), ListNode(7)
first.next = entry
entry.next = tail
tail.next = entry

solution = Solution()
assert solution.detectCycle(first) is entry
assert tail.next is entry
assert solution.detectCycle(ListNode(7)) is None
```

## 总结

一快一慢找到环内相遇点，再从链表头与相遇点同速前进，就能用常数空间返回入口节点。
