---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.141: 环形链表"
categories: LeetCode
tags: [简单, 链表, 双指针, HOT 100]
---

> 在环形跑道上，同向运动的两人若速度不同，就可能再次相遇。快慢指针把这个追赶过程用于链表，只需保存两个节点引用，就能判断是否有环。

## 题目

[LeetCode 141. Linked List Cycle（环形链表）](https://leetcode.com/problems/linked-list-cycle/description/)

Difficulty: **Easy**

给定链表头节点 `head`，判断沿 `next` 指针访问时，是否能够再次到达同一个节点。存在环时返回 `True`，否则返回 `False`。

判题器用 `pos` 表示尾节点连接的节点下标，下标从 `0` 开始，`-1` 表示无环。`pos` 只用于构造测试链表，函数实际只接收 `head`。

约束：

- 节点数在 `[0, 10^4]` 范围内。
- `-10^5 <= Node.val <= 10^5`。
- `pos` 为 `-1` 或链表中的有效下标。
- 进阶要求使用 `O(1)` 额外空间。

### 示例

```text
输入：head = [3,2,0,-4]，pos = 1
输出：True
解释：尾节点连接下标 1 的节点，形成环。

输入：head = [1,2]，pos = 0
输出：True
解释：尾节点连接头节点。

输入：head = [1]，pos = -1
输出：False
```

## 解题思路

### 一次走一步，一次走两步

令 `slow` 和 `fast` 都从头节点出发，每轮执行：

1. `slow` 沿 `next` 前进一步。
2. 若 `fast.next` 存在，`fast` 前进两步；否则令 `fast = None`，表示到达末尾。
3. 如果移动后两个指针指向同一个非空节点，就返回 `True`。

只要一个指针到达 `None`，循环就结束，返回 `False`。检查相遇必须放在移动之后，否则两个指针初始都在头节点，会把普通链表误判为有环。

以示例 1 为例，用节点下标记录位置：

| 移动轮数 | slow | fast |
|---|---|---|
| 初始 | 0 | 0 |
| 1 | 1 | 2 |
| 2 | 2 | 1 |
| 3 | 3 | 3 |

第三轮在下标 `3` 相遇，说明有环。相遇节点不一定是环的入口，本题只需判断是否有环。

### 为什么一定能相遇

无环时，节点的后继最终是 `None`，快指针会走到末尾，因此算法能结束并返回 `False`。

有环时，两个指针最终都会进入环。设环长为 `L`，每轮快指针比慢指针多走一步，所以它们在环上的相对位置每轮变化 `1`。模 `L` 意义下，相对位置至多经过 `L` 轮就会变成 `0`，此时两个指针指向同一个节点。

### 复杂度分析

设从头节点可达的不同节点数为 `n`。

- 时间复杂度：`O(n)`。有环时，进入环及环内追赶均只需线性步数；无环时最多线性遍历。
- 额外空间复杂度：`O(1)`，只使用两个指针。

## 代码实现

仓库统一导入公共 `ListNode`；在 LeetCode 上提交时，使用平台提供的节点定义即可。

```python
from leetcode_common import ListNode


class Solution:
    def hasCycle(self, head: ListNode | None) -> bool:
        slow, fast = head, head

        while slow is not None and fast is not None:
            slow = slow.next

            if fast.next is not None:
                fast = fast.next.next
            else:
                fast = None

            if slow == fast and slow is not None and fast is not None:
                return True
        return False
```

### 代码解析

- `fast.next` 的检查保证访问 `fast.next.next` 时不会解引用空节点；循环条件已保证当前 `fast` 非空。
- 相遇时要求指针非空，避免把两个 `None` 当成环。
- 公共 `ListNode` 未重写 `__eq__`，因此代码中的 `==` 按对象身份判断；节点值相同不代表同一个节点。
- 算法只修改局部引用，原链表的节点值和连接关系均保持不变。

## 测试用例

12 组用例覆盖题目示例、空链表、单节点自环、头部环、中间入口、尾部自环、奇偶长度无环链表，以及重复值场景。

测试用节点数组保存引用，再根据 `pos` 将尾部接回指定节点。对于有环链表，不能调用一直遍历到 `None` 的 `to_list`，也不要直接打印依赖它的节点表示，否则可能无法结束。

```python
from leetcode_common import ListNode


def test_solution() -> None:
    solution = Solution()
    # (节点值, 尾节点连接的下标, 是否有环)
    cases = [
        ([3, 2, 0, -4], 1, True),  # 官方示例 1
        ([1, 2], 0, True),  # 官方示例 2
        ([1], -1, False),  # 官方示例 3
        ([], -1, False),  # 空链表
        ([1], 0, True),  # 单节点自环
        ([1, 2], -1, False),  # 偶数长度无环
        ([7, 7, 7], -1, False),  # 相同值的独立节点不能误判为环
        ([1, 2, 3, 4], 0, True),  # 环入口在头节点
        ([1, 2, 3, 4], 2, True),  # 非环前缀后接一个短环
        ([1, 2, 3, 4], 3, True),  # 尾节点自环
        ([1, 2, 3, 4, 5], -1, False),  # 奇数长度无环
        ([7, 7, 7], 1, True),  # 相同值且确实有环
    ]

    for values, pos, expected in cases:
        nodes = [ListNode(value) for value in values]
        for i in range(len(nodes) - 1):
            nodes[i].next = nodes[i + 1]
        if pos >= 0:
            nodes[-1].next = nodes[pos]
        head = nodes[0] if nodes else None

        # 使用有限的节点数组保存结构，不能对有环链表调用 to_list。
        before = [(node, node.val, node.next) for node in nodes]
        assert solution.hasCycle(head) is expected
        for node, value, next_node in before:
            assert node.val == value
            assert node.next is next_node
```

## 总结

- 快慢指针借助速度差判断是否有环，时间 `O(n)`、额外空间 `O(1)`。
- 判断的是非空节点对象是否相同，重复值不能作为有环的证据。
- 构造和检查有环测试时，应使用有限的节点集合，避免普通链表遍历陷入循环。
