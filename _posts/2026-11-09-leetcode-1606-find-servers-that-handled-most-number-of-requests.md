---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1606: 找到处理最多请求的服务器"
categories: LeetCode
tags: [困难, 数组, 堆, 模拟]
---

> 轮询加环形搜索是最朴素的负载均衡策略，Nginx 的 round-robin 是它的近亲。本题巧在「编号重定位」：归还服务器时顺手改键，让小根堆自己记住从哪里绕，一次弹出完成环形搜索。

## 题目

LeetCode 1606. Find Servers That Handled Most Number of Requests（找到处理最多请求的服务器）

Difficulty: **Hard**

你有 `k` 个服务器，编号为 `0` 到 `k-1`，它们可以同时处理多个请求组。每个服务器有无穷的计算能力但是**不能同时处理超过一个请求**。请求分配到服务器的规则如下：

- 第 `i`（序号从 0 开始）个请求到达；
- 如果所有服务器都已被占据，那么该请求被舍弃（完全不处理）；
- 如果第 `(i % k)` 个服务器空闲，那么对应服务器会处理该请求；
- 否则，将请求安排给下一个空闲的服务器（服务器构成一个环，必要的话可能从第 0 个服务器开始继续找下一个空闲的服务器）。

给你一个**严格递增**的正整数数组 `arrival`，表示第 `i` 个任务的到达时间；和数组 `load`，其中 `load[i]` 表示第 `i` 个请求的工作量（服务器完成它所需的时间）。返回包含所有**最繁忙服务器**序号的列表（按编号升序），最繁忙定义为处理的请求数最多。

约束：

- `1 <= k <= 10^5`
- `1 <= arrival.length == load.length <= 10^5`
- `1 <= arrival[i], load[i] <= 10^9`
- `arrival` 严格递增

### 示例

```text
输入：k = 3, arrival = [1,2,3,4,5], load = [5,2,3,3,3]
输出：[1]
解释：前 3 个请求由服务器 0/1/2 依次处理；请求 3 到达时服务器 1 已空闲，接力
处理（共 2 个）；请求 4 到达时全部繁忙，被舍弃。服务器 1 最忙。
```

```text
输入：k = 3, arrival = [1,2,3,4,8,9,10], load = [5,2,10,3,1,2,2]
输出：[1]
```

## 解题思路

### 朴素做法为什么不行

每个请求从 `i % k` 开始逐个试服务器，最坏要扫完整个环：单次 `O(k)`，总共 `O(n·k)`，在 `n = k = 10^5` 的规模下不可接受。瓶颈有两个：**找环形第一个空闲服务器**和**找最早完成的服务器**——两者都指向堆。

### 双小根堆 + 编号重定位

1. **忙碌堆 busy**：按 `(结束时间, 编号)` 组织的小根堆。请求 `i` 在时刻 `arrival[i]` 到达时，先把所有结束时间 `<= arrival[i]` 的服务器弹出归还空闲堆；
2. **关键技巧——编号重定位**：归还编号为 `j` 的服务器时，不直接存 `j`，而是存键 `i + (j - i) % k`——即 `>= i` 且与 `j` 同余 `(mod k)` 的最小值。这样空闲堆里所有键的大小顺序就等于"从 `i % k` 开始环形搜索"的先后顺序，堆顶弹出后对 `k` 取模即还原真实编号；
3. 空闲堆为空则该请求被丢弃；否则弹出堆顶，把 `(到达时间 + 耗时, 编号)` 压入忙碌堆并给该服务器计数；
4. 最后取计数最大值，所有等于最大值的编号即答案。`k > n` 时每个请求各占一台空闲服务器，编号 `0..n-1` 全部并列，直接返回。

为什么不能直接用小编号堆？环形搜索的**起点随 `i` 变化**：比如空闲服务器 `{0, 2}`、当前请求 `i % k = 2`，正确答案是服务器 2（它自己就是起点），而普通最小堆会给出全局最小编号 0。重定位后服务器 2 的键为 `i + 0`、服务器 0 的键为 `i + (0 - i) % k > i`，堆顶自然落在服务器 2 上。

### 手算示例 1（k = 3）

- 请求 0（t=1，耗时 5）：空闲堆 `{0,1,2}` 弹出 0，服务器 0 处理到时刻 6；
- 请求 1（t=2）：弹出 1，处理到时刻 4；
- 请求 2（t=3）：弹出 2，处理到时刻 6；
- 请求 3（t=4）：服务器 1 恰在时刻 4 完成，归还——重定位键 `3 + (1-3) % 3 = 4`；弹出键 4，还原编号 1，接力处理到时刻 7；
- 请求 4（t=5）：无人完成（0、2 都到时刻 6），空闲堆空，丢弃；
- 计数 `[1,2,1]`，答案 `[1]`。

### 复杂度分析

- 时间复杂度：`O((n + k) log k)`——每台服务器每次空闲/忙碌进出堆各一次；
- 空间复杂度：`O(k)`——两个堆与计数数组（忙碌堆至多同时存 `k` 个元素）。

## 代码实现

