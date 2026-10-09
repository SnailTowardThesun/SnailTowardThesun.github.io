---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.22: 括号生成"
categories: LeetCode
---

> 括号组合数是卡特兰数，它在凸多边形三角剖分、二叉树形态计数等问题中反复出现。

## 题目

LeetCode 22. Generate Parentheses（括号生成）

Difficulty: **Medium**

数字 `n` 代表生成括号的对数，请你设计一个函数，用于能够生成所有可能的并且**有效的**括号组合。

### 示例

```
输入：n = 3
输出：["((()))","(()())","(())()","()(())","()()()"]

输入：n = 1
输出：["()"]
```

## 解题思路

### DFS 回溯 + 剪枝

暴力法是生成全部 2^(2n) 个括号序列再逐一校验，大量无效分支浪费严重。更聪明的做法是**边生成边剪枝**，只走合法分支：

维护三个状态：当前路径 `path`、已用左括号数 `left`、已用右括号数 `right`。每层递归有两个选择，各自带剪枝条件：

1. **加 `'('`**：前提 `left < n`（左括号还有配额）；
2. **加 `')'`**：前提 `right < left`（右括号数不能超过左括号数，否则前面必然出现非法前缀）。

当 `path` 长度达到 `2n` 时，左右括号各用完 `n` 个，且全程未违反规则，天然合法，直接收集。

以 `n = 2` 为例：从 `"("` 出发，走 `"(("` 分支得到 `"(()"` 再补 `")"` 收获 `"(())"`；走 `"()"` 分支得到 `"()("` 再补 `")"` 收获 `"()()"`。两条路都合法，剪枝保证了不会出现 `")("` 这样的非法前缀。

### 复杂度分析

- **时间复杂度**：O(4^n / √n)，合法组合数为第 n 个卡特兰数，每个方案需要 O(n) 复制。
- **空间复杂度**：O(n)，递归栈深度与 `path` 长度（不计输出）。

## 代码实现

```cpp
class Solution {
   public:
    void dfs(string path, vector<string> &container, int n, int left,
             int right) {
        if (left > n) {
            return;
        }
        if (right > left) {
            return;
        }

        if (path.length() == n * 2) {
            container.push_back(path);
            return;
        }

        dfs(path + "(", container, n, left + 1, right);
        dfs(path + ")", container, n, left, right + 1);
    }

    vector<string> generateParenthesis(int n) {
        vector<string> ret;
        dfs("", ret, n, 0, 0);
        return ret;
    }
};
```

### 代码解析

- **入口处双重剪枝**：`left > n` 和 `right > left` 两个条件在函数开头拦截非法状态，保证进入后续递归的状态都可扩展。
- **值传递的 `path`**：每层递归拿到字符串副本，回溯时无需手动撤销，代码更简洁（代价是多一次拷贝）。
- **终点即答案**：`path.length() == n * 2` 时左右恰好用尽，无需再检查合法性——剪枝已在生成阶段完成。

## 测试用例

```cpp
TEST(Daily, 22) {
    Solution s;
    // n=3 时卡特兰数 C_3 = 5
    auto ret = s.generateParenthesis(3);
    EXPECT_EQ(ret.size(), 5);
}
```

## 总结

1. 回溯的两个选择各带剪枝：`left < n` 才能加左，`right < left` 才能加右；
2. 长度达到 2n 的路径天然合法，无需事后校验；
3. 组合数是卡特兰数，时间 O(4^n / √n)。
