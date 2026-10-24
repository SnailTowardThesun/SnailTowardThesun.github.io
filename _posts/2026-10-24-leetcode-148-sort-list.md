---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.148: 排序链表"
categories: LeetCode
tags: [中等, 链表, 归并排序, 分治]
---

> 对数组，快排常凭原地划分压归并一头；换到链表攻守易形——没有随机访问，划分失去支点，而归并只需顺序推进，合并阶段改改指针就完成，连辅助数组都不需要。

## 题目

LeetCode 148. Sort List（排序链表）

Difficulty: **Medium**

给你链表的头结点 `head`，请将其按**升序**排列并返回排序后的链表。

进阶：你可以在 `O(n log n)` 时间复杂度和常数级空间复杂度下，对链表进行排序吗？

提示：链表中节点的数目在范围 `[0, 5 * 10^4]` 内；`-10^5 <= Node.val <= 10^5`。

### 示例

```
输入：head = [4,2,1,3]
输出：[1,2,3,4]

输入：head = [-1,5,3,4,0]
输出：[-1,0,3,4,5]

输入：head = []
输出：[]
```

## 解题思路

### 为什么是归并

链表排序的天选算法是归并排序：链表不支持随机访问，快排"按下标取支点、双向划分"的核心动作无从谈起；而归并全程只做 `next` 顺序推进。更妙的是，数组归并需要 `O(n)` 辅助数组来暂存，链表归并只改指针就能把两段链在一起，合并本身是 `O(1)` 额外空间——代价只剩递归栈。

### 三步走

1. **切分**：快慢指针找中点，`slow` 每两轮前进一格，`fast` 到尾时 `slow` 恰停在前半段最后一个节点，`slow.next = None` 把链一分为二；
2. **递归**：左右两半各自 `doSort`，直到长度 ≤ 1 天然有序；
3. **归并**：哑节点 + 双指针，每轮取较小者接上，一段耗尽后把另一段余下的整段接走。

### 快慢指针的 n=2 陷阱

这题最容易翻车的是切分。若 `fast` 与 `slow` 同起点、每两轮推进 `slow` 一次，n=2 时 `slow` 会停在**第 2 个**节点——从它后面切开，左半边是整条链表，右半边是空，`doSort` 拿到一模一样的输入无限递归。解法只需一行：**`fast` 先迈出一步**（`fast = head.next`）。这样 `slow` 少走一步，各规模切分点都正确：n=2 → 1+1，n=3 → 2+1，n=4 → 2+2，n=5 → 3+2。

### 复杂度分析

时间 `O(n log n)`：每层归并共遍历 n 个节点，共 `log n` 层。空间 `O(log n)`：递归栈深度。题目进阶要求 `O(1)` 空间，需改用**自底向上**迭代归并——从长度 1 的段开始两两合并、段长逐层翻倍，省去递归。

## 代码实现

```python
from leetcode_common import ListNode


class Solution:
    def sortList(self, head: ListNode | None) -> ListNode | None:

        def doSort(head):
            if head is None or head.next is None:
                return head

            # 快慢指针找中点：fast 先走一步，slow 每两轮前进一格
            slow = head
            fast = head.next
            step = 0
            while fast is not None:
                fast = fast.next
                if step > 0:
                    step = 0
                    slow = slow.next
                else:
                    step += 1
            pre_slow = slow.next  # 右半段头
            slow.next = None      # 切断，左半段收尾

            sort_pre = doSort(head)
            sort_last = doSort(pre_slow)

            # 哑节点 + 双指针归并两段有序链表
            pp = sort_pre
            lp = sort_last

            ret = ListNode()
            pr = ret

            while pp is not None and lp is not None:
                if pp.val < lp.val:
                    pr.next = pp
                    pp = pp.next
                else:
                    pr.next = lp
                    lp = lp.next

                pr = pr.next
            while pp is not None:
                pr.next = pp
                pp = pp.next
                pr = pr.next
            while lp is not None:
                pr.next = lp
                lp = lp.next
                pr = pr.next

            return ret.next

        return doSort(head)
```

### 代码解析

- **`fast = head.next` 是正确性关键**：保证 n=2 时 `slow` 停在第 1 个节点，从中间切开；若同起点启动则左半边永远是整条链表，直接 `RecursionError`；
- **`step` 乒乓计数**：`step` 在 0/1 间交替，`fast` 每走两格 `slow` 才走一格，等价于经典的 `fast = fast.next.next` 双步写法，但每轮只动一格；
- **`pr = pr.next` 必须紧跟每次 `pr.next = ...`**：否则 `pr` 永远停在哑节点上，每次接链都在覆盖 `ret.next`，前面接好的节点全部丢失；
- **哑节点 `ret`**：归并结果的头节点不确定，挂个哨兵让"接第一个节点"与后续节点处理完全一致，最后返回 `ret.next`。

## 测试用例

```python
# 官方示例 + 空链表
assert to_list(solution.sortList(build_list([4, 2, 1, 3]))) == [1, 2, 3, 4]
assert to_list(solution.sortList(build_list([-1, 5, 3, 4, 0]))) == [-1, 0, 3, 4, 5]
assert solution.sortList(build_list([])) is None

# 单元素、已有序、逆序、两元素、含重复值
assert to_list(solution.sortList(build_list([1]))) == [1]
assert to_list(solution.sortList(build_list([5, 4, 3, 2, 1]))) == [1, 2, 3, 4, 5]
assert to_list(solution.sortList(build_list([2, 1]))) == [1, 2]  # n=2：切分陷阱
assert to_list(solution.sortList(build_list([3, 1, 2, 3, 1]))) == [1, 1, 2, 3, 3]
```

完整测试另含官方上限规模压测：固定随机种子的 5000 个值与内置 `sorted` 对拍，以及 1000 个全等值节点（重复值压力）——正是这两类规模用例能稳定暴露切分死循环与丢节点问题。

## 总结

- 链表排序选归并：无随机访问淘汰快排，指针拼接让合并阶段零辅助空间；
- 快慢指针切分务必让 `fast` 先走一步，否则 n=2 时切分退化成整条链，无限递归；
- 归并接链后 `pr` 立即后移、哑节点统一头部处理，是链表 dummy 技巧的标准应用。
