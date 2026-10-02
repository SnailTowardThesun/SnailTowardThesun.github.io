---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.23: 合并K个升序链表"
categories: LeetCode
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
