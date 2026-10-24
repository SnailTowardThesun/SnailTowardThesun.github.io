---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.23: 合并K个升序链表"
categories: LeetCode
tags: [困难, 链表, 堆, 分治]
---

> 最小堆始终维护 k 条链表的当前最小节点，每弹出一个就补上它的后继——多路归并的标准实现。

## 题目

LeetCode 23. Merge k Sorted Lists（合并 K 个升序链表）

Difficulty: **Hard**

给你一个链表数组，每条链表都已升序排列。合并所有链表并返回升序结果。

### 示例

```
输入：lists = [[1,4,5],[1,3,4],[2,6]]
输出：[1,1,2,3,4,4,5,6]
```

## 解题思路

### 最小堆多路归并

1. 把所有非空链表的头节点放入最小堆（按节点值排序）。
2. 每次取出堆顶接到结果尾部；若该节点有后继，把后继入堆。
3. 堆中始终不超过 k 个节点，堆空则合并完成。

哨兵节点 node 省去对头节点的特判。

### 复杂度分析

- **时间复杂度**：O(N log k)，N 为总节点数，每个节点入堆出堆一次。
- **空间复杂度**：O(k)。

## 代码实现

```cpp
class Solution {
public:
    ListNode* mergeKLists(vector<ListNode*>& lists) {
        if (lists.empty()) return nullptr;

        ListNode node(0), *res = &node;
        auto cmp = [](const ListNode* a, const ListNode* b) { return a->val > b->val; };
        priority_queue<ListNode*, vector<ListNode*>, decltype(cmp)> que(cmp);

        for (auto head : lists) {
            if (head) que.push(head);
        }

        while (!que.empty()) {
            ListNode* p = que.top();
            que.pop();
            res->next = p;
            res = p;
            if (p->next) que.push(p->next);
        }
        return node.next;
    }
};
```

### 代码解析

- 比较器用 `a->val > b->val`，priority_queue 默认是大顶堆，反向比较得到小顶堆。

## 解法二：顺序两两合并（Python）

Top 150 重刷这题时的另一种写法：不维护堆，从第一条链表开始，把后面的链表逐条用「哑节点 + 双指针」归并进结果——归并两条有序链表是第 21 题的原语，k 条链表就是把这个原语顺序用 k-1 次。

两个实现细节：哑节点省掉头节点特判；每次 `ph.next = ...` 接上节点后 `ph` 必须**立即后移**，否则指针永远停在哑节点上，每次赋值都在覆盖同一个 `next`，前面接好的节点会全部丢失。

```python
from leetcode_common import ListNode


class Solution:
    def mergeKLists(self, lists: list[ListNode | None]) -> ListNode | None:
        def mergeLists(l1, l2):
            head = ListNode()
            ph = head
            p1 = l1
            p2 = l2
            while p1 is not None and p2 is not None:
                if p1.val < p2.val:
                    ph.next = p1
                    p1 = p1.next
                else:
                    ph.next = p2
                    p2 = p2.next

                ph = ph.next
            while p1 is not None:
                ph.next = p1
                p1 = p1.next
                ph = ph.next
            while p2 is not None:
                ph.next = p2
                p2 = p2.next
                ph = ph.next

            return head.next

        if len(lists) == 0:
            return None

        ret = lists[0]
        for i in range(1, len(lists)):
            ret = mergeLists(ret, lists[i])
        return ret
```

复杂度：时间 O(k²·n)（k 条平均长度 n 的链表，顺序合并的最坏情形），空间 O(1)。官方约束总结点 N ≤ 10⁴ 下完全够用；若 k 很大（上万条单节点链表这种极端分布），两两分治合并或上面的最小堆可降到 O(N log k)。

## 测试用例

```cpp
TEST(Daily, 23) {
    Solution s;
    ListNode* l1 = buildList({1, 4, 5});
    ListNode* l2 = buildList({1, 3, 4});
    ListNode* l3 = buildList({2, 6});
    vector<ListNode*> lists = {l1, l2, l3};
    ListNode* result = s.mergeKLists(lists);
    EXPECT_EQ(result->next->next->val, 2);
}
```

## 总结

1. 小顶堆维护每条链表当前最小节点；
2. 弹出后补后继，直到堆空；
3. 时间 O(N log k)，空间 O(k)。
