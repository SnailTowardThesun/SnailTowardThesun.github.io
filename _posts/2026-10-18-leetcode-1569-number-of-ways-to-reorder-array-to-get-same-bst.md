---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1569: 将子数组重新排列得到同一个二叉搜索树的方案数"
categories: LeetCode
tags: 困难
---

> BST 的形状只由「根是谁、左右各分到哪些元素」决定，与左右子树元素在插入序列里如何交错无关——这个观察把「数排列」问题降维成了「组合数 × 子问题」的递归。

## 题目

LeetCode 1569. Number of Ways to Reorder Array to Get Same BST（将子数组重新排列得到同一个二叉搜索树的方案数）

Difficulty: **Hard**

给你一个数组 `nums`，表示 `1` 到 `n` 的一个**排列**。把 `nums` 中的元素**依次插入**一棵初始为空的二叉搜索树（BST），得到一棵 BST。

请你返回能生成**同一棵 BST** 的 `nums` 的不同**排列**的数目。由于答案可能很大，请将结果对 `10^9 + 7` **取余**后返回。

数据范围：`1 <= nums.length <= 1000`。

### 示例

```
输入：nums = [2,1,3]
输出：1
解释：与原数组生成同一棵 BST 的排列只有 [2,3,1]，故返回 1。

输入：nums = [3,4,5,1,2]
输出：5
解释：共有 5 种排列能生成同一棵 BST：
     [3,1,2,4,5]、[3,1,4,2,5]、[3,1,4,5,2]、[3,4,1,2,5]、[3,4,1,5,2]

输入：nums = [1,2,3]
输出：0
解释：没有其他排列能生成同一棵 BST。
```

注意返回的数目需**排除原数组本身的顺序**（即最终答案要减 1）。

## 解题思路

递归 + 组合数学（杨辉三角预处理组合数）。

关键观察——什么样的排列会生成同一棵 BST？

1. **根必须相同**：任何排列的第一个元素会成为根，所以合法排列必须以 `nums[0]` 开头；
2. **左右子树的元素集合固定**：按 BST 性质，小于根的元素全部进左子树，大于根的元素全部进右子树。设左子树元素共 `m` 个（记为序列 `L`，保持其在 `nums` 中的出现顺序），右子树元素共 `k` 个（记为序列 `R`）；
3. **左右元素可以任意「交错」**：根之后的部分是 `L` 与 `R` 的某个混排。由于左右元素互不影响（小于根/大于根），只要左右子树各自的相对顺序合法，最终 BST 就相同。交错方式数就是从 `m+k` 个位置中选出 `m` 个给左边：`C(m+k, m)`；
4. **子问题递归**：`L` 内部能生成同一棵左子树的排列数正是 `f(L)`，右边同理 `f(R)`。由乘法原理：

   `f(nums) = C(m+k, m) × f(L) × f(R)`

   递归终点：元素个数 `<= 2` 时只有一种顺序（单元素序列无重排余地），返回 1；
5. **排除原排列**：题目要求答案减 1。取模后 `f(nums)` 可能为 0，减 1 前需 `+MOD` 防止负数。

为什么「交错」时保持 `L`、`R` 各自相对顺序就够？因为打破 `L` 内部相对顺序的情况已经由 `f(L)` 递归统计（`f(L)` 统计的是 `L` 中元素的所有合法排列），二者相乘恰好不重不漏地覆盖了所有合法排列。

以 `nums = [3,4,5,1,2]` 手算：根为 3，`L = [1,2]`（m=2），`R = [4,5]`（k=2）。`f(L) = f(R) = 1`（两元素无重排余地），总数 `f = C(4,2) × 1 × 1 = 6`，答案 `6 - 1 = 5`，与示例一致。

再如 `nums = [4,2,6,1,3,5,7]`：根 4，`L = [2,1,3]`，`R = [6,5,7]`；`f(L) = f(R) = C(2,1) = 2`，总数 `f = C(6,3) × 2 × 2 = 80`，答案 79。

### 复杂度分析

- **时间复杂度**：O(n²) —— 杨辉三角预处理 O(n²)，每层递归对当前序列做一次 O(len) 分组，各层成本合计 O(n²)（最坏链状树）；
- **空间复杂度**：O(n²) —— 杨辉三角表；递归栈深 O(n)。

