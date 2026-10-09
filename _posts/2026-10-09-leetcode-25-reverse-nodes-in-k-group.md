---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.25: K 个一组翻转链表"
categories: LeetCode
---

> 链表分组翻转是字节跳动、谷歌等大厂的高频面试题，考察指针操作与边界处理的双重功力。

## 题目

LeetCode 25. Reverse Nodes in k-Group（K 个一组翻转链表）

Difficulty: **Hard**

给你链表的头节点 `head`，每 `k` 个节点一组进行翻转，请你返回修改后的链表。

- `k` 是一个正整数，它的值小于或等于链表的长度；
- 如果节点总数不是 `k` 的整数倍，那么请将最后剩余的节点保持原有顺序；
- 进阶：你可以设计一个只用 O(1) 额外内存空间的算法解决此问题吗？

### 示例

```
输入：head = [1,2,3,4,5], k = 2
输出：[2,1,4,3,5]

输入：head = [1,2,3,4,5], k = 3
输出：[3,2,1,4,5]
```

## 解题思路

### 数组化 + 分组反转

与其在链表上做复杂的指针穿插，不如换个视角：**先把节点指针收集到数组里**，数组上的"分组翻转"就变成了对一段下标区间的 `reverse` 操作。

1. **收集节点**：一次遍历把所有节点指针存入数组 `nodes`；
2. **分组反转**：从下标 0 开始，每隔 `k` 个一组做反转。注意只翻转完整组：条件是 `i + k <= n`，这样末尾不足 `k` 的部分天然保持原序；
3. **重新串联**：反转后依次执行 `nodes[i]->next = nodes[i+1]`，末节点 `next` 置空；
4. **返回新头**：`nodes[0]` 即翻转后的头节点。

以 `[1,2,3,4,5], k = 3` 为例：数组收集后为 `[1,2,3,4,5]`；下标 0~2 是完整组，反转为 `[3,2,1,4,5]`；下标 3~4 不足 3 个，保持原序；重连后得到 `3->2->1->4->5`。

### 复杂度分析

- **时间复杂度**：O(n)，收集、反转、重连各一遍。
- **空间复杂度**：O(n)，用于存储节点指针数组（进阶解法可做到 O(1)）。

## 代码实现

```cpp
class Solution {
   public:
    ListNode* reverseKGroup(ListNode* head, int k) {
        vector<ListNode*> nodes;
        ListNode* cur = head;
        while (cur) {
            nodes.emplace_back(cur);
            cur = cur->next;
        }

        int n = nodes.size();
        if (n == 0) {
            return nullptr;
        }
        // 只翻转完整的组，末尾不足 k 的部分保持原顺序
        for (int i = 0; i + k <= n; i += k) {
            reverse(nodes.begin() + i, nodes.begin() + i + k);
        }

        for (int i = 0; i + 1 < n; i++) {
            nodes[i]->next = nodes[i + 1];
        }
        nodes[n - 1]->next = nullptr;

        return nodes[0];
    }
};
```

### 代码解析

- **`i + k <= n` 是灵魂**：保证每次反转的区间不越界，末尾残组自然跳过；注释里特别提醒"越界 reverse 会读到野指针"。
- **空表防御**：`n == 0` 直接返回 `nullptr`，避免后面 `nodes[n-1]` 越界。
- **重连一步到位**：数组顺序即目标顺序，逐个接 `next` 比在链表上穿针引线清晰得多。

## 测试用例

```cpp
TEST(Daily, 25) {
    Solution s;

    // k=3，长度 5：前 3 个翻转，末尾 2 个保持原样 -> 3->2->1->4->5
    auto ret = s.reverseKGroup(make_list({1, 2, 3, 4, 5}), 3);
    for (int v : {3, 2, 1, 4, 5}) {
        ASSERT_NE(ret, nullptr);
        EXPECT_EQ(ret->val, v);
        ret = ret->next;
    }
    EXPECT_EQ(ret, nullptr);

    // k=1：等价于不翻转
    ret = s.reverseKGroup(make_list({1, 2, 3}), 1);
    for (int v : {1, 2, 3}) {
        ASSERT_NE(ret, nullptr);
        EXPECT_EQ(ret->val, v);
        ret = ret->next;
    }
    EXPECT_EQ(ret, nullptr);

    // 长度恰为 k 的倍数：全部翻转
    ret = s.reverseKGroup(make_list({1, 2, 3, 4}), 2);
    for (int v : {2, 1, 4, 3}) {
        ASSERT_NE(ret, nullptr);
        EXPECT_EQ(ret->val, v);
        ret = ret->next;
    }
    EXPECT_EQ(ret, nullptr);

    // 边界：空链表
    EXPECT_EQ(s.reverseKGroup(nullptr, 3), nullptr);
}
```

## 总结

1. 数组化是链表题的常用降维手段，区间反转变 `reverse` 一行搞定；
2. `i + k <= n` 保证只翻完整组，末尾残组保持原序；
3. 时间 O(n)、空间 O(n)，进阶可写原地穿针 O(1) 版本。
