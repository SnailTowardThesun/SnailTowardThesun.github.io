---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.208: 实现 Trie (前缀树)"
categories: LeetCode
tags: [中等, 字典树, 设计, 字符串]
---

> 前缀树把「公共前缀」折叠成共享路径：输入框自动补全、拼写检查、IP 路由最长前缀匹配，背后都是它。查询代价只与字符串长度有关，与词库规模无关，这正是它对哈希表的优势所在。

## 题目

LeetCode 208. Implement Trie (Prefix Tree)（实现 Trie 前缀树）

Difficulty: **Medium**

**Trie**（发音类似 "try"）或者说**前缀树**是一种树形数据结构，用于高效地存储和检索字符串数据集中的键。这一数据结构有相当多的应用情景，例如自动补全和拼写检查。

请你实现 `Trie` 类：

- `Trie()` 初始化前缀树对象。
- `insert(word)` 向前缀树中插入字符串 `word`。
- `search(word)` 如果字符串 `word` 在前缀树中（即在检索之前已经插入），返回 `true`；否则返回 `false`。
- `startsWith(prefix)` 如果之前已经插入的字符串 `word` 的前缀之一为 `prefix`，返回 `true`；否则返回 `false`。

### 示例

```
输入：
["Trie", "insert", "search", "search", "startsWith", "insert", "search"]
[[], ["apple"], ["apple"], ["app"], ["app"], ["app"], ["app"]]
输出：
[null, null, true, false, true, null, true]
```

## 解题思路

### 节点即树

每个节点只需两样东西：`child`（字符到子节点的映射）和 `is_end`（这个位置是否是某个单词的结尾）。一个巧妙的写法是**让 `Trie` 类本身就是节点**——用户 `new` 出来的那个实例就是根，子节点也是 `Trie` 实例，不用再单独定义 `TrieNode`。

### 三个操作

1. **insert**：从根逐字符下行，缺失的子节点现场创建；走到最后把 `is_end` 置真；
2. **find（公共下行逻辑）**：逐字符下行，中途断路返回 `0`；走完返回 `2`（此处是单词结尾）或 `1`（只是某些单词的前缀）；
3. **search / startsWith** 都复用 `find`：`search` 要求结果为 `2`，`startsWith` 只要求结果**不为 `0`**。

### 最容易写错的地方

`startsWith` 不能写成 `find(prefix) == 1`。如果 `prefix` 恰好也是一个完整单词（例如插入了 `app` 和 `apple` 之后查 `startsWith("app")`），`find` 返回 `2`，`== 1` 就会误判为假。前缀存在与否只看路径是否走得通，与它是不是单词结尾无关。

### 复杂度分析

| 操作 | 时间 | 说明 |
|------|------|------|
| insert / search / startsWith | `O(L)` | `L` 为字符串长度，与词库大小无关 |
| 空间 | `O(总字符数)` | 公共前缀共享节点，实际远小于上界 |

## 代码实现

```python
class Trie:
    def __init__(self):
        self.is_end = False
        self.child = {}

    def insert(self, word: str) -> None:
        cur = self
        for ch in word:
            if cur.child.get(ch) is None:
                cur.child[ch] = Trie()
            cur = cur.child[ch]

        cur.is_end = True

    def find(self, word: str) -> int:
        cur = self
        for ch in word:
            if cur.child.get(ch) is None:
                return 0
            cur = cur.child[ch]

        return 2 if cur.is_end else 1

    def search(self, word: str) -> bool:
        return self.find(word) == 2

    def startsWith(self, prefix: str) -> bool:
        return self.find(prefix) != 0
```

### 代码解析

- **自引用结构**：`cur.child[ch] = Trie()` 把子节点也建成 `Trie`，省掉一个节点类，根与节点同构；
- **三态 `find`**：把「走不通 / 走得通但不是词尾 / 走得通且是词尾」编码为 `0 / 1 / 2`，两个查询接口只是对它做不同阈值判断；
- **`!= 0` 而非 `== 1`**：前缀匹配的语义是「路径存在」，词尾与否不影响判断。

## 测试用例

```python
def test_trie():
    t = Trie()
    t.insert("apple")
    assert t.search("apple")
    assert not t.search("app")  # 只是前缀，不算单词
    assert t.startsWith("app")
    t.insert("app")
    assert t.search("app")

    # 单词互为前缀：startsWith 对「同时是单词」的前缀也必须为真
    t = Trie()
    t.insert("app")
    t.insert("apple")
    assert t.startsWith("app") and t.startsWith("apple")
    assert not t.search("ap") and not t.search("appl")
```

完整测试另含重复插入、多词共享分支，以及 3 轮 × 500 次随机插入/查询与「集合 + `startswith`」朴素解法的对拍——开发时正是这组对拍抓到了 `startsWith` 写成 `== 1` 的边界 bug。

## 总结

- Trie 用「公共前缀共享路径」换取与词库规模无关的 `O(L)` 查询；
- 让类自身充当节点可以少写一个 `TrieNode`，`insert / search / startsWith` 共用同一套下行逻辑；
- 前缀判断只看路径是否存在，别和「是否单词结尾」耦合——这是本题最常见的翻车点。
