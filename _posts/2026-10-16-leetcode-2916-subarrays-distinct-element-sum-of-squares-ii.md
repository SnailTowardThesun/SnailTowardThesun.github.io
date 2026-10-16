---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2916: 子数组不同元素数目的平方和 II"
categories: LeetCode
---

> 把 f² 拆成 2×T(f) − f（T 为三角形数）后，平方和就能跟随「区间整体 +1」增量维护——这是 2913 的 O(n²) 暴力无法提速时，贡献法 + 线段树登场的关键一步。

## 题目

LeetCode 2916. Subarrays Distinct Element Sum of Squares II（子数组不同元素数目的平方和 II）

Difficulty: **Hard**（第 116 场双周赛 Q4）

给你一个下标从 **0** 开始的整数数组 `nums`。

定义 `nums` 一个子数组的**不同计数**为其中**不同值的数目**。

请你返回 `nums` 中**所有**子数组的不同计数的**平方和**。

由于答案可能很大，返回其对 `10^9 + 7` 取模的结果。

数据范围：`1 <= nums.length <= 10^5`，`1 <= nums[i] <= 10^5`。

### 示例

```
输入：nums = [1,2,1]
输出：15
解释：六个子数组的不同计数分别为 1、1、1、2、2、2，
     平方和 = 1 + 1 + 1 + 4 + 4 + 4 = 15

输入：nums = [2,2]
输出：3
解释：三个子数组 [2]、[2]、[2,2] 的不同计数均为 1，平方和 = 3
```

## 解题思路

这是 2913（Easy 版，`n <= 100`）的 Hard 加强版：`n` 放宽到 `10^5`，O(n²) 暴力会超时，需要 **贡献法 + 懒标记线段树** 的 O(n log n) 解法。

1. **枚举右端点**：设 `f(j) = 子数组 nums[j..i] 的不同计数`，答案为每个 `i` 下 `s = Σ f(j)²` 的累加取模；
2. **恒等式降维**：平方和无法直接区间维护，利用 `f² = 2*T(f) - f`（其中 `T(f) = 1+2+…+f` 为三角形数），转为分别增量维护 `ΣT` 与 `Σf`：当一段区间上每个 `f` 同时加 1 时，`ΔΣT = Σf(旧值) + 区间长度`，`ΔΣF = 区间长度`，故 `s` 的增量 = `2*Σf(旧值) + 区间长度`；
3. **贡献法定位区间**：设 `x = nums[i]` 上次出现的下标为 `j`（从 1 计，不存在则为 0），则左端点落在 `[j+1, i]` 的子数组恰好新增一个不同值 `x`，对这段的 `f` 整体 +1；其中「查询加一前的区间和 + 区间加一」合并为线段树的一次递归遍历（`query_and_add1`）；
4. **懒标记线段树**：节点维护区间和 `sum` 与懒标记 `todo`（待下传的加值），进入子节点前先下传标记，回溯时由左右子节点上传合并。

以 `nums = [1,2,1]` 为例，手算如下（`f` 数组按左端点 `1..i` 列出）：

```
i=1, x=1: 上次出现 j=0，对 [1,1] 加一  旧区间和=0  Δs = 2*0+1 = 1
          f = [1]              Σf² = 1        ans = 1
i=2, x=2: 上次出现 j=0，对 [1,2] 加一  旧区间和=1  Δs = 2*1+2 = 4
          f = [2,1]            Σf² = 5        ans = 6
i=3, x=1: 上次出现 j=1，对 [2,3] 加一  旧区间和=1  Δs = 2*1+2 = 4
          f = [2,2,1]          Σf² = 9        ans = 15
```

### 复杂度分析

- **时间复杂度**：O(n log n)，每个元素一次线段树区间查询+更新；
- **空间复杂度**：O(n)，线段树开 4n 个节点。

## 代码实现

