---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.150: 逆波兰表达式求值"
categories: LeetCode
tags: 中等
---

> 后缀表达式没有括号，运算符直接作用于它前面的两个操作数——用栈顺序处理即可，这也是虚拟机字节码执行的基本模型。

## 题目

LeetCode 150. Evaluate Reverse Polish Notation（逆波兰表达式求值）

Difficulty: **Medium**

给定逆波兰表示法的 token 数组，操作数为整数，运算符为 +、-、*、/，除法向零取整，无除零情况。返回表达式的整数值。

### 示例

```
输入：tokens = ["2","1","+","3","*"]
输出：9，即 (2+1)*3

输入：tokens = ["4","13","5","/","+"]
输出：6，即 4 + (13/5)
```

## 解题思路

### 栈模拟

1. 数字 token 转成整数入栈。
2. 运算符 token：连续弹出 last、pre 两个操作数，按 `pre op last` 计算，结果入栈。
3. 最终栈中唯一元素即答案。

减法和除法操作数顺序关键：先弹出的是右操作数。

### 复杂度分析

- **时间复杂度**：O(n)。
- **空间复杂度**：O(n)。

## 代码实现

```cpp
class Solution {
public:
    int evalRPN(vector<string>& tokens) {
        stack<int> container;
        container.emplace(stoi(tokens[0]));
        int ret = stoi(tokens[0]);

        for (int i = 1; i < (int)tokens.size(); i++) {
            if (tokens[i] == "+" || tokens[i] == "-" ||
                tokens[i] == "*" || tokens[i] == "/") {
                int last = container.top(); container.pop();
                int pre = container.top(); container.pop();
                if (tokens[i] == "+") ret = pre + last;
                else if (tokens[i] == "-") ret = pre - last;
                else if (tokens[i] == "*") ret = pre * last;
                else ret = pre / last;
                container.emplace(ret);
            } else {
                container.emplace(stoi(tokens[i]));
            }
        }
        return ret;
    }
};
```

### 代码解析

- 源文件把四种运算分成四个分支；合并 token 判断后结构更紧凑。
- 除法靠 C++ 整数除法天然向零截断（与题意一致）。

## 测试用例

```cpp
TEST(top150, 150) {
    Solution s;
    vector<string> tokens{"2", "1", "+", "3", "*"};
    EXPECT_EQ(9, s.evalRPN(tokens));
}
```

## 总结

1. 后缀表达式用栈即可线性求值；
2. 操作数弹出顺序决定减除法结果；
3. 同一模型用于表达式编译器与栈式虚拟机。

## 补充：Top 150 C++ 实现

以下是当前 Top 150 源码中的实现，已同步到 `cplusplus/questions/150.cpp`。

{% raw %}
```cpp
#include <stack>

using namespace std;

class Solution {
   public:
    int evalRPN(vector<string>& tokens) {
        stack<int> container;
        container.emplace(stoi(tokens[0]));

        int ret = stoi(tokens[0]);
        for (auto i = 1; i < tokens.size(); i++) {
            if (tokens[i] == "+") {
                // pop two to add
                int last = container.top();
                container.pop();
                int pre = container.top();
                container.pop();

                ret = pre + last;
                container.emplace(ret);

            } else if (tokens[i] == "-") {
                int last = container.top();
                container.pop();
                int pre = container.top();
                container.pop();

                ret = pre - last;
                container.emplace(ret);

            } else if (tokens[i] == "*") {
                int last = container.top();
                container.pop();
                int pre = container.top();
                container.pop();

                ret = pre * last;
                container.emplace(ret);

            } else if (tokens[i] == "/") {
                int last = container.top();
                container.pop();
                int pre = container.top();
                container.pop();

                ret = pre / last;
                container.emplace(ret);

            } else {
                container.emplace(stoi(tokens[i]));
            }
        }

        return ret;
    }
};
```
{% endraw %}

### 补充说明

- 该实现与 Top 150 源码保持一致；若与前文旧实现不同，以本节当前版本为准。
- 代码保留源码中的关键注释（如有），便于对照变量含义和边界处理。
