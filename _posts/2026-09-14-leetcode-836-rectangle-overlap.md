---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.836: 矩形重叠"
categories: LeetCode
---

> 矩形重叠判定是游戏碰撞检测中 AABB（轴对齐包围盒）算法的核心，GUI 窗口命中测试、图形框选也都离不开它。

## 题目

LeetCode 836. Rectangle Overlap（矩形重叠）

Difficulty: **Easy**

矩形以 `[x1, y1, x2, y2]` 的形式表示，其中 `(x1, y1)` 为左下角坐标，`(x2, y2)` 为右上角坐标。矩形的上下边与 x 轴平行，左右边与 y 轴平行。

如果两个矩形相交的**面积为正**，则称它们重叠。仅在角或边上接触的两个矩形不算重叠。给定两个矩形 `rec1` 和 `rec2`，重叠返回 `true`，否则返回 `false`。

### 示例

```
示例 1：
输入：rec1 = [0,0,2,2], rec2 = [1,1,3,3]
输出：true

示例 2：
输入：rec1 = [0,0,1,1], rec2 = [1,0,2,1]
输出：false
解释：两个矩形仅在一条边上接触，相交面积为 0，不算重叠。

示例 3：
输入：rec1 = [0,0,1,1], rec2 = [2,2,3,3]
输出：false
```

## 解题思路

### 核心思路：坐标轴投影

两个轴对齐矩形的重叠关系，可以拆到两个独立的坐标轴上分别判断：

- 投影到 **x 轴**：两矩形的投影区间分别是 `[x1, x2]`，交叠区间为 `[max(x1), min(x2)]`。交叠长度为正的条件是：

```
max(rec1[0], rec2[0]) < min(rec1[2], rec2[2])
```

- 投影到 **y 轴**：投影区间分别是 `[y1, y2]`，同理交叠长度为正的条件是：

```
max(rec1[1], rec2[1]) < min(rec1[3], rec2[3])
```

二维矩形面积为正地重叠，当且仅当 **x、y 两个方向的投影都严格相交**，两个条件取与即可。

### 为什么必须是严格不等号「<」？

这是本题唯一的坑点：题目要求相交**面积为正**。当两个矩形只是边贴着边（如示例 2 中 `rec1[2] == rec2[0] == 1`）时，投影区间在端点处相接，交叠长度为 0，面积也为 0，不算重叠。因此判定必须用 `<` 而不是 `<=`；角接触同理（两个方向都退化为点，长度均为 0）。

### 另一种等价思路：排除法

也可以枚举「不重叠」的四种位置关系——rec1 完全在 rec2 的左、右、下、上：

```
rec1[2] <= rec2[0]  // rec1 在 rec2 左边
rec1[0] >= rec2[2]  // 右边
rec1[3] <= rec2[1]  // 下边
rec1[1] >= rec2[3]  // 上边
```

四种情况都不成立即为重叠。与投影法数学上完全等价，投影法的代码更对称直观。

### 复杂度分析

- **时间复杂度**：O(1)，只做常数次取最值与比较。
- **空间复杂度**：O(1)，只使用常数个额外变量。

## 代码实现

{% raw %}
```cpp
class Solution {
   public:
    bool isRectangleOverlap(vector<int>& rec1, vector<int>& rec2) {
        // x 轴投影交叠区间 [max_left, min_right]，严格小于才有正长度
        int max_left = max(rec1[0], rec2[0]);
        int min_right = min(rec1[2], rec2[2]);

        // y 轴投影交叠区间 [max_bottom, min_top]，严格小于才有正长度
        int max_bottom = max(rec1[1], rec2[1]);
        int min_top = min(rec1[3], rec2[3]);

        // 两个方向都严格相交，矩形才面积为正地重叠
        return max_left < min_right && max_bottom < min_top;
    }
};
```
{% endraw %}

### 代码解析

- 四行核心计算分别求出两个坐标轴上交叠区间的左右（上下）端点。
- 最后的返回值是两个布尔条件的与运算：任何一个方向不相交，二维上就不可能重叠。
- 全程只用 `max/min` 做比较，不做减法，天然避免了整数溢出问题。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 836) {
    Solution s;

    // 基本用例：部分重叠
    vector<int> rec1{0, 0, 2, 2};
    vector<int> rec2{1, 1, 3, 3};
    EXPECT_TRUE(s.isRectangleOverlap(rec1, rec2));

    // 边界用例：仅在一条边上接触，面积为 0，不算重叠
    vector<int> rec3{0, 0, 1, 1};
    vector<int> rec4{1, 0, 2, 1};
    EXPECT_FALSE(s.isRectangleOverlap(rec3, rec4));

    // 边界用例：完全分离
    vector<int> rec5{0, 0, 1, 1};
    vector<int> rec6{2, 2, 3, 3};
    EXPECT_FALSE(s.isRectangleOverlap(rec5, rec6));
}
```
{% endraw %}

## 总结

这道 Easy 题的价值在于体会**降维思想**：二维矩形的重叠关系，投影到两条坐标轴后就化归为两个一维区间相交问题，各用一次 `max < min` 判定即可。需要牢记的细节是严格不等号——「接触」不等于「重叠」，面积必须严格为正。同一套投影思想正是游戏物理引擎里 AABB 碰撞检测的基础，当物体数量很大时，还会配合扫描线、空间划分等手段做批量加速。
