---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2130: Maximum Twin Sum of a Linked List"
categories: LeetCode
---

> 孪生链表的结构与字符串回文检测异曲同工——都将序列的对称性发挥到极致，只不过链表版本的"镜像翻转"通过指针反转而非数组索引来实现。

## 题目

LeetCode 2130. Maximum Twin Sum of a Linked List（链表最大孪生和）

Difficulty: **Medium**

在一个大小为 n 且 n 为偶数的链表中，对于满足 `0 <= i <= n/2 - 1` 的 i，第 i 个节点（从 0 开始计数）的孪生节点是第 (n-1-i) 个节点。

例如：链表有 4 个节点时，索引为 0 和 3 互为孪生，索引为 1 和 2 互为孪生。

请你返回链表中所有节点的最大孪生和。

### 示例

**示例 1：**
```
输入：head = [5,4,2,1]
输出：6
解释：节点 0 和节点 3 互为孪生，和为 5+1=6；节点 1 和节点 2 互为孪生，和为 4+2=6。最大值为 6。
```

**示例 2：**
```
输入：head = [4,2,2,3]
输出：7
解释：最大孪生和为 4+3=7。
```

**示例 3：**
```
输入：head = [1,100000]
输出：100001
解释：只有两个节点互为孪生，和为 1+100000=100001。
```

## 解题思路

本题的核心挑战在于**链表不支持随机访问**，无法像数组那样直接通过索引找到孪生节点。最优解法采用经典的**快慢指针 + 链表反转**技巧：

### 核心思路

1. **快慢指针找中点**：利用 `fast` 每次走两步、`slow` 每次走一步的速度差，当 `fast` 到达末尾时，`slow` 恰好指向链表中点
2. **反转后半段链表**：将中点之后的节点原地反转，时间复杂度 O(1) 额外空间
3. **双指针同步遍历**：从头节点和反转后的后半段同时向后移动，计算每对孪生节点的孪生和
4. **取最大值**：维护并返回所有孪生和的最大值

### 算法详解

以示例 `head = [5,4,2,1]` 为例（链表长度为 4）：

```
初始状态:    5 → 4 → 2 → 1 → NULL
              ↑           ↑
            slow         fast (start)

Step 1:      slow=4,     fast=2 (fast走了两步到节点2)
Step 2:      slow=2,     fast=NULL (fast到达末尾，停止)

反转后半段（从slow指向的节点开始）:
原后半段:    2 → 1 → NULL
反转后:      1 → 2 → NULL
             ↑     ↑
           prev   null

同步遍历计算孪生和:
head(5) + prev(1) = 6
next(4) + next-of-prev(2) = 6
最大孪生和 = max(6, 6) = 6
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int pairSum(ListNode *head) {
        // Step 1: Find the middle using slow/fast pointers
        ListNode* slow = head;
        ListNode* fast = head;
        while (fast != NULL && fast->next != NULL) {
            slow = slow->next;
            fast = fast->next->next;
         }

         // Step 2: Reverse the second half in-place
        ListNode* prev = NULL;
        ListNode* curr = slow;
        while (curr != NULL) {
            ListNode* nextNode = curr->next;
            curr->next = prev;
            prev = curr;
            curr = nextNode;
         }

         // Step 3: Traverse both halves to find max twin sum
        int maxSum = 0;
        ListNode* left = head;
        ListNode* right = prev;
        while (right != NULL) {
            maxSum = max(maxSum, left->val + right->val);
            left = left->next;
            right = right->next;
         }

        return maxSum;
     }
};
```
{% endraw %}

## 复杂度分析

- **时间复杂度**：O(n)，其中 n 是链表的节点数。快慢指针遍历 O(n/2)，反转链表 O(n/2)，同步遍历计算孪生和 O(n/2)，合计仍为 O(n)
- **空间复杂度**：O(1)，原地反转链表，只使用常数额外空间（三个指针变量）

## 测试用例

```cpp
TEST(Daily, 2130) {
    Solution s;
    
    // Test case 1: [5,4,2,1] => twin sums: 5+1=6, 4+2=6 => max=6
    ListNode* head1 = new ListNode(5);
    head1->next = new ListNode(4);
    head1->next->next = new ListNode(2);
    head1->next->next->next = new ListNode(1);
    EXPECT_EQ(s.pairSum(head1), 6);
    
    // Test case 2: [4,2,2,3] => twin sums: 4+3=7, 2+2=4 => max=7
    ListNode* head2 = new ListNode(4);
    head2->next = new ListNode(2);
    head2->next->next = new ListNode(2);
    head2->next->next->next = new ListNode(3);
    EXPECT_EQ(s.pairSum(head2), 7);
    
    // Test case 3: [1,100000] => twin sum: 1+100000=100001
    ListNode* head3 = new ListNode(1);
    head3->next = new ListNode(100000);
    EXPECT_EQ(s.pairSum(head3), 100001);
}
```

## 总结

本题是链表操作的经典问题，核心考察了两个关键技术：快慢指针定位中点、原地反转链表。通过将原问题转化为"前半段 vs 反转后半段"的同步遍历，巧妙地将空间复杂度从 O(n) 优化到 O(1)。这种模式在回文链表检测（LeetCode 234）等类似问题中也经常出现，值得熟练掌握。
