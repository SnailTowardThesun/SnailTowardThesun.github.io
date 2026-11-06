---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2747: 统计没有收到请求的服务器数目"
categories: LeetCode
tags: [中等, 数组, 排序, 双指针, 滑动窗口, 哈希表]
---

> 「离线处理」是算法里常见的时空魔法：把查询按自己的顺序排好再统一回答，往往能把在线做法的 O(n·q) 降到 O((n+q)·log n)。数据库的物化视图、CDN 的边缘预计算，都是同款思想。

## 题目

LeetCode 2747. Count Zero Request Servers（统计没有收到请求的服务器数目）

Difficulty: **Medium**

给你一个整数 `n` 表示服务器总数（编号 `1` 到 `n`），和一个二维整数数组 `logs`，其中 `logs[i] = [server_id, time]` 表示编号为 `server_id` 的服务器在 `time` 时刻收到了一个请求。

再给你一个整数 `x` 和一个整数数组 `queries`。在时间区间 `[queries[j] - x, queries[j]`（闭区间）内收到过请求的服务器会承受额外负载。

返回一个长度为 `queries.length` 的数组 `answer`，其中 `answer[j]` 表示第 `j` 个查询的时间区间内**没有收到任何请求**的服务器数目。

约束：

- `1 <= n <= 10^5`
- `1 <= logs.length, queries.length <= 10^5`
- `1 <= logs[i][0] <= n`，`1 <= logs[i][1] <= 10^6`
- `1 <= x <= 10^5`
- `x < queries[j] <= 10^6`

### 示例

```text
输入：n = 3, logs = [[1,3],[2,6],[1,5]], x = 5, queries = [10,11]
输出：[1,2]
解释：
- 查询 10 的区间为 [5, 10]：服务器 1（t=5）和 2（t=6）收到过请求，只有 3 号没有，答案为 1。
- 查询 11 的区间为 [6, 11]：只有服务器 2（t=6）收到过请求，服务器 1 和 3 都没有，答案为 2。
```

```text
输入：n = 3, logs = [[2,4],[2,1],[1,2],[3,1]], x = 2, queries = [3,4]
输出：[0,1]
解释：
- 查询 3 的区间为 [1, 3]：三台服务器都收到过请求，答案为 0。
- 查询 4 的区间为 [2, 4]：服务器 1（t=2）和 2（t=4）收到过请求，只有 3 号没有，答案为 1。
```

## 解题思路

### 第一步转化：数「没有」不如数「有」

直接统计「区间内零请求的服务器」不好下手，反过来数它的补集：

```text
answer[j] = n - 窗口 [q-x, q] 内收到过请求的不同服务器数
```

难点在后半句的「不同」二字——logs 和 queries 都可达 10^5，每个查询独立扫一遍 logs 是 O(M·Q) = 10^10，必然超时。

### 为什么不能用前缀和

「区间和」类问题的第一反应是前缀和，但这里统计的是**去重计数**：同一服务器在窗口内出现 3 条日志只算 1 台。去重计数不满足可加性——把窗口拆成两段分别统计再相加，跨段出现的同一台服务器会被数两次。差分与前缀和在此失效，得换武器。

### 离线 + 排序 + 双指针滑动窗口

查询之间并非独立：把 `queries` 连同原下标按时间**从小到大排序**（离线处理），窗口 `[q-x, q]` 的左右边界就都单调不减——这正是滑动窗口「两端只进不退」的形状：

1. `logs` 按时间排序；`queries` 带原下标排序，答案按原下标写回；
2. 右指针把 `time <= q` 的日志逐条收进哈希表：`cnt[server]` 从 0 变 1 时，「忙碌服务器数」`busy` 加一；
3. 左指针把 `time < q-x` 的日志逐条移出：`cnt[server]` 减到 0 时删除键，`busy` 减一；
4. 双指针收敛后 `answer = n - busy`。

哈希表按服务器计数天然完成去重——「同一服务器多条日志只算一台」不需要任何额外判断；窗口单向滑动保证每条日志至多进出各一次，均摊线性。

### 两个边界细节

- **闭区间两端**：右指针条件是 `time <= q`（右端点含），左指针条件是 `time < q-x`（左端点等于的保留），一收一剔正好卡住闭区间 `[q-x, q]`；
- **乱序查询**：输入的 `queries` 未必有序，排序前要记下原下标，答案写回原位置而不是排序后的位置。

