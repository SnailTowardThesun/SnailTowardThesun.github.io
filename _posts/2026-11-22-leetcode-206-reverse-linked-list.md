---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.206: 反转链表"
categories: LeetCode
tags: [简单, 链表, 数组, HOT 100]
---

> 单链表只保存后继引用，无法像数组一样按下标倒着访问。把节点值暂存到数组后，就能方便地逆序重建，但会增加存储开销。

## 题目

[LeetCode 206. Reverse Linked List（反转链表）](https://leetcode.com/problems/reverse-linked-list/description/)

Difficulty: **Easy**

给定单链表的头节点 `head`，返回反转后的链表。

约束：

- 节点数在 `[0, 5000]` 范围内。
- `-5000 <= Node.val <= 5000`。
- 进阶：分别用迭代和递归实现反转。

本文使用**收集节点值、逆序重建**的方法。返回链表由新节点组成，原链表保持不变；时间和额外空间都是 `O(n)`。

### 示例

```text
输入：head = [1,2,3,4,5]
输出：[5,4,3,2,1]

输入：head = [1,2]
输出：[2,1]

输入：head = []
输出：[]
```

## 解题思路

### 用数组保存遍历结果

从 `head` 出发，沿着 `next` 访问所有节点，将节点值依次加入数组 `container`。遍历完成后，数组顺序与原链表一致。

调用 `container.reverse()`，把数组中的值原地逆序排列。这里改变的是数组顺序，原链表的连接关系保持不变。

### 用哑节点构造结果

先创建哑节点 `ret`，再用 `cur` 指向当前结果链表的尾部。按逆序后的数组依次执行：

1. 创建保存当前值的新节点，接到 `cur.next`。
2. 将 `cur` 移动到新节点。

最终返回 `ret.next`，跳过只用于简化连接操作的哑节点。

以 `[1,2,3]` 为例：

```text
收集节点值：container = [1,2,3]
逆序数组：  container = [3,2,1]
构造结果：  哑节点 -> 3 -> 2 -> 1 -> None
返回：      节点 3
```

数组逆序后，第 `k` 个值来自原链表倒数第 `k` 个节点。构造过程按这个顺序逐个连接，所以结果链表恰好包含原链表的逆序值序列。

空链表会得到空数组，构造循环不执行，哑节点的 `next` 保持 `None`，自然返回空链表。

### 复杂度分析

设节点数为 `n`。

- 时间复杂度：`O(n)`。收集、数组逆序和重建各需要线性时间。
- 额外空间复杂度：`O(n)`。即使排除返回链表，临时数组也要保存 `n` 个值。数组的 `reverse()` 操作本身仅需 `O(1)` 额外空间。
- 返回的新链表另占 `O(n)` 空间；计入它后，总空间仍为 `O(n)`。

若需要复用原节点，可以用 `prev`、`cur` 和保存后继的临时变量，逐个将 `cur.next` 指向前驱。该迭代方法能将额外空间降为 `O(1)`，同时会改变原节点的连接关系。

## 代码实现

仓库统一导入 `leetcode_common.ListNode`；在 LeetCode 上提交时，使用平台提供的节点定义即可。

```python
from leetcode_common import ListNode


class Solution:
    def reverseList(self, head: ListNode | None) -> ListNode | None:
        container = []
        cur = head
        while cur is not None:
            container.append(cur.val)
            cur = cur.next

        container.reverse()

        ret = ListNode(0)  # 哑节点，统一处理空链表和第一个节点
        cur = ret
        for i in container:
            cur.next = ListNode(i)
            cur = cur.next

        return ret.next
```

### 代码解析

- `container` 保存的是节点值，重建时每次 `ListNode(i)` 都会分配新节点，因此输出与输入不共享节点。
- `list.reverse()` 直接修改数组并返回 `None`，不能把返回值重新赋给 `container`。
- 哑节点的值 `0` 不属于结果，真实输入中的零值仍会正常保留。
- 重复值、负数和零都无需特殊处理，算法只调整值的排列顺序。

## 测试用例

下面 9 组用例覆盖题目示例、空链表、单节点、重复值、正负数、零、数值上下界及回文序列。除了核对输出顺序，也检查当前实现返回新节点，并保持原链表的值和连接关系。

```python
from leetcode_common import ListNode, build_list


def test_solution() -> None:
    solution = Solution()
    cases = [
        ([1, 2, 3, 4, 5], [5, 4, 3, 2, 1]),
        ([1, 2], [2, 1]),
        ([], []),
        ([7], [7]),
        ([2, 2, 2], [2, 2, 2]),
        ([-2, 0, 3], [3, 0, -2]),
        ([-5000, 5000], [5000, -5000]),
        ([1, 2, 1, 2], [2, 1, 2, 1]),
        ([1, 2, 3, 2, 1], [1, 2, 3, 2, 1]),
    ]

    for values, expected in cases:
        head = build_list(values)
        before = []
        cur = head
        while cur is not None:
            before.append((cur, cur.val, cur.next))
            cur = cur.next
        original_nodes = {node for node, _, _ in before}

        result = solution.reverseList(head)
        cur = result
        for value in expected:
            assert cur is not None
            assert cur.val == value
            assert cur not in original_nodes
            cur = cur.next
        assert cur is None

        for node, value, next_node in before:
            assert node.val == value
            assert node.next is next_node
```

按预期长度检查后要求尾部为 `None`，可以同时验证节点数、尾部终止和是否意外形成环。

## 总结

- 将链表值存入数组，逆序后重建，可以直观地得到反转后的值序列。
- 哑节点统一处理空链表和首节点，返回时跳过它即可。
- 当前方法保留原链表，代价是线性存储；复用节点的指针反转法可将额外空间降到常数级。
