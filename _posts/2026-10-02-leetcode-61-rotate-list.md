---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.61: 旋转链表"
categories: LeetCode
---

> 链表右转 k 位等价于把后 k 个节点整体挪到头部。先对长度取模去掉整圈旋转，再找切断点重连。

## 题目

LeetCode 61. Rotate List（旋转链表）

Difficulty: **Medium**

给定链表，将每个节点向右移动 k 个位置，k 非负。

### 示例

```
输入：head = [1,2,3,4,5], k = 2
输出：[4,5,1,2,3]

输入：head = [0,1,2], k = 4
输出：[2,0,1]
```

## 解题思路

### 数组辅助 / 环形切断

源文件实现（数组辅助）：
1. 遍历链表把节点值存入数组。
2. 实际旋转步数为 `n - k % n`，即新数组的切点。
3. 把后半段拼到前半段之前，按新顺序重建链表。

经典指针做法：先求长度 n 并将尾节点接到头形成环，再向前走 `n - k % n` 步找到新尾部，断开环即可，空间 O(1)。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(n)（数组辅助版）；指针环形版为 O(1)。

## 代码实现

```cpp
class Solution {
public:
    ListNode* rotateRight(ListNode* head, int k) {
        if (head == nullptr) return head;

        vector<int> container;
        for (auto it = head; it != nullptr; it = it->next) {
            container.push_back(it->val);
        }

        auto steps = container.size() - k % container.size();
        vector<int> ret_container;
        ret_container.insert(ret_container.begin(),
                             container.begin() + steps, container.end());
        ret_container.insert(ret_container.end(),
                             container.begin(), container.begin() + steps);

        ListNode dummy(0), *pos = &dummy;
        for (int v : ret_container) {
            pos->next = new ListNode(v);
            pos = pos->next;
        }
        return dummy.next;
    }
};
```

### 代码解析

- `k % n` 去掉整圈，`n - k%n` 是左半段长度。
- 空链表提前返回，否则取模会除零。

## 测试用例

```cpp
TEST(Daily, 61) {
    Solution s;
    ListNode head(1);
    head.next = new ListNode(2);
    head.next->next = new ListNode(3);
    head.next->next->next = new ListNode(4);
    head.next->next->next->next = new ListNode(5);
    auto ret = s.rotateRight(&head, 2);
    EXPECT_EQ(4, ret->val);
}
```

## 总结

1. 先对长度取模，旋转整圈等于没转；
2. 本质是把后 k 个节点挪到前面；
3. 环形指针做法可做到 O(1) 空间。