## 代码实现

```cpp
class Solution {
   public:
    static constexpr long long MOD = 1'000'000'007LL;

    int numOfWays(vector<int>& nums) {
        int n = nums.size();
        // 杨辉三角预处理组合数 C[i][j]（对 MOD 取模）
        c_.assign(n + 1, vector<long long>(n + 1, 0));
        for (int i = 0; i <= n; ++i) {
            c_[i][0] = 1;
            for (int j = 1; j <= i; ++j) {
                c_[i][j] = (c_[i - 1][j - 1] + c_[i - 1][j]) % MOD;
            }
        }

        // f(nums) 统计包含原排列在内的方案数，题目要求排除原排列故减 1
        long long total = dfs(nums);
        return static_cast<int>((total - 1 + MOD) % MOD);
    }

   private:
    // 返回当前插入序列能生成同一棵 BST 的排列数（含原顺序）
    long long dfs(vector<int>& nums) {
        // 0 或 1 个元素时只有一种插入顺序
        if (nums.size() <= 2) {
            return 1;
        }

        int root = nums[0];
        vector<int> left, right;  // 小于根的进左子树，大于根的进右子树
        for (size_t i = 1; i < nums.size(); ++i) {
            (nums[i] < root ? left : right).push_back(nums[i]);
        }

        // 左右子树元素在根之后可任意交错：C(m+k, m) 种位置分配
        long long ways = c_[left.size() + right.size()][left.size()];
        ways = ways * dfs(left) % MOD;   // 左子树内部的合法排列数
        ways = ways * dfs(right) % MOD;  // 右子树内部的合法排列数
        return ways;
    }

    vector<vector<long long>> c_;  // 组合数表
};
```

### 代码解析

- **状态转移的灵魂是「交错数」**：`C(m+k, m)` 只决定左右元素占哪些位置，不决定左右内部的顺序——内部顺序交给递归子问题，职责分离保证不重不漏；
- **杨辉三角代替模逆元**：`C[i][j] = C[i-1][j-1] + C[i-1][j]` 只用加法取模，省去费马小定理求逆元；n ≤ 1000 时表约 4MB，可接受（追求 O(n) 预处理可改用阶乘 + 乘法逆元）；
- **减 1 的负数陷阱**：`f(nums)` 已对 MOD 取模，可能为 0，直接减 1 会得到 -1，必须 `(total - 1 + MOD) % MOD`；
- **每层递归拷贝子序列**：`dfs` 按值接收 vector，各层分组成本合计 O(n²)，n ≤ 1000 时约 10^6 次元素拷贝，无需优化。

## 测试用例

```cpp
TEST(Daily, 1569) {
    Solution s;

    // 示例用例
    auto nums1 = vector<int>{2, 1, 3};
    EXPECT_EQ(s.numOfWays(nums1), 1);

    auto nums2 = vector<int>{3, 4, 5, 1, 2};
    EXPECT_EQ(s.numOfWays(nums2), 5);

    auto nums3 = vector<int>{1, 2, 3};
    EXPECT_EQ(s.numOfWays(nums3), 0);

    // 边界用例：单元素与两元素，均无其他排列
    auto nums4 = vector<int>{1};
    EXPECT_EQ(s.numOfWays(nums4), 0);

    auto nums5 = vector<int>{7, 3};
    EXPECT_EQ(s.numOfWays(nums5), 0);

    // 满二叉树 [4,2,6,1,3,5,7]：根 4，左 [2,1,3]、右 [6,5,7]，
    // f(左)=C(2,1)=2，f(右)=C(2,1)=2，总数 C(6,3)*2*2=80，答案 80-1=79
    auto nums6 = vector<int>{4, 2, 6, 1, 3, 5, 7};
    EXPECT_EQ(s.numOfWays(nums6), 79);
}
```

## 总结

1. BST 形状由「根 + 左右元素集合」唯一决定，合法重排 = 根固定 + 左右子树递归 + 左右元素任意交错；
2. 交错方式数为组合数 `C(m+k, m)`，与左右内部顺序解耦后用乘法原理合并，减 1 排除原排列；
3. 组合数用杨辉三角加法递推即可免模逆元，整体 O(n²)。
