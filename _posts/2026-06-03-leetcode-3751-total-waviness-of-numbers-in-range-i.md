---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.3751: 范围内总波动值 I"
categories: LeetCode
---

> 数字序列中的峰谷检测算法在信号处理、趋势分析等场景中经常使用，可以用来识别数据中的局部极值点。

{% raw %}
```cpp
/**
 * @题目描述: 给你两个整数 num1 和 num2，表示一个闭区间 [num1, num2]。
 *           一个数字的波动值定义为该数字中峰和谷的总数：
 *           - 如果一个数位严格大于其两个相邻数位，则该数位为峰。
 *           - 如果一个数位严格小于其两个相邻数位，则该数位为谷。
 *           - 数字的第一个和最后一个数位不能是峰或谷。
 *           - 任何少于 3 位的数字，其波动值均为 0。
 *           返回范围 [num1, num2] 内所有数字的波动值之和。
 * @示例:
 *   示例 1:
 *     输入: num1 = 120, num2 = 130
 *     输出: 3
 *     解释: 120(峰:2) + 121(峰:2) + 130(峰:3) = 3
 *   示例 2:
 *     输入: num1 = 198, num2 = 202
 *     输出: 3
 *     解释: 198(峰:9) + 201(谷:0) + 202(谷:0) = 3
 *   示例 3:
 *     输入: num1 = 4848, num2 = 4848
 *     输出: 2
 *     解释: 4848(峰:8, 谷:4) = 2
 * @解题思路: 枚举法。遍历区间内每个数字，将其转为字符串后检查每个数位是否为峰或谷。
 *           对于每个中间位置的数位，判断是否严格大于或小于相邻两个数位。
 *           时间复杂度: O((num2-num1) * log(num2))，空间复杂度: O(log(num2))。
 */
#include <gtest/gtest.h>
#include <string>
#include <vector>
using namespace std;


class Solution {
public:
    int helper(int n) {
        string num = to_string(n);
        int ret = 0;

        for (int i = 1; i < num.size() - 1; i++) {
            bool p = false;
            bool v = false;
            if (num.at(i) > num.at(i-1) && num.at(i) > num.at(i+1)) {
                p = true;
            }

            if (num.at(i) < num.at(i-1) && num.at(i) < num.at(i + 1)) {
                v = true;
            }

            if (p || v) {
                ret++;
            }
        }

        return ret;
    }
    int totalWaviness(int num1, int num2) {
        int ret = 0;
        for (int i = num1; i <= num2; i++) {
            ret += helper(i);
        }

        return ret;
    }
};

TEST(Daily, 3751) {
    Solution s;

    // 示例 1: num1 = 120, num2 = 130
    auto ret1 = s.totalWaviness(120, 130);
    EXPECT_EQ(3, ret1);

    // 示例 2: num1 = 198, num2 = 202
    auto ret2 = s.totalWaviness(198, 202);
    EXPECT_EQ(3, ret2);

    // 示例 3: num1 = 4848, num2 = 4848
    auto ret3 = s.totalWaviness(4848, 4848);
    EXPECT_EQ(2, ret3);

    // 边界测试: 少于 3 位的数字波动值为 0
    auto ret4 = s.totalWaviness(1, 99);
    EXPECT_EQ(0, ret4);

    // 边界测试: 单个数字 100
    auto ret5 = s.totalWaviness(100, 100);
    EXPECT_EQ(0, ret5);

    // 测试: 1 到 10 的范围（少于 3 位）
    auto ret6 = s.totalWaviness(1, 10);
    EXPECT_EQ(0, ret6);
}
```
{% endraw %}
