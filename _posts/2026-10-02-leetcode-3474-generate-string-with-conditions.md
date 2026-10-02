---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3474: 生成满足条件的字符串"
categories: LeetCode
---

> 贪心构造题的两个要点：先满足强约束（T），再处理弱约束（F），修改时尽量靠右以保证字典序最小。

## 题目

LeetCode 3474. Generate a String With Conditions（生成满足条件的字符串）

Difficulty: **Medium**

给你两个字符串 `str1` 和 `str2`，生成一个满足以下条件的字符串：
1. `str1` 中每个 `'T'`：从该位置开始的 `str2.length()` 长度子串必须等于 `str2`
2. 每个 `'F'`：对应子串必须不等于 `str2`
3. 结果长度为 `str1.length() + str2.length() - 1`
4. 不存在满足条件的字符串时返回空串
5. 返回的字符串必须是字典序最小的

### 示例

```
输入：str1 = "TFF", str2 = "ab"
输出：长度为 4 的字典序最小满足条件字符串
约束：位置0子串="ab"，位置1、2的子串均≠"ab"
```

## 解题思路

### 贪心构造 + 约束传播

1. **初始化**：结果容器长度为 `str1.length() + str2.length() - 1`，全部填 `'a'`（字典序最小字符）；另用数组标记每个位置是否已被确定。
2. **处理 T（强约束）**：遍历每个 `'T'`，把对应子串强制设为 `str2`。若某位置已被确定且与 `str2` 冲突，返回空串。
3. **处理 F（弱约束）**：遍历每个 `'F'`，若当前子串已等于 `str2`，必须修改其中一个字符。为保证字典序最小，选择子串中**最右边**的未确定位置，将其循环递增（`a→b`，`z→a`）。若子串内位置全部已确定则无法修改，返回空串。
4. 返回构造结果。

为什么改最右边？字典序优先比较左侧字符，只动最右边的必要位置能让左边保持最小。

### 复杂度分析

- **时间复杂度**：O(m × n)，m 为 str1 长度，n 为 str2 长度。
- **空间复杂度**：O(m + n)。

## 代码实现

```cpp
class Solution {
   public:
    string generateString(string str1, string str2) {
        int str1_m = str1.length();
        int str2_n = str2.length();

        vector<int> position_container(str1_m + str2_n - 1, 0);  // 0未确定, 1已确定
        vector<char> container(str1_m + str2_n - 1, 'a');

        // 处理 T
        for (auto i = 0; i < str1.length(); i++) {
            if (str1.at(i) == 'T') {
                if (i + str2_n > position_container.size()) return "";
                for (int j = i; j < i + str2_n; j++) {
                    if (position_container[j] == 1 && container[j] != str2.at(j - i)) return "";
                    container[j] = str2.at(j - i);
                    position_container[j] = 1;
                }
            }
        }

        // 处理 F
        for (auto i = 0; i < str1.length(); i++) {
            if (str1.at(i) == 'F') {
                if (i + str2_n > position_container.size()) continue;
                bool is_equal = true;
                for (int j = i; j < i + str2_n; j++) {
                    if (container[j] != str2.at(j - i)) { is_equal = false; break; }
                }
                if (!is_equal) continue;

                // 找最右边可修改位置
                int modify_pos = -1;
                for (int j = i + str2_n - 1; j >= i; j--) {
                    if (position_container[j] == 0) { modify_pos = j; break; }
                }
                if (modify_pos == -1) return "";
                container[modify_pos] = (container[modify_pos] - 'a' + 1) % 26 + 'a';
                position_container[modify_pos] = 1;
            }
        }

        return string(container.begin(), container.end());
    }
};
```

### 代码解析

- T 必须先处理，因为它强制锁定位置；F 只需避开相等，约束更弱。
- 修改位置取 `j` 从右往左扫描的第一个未确定点。

## 测试用例

```cpp
TEST(Daily, 3474) {
    Solution s;
    string str1_long = "TFFF...FFFT";
    string str2_long = "baaa...ab";
    auto ret = s.generateString(str1_long, str2_long);
    // 期望为构造出的长字符串（完整用例见源文件）
    EXPECT_FALSE(ret.empty());
}
```

## 总结

1. 先 T 后 F，强约束优先锁定位置；
2. F 需要破坏相等时，改最右边的未确定字符，保证字典序最小；
3. 所有位置都被锁定且仍相等时无解。
