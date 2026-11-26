---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3360: 移除石头游戏"
categories: LeetCode
tags: [简单, 模拟, 数学]
---

> 每一手要取的数量都由上一手决定。石头总数只影响游戏在哪一手停止，因此胜负可以从成功取石的次数看出来。

## 题目

Alice 先手，和 Bob 轮流从同一堆石头中取石。Alice 第一手要取 10 颗，以后每手都要比上一手少取 1 颗。轮到某人时，若剩余石头不足，就由该玩家输掉游戏。初始石头数 `n` 在 1 到 50 之间，判断 Alice 能否获胜。[LeetCode 3360. Stone Removal Game（简单）](https://leetcode.cn/problems/stone-removal-game/description/)

### 示例

```text
n = 12 → True。Alice 取走 10 颗后剩 2 颗，Bob 无法取 9 颗。
n = 1  → False。Alice 第一手就取不够 10 颗。
```

## 解题思路

用 `take` 记录本手必须取的石头数，初始为 10。剩余石头足够时，扣掉 `take`，把下一手的取石数减一，并给成功手数 `moves` 加一。轮到 Alice 时，之前两人各完成了相同的手数，所以 `moves` 为偶数。轮到 Bob 时，Alice 比他多完成一手，所以 `moves` 为奇数。循环在当前玩家无法继续时结束，因此只要看 `moves` 是否为奇数就知道 Alice 是否赢了。

例如，18 颗和 19 颗石头只差一颗，却足以改变胜负。18 颗时，Alice 取走 10 颗，Bob 面前只剩 8 颗。19 颗时，Bob 刚好能取走 9 颗，轮到 Alice 时已无石可取。判断能否出手要用 `n >= take`，这样刚好取尽也算成功。

### 复杂度分析

前七手总共消耗 `10 + 9 + 8 + 7 + 6 + 5 + 4 = 49` 颗，完成第八手要累计 52 颗。给定的 50 颗上限只允许最多七手成功，时间和额外空间都是 `O(1)`。

## 代码实现

C++ 和 Python 都只记录剩余石数、本手取石数和已完成手数。

<div class="lang-tabs">
  <input type="radio" id="lt3360-cpp" name="lt3360-lang" checked>
  <input type="radio" id="lt3360-py" name="lt3360-lang">
  <div class="lang-tab-nav">
    <label for="lt3360-cpp">C++</label>
    <label for="lt3360-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    bool canAliceWin(int n) {
        int take = 10;
        int moves = 0;
        while (take > 0 && n >= take) {
            n -= take;
            --take;
            ++moves;
        }
        return moves % 2 == 1;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def canAliceWin(self, n: int) -> bool:
        take = 10
        moves = 0
        while take > 0 and n >= take:
            n -= take
            take -= 1
            moves += 1
        return moves % 2 == 1
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

`moves` 只在成功取石之后递增。比如开局少于 10 颗时，循环一次也不执行，此时 `moves = 0`，自然得到 Alice 失败。

## 测试用例

可以用累计石数独立核对模拟。前八手的累计数依次为 10、19、27、34、40、45、49、52。Alice 取完奇数手、Bob 无法再取一手时，Alice 获胜，对应以下四段整数范围。

```python
solution = Solution()
for n in range(1, 51):
    alice_wins = 10 <= n < 19 or 27 <= n < 34 or 40 <= n < 45 or 49 <= n <= 50
    assert solution.canAliceWin(n) == alice_wins, n
```

## 总结

每成功一手，下一手需要的石头减一，玩家也随之交换。找到第一手取不够的位置，胜负就确定了。
