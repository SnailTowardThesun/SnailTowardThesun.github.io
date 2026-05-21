---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3043: 最长公共前缀的长度"
categories: LeetCode
---

> 前缀树（Trie）在字符串处理和搜索中有广泛应用，理解前缀概念有助于解决电话号码簿匹配、URL路由等实际问题。

## 题目

LeetCode 3043. 最长公共前缀的长度（Find the Length of the Longest Common Prefix）

Difficulty: **Medium**

给你两个正整数数组 arr1 和 arr2。

一个正整数的前缀是由一个或多个数字组成的整数，从最左边开始。例如，123 是 12345 的前缀，而 234 不是。

两个整数 a 和 b 的公共前缀是一个整数 c，使得 c 是 a 和 b 的前缀。例如，5655359 和 56554 的公共前缀是 565 和 5655，而 1223 和 43456 没有公共前缀。

你需要找到所有数对 (x, y) 之间的最长公共前缀的长度，其中 x 属于 arr1，y 属于 arr2。

返回所有数对中最长公共前缀的长度。如果不存在公共前缀，返回 0。

### 示例

```
示例 1:
输入: arr1 = [1,10,100], arr2 = [1000]
输出: 3
解释:
有 3 个数对 (arr1[i], arr2[j])：
- (1, 1000) 的最长公共前缀是 1
- (10, 1000) 的最长公共前缀是 10
- (100, 1000) 的最长公共前缀是 100
最长公共前缀是 100，长度为 3

示例 2:
输入: arr1 = [1,2,3], arr2 = [4,4,4]
输出: 0
解释: 任意数对之间都不存在公共前缀，返回 0
```

## 解题思路

### 方法一：前缀集合法

利用集合来存储所有可能的前缀，然后查找最长匹配。

1. **构建前缀集合**：遍历 arr1，将每个数字的所有前缀存入 unordered_set
2. **搜索最长前缀**：遍历 arr2 中的每个数字，从最长可能长度开始搜索
3. **维护最大值**：记录找到的最长公共前缀长度

### 算法详解

以 arr1 = [1,10,100], arr2 = [1000] 为例：

```
步骤 1：构建前缀集合
- 1 的前缀：1
- 10 的前缀：1, 10
- 100 的前缀：1, 10, 100
集合内容：{1, 10, 100}

步骤 2：搜索最长前缀
- 1000 的前缀：1, 10, 100, 1000
  - 1000 不在集合中
  - 100 在集合中！找到长度为 3 的公共前缀

最终结果：3
```

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    int longestCommonPrefix(vector<int>& arr1, vector<int>& arr2) {
        unordered_set<string> prefixes;
        for (int num : arr1) {
            string s = to_string(num);
            for (int i = 1; i <= static_cast<int>(s.size()); ++i) {
                prefixes.insert(s.substr(0, i));
            }
        }

        int result = 0;
        for (int num : arr2) {
            string s = to_string(num);
            for (int i = static_cast<int>(s.size()); i >= 1; --i) {
                if (prefixes.find(s.substr(0, i)) != prefixes.end()) {
                    result = max(result, i);
                    break;
                }
            }
        }

        return result;
    }
};
```
{% endraw %}

### 复杂度分析

- **时间复杂度**: O(N * M)，其中 N 是数组长度，M 是数字的平均长度
- **空间复杂度**: O(N * M)

### 字典树优化（推荐）

字典树是处理前缀问题的经典数据结构，可以更高效地解决这个问题。

{% raw %}
```cpp
struct TrieNode {
    vector<shared_ptr<TrieNode>> children;
    TrieNode() : children(10) {}
};

class Trie {
public:
    void insert(const string& word) {
        auto node = root;
        for (const char c : word) {
            const int i = c - '0';
            if (node->children[i] == nullptr)
                node->children[i] = make_shared<TrieNode>();
            node = node->children[i];
        }
    }

    int search(const string& word) {
        int prefixLength = 0;
        auto node = root;
        for (const char c : word) {
            const int i = c - '0';
            if (node->children[i] == nullptr)
                break;
            node = node->children[i];
            ++prefixLength;
        }
        return prefixLength;
    }

private:
    shared_ptr<TrieNode> root = make_shared<TrieNode>();
};

class Solution {
public:
    int longestCommonPrefix(vector<int>& arr1, vector<int>& arr2) {
        int ans = 0;
        Trie trie;

        for (const int num : arr1)
            trie.insert(to_string(num));

        for (const int num : arr2)
            ans = max(ans, trie.search(to_string(num)));

        return ans;
    }
};
```
{% endraw %}

## 测试用例

{% raw %}
```cpp
TEST(Daily, 3043) {
    Solution s;

    auto arr1_1 = vector<int>{1, 10, 100};
    auto arr2_1 = vector<int>{1000};
    EXPECT_EQ(s.longestCommonPrefix(arr1_1, arr2_1), 3);

    auto arr1_2 = vector<int>{1, 2, 3};
    auto arr2_2 = vector<int>{4, 4, 4};
    EXPECT_EQ(s.longestCommonPrefix(arr1_2, arr2_2), 0);

    auto arr1_3 = vector<int>{123, 12345, 1234};
    auto arr2_3 = vector<int>{123456};
    EXPECT_EQ(s.longestCommonPrefix(arr1_3, arr2_3), 5);

    auto arr1_4 = vector<int>{100};
    auto arr2_4 = vector<int>{1};
    EXPECT_EQ(s.longestCommonPrefix(arr1_4, arr2_4), 1);
}
```
{% endraw %}

## 总结

这道题的核心在于理解"公共前缀"的定义，以及如何高效地查找最长匹配。关键点是：

1. **前缀生成**：将数字转换为字符串后，可以方便地生成所有前缀
2. **集合查找**：利用 unordered_set 的 O(1) 查找复杂度
3. **逆向搜索**：从最长可能长度开始搜索，可以快速找到最长前缀
4. **字典树优化**：对于更大规模的数据，字典树是更优的选择

这道题展示了两种解决前缀问题的经典方法，是理解字符串处理和搜索算法的很好的练习。
