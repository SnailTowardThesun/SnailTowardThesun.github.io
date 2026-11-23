---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1352: 最后 K 个数的乘积"
categories: LeetCode
tags: [中等, 设计, 前缀积, 数据流]
---

> 空序列的乘积定义为 1。把这个 1 放在前缀积数组的首位，查询整段乘积时也可以沿用相同的除法公式。

## 题目

[LeetCode 1352. Product of the Last K Numbers](https://leetcode.com/problems/product-of-the-last-k-numbers/description/)（中等）

设计类 `ProductOfNumbers`。数据流初始为空，`add(num)` 在末尾追加一个整数，`getProduct(k)` 返回最近 `k` 个数的乘积。查询时数据流至少有 `k` 项。

输入的整数介于 0 和 100 之间，`k` 介于 1 和 40000 之间，两种操作合计最多调用 40000 次。题目保证任意连续区间的乘积都能用 32 位有符号整数表示。

### 示例

依次写入 `3, 0, 2, 5, 4`，查询和追加操作得到以下结果。

| 操作 | 查询范围 | 返回值 |
| --- | --- | --- |
| `getProduct(2)` | 5, 4 | 20 |
| `getProduct(3)` | 2, 5, 4 | 40 |
| `getProduct(4)` | 0, 2, 5, 4 | 0 |
| `add(8)` 后执行 `getProduct(2)` | 4, 8 | 32 |

## 解题思路

只维护最近一个零之后的连续非零段。设这段有 `m` 个数，令 `P[0] = 1`，`P[i]` 等于段内前 `i` 个数的乘积。写入正数时，将当前末项乘以新数并追加到数组。写入零时，将数组重置为 `[1]`。

以示例为例，写入零后的三个数 `2, 5, 4` 后，前缀积数组为 `[1, 2, 10, 40]`。查询最近两个数，末项 40 中含有多余的因子 2，因此答案为 `P[3] / P[1] = 20`。一般地，只要 `k <= m`，`P[m] / P[m-k]` 就能准确消去查询区间之前的全部因子。

当 `k = m` 时，分母恰好是 `P[0] = 1`，应返回整段的乘积 40。当 `k = m + 1` 时，窗口刚好包含最近的零，应返回 0。因为数组长度为 `m + 1`，代码里的零值判断要写成 `k >= len(P)`。这个等号也覆盖了刚写入零就查询最近一个数的情况。

### 复杂度分析

`getProduct` 只需一次边界判断和至多一次整数除法，耗时 `O(1)`。`add` 均摊耗时 `O(1)`。动态数组扩容或释放旧数组时单次开销可能较大，但每个前缀积只会追加一次、随所属非零段一起丢弃一次。连续写入 `n` 个非零数时，空间为最坏的 `O(n)`。

## 代码实现

C++ 用 `vector`，Python 用列表，两个版本都从空前缀的乘积 1 开始。

<div class="lang-tabs">
  <input type="radio" id="lt1352-cpp" name="lt1352-lang" checked>
  <input type="radio" id="lt1352-py" name="lt1352-lang">
  <div class="lang-tab-nav">
    <label for="lt1352-cpp">C++</label>
    <label for="lt1352-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
#include <utility>
#include <vector>

class ProductOfNumbers {
   public:
    std::vector<int> container{1};

    void add(int num) {
        if (num == 0) {
            container = std::vector<int>{1};
        } else {
            container.emplace_back(container.back() * num);
        }
    }

    int getProduct(int k) {
        if (std::cmp_greater_equal(k, container.size())) {
            return 0;
        }
        return container.back() / container[container.size() - 1 - k];
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class ProductOfNumbers:
    def __init__(self) -> None:
        self._container = [1]

    def add(self, num: int) -> None:
        if num == 0:
            self._container = [1]
        else:
            self._container.append(self._container[-1] * num)

    def getProduct(self, k: int) -> int:
        if k >= len(self._container):
            return 0
        return self._container[-1] // self._container[-1 - k]
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

C++ 的 `back()` 和 Python 的 `[-1]` 都取最后一个前缀积。向前移动 `k` 个位置就是分母。数组只记录非零段，因此分母始终为正数，分子是分母的整数倍。

## 测试用例

以下用例分别取完整非零段，再把窗口向前扩大一项，检查哨兵与零的分界。

```python
stream = ProductOfNumbers()
stream.add(0)
assert stream.getProduct(1) == 0
for num in (2, 5, 4):
    stream.add(num)
assert stream.getProduct(2) == 20
assert stream.getProduct(3) == 40
assert stream.getProduct(4) == 0
```

## 总结

用最近一次出现的零划分数据流。窗口跨过非零段的起点时返回零，其余查询都可以通过两个前缀积相除完成。
