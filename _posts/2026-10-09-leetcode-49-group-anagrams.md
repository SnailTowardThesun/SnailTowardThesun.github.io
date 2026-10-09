---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.49: 字母异位词分组"
categories: LeetCode
---

> 字母异位词检测在拼写检查、DNA 序列分析中有广泛应用，排序键法是它最简洁优雅的解法。

## 题目

LeetCode 49. Group Anagrams（字母异位词分组）

Difficulty: **Medium**

给你一个字符串数组 `strs`，将**字母异位词**组合在一起。字母异位词是由重新排列源单词的所有字母得到的新单词，例如 `"eat"` 的字母异位词有 `"ate"`、`"tea"`。可以按任意顺序返回结果列表。

### 示例

{% raw %}
```
输入：strs = ["eat", "tea", "tan", "ate", "nat", "bat"]
输出：[["bat"], ["nat", "tan"], ["ate", "eat", "tea"]]

输入：strs = [""]
输出：[[""]]

输入：strs = ["a"]
输出：[["a"]]
```
{% endraw %}

## 解题思路

### 排序作为哈希键

字母异位词的本质特征：**排序后的结果完全相同**。`"eat"`、`"tea"`、`"ate"` 排序后都是 `"aet"`。

这个特征天然适合做哈希表的 key：

1. 遍历每个字符串，复制一份并排序；
2. 以排序结果为 key，把原字符串追加到该 key 对应的分组；
3. 遍历结束后，哈希表中每个 value 就是一个异位词分组，收集所有 value 即答案。

以示例 1 为例：

```
"eat" → "aet" → 组1
"tea" → "aet" → 组1
"tan" → "ant" → 组2
"ate" → "aet" → 组1
"nat" → "ant" → 组2
"bat" → "abt" → 组3
```

> 进阶：还可以用 26 位质数乘积或字符计数串作为 key，把分组时间从 O(n·k·log k) 优化到 O(n·k)。

### 复杂度分析

- **时间复杂度**：O(n · k log k)，其中 n 是字符串数量，k 是字符串最大长度（每个字符串排序 O(k log k)）。
- **空间复杂度**：O(n · k)，哈希表存储所有字符串内容。

## 代码实现

```cpp
class Solution {
   public:
    vector<vector<string> > groupAnagrams(vector<string> &strs) {
        unordered_map<string, vector<string> > container;
        for (auto str : strs) {
            auto sorted = str;
            sort(sorted.begin(), sorted.end());
            container[sorted].emplace_back(str);
        }

        vector<vector<string> > ret;
        for (auto it : container) {
            ret.emplace_back(it.second);
        }

        return ret;
    }
};
```

### 代码解析

- **`container[sorted]` 的妙用**：`operator[]` 在 key 不存在时自动创建空的 `vector<string>`，一行完成"查找 + 插入"。
- **复制再排序**：`auto sorted = str` 先拷贝，排序只动副本，原字符串保持原样进入分组。
- **收集结果**：遍历哈希表把每个 `it.second`（分组列表）加入结果，分组内顺序与输入顺序一致。

## 测试用例

```cpp
TEST(top150, 49) {
    Solution s;
    // 经典分组
    vector<string> strs{"eat", "tea", "tan", "ate", "nat", "bat"};
    auto ret = s.groupAnagrams(strs);
    EXPECT_EQ(ret.size(), 3);

    // 单个空串
    vector<string> empty{""};
    EXPECT_EQ(s.groupAnagrams(empty).size(), 1);

    // 单字符
    vector<string> single{"a"};
    EXPECT_EQ(s.groupAnagrams(single).size(), 1);
}
```

## 总结

1. 异位词排序后相同，排序结果是天然的哈希 key；
2. `map[key].push_back(str)` 一行完成分组；
3. 时间 O(n·k·log k)，用字符计数 key 可优化到 O(n·k)。
