---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.380: O(1) 时间插入、删除和获取随机元素"
categories: LeetCode
---

> 等概率取随机值依赖连续存储的数组；数组删中间又是 O(n)——解法是「待删元素与末尾交换后删尾」，哈希表负责 O(1) 定位。

## 题目

LeetCode 380. Insert Delete GetRandom O(1)

Difficulty: **Medium**

实现集合类，insert、remove、getRandom 均为平均 O(1)，getRandom 等概率返回任一元素。

### 示例

```
insert(1) -> true
remove(2) -> false
insert(2) -> true
getRandom() -> 1 或 2（等概率）
remove(1) -> true
insert(2) -> false
getRandom() -> 2
```

## 解题思路

### 哈希表 + 动态数组（标准做法）

- vector：存元素，支持下标 O(1) 随机访问，getRandom 按下标等概率取。
- unordered_map：值 → 数组下标，insert/remove O(1) 定位。
- 删除关键：把待删位置的值替换为数组末尾元素（同步更新哈希表中末尾元素的下标），再 pop_back，避免移动中间元素。

当前源文件使用 unordered_set，getRandom 时把集合整体拷入 vector，实际为 O(n)；严格满足要求应采用上述结构。

### 复杂度分析

- 标准做法：三个操作平均 O(1)，空间 O(n)。
- 当前实现：getRandom O(n)。

## 代码实现

```cpp
class RandomizedSet {
    vector<int> values;
    unordered_map<int, int> index;  // 值 -> 在 values 中的下标

public:
    bool insert(int val) {
        if (index.count(val)) return false;
        index[val] = values.size();
        values.push_back(val);
        return true;
    }

    bool remove(int val) {
        auto it = index.find(val);
        if (it == index.end()) return false;

        int pos = it->second;
        int last_val = values.back();
        values[pos] = last_val;       // 末尾元素覆盖待删位置
        index[last_val] = pos;        // 更新末尾元素下标
        values.pop_back();
        index.erase(it);
        return true;
    }

    int getRandom() {
        return values[rand() % values.size()];
    }
};
```

### 代码解析

- 删除单元素（删的恰是末尾）时「覆盖 + 更新下标」仍自洽：pos 就是末尾位置。

## 测试用例

```cpp
TEST(TOP150, No380_RandomizedSet) {
    RandomizedSet set;
    EXPECT_TRUE(set.insert(1));
    EXPECT_FALSE(set.remove(2));
    EXPECT_TRUE(set.insert(2));
    int r = set.getRandom();
    EXPECT_TRUE(r == 1 || r == 2);
    EXPECT_TRUE(set.remove(1));
    EXPECT_FALSE(set.insert(2));
    EXPECT_EQ(2, set.getRandom());
}
```

## 总结

1. 数组保证随机访问，哈希表保证定位；
2. 交换删尾是 O(1) 删除的核心技巧；
3. 同步维护两份数据结构，别忘了更新被移动元素的下标。
