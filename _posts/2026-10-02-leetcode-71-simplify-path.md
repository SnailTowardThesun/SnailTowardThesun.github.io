---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.71: 简化路径"
categories: LeetCode
---

> ".." 的本质是撤销上一次入栈操作，"." 是空操作——把路径按斜杠切开后，这就是一个简单的栈处理问题。

## 题目

LeetCode 71. Simplify Path（简化路径）

Difficulty: **Medium**

给定 Unix 风格绝对路径，转换为规范路径：多个 '/' 合并、"." 忽略、".." 回退一级、不以 '/' 结尾（根目录除外）。

### 示例

```
输入："/home/user/Documents/../Pictures"
输出："/home/user/Pictures"

输入："/home//foo/"
输出："/home/foo"
```

## 解题思路

### 分词 + 栈

1. 遍历路径，以 '/' 为分隔，累积出每个非空 token。
2. 按规则处理：
   - ".."：栈非空则弹栈（根目录之上不再回退）
   - "."：跳过
   - 普通名：入栈
3. 从栈底到栈顶拼接，每段前加 '/'，去掉结果末尾的多余斜杠。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(n)。

## 代码实现

```cpp
class Solution {
public:
    string simplifyPath(string path) {
        vector<string> container;
        string tmp = "";
        for (char i : path) {
            if (i == '/') {
                if (tmp != "") container.emplace_back(tmp);
                tmp = "";
                continue;
            }
            tmp += i;
        }
        if (tmp != "") container.emplace_back(tmp);

        vector<string> simple_container;
        for (const string& i : container) {
            if (i == "..") {
                if (!simple_container.empty()) simple_container.pop_back();
            } else if (i == ".") {
                continue;
            } else {
                simple_container.emplace_back(i);
            }
        }

        string ret = "/";
        for (const string& i : simple_container) {
            ret += i;
            ret += '/';
        }
        if (ret.size() > 1 && ret.back() == '/') ret.pop_back();
        return ret;
    }
};
```

### 代码解析

- 分词循环遇到 '/' 只在 tmp 非空时入列表，天然合并连续斜杠。
- 根目录的 ".." 靠「栈空不弹」处理，结果始终以 '/' 开头。

## 测试用例

```cpp
TEST(top150, 71) {
    Solution s;
    EXPECT_EQ(s.simplifyPath("/home/user/Documents/../Pictures"), "/home/user/Pictures");
    EXPECT_EQ(s.simplifyPath("/../"), "/");
}
```

## 总结

1. 按 '/' 切 token，连续斜杠自动合并；
2. ".." 弹栈、"." 跳过、其他入栈；
3. 栈空结果就是 "/"，根目录回退不出界。
