---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2573: 找出与LCP矩阵对应的字符串"
categories: LeetCode
---

> LCP 矩阵的递推式：字符相同则 lcp[i][j] = lcp[i+1][j+1] + 1，不同则为 0。贪心赋最小字符再反向验证即可。

## 题目

LeetCode 2573. Find the String with LCP（找出与 LCP 矩阵对应的字符串）

Difficulty: **Hard**

给定一个由 n 个小写字母组成的字符串 word，定义 n × n 矩阵 `lcp`，其中 `lcp[i][j]` 是子串 `word[i..n-1]` 与 `word[j..n-1]` 的最长公共前缀长度。现给出矩阵 `lcp`，返回与之对应的、字典序最小的字符串；不存在则返回空串。

### 示例

```
示例 1：
输入：lcp = [[4,0,2,0],[0,3,0,1],[2,0,2,0],[0,1,0,1]]
输出："abab"

示例 2：
输入：lcp = [[4,3,2,1],[3,3,2,1],[2,2,2,1],[1,1,1,1]]
输出："aaaa"

示例 3：
输入：lcp = [[4,3,2,1],[3,3,2,1],[2,2,2,1],[1,1,1,3]]
输出：""
```

## 解题思路

### 贪心赋值 + 反向验证

关键性质：
- `word[i] == word[j]`：`lcp[i][j] = lcp[i+1][j+1] + 1`（边界为 1）
- `word[i] != word[j]`：`lcp[i][j] = 0`

构造步骤：
1. **贪心赋值**：从左到右扫描，遇到未赋值位置 i 时给当前最小可用字符 c，所有满足 `lcp[i][j] > 0` 的位置 j 也赋为 c（lcp 为正意味着字符相同）。字符超过 z 则无解。
2. **反向验证**：从右下到左上按递推式核对每个 `lcp[i][j]`，与构造串不符则返回空串。

源文件同时给出并查集实现（先合并等价位置再分字符）与贪心实现，思路相同。

### 复杂度分析

- **时间复杂度**：O(n²)，构造与验证各遍历一次矩阵。
- **空间复杂度**：O(n)。

## 代码实现

```cpp
class SolutionUnionFind {
   public:
    string findTheString(vector<vector<int>>& lcp) {
        int n = lcp.size();
        string ret(n, '1');
        vector<int> container(n, -1);
        iota(container.begin(), container.end(), 0);

        auto find = [&](auto self, int i) -> int {
            if (container[i] == i) return i;
            container[i] = self(self, container[i]);
            return container[i];
        };

        // lcp[i][j] > 0 说明 i、j 字符相同，合并集合
        for (int i = 0; i < n; i++) {
            for (int j = i; j < n; j++) {
                if (lcp[i][j] > 0) {
                    int rootI = find(find, i), rootJ = find(find, j);
                    if (rootI != rootJ) container[rootI] = rootJ;
                }
            }
        }

        // 按首次出现顺序分配最小字符
        char ch = 'a';
        vector<char> char_map(n, '1');
        for (int i = 0; i < n; i++) {
            int root = find(find, i);
            if (char_map[root] == '1') {
                if (ch > 'z') return "";
                char_map[root] = ch++;
            }
            ret[i] = char_map[root];
        }

        // 反向验证矩阵
        for (int i = n - 1; i >= 0; i--) {
            for (int j = n - 1; j >= 0; j--) {
                int correct_number = 0;
                if (ret[i] == ret[j]) {
                    if (i == n - 1 || j == n - 1) correct_number = 1;
                    else correct_number = lcp[i + 1][j + 1] + 1;
                }
                if (lcp[i][j] != correct_number) return "";
            }
        }
        return ret;
    }
};
```

## 测试用例

{% raw %}
```cpp
TEST(Daily, 2573) {
    SolutionUnionFind s;
    vector<vector<int>> lcp1 = {{4, 0, 2, 0}, {0, 3, 0, 1}, {2, 0, 2, 0}, {0, 1, 0, 1}};
    EXPECT_EQ(s.findTheString(lcp1), "abab");

    vector<vector<int>> lcp2 = {{4, 3, 2, 1}, {3, 3, 2, 1}, {2, 2, 2, 1}, {1, 1, 1, 1}};
    EXPECT_EQ(s.findTheString(lcp2), "aaaa");

    vector<vector<int>> lcp3 = {{4, 3, 2, 1}, {3, 3, 2, 1}, {2, 2, 2, 1}, {1, 1, 1, 3}};
    EXPECT_EQ(s.findTheString(lcp3), "");
}
```
{% endraw %}

## 总结

1. lcp 为正即字符相同，贪心时同步赋值，保证字典序最小；
2. 构造完必须用递推式反向验证，矩阵自相矛盾则无解；
3. 并查集与贪心两种实现殊途同归。
