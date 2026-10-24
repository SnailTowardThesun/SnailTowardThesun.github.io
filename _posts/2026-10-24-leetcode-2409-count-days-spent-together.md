---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2409: 统计共同度过的日子"
categories: LeetCode
tags: [简单, 数学, 字符串]
---

> 双闭区间的交集长度是 `min(离开) - max(到达) + 1`——那个 `+1` 是两端都计入的代价，也是这类日期题最容易丢的一分。

## 题目

LeetCode 2409. Count Days Spent Together（统计共同度过的日子）

Difficulty: **Easy**

Alice 和 Bob 计划去纽约旅游。Alice 在 `arriveAlice` 到 `leaveAlice` 之间旅游（**包含边界**），Bob 在 `arriveBob` 到 `leaveBob` 之间旅游（**包含边界**）。

每个日期字符串都由 5 个字符组成，格式为 `"MM-DD"`，对应某个月中的某一天。给你四个字符串 `arriveAlice`、`leaveAlice`、`arriveBob`、`leaveBob`，请你计算 Alice 和 Bob **同时在纽约**旅游的天数。

注：题目使用的日历为**非闰年**，一年共 365 天。

### 示例

```
输入：arriveAlice = "08-15", leaveAlice = "08-18", arriveBob = "08-16", leaveBob = "08-19"
输出：3
解释：Alice 与 Bob 同时在纽约的日子为 08-16、08-17、08-18，共 3 天。

输入：arriveAlice = "10-01", leaveAlice = "10-31", arriveBob = "11-01", leaveBob = "12-31"
输出：0
解释：Alice 于 10-31 离开纽约，Bob 于 11-01 到达，两人没有同时在纽约的日子。
```

## 解题思路

### 先转成「一年中的第几天」

`"MM-DD"` 是零填充的，字典序恰好等于日期序——理论上拿字符串直接比大小也能判相交。但要做**加减法**算天数，还是得先换算成数轴坐标：累加第 `month` 个月之前的整月天数（非闰年 2 月固定 28 天），再加上日号，得到「一年中的第几天」。四个日期各转一次，后面全是整数运算。

### 数轴上的闭区间交集

两人的行程就是一年这条数轴上的两个闭区间 `[arriveAlice, leaveAlice]` 与 `[arriveBob, leaveBob]`：

- 交集左端点 = `max(两个到达日)`，右端点 = `min(两个离开日)`；
- 天数 = `min - max + 1`，双闭区间**两端都要计入**，所以有 `+1`；
- 不相交（Alice 先离开，或 Alice 后到达）时上式必为非正数，提前判掉返回 `0` 即可——这与 `max(0, min - max + 1)` 完全等价，显式分支只是更好读。

### 复杂度分析

换算每次最多累加 11 个月，时间 `O(1)`，空间 `O(1)`。

## 代码实现

```python
class Solution:
    def countDaysTogether(self, arriveAlice: str, leaveAlice: str, arriveBob: str, leaveBob: str) -> int:
        def cal_days(d):
            days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
            dds = d.split("-")
            rt = 0
            for i in range(int(dds[0]) - 1):
                rt += days[i]
            rt += int(dds[1])
            return rt

        int_arr_alice = cal_days(arriveAlice)
        int_lea_alice = cal_days(leaveAlice)
        int_arr_bob = cal_days(arriveBob)
        int_lea_bob = cal_days(leaveBob)

        if int_lea_alice < int_arr_bob or int_arr_alice > int_lea_bob:
            return 0

        return min(int_lea_alice, int_lea_bob) - max(int_arr_alice, int_arr_bob) + 1
```

### 代码解析

- **`cal_days`**：`days` 表存每月天数，循环累加的是第 `month` 个月**之前**的整月，最后加上日号；
- **不相交的两分支**：`leaveAlice < arriveBob`（Alice 走得比 Bob 来得早）或 `arriveAlice > leaveBob`（Alice 来得比 Bob 走得晚），覆盖了左右两种相离方向；
- **`+ 1` 别丢**：这题我真实踩过——第一版漏了它，官方示例 1 算出 `2` 而不是 `3`，被测试用例当场抓了出来。

## 测试用例

```python
s = Solution()

# ---- 官方示例 ----
assert s.countDaysTogether("08-15", "08-18", "08-16", "08-19") == 3  # 08-16 ~ 08-18
assert s.countDaysTogether("10-01", "10-31", "11-01", "12-31") == 0  # 相邻月份不重叠

# ---- 区间完全相同 ----
assert s.countDaysTogether("01-01", "12-31", "01-01", "12-31") == 365  # 全年 365 天

# ---- 包含关系 ----
assert s.countDaysTogether("01-01", "12-31", "02-10", "03-10") == 29  # Bob 被包含：2 月 19 天 + 3 月 10 天
assert s.countDaysTogether("06-01", "06-10", "01-01", "12-31") == 10  # Alice 被包含

# ---- 部分重叠 ----
assert s.countDaysTogether("08-15", "09-10", "09-01", "09-20") == 10  # Alice 在前，跨月交集 09-01 ~ 09-10
assert s.countDaysTogether("03-05", "03-12", "03-01", "03-08") == 4  # Bob 在前，交集 03-05 ~ 03-08

# ---- 不相交（左邻 / 右邻）----
assert s.countDaysTogether("01-01", "01-10", "01-11", "01-20") == 0  # Alice 先离开
assert s.countDaysTogether("12-20", "12-31", "01-01", "12-19") == 0  # Bob 先离开

# ---- 单点 / 单日边界 ----
assert s.countDaysTogether("02-25", "02-28", "02-28", "03-05") == 1  # 仅共享 02-28（非闰年）
assert s.countDaysTogether("01-01", "01-01", "01-01", "01-01") == 1  # 两人同一天到达并离开
assert s.countDaysTogether("05-05", "05-05", "05-06", "05-06") == 0  # 两个单日行程不重合
assert s.countDaysTogether("05-05", "05-05", "05-05", "05-20") == 1  # 单日行程落在对方区间端点
```

用例按区间关系分类铺开：完全相同、双向包含、跨月部分重叠、左右相邻不相交、单点/单日边界。几个关键锚点——全年 `01-01 ~ 12-31` 相等时得 `365`（顺带钉死非闰年总天数）、`02-28` 边界（2 月按 28 天算）、`leaveAlice == arriveBob` 的单点相交得 `1`（专防漏 `+1`）。

## 总结

- `"MM-DD"` 零填充时字典序等于日期序，但要算天数，先转成「一年中的第几天」更踏实；
- 双闭区间的交集长度记得 `+1`，不相交时和 `max(0, ...)` 等价；
- 把 `365`、`02-28`、单点相交接进测试，两处 bug（累加时下标误用、漏 `+1`）都是被它们当场抓出来的——边界用例先行，比肉眼检查可靠。