### 复杂度分析

- 时间复杂度：`O(M log M + Q log Q)`（两次排序占主导，M、Q 为 logs 与 queries 长度；双指针各走至多 M 步，均摊线性）
- 空间复杂度：`O(M + Q)`（哈希表 + 查询下标数组 + 输出）

## 代码实现

```python
class Solution:
    def countServers(self, n: int, logs: list[list[int]], x: int, queries: list[int]) -> list[int]:
        logs = sorted(logs, key=lambda log: log[1])
        order = sorted(range(len(queries)), key=lambda i: queries[i])

        cnt: dict[int, int] = {}  # 窗口内 server_id -> 请求条数
        busy = 0  # 窗口内收到过至少一个请求的不同服务器数
        ret = [0] * len(queries)

        left = right = 0
        for i in order:
            start, end = max(0, queries[i] - x), queries[i]
            # 右指针：纳入 time <= q 的日志（右端点闭区间）
            while right < len(logs) and logs[right][1] <= end:
                server = logs[right][0]
                cnt[server] = cnt.get(server, 0) + 1
                if cnt[server] == 1:
                    busy += 1
                right += 1
            # 左指针：剔除 time < q-x 的日志（左端点闭区间，等于的保留）
            while left < right and logs[left][1] < start:
                server = logs[left][0]
                cnt[server] -= 1
                if cnt[server] == 0:
                    busy -= 1
                    del cnt[server]
                left += 1
            ret[i] = n - busy

        return ret
```

### 代码解析

- `sorted(range(len(queries)), key=...)` 排的是**下标**而非查询值本身，`ret[i]` 按原下标写回，乱序输入也能正确对应；
- `busy` 的增减只挂在计数跨越 0/1 边界的瞬间（0→1 加一、1→0 减一并删键），这是「维护不同元素个数」的标准姿势，删键同时避免哈希表无限膨胀；
- `max(0, queries[i] - x)` 防御左端点为负——本题约束 `x < queries[j]` 其实保证了非负，写上无妨但非必需；
- 先右后左的顺序没有讲究：两个条件互不依赖（右收 `<= q`，左剔 `< q-x`），换序结果相同，因为两指针都单调。

## 测试用例

覆盖两个官方示例、请求恰落在右端点/左端点（闭区间校验）、同一服务器多条日志去重、乱序查询、无日志、窗口整体早于/晚于所有日志：

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 1 ----
    assert solution.countServers(3, [[1, 3], [2, 6], [1, 5]], 5, [10, 11]) == [1, 2]

    # ---- 官方示例 2 ----
    assert solution.countServers(3, [[2, 4], [2, 1], [1, 2], [3, 1]], 2, [3, 4]) == [0, 1]

    # ---- 请求恰好落在右端点 t = q：闭区间必须计入 ----
    assert solution.countServers(2, [[1, 10]], 0, [10]) == [1]

    # ---- 请求恰好落在左端点 t = q - x：闭区间必须计入 ----
    assert solution.countServers(2, [[1, 5]], 5, [10]) == [1]

    # ---- 同一服务器多条日志：去重后只算一台 ----
    assert solution.countServers(3, [[1, 3], [1, 4], [1, 5]], 10, [5]) == [2]

    # ---- 查询乱序输入：离线排序后仍按原下标返回 ----
    assert solution.countServers(3, [[1, 3], [2, 6], [1, 5]], 5, [11, 10]) == [2, 1]

    # ---- 没有任何日志：所有服务器都是零请求 ----
    assert solution.countServers(3, [], 2, [10, 11]) == [3, 3]

    # ---- 窗口完全早于所有日志：同样全部零请求 ----
    assert solution.countServers(2, [[1, 100]], 5, [10]) == [2]

    # ---- 窗口完全晚于所有日志 ----
    assert solution.countServers(2, [[1, 1]], 5, [10]) == [2]
```

## 总结

- 正难则反：数「零请求服务器」转化为 `n - 忙碌服务器数`，补集思维把陌生问题拉回熟悉赛道；
- 去重计数不可加，前缀和失效；改用离线排序让查询窗口单调化，滑动窗口 + 哈希计数以均摊线性代价逐个回答；
- 「计数跨越 0/1 边界时增减 busy、减到 0 删键」是维护窗口内不同元素个数的万能模板，值得单独记下。
