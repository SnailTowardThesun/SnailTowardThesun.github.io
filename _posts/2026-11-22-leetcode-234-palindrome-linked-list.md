---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.234: 回文链表"
categories: LeetCode
tags: [简单, 链表, 数组, HOT 100]
---

> 回文比较的是对称位置的值。单链表只能沿后继方向遍历，把节点值存入数组后，就能通过下标直接比较首尾两端，无需改变链表结构。

## 题目

[LeetCode 234. Palindrome Linked List（回文链表）](https://leetcode.com/problems/palindrome-linked-list/description/)

Difficulty: **Easy**

给定单链表的头节点 `head`，判断节点值序列正着读和反着读是否完全一致。一致时返回 `True`，否则返回 `False`。

约束：

- 节点数在 `[1, 10^5]` 范围内。
- `0 <= Node.val <= 9`。
- 进阶要求时间 `O(n)`、额外空间 `O(1)`。本文保留数组比较方案，使用 `O(n)` 额外空间。

### 示例

```text
输入：head = [1,2,2,1]
输出：True

输入：head = [1,2]
输出：False
```

## 解题思路

### 保存值，再比较对称位置

1. 从 `head` 出发遍历链表，将每个节点值按顺序加入数组 `container`。
2. 设数组长度为 `n`，对于前半部分的下标 `i`，比较 `container[i]` 与 `container[n - 1 - i]`。
3. 任意一对值不同就返回 `False`；全部相同则返回 `True`。

例如 `[1,2,2,1]`，依次比较下标 `(0,3)` 和 `(1,2)`，两组值都相同，因此是回文。对于 `[1,2,3,1]`，首尾相同，但下标 `(1,2)` 的值不同，因此不是回文。

### 为什么只检查前半部分

每个下标 `i` 都有一个对称位置 `n - 1 - i`，比较两次不会增加信息，因此只需枚举 `range(n // 2)`。

偶数长度时，这些比较覆盖全部节点值；奇数长度时，中间元素与自身对称，无需额外检查。回文的定义正是所有对称位置的值都相同，因此这些比较既必要又充分。

### 复杂度分析

设节点数为 `n`。

- 时间复杂度：`O(n)`。收集全部节点值需要线性时间，对称比较最多进行 `n // 2` 次。
- 额外空间复杂度：`O(n)`，数组保存全部节点值。

若要满足进阶空间要求，可以用快慢指针找到中点，反转后半段，再与前半段逐一比较。该方法会暂时改变链表结构；如果调用后需要保留原链表，应在返回结果前将后半段反转回来，包括发现不匹配的情况。

## 代码实现

仓库通过 `leetcode_common` 复用节点类型；在 LeetCode 上提交时使用平台提供的 `ListNode`。

```python
from leetcode_common import ListNode


class Solution:
    def isPalindrome(self, head: ListNode | None) -> bool:
        container = []
        cur = head
        while cur is not None:
            container.append(cur.val)
            cur = cur.next

        n = len(container)
        for i in range(n // 2):
            if container[i] != container[n - 1 - i]:
                return False
        return True
```

### 代码解析

- 回文依据是节点值，因此这里保存和比较 `cur.val`，不需要比较节点对象身份。
- `n - 1 - i` 是下标 `i` 的镜像位置，减一用于适配从 `0` 开始的数组下标。
- 第一次不匹配即可确定答案；即使比较提前返回，之前的链表遍历仍需 `O(n)` 时间。
- 算法只读取节点值和 `next`，原链表保持不变。对于题目范围外的空链表，循环不执行，这段实现也会返回 `True`。

## 测试用例

12 组用例覆盖题目示例、单节点、两个相同值、奇偶长度、内外层不匹配、零与九、重复值，以及扩展的空链表边界。每组同时检查调用前后的节点值及 `next` 引用。

```python
from leetcode_common import build_list


def test_solution() -> None:
    solution = Solution()
    cases = [
        ([1, 2, 2, 1], True),  # 官方示例 1
        ([1, 2], False),  # 官方示例 2
        ([7], True),  # 单节点
        ([1, 1], True),  # 两个相同节点值
        ([1, 2, 1], True),  # 奇数长度回文
        ([1, 2, 3], False),  # 奇数长度非回文
        ([1, 2, 3, 1], False),  # 外层相同，内层不同
        ([1, 2, 2, 3], False),  # 内层相同，外层不同
        ([0, 9, 9, 0], True),  # 节点值上下界
        ([0, 0, 0, 0], True),  # 全部相同
        ([1, 2, 3, 2, 1], True),  # 多组对称位置
        ([], True),  # 题目范围外的扩展边界：空序列也满足回文条件
    ]

    for values, expected in cases:
        head = build_list(values)
        before = []
        cur = head
        while cur is not None:
            before.append((cur, cur.val, cur.next))
            cur = cur.next

        assert solution.isPalindrome(head) is expected
        for node, value, next_node in before:
            assert node.val == value
            assert node.next is next_node
```

## 总结

- 数组提供随机访问能力，将回文链表转化为对称下标比较。
- 只需检查前半部分，奇数长度的中心元素自然跳过。
- 当前方案保持原链表不变，时间和额外空间均为 `O(n)`。
