---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.211: 添加与搜索单词 - 数据结构设计"
categories: LeetCode
tags: [中等, 字典树, 深度优先搜索, 设计]
---

> 遇到通配符「不知道该走哪条边」时，标准答案是让所有可能状态并行前进：Trie 遇 `.` 就把全部孩子纳入候选逐层展开。这与正则引擎的 NFA 模拟、BFS 的「按层扩展」是同一个思想——不确定，就都带上。

## 题目

LeetCode 211. Design Add and Search Words Data Structure（添加与搜索单词 - 数据结构设计）

Difficulty: **Medium**

请你设计一个数据结构，支持添加新单词和查找字符串是否与任何先前添加的字符串匹配。

实现词典类 `WordDictionary`：

- `WordDictionary()` 初始化词典对象。
- `addWord(word)` 将 `word` 添加到词典中，可以对它进行匹配。
- `search(word)` 如果数据结构中存在字符串与 `word` 匹配，返回 `true`；否则返回 `false`。`word` 中可能包含一些 `.`，每个 `.` 都可以表示**任何一个字母**。

### 示例

```
输入：
["WordDictionary", "addWord", "addWord", "addWord", "search", "search", "search", "search"]
[[], ["bad"], ["dad"], ["mad"], ["pad"], ["bad"], [".ad"], ["b.."]]
输出：
[null, null, null, null, false, true, true, true]
```

## 解题思路

### 结构沿用 208 的 Trie

节点仍是两件套：`child`（字符到子节点的映射）和 `is_end`（单词结尾标记），`WordDictionary` 类自身就是根节点。`addWord` 与 208 题完全一样：逐字符下行，缺节点现场创建，末尾打词尾标记。

### search：逐层候选集合

`.` 无法定位到具体分支，于是退一步做**按层扩展**——维护「当前层候选节点集合 `curs`」，每个字符消耗一层：

1. 字符是 `.`：把**所有候选的所有孩子**收进下一层；
2. 字符是实字符：把**每个候选中名为该字符的孩子**收进下一层；
3. 某层收完为空即失败（长度不匹配、路径断裂都自然落空）；
4. 所有字符消耗完后，候选中**任一** `is_end` 为真即命中。

### 开发中踩过的三个坑

这题的实际开发被自己的测试抓过三次，都很典型：

1. **取错节点**：第二层开始误写成根节点的 `self.child[ch]`，官方示例直接 `KeyError`——多级下行必须用**当前候选** `cur` 的孩子表；
2. **字符接不上时没失败**：某层没有任何候选能接住当前字符时，若候选集原封不动，后续字符会「白拿」旧候选，末尾错误地检查了错误层次的 `is_end`——词库里只有 `abc` 时 `search("abcd")` 竟然返回真；
3. **只收第一个命中就 break**：`.` 展开出多个分支后，某实字符若只保留第一个命中的分支，其他分支的词尾就被丢弃——词库 `{'aaaa', 'aabab'}` 查 `'.....'` 会误判为假。两个分支都必须**追加**而不是**替换**。

### 复杂度分析

| 操作 | 时间 | 说明 |
|------|------|------|
| addWord | `O(L)` | `L` 为单词长度 |
| search（无点） | `O(L)` | 逐字符下行 |
| search（最坏） | `O(26^(L-1))` | 全点模式，与词库大小无关 |

## 代码实现

```python
class WordDictionary:
    def __init__(self):
        self.child = {}
        self.is_end = False

    def addWord(self, word: str) -> None:
        cur = self
        for ch in word:
            if cur.child.get(ch) is None:
                cur.child[ch] = WordDictionary()
            cur = cur.child[ch]

        cur.is_end = True

    def search(self, word: str) -> bool:
        curs = [self]
        for ch in word:
            pre = curs
            curs = []
            for cur in pre:
                if ch == ".":
                    curs.extend(cur.child.values())
                elif cur.child.get(ch) is not None:
                    curs.append(cur.child[ch])

        for cur in curs:
            if cur.is_end:
                return True
        return False
```

### 代码解析

- **每层先落空再收集**：`curs = []` 后逐候选追加，接不上时集合自然为空，天然覆盖「长度不同即失败」；
- **`.` 分支放在前面**：点永远不会是存储在 `child` 里的键，先判点语义更清晰；
- **无 break 的聚合**：实字符与点都遍历完所有候选再整体换层，多分支词尾不会被提前剪掉；
- **词尾检查在层末**：`is_end` 只在全部字符消耗完后检查，避免把中间节点误当单词。

## 测试用例

```python
def test_word_dictionary():
    wd = WordDictionary()
    wd.addWord("bad")
    wd.addWord("dad")
    wd.addWord("mad")
    assert not wd.search("pad") and wd.search("bad")
    assert wd.search(".ad") and wd.search("b..")

    # '.' 恰好匹配一个字符：不是零个也不是多个
    wd = WordDictionary()
    wd.addWord("a")
    assert wd.search(".")
    wd = WordDictionary()
    wd.addWord("ab")
    assert not wd.search(".") and wd.search("..") and not wd.search("...")
```

完整测试另含点在首/中/尾、单词互为前缀、重复添加、空字典查询，以及 3 轮 × 600 次随机插入/查询与「集合 + 逐字符对照」朴素解法的对拍——上面三个坑全部由这套对拍抓获。

## 总结

- `.` 把确定性下行变成不确定性，解法从「一条路走到底」升级为「逐层维护候选集合」；
- 聚合候选时**追加**而非替换、接不上时让集合落空，是这类 BFS 式展开的两个不变式；
- 测试先行 + 随机对拍对「数据结构设计」题收益极高：官方示例只覆盖浅层路径，深层的分支丢失只有长随机流能暴露。
