---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.160: 相交链表"
categories: LeetCode
tags: [简单, 链表, 哈希表, HOT 100]
---

> 两个无环单链表一旦共享某个节点，后续节点也会全部共享，因为同一个节点只有一个 next 引用。相交描述的是对象身份，节点值相同并不代表相交。

## 题目

[LeetCode 160. Intersection of Two Linked Lists（相交链表）](https://leetcode.com/problems/intersection-of-two-linked-lists/description/)

Difficulty: **Easy**

给定两个无环单链表的头节点 `headA`、`headB`，找到它们的第一个公共节点并返回该节点；没有公共节点时返回 `None`。调用结束后，两个链表的结构必须保持不变。

这里要求两个引用指向**同一个节点对象**。即使两个链表包含完全一样的数值序列，只要各自使用独立节点，它们就没有相交。

约束：

- 两个链表的长度分别为 `m`、`n`，`1 <= m, n <= 3 * 10^4`。
- `1 <= Node.val <= 10^5`，链表结构中不存在环。
- 判题器使用 `intersectVal`、`listA`、`listB`、`skipA`、`skipB` 构造链表。`skipA`、`skipB` 表示各自交点前的节点数，函数实际只接收两个头节点。
- 进阶要求时间 `O(m+n)`、额外空间 `O(1)`。本文保留哈希集合实现，使用 `O(m)` 额外空间。

### 示例

```text
示例 1：
A = [4,1,8,4,5]，B = [5,6,1,8,4,5]
A 跳过 2 个节点、B 跳过 3 个节点后，共享尾部 [8,4,5]。
输出：公共节点 8 的引用。

示例 2：
A = [1,9,1,2,4]，B = [3,2,4]
A 跳过 3 个节点、B 跳过 1 个节点后，共享尾部 [2,4]。
输出：公共节点 2 的引用。

示例 3：
A = [2,6,4]，B = [1,5]，节点各自独立。
输出：None。
```

## 解题思路

### 先记录 A，再扫描 B

1. 从 `headA` 开始遍历，将每个节点对象加入集合 `set_a`。
2. 从 `headB` 开始遍历，检查当前节点是否已经在 `set_a` 中。
3. 第一次命中就返回当前节点；遍历到末尾仍未命中则返回 `None`。

以示例 1 为例，B 前缀中的节点 1 与 A 中的节点 1 是两个对象，因此不会命中。到达共享的节点 8 时，集合中存在的正是这个对象，于是返回它。

### 为什么第一个命中就是交点

集合恰好包含 A 的全部节点，因此 B 中某个节点命中集合，当且仅当该节点同时属于 A。扫描顺序从 B 的头部开始，所以第一次命中就是公共尾部的起点。无环单链表相交后不会再次分离，返回的也就是题目要求的第一个公共节点。

算法只读取 `next` 引用，没有任何修改链表的操作。

### 复杂度分析

设 A、B 的长度分别为 `m`、`n`。

- 时间复杂度：`O(m+n)`，基于哈希集合插入和查询平均 `O(1)` 的分析。
- 额外空间复杂度：`O(m)`，集合保存 A 的节点引用，不复制节点。

若要满足进阶空间要求，可以用两个指针分别从 A、B 出发，走完当前链表后切换到另一条。交换路径能抵消独有前缀的长度差，两个指针最终会在交点或 `None` 处相遇，额外空间可降至 `O(1)`。

## 代码实现

仓库通过 `leetcode_common` 复用节点类型；在 LeetCode 中提交时，使用平台提供的 `ListNode` 即可。

```python
from leetcode_common import ListNode


class Solution:
    def getIntersectionNode(self, headA: ListNode | None, headB: ListNode | None) -> ListNode | None:
        set_a = set()
        cur = headA
        while cur is not None:
            set_a.add(cur)  # 保存节点对象，而非 cur.val
            cur = cur.next
        cur = headB
        while cur is not None:
            if cur in set_a:
                return cur
            cur = cur.next
        return None
```

### 代码解析

- **存节点引用**：若保存的是 `cur.val`，两个独立的同值节点就会被误认为交点。
- **对象身份**：仓库的 `ListNode` 没有重写 `__eq__`、`__hash__`，因此集合按对象身份区分节点。测试也用 `is` 验证返回了预期对象。
- **立即返回**：第一次命中就是交点，继续遍历可能把答案推进到公共尾部的后续节点。
- **空链表**：虽然题目约束长度至少为 1，这段实现也能自然处理 `None`，测试将其作为扩展边界。

## 测试用例

测试构造时，共享尾部只创建一次，再把两个独立前缀接到同一个尾部对象上。分别调用两次 `build_list` 构造完整链表，会得到互不相交的两组节点，不能用来模拟交点。

下面 12 组用例覆盖三个题目示例、同值独立节点、同一头节点、头节点位于另一条链表内部、仅尾节点相交和空链表。每组还会核对调用前后的节点值和 `next` 引用。

```python
from leetcode_common import ListNode, build_list


def test_solution() -> None:
    solution = Solution()
    # (A 独有前缀, B 独有前缀, 共享尾部)
    cases = [
        ([4, 1], [5, 6, 1], [8, 4, 5]),
        ([1, 9, 1], [3], [2, 4]),
        ([2, 6, 4], [1, 5], []),
        ([1, 2, 3], [1, 2, 3], []),
        ([], [], [7]),
        ([], [1, 2], [3, 4]),
        ([1, 2], [], [3, 4]),
        ([1, 2], [3], [9]),
        ([1], [1], []),
        ([], [1], []),
        ([1], [], []),
        ([], [], []),
    ]

    def prepend(values: list[int], tail: ListNode | None) -> ListNode | None:
        for value in reversed(values):
            tail = ListNode(value, tail)
        return tail

    for prefix_a, prefix_b, common in cases:
        shared = build_list(common)
        head_a = prepend(prefix_a, shared)
        head_b = prepend(prefix_b, shared)

        before = []
        for head in (head_a, head_b):
            cur = head
            while cur is not None:
                before.append((cur, cur.val, cur.next))
                cur = cur.next

        assert solution.getIntersectionNode(head_a, head_b) is shared
        for node, value, next_node in before:
            assert node.val == value
            assert node.next is next_node
```

## 总结

- 相交链表的判断依据是节点对象身份，不能比较数值或数值序列。
- 用集合记录 A，再沿 B 查找，第一次命中就是公共尾部的起点。
- 测试必须构造真正共享的节点，并确认算法没有修改原链表。
