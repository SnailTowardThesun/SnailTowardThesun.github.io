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

### 解法一：最小堆多路归并

1. 把所有非空链表的头节点放入最小堆（按节点值排序）。
2. 每次取出堆顶接到结果尾部；若该节点有后继，把后继入堆。
3. 堆中始终不超过 k 个节点，堆空则合并完成。

哨兵节点 node 省去对头节点的特判。

### 解法二：顺序两两合并

Top 150 重刷这题时的另一种写法：不维护堆，从第一条链表开始，把后面的链表逐条用「哑节点 + 双指针」归并进结果——归并两条有序链表是第 21 题的原语，k 条链表就是把这个原语顺序用 k-1 次。

两个实现细节：哑节点省掉头节点特判；每次 `ph.next = ...` 接上节点后 `ph` 必须**立即后移**，否则指针永远停在哑节点上，每次赋值都在覆盖同一个 `next`，前面接好的节点会全部丢失。

### 复杂度分析

- **解法一（最小堆）**：时间 O(k + N log(k+1))，N 为总节点数；先扫描 k 个表头，再处理每个节点。空间 O(k)。此写法也覆盖 k 为 0/1 或全空链表的边界。
- **解法二（顺序两两合并）**：时间 O(k + kN)，空间 O(1)。前面的节点可能被反复遍历；即使 N ≤ 10⁴，在大量短链表时也可能很慢。大规模输入宜采用最小堆或两两分治合并。

## 代码实现

两个面板是**两种解法**：C++ 为最小堆多路归并，Python 为顺序两两合并，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt23-cpp" name="lt23" checked>
  <input type="radio" id="lt23-py" name="lt23">
  <div class="lang-tab-nav">
    <label for="lt23-cpp">C++</label>
    <label for="lt23-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
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
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
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
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- **C++ 版（解法一）**：比较器用 `a->val > b->val`，priority_queue 默认是大顶堆，反向比较得到小顶堆。
- **Python 版（解法二）**：哑节点 + 双指针归并是第 21 题的原语；注意 `ph.next = ...` 接上节点后 `ph` 必须立即后移，否则每次赋值都在覆盖哑节点的同一个 `next`。

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

```python
from leetcode_common import build_list, to_list


def test_solution() -> None:
    solution = Solution()
    for rows in ([], [[]], [[1, 4, 5], [1, 3, 4], [2, 6]], [[-2, 0], [], [-3, 5]], [[1], [1]]):
        lists = [build_list(row) for row in rows]
        assert to_list(solution.mergeKLists(lists)) == sorted(value for row in rows for value in row)
```

## 总结

1. 解法一（最小堆）：小顶堆维护每条链表当前最小节点，弹出后补后继直到堆空，时间 O(k + N log(k+1))、空间 O(k)；
2. 解法二（顺序两两合并）：逐条归并，时间 O(k + kN)、空间 O(1)，适合少量链表的对照实现；
3. k 很大时采用堆或两两分治合并，避免反复扫描已经合并的长链表。
