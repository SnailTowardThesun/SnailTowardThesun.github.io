---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.202: 快乐数"
categories: LeetCode
---

> 快慢指针判圈法源自弗洛伊德的循环检测算法，它同样用于检测链表环与重复序列。

## 题目

LeetCode 202. Happy Number（快乐数）

Difficulty: **Easy**

编写一个算法来判断一个数 `n` 是不是**快乐数**。

快乐数定义为：

- 对于一个正整数，每一次将该数替换为它每个位置上的数字的平方和；
- 然后重复这个过程直到这个数变为 1，也可能是**无限循环但始终变不到 1**；
- 如果这个过程的结果为 1，那么这个数就是快乐数。

如果 `n` 是快乐数就返回 `true`；不是则返回 `false`。

### 示例

```
输入：n = 19
输出：true
解释：
1² + 9² = 82
8² + 2² = 68
6² + 8² = 100
1² + 0² + 0² = 1

输入：n = 2
输出：false
解释：平方和会在 4, 16, 37, 58, 89, 145, 42, 20 中无限循环。
```

## 解题思路

### 快慢指针（弗洛伊德判圈法）

题目的难点在"无限循环"：非快乐数的平方和序列会陷入死循环，朴素模拟无法终止。

关键洞察：**平方和序列的结构与"链表"完全同构**——`helper(n)` 就是链表的 `next` 指针。序列要么最终停在 1（链表有终点），要么进入环（链表有环）。判断链表是否有环的经典解法就是快慢指针：

1. `slow` 每次走一步（调用一次 `helper`），`fast` 每次走两步（调用两次 `helper`）；
2. 若序列收敛到 1：1 的平方和还是 1，`fast` 与 `slow` 在 1 处相遇；
3. 若序列有环：`fast` 会在环内追上 `slow`；
4. 相遇时判断 `slow == 1` 即可区分两种情况。

以 `n = 2` 为例：序列 `2 → 4 → 16 → 37 → 58 → 89 → 145 → 42 → 20 → 4` 形成环，快慢指针在环内相遇且值不为 1，返回 false。

### 复杂度分析

- **时间复杂度**：O(log n)，数位平方和下降极快（大数一步掉到三位数以内），判圈步数为常数级。
- **空间复杂度**：O(1)，只用两个指针变量（对比哈希表记录法需要 O(log n) 存储）。

## 代码实现

```cpp
class Solution {
   public:
    bool isHappy(int n) {
        int fast = n;
        int slow = n;

        auto helper = [](int n) {
            int sum = 0;

            while (n > 0) {
                int d = n % 10;
                sum = sum + d * d;
                n = n / 10;
            }

            return sum;
        };

        do {
            slow = helper(slow);
            fast = helper(fast);
            fast = helper(fast);
        } while (fast != slow);

        return slow == 1;
    }
};
```

### 代码解析

- **`do-while` 而非 `while`**：初始时 `fast == slow`，若用 `while` 条件判断循环体一次都不执行；`do-while` 保证先走再判。
- **lambda 即 next**：`helper` 捕获为空，纯函数地完成"取数位平方和"，语义上就是链表的 `next`。
- **无需哈希集合**：相比"用 set 记录见过的数"的解法，快慢指针把空间从 O(log n) 降到 O(1)。

## 测试用例

```cpp
TEST(top150, 202) {
    Solution s;
    auto n = 19;
    auto ret = s.isHappy(n);
    EXPECT_EQ(ret, true);
}
```

## 总结

1. 平方和序列 = 隐式链表，循环 = 环，直接套弗洛伊德判圈；
2. `do-while` 处理初值相等的细节；
3. 时间 O(log n)、空间 O(1)，优于哈希集合记录法。
