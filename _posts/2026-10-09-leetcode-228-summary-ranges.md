---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.228: 汇总区间"
categories: LeetCode
---

> 区间汇总是日志分析系统的日常操作，把离散时间点合并成时间段能大幅压缩存储和提升可读性。

## 题目

LeetCode 228. Summary Ranges（汇总区间）

Difficulty: **Easy**

给定一个**无重复元素**的**有序**整数数组 `nums`，返回恰好覆盖数组中所有数字的**最小有序区间范围**列表。也就是说，`nums` 的每个元素都恰好被某个区间范围所覆盖，并且不存在属于某个范围但不属于 `nums` 的数字。

列表中的每个区间范围 `[a,b]` 应该按如下格式输出：

- `"a->b"`：如果 `a != b`
- `"a"`：如果 `a == b`

### 示例

{% raw %}
```
输入：nums = [0,1,2,4,5,7]
输出：["0->2","4->5","7"]
解释：区间范围是：
[0,2] --> "0->2"
[4,5] --> "4->5"
[7,7] --> "7"

输入：nums = [0,2,3,4,6,8,9]
输出：["0","2->4","6","8->9"]
```
{% endraw %}

## 解题思路

### 双指针扫描连续段

数组有序且无重复，连续段的特征非常明确：**相邻元素差 1**。用两个指针把数组切成若干连续段：

1. 外层指针 `left` 指向当前段的起点；
2. 内层指针 `right` 从 `left + 1` 右移，只要 `nums[right] == nums[right-1] + 1` 就继续延伸；一旦断开（差值不为 1）立即停止；
3. 段的输出：
   - `right` 停在 `left + 1` 之后 → 段长大于 1，输出 `"起点->终点"`；
   - 否则段里只有一个元素，直接输出 `"起点"`；
4. `left = right`，开始下一段。

以 `[0,1,2,4,5,7]` 为例：`right` 从下标 1 走到 3 时发现 `4 != 2+1` 停止，输出 `"0->2"`；下一段 `4,5` 同理输出 `"4->5"`；最后的 `7` 孤立，输出 `"7"`。

### 复杂度分析

- **时间复杂度**：O(n)，每个元素只被访问一次。
- **空间复杂度**：O(1)，不计输出数组。

## 代码实现

```cpp
class Solution {
   public:
    vector<string> summaryRanges(vector<int> &nums) {
        vector<string> ret;

        int left = 0;
        while (left < nums.size()) {
            string tmp = to_string(nums[left]);
            int right = left + 1;
            while (right < nums.size()) {
                if (nums[right] != nums[right - 1] + 1) {
                    break;
                }
                right++;
            }

            if (right > left + 1) {
                tmp += "->";
                tmp += to_string(nums[right - 1]);
            }
            ret.push_back(tmp);
            left = right;
        }

        return ret;
    }
};
```

### 代码解析

- **`right` 停在哪很重要**：循环退出时 `nums[right]` 已不连续，段的最后一个元素是 `nums[right - 1]`，拼接终点时要取 `right - 1`。
- **单元素判定**：`right > left + 1` 即"至少延伸过一次"，反之为孤立元素，两个分支覆盖所有情况。
- **`to_string` 拼接**：直接把数字转字符串累加，避免 `sprintf` 等更繁琐的格式化操作。

## 测试用例

{% raw %}
```cpp
TEST(top150, 228) {
    Solution s;
    // 混合连续段与孤立点
    vector<int> nums{0, 1, 2, 4, 5, 7};
    auto ret = s.summaryRanges(nums);
    EXPECT_EQ(ret.size(), 3);
    EXPECT_EQ(ret[0], "0->2");
    EXPECT_EQ(ret[1], "4->5");
    EXPECT_EQ(ret[2], "7");
}
```
{% endraw %}

## 总结

1. 有序无重复数组中，差 1 即连续；
2. `right` 断开时回退一步取段尾，长度 1 的段输出单元素；
3. 一次扫描 O(n)，两个指针各走一遍。