```cpp
class Solution {
    vector<long long> sum;
    vector<int> todo;

    void do_(int o, int l, int r, int add) {
        sum[o] += (long long)add * (r - l + 1);
        todo[o] += add;
    }

    // o=1  [l,r] 1<=l<=r<=n
    // 把 [L,R] 加一，同时返回加一之前的区间和
    long long query_and_add1(int o, int l, int r, int L, int R) {
        if (L <= l && r <= R) {
            long long res = sum[o];
            do_(o, l, r, 1);
            return res;
        }

        int m = (l + r) / 2;
        int add = todo[o];
        if (add != 0) {
            do_(o * 2, l, m, add);
            do_(o * 2 + 1, m + 1, r, add);
            todo[o] = 0;
        }

        long long res = 0;
        if (L <= m) res += query_and_add1(o * 2, l, m, L, R);
        if (m < R) res += query_and_add1(o * 2 + 1, m + 1, r, L, R);
        sum[o] = sum[o * 2] + sum[o * 2 + 1];
        return res;
    }

public:
    int sumCounts(vector<int>& nums) {
        int n = nums.size();
        sum.resize(n * 4);
        todo.resize(n * 4);

        long long ans = 0, s = 0;
        unordered_map<int, int> last;
        for (int i = 1; i <= n; i++) {
            int x = nums[i - 1];
            int j = last.count(x) ? last[x] : 0;
            s += query_and_add1(1, 1, n, j + 1, i) * 2 + i - j;
            ans = (ans + s) % 1'000'000'007;
            last[x] = i;
        }
        return ans;
    }
};
```

### 代码解析

- **恒等式是灵魂**：`f² = 2*T(f) − f` 把「平方和」拆成两个可增量维护的量，区间整体 +1 时两者的变化量都能由「旧区间和 + 区间长度」直接算出；
- **查询与修改合并**：`query_and_add1` 在一次递归里同时返回加一前的区间和并完成整体加一，省去两次独立遍历，常数减半；
- **贡献法定位**：`last` 记录每个值上次出现的下标，`x` 恰好对左端点在 `[j+1, i]` 的子数组贡献一个新不同值——这是「子数组不同值」类问题的通用套路；
- **溢出检查**：`s <= n³ = 10^15`、线段树区间和 `<= n² = 10^10`，均在 `long long` 范围内，只需对 `ans` 每步取模；
- **易错点**：内部数组用 `resize` 分配不清零旧值，`Solution` 是有状态的，多个用例须各自新建实例（与 LeetCode 每用例新实例的语义一致）。

## 测试用例

```cpp
TEST(Daily, 2916) {
    // Solution 内部线段树数组用 resize 分配，不清零旧值，
    // 每个用例须新建实例（与 LeetCode 每用例新实例的语义一致）
    {
        // 官方示例 1：六个子数组的不同计数 1、1、1、2、2、2
        Solution s;
        vector<int> nums = {1, 2, 1};
        EXPECT_EQ(s.sumCounts(nums), 15);
    }

    {
        // 官方示例 2：三个子数组的不同计数均为 1
        Solution s;
        vector<int> nums = {2, 2};
        EXPECT_EQ(s.sumCounts(nums), 3);
    }

    {
        // 手算用例：全不同元素 4*1 + 3*4 + 2*9 + 1*16 = 50
        Solution s;
        vector<int> nums = {1, 2, 3, 4};
        EXPECT_EQ(s.sumCounts(nums), 50);
    }

    // 随机小数组与 O(n^2) 暴力对拍
    mt19937 rng(2916);
    for (int t = 0; t < 200; t++) {
        int n = uniform_int_distribution<int>(1, 50)(rng);
        vector<int> nums(n);
        for (auto& x : nums) {
            x = uniform_int_distribution<int>(1, 5)(rng);
        }

        // 暴力：枚举全部子数组，哈希集合去重
        int brute = 0;
        for (int i = 0; i < n; i++) {
            unordered_set<int> st;
            for (int j = i; j < n; j++) {
                st.insert(nums[j]);
                brute += (int)st.size() * (int)st.size();
            }
        }

        Solution s;
        EXPECT_EQ(s.sumCounts(nums), brute);
    }

    {
        // 大规模取模：全不同元素时答案 = Σ (n-len+1)*len^2，n = 10^5
        const long long n = 100000, MOD = 1'000'000'007;
        vector<int> nums(n);
        iota(nums.begin(), nums.end(), 1);

        long long expect = 0;
        for (long long len = 1; len <= n; len++) {
            expect = (expect + (n - len + 1) * len % MOD * len) % MOD;
        }

        Solution s;
        EXPECT_EQ(s.sumCounts(nums), (int)expect);
    }
}
```

## 总结

1. 平方和不能区间维护时，用恒等式 `f² = 2*T(f) − f` 降维到可增量维护的 `ΣT` 与 `ΣF`；
2. 「上次出现位置」决定贡献区间 `[last+1, i]`，是子数组不同值问题的通用贡献法套路；
3. 把查询与修改合并成一次线段树递归，配合懒标记下传与回溯上传，整体 O(n log n)。