C++ 与 Python 逻辑一一对应，唯一的语义差异在取模：Python 的 `%` 对负数返回非负结果，C++ 是截断取余，重定位键必须显式修正，点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt1606-cpp" name="lt1606" checked>
  <input type="radio" id="lt1606-py" name="lt1606">
  <div class="lang-tab-nav">
    <label for="lt1606-cpp">C++</label>
    <label for="lt1606-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    vector<int> busiestServers(int k, vector<int>& arrival, vector<int>& load) {
        int n = arrival.size();
        vector<int> ret;
        // 特例：服务器多于请求数，每个请求各占一台，编号 0..n-1 全部并列
        if (k > n) {
            for (int i = 0; i < n; i++) {
                ret.emplace_back(i);
            }
            return ret;
        }

        // 空闲堆：存「重定位后」的编号，堆顶即环形搜索遇到的第一个空闲服务器
        priority_queue<int, vector<int>, greater<int>> idle;
        for (int i = 0; i < k; i++) {
            idle.push(i);
        }

        // 忙碌堆：(结束时间, 编号)，堆顶是最早空闲的
        priority_queue<vector<int>, vector<vector<int>>, greater<vector<int>>> busy;
        vector<int> cnt(k, 0);

        for (int i = 0; i < n; i++) {
            int time = arrival[i];
            int duration = load[i];

            // 先归还所有在该请求到达前已处理完的服务器
            while (!busy.empty() && busy.top()[0] <= time) {
                auto item = busy.top();
                busy.pop();
                // 重定位为 >= i 且 ≡ j (mod k) 的最小值
                // C++ 负数取余需 +k 再 %k 修正
                idle.push(i + ((item[1] - i) % k + k) % k);
            }

            if (idle.empty()) {
                continue;  // 全部繁忙，丢弃该请求
            }

            int j = idle.top() % k;  // 还原真实服务器编号
            idle.pop();
            busy.push(vector<int>{time + duration, j});
            cnt[j] += 1;
        }

        int mm = *max_element(cnt.begin(), cnt.end());
        for (int i = 0; i < k; i++) {
            if (cnt[i] == mm) {
                ret.emplace_back(i);
            }
        }
        return ret;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
from heapq import heappop, heappush


class Solution:
    def busiestServers(self, k: int, arrival: list[int], load: list[int]) -> list[int]:
        # 特例：服务器多于请求数，编号 0..n-1 全部并列
        if k > len(arrival):
            return list(range(len(arrival)))

        idle = list(range(k))  # 空闲堆：存「重定位后」的编号
        busy = []              # 忙碌堆：(结束时间, 编号)
        cnt = [0] * k

        for i, (t, d) in enumerate(zip(arrival, load)):
            while busy and busy[0][0] <= t:       # 归还已完成的服务器
                _, j = heappop(busy)
                heappush(idle, i + (j - i) % k)   # 重定位键（Python 取模天然非负）

            if not idle:
                continue                          # 全部繁忙，丢弃该请求

            j = heappop(idle) % k                 # 还原真实服务器编号
            heappush(busy, (t + d, j))
            cnt[j] += 1

        mm = max(cnt)
        return [i for i in range(k) if cnt[i] == mm]
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- **重定位技巧是本题的灵魂**：把「从 `i % k` 开始环形搜索」编码进键值——归还的编号 `j` 变成 `>= i` 且同余的最小值后，键序与环形搜索序完全一致，一次堆顶弹出即得正确服务器，省掉了逐个试探的 `O(k)`；
- **C++ 版**必须写 `((j - i) % k + k) % k`：C++/Java 的 `%` 是截断取余，`(j - i)` 为负时结果落在 `(-k, 0]`，直接用会得到「`>= i` 且同余的最大值」之外的混乱键序，空闲令牌被张冠李戴后计数全乱（回归用例专门覆盖这一处，误写 `i + j % k` 会错答 `[2]`）；
- 两个堆分工明确：忙碌堆按 `(结束时间, 编号)` 取最早完成的，空闲堆按重定位键取环形第一个；
- `k > n` 的特判只是短路优化：每个请求各占一台服务器，答案必然是 `[0..n-1]`；
- 结束时间上限 `2 * 10^9 < INT_MAX`，`int` 承载安全。

## 测试用例

覆盖四个官方示例、一处回归（重定位键写错的场景）与两个边界（服务器多于请求、单台串行）：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1：服务器 1 处理 2 个请求 ----
    assert solution.busiestServers(3, [1, 2, 3, 4, 5], [5, 2, 3, 3, 3]) == [1]

    # ---- 官方示例 2：请求 3 时刻服务器 0 恰好空闲，环首接力 ----
    assert solution.busiestServers(3, [1, 2, 3, 4], [1, 2, 1, 2]) == [0]

    # ---- 官方示例 3：三台各处理 1 个请求，全部并列 ----
    assert solution.busiestServers(3, [1, 2, 3], [10, 12, 11]) == [0, 1, 2]

    # ---- 官方示例 4：服务器 1 处理 4 个请求 ----
    assert solution.busiestServers(3, [1, 2, 3, 4, 8, 9, 10], [5, 2, 10, 3, 1, 2, 2]) == [1]

    # ---- 回归用例：空闲编号若未按 (j - i) % k 重定位会错答 [2] ----
    assert solution.busiestServers(3, [1, 2, 3, 4, 8], [1, 5, 5, 1, 1]) == [0, 1]

    # ---- 边界：服务器数多于请求数 ----
    assert solution.busiestServers(5, [1, 2], [3, 4]) == [0, 1]

    # ---- 边界：单台服务器串行处理所有请求 ----
    assert solution.busiestServers(1, [1, 2], [1, 1]) == [0]
```

C++ 侧在 `TEST(Daily, 1606)` 里用同样的 7 组用例断言，`./tests --gtest_filter='Daily.1606*'` 通过。

## 总结

- 「环形搜索第一个空闲服务器」用编号重定位 `i + (j - i) % k` 编码进空闲堆的键，与忙碌堆配合把单请求分配降到 `O(log k)`；
- 跨语言实现要盯紧取模语义：Python 非负取模一步到位，C++/Java 截断取余必须 `+k` 修正；
- 弱断言（只查 `size == 1`）会让逻辑 bug 漏网，回归用例 + 精确值断言才能锁住重定位技巧的正确性。
