---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.1401: 圆和矩形是否有重叠"
categories: LeetCode
---

> 「点到矩形的最近距离」是几何碰撞检测的基石：粒子碰撞、UI 悬停命中、游戏拾取判定都在用它，一行 clamp 加勾股定理就够。

## 题目

LeetCode 1401. Circle and Rectangle Overlapping（圆和矩形是否有重叠）

Difficulty: **Medium**

给你一个以 `(radius, xCenter, yCenter)` 表示的圆，和一个轴对齐矩形，矩形以 `(x1, y1, x2, y2)` 表示，其中 `(x1, y1)` 是左下角坐标，`(x2, y2)` 是右上角坐标。

如果圆和矩形有重叠（即**存在既属于圆又属于矩形的点**），返回 `true`，否则返回 `false`。

注意：圆周上的点也算属于圆，因此**相切的情况算作重叠**。

### 示例

```
示例 1：
输入：radius = 1, xCenter = 0, yCenter = 0, x1 = 1, y1 = -1, x2 = 3, y2 = 1
输出：true
解释：圆与矩形在边 x=1 处相切，存在公共点，算重叠。

示例 2：
输入：radius = 1, xCenter = 1, yCenter = 1, x1 = 1, y1 = -3, x2 = 2, y2 = -1
输出：false

示例 3：
输入：radius = 1, xCenter = 0, yCenter = 0, x1 = -1, y1 = -1, x2 = 3, y2 = 3
输出：true
解释：圆心在矩形内部，圆完全与矩形重叠。
```

## 解题思路

### 核心思路：最近点法

圆与矩形有公共点，等价于**圆心到矩形的最近距离 ≤ radius**。

矩形是轴对齐的，圆心到矩形最近点有一个极简的求法——把圆心坐标逐轴「钳制」到矩形范围内：

```
x = clamp(xCenter, x1, x2)   // 钳到 [x1, x2]
y = clamp(yCenter, y1, y2)   // 钳到 [y1, y2]
```

点 `(x, y)` 就是矩形上离圆心最近的点：

- 圆心在矩形**内部**时，钳制后 `(x, y)` 就是圆心本身，距离为 0，必然重叠（示例 3）；
- 圆心在矩形**外部**时，钳制后的点落在矩形边界上，是真正的最近点。

再用勾股定理判断距离平方是否不超过半径平方：

```
(x - xCenter)² + (y - yCenter)² <= radius²
```

### 三个关键细节

1. **必须用 `<=` 而非 `<`**：题目判定「存在公共点」，圆周上的点属于圆，所以相切（距离恰好等于 radius）算重叠。这与 836 题「面积为正才算重叠」恰好相反，读题不细容易踩坑。
2. **比较距离平方**：全程整数运算，避免 `sqrt` 开方与浮点精度问题。
3. **溢出分析**：`radius ≤ 10⁴`，`radius² ≤ 10⁸`，int 足够，无需 long long。

### 复杂度分析

- **时间复杂度**：O(1)，常数次比较与乘法。
- **空间复杂度**：O(1)。

## 代码实现

{% raw %}
```cpp
class Solution {
public:
    bool checkOverlap(int radius, int xCenter, int yCenter, int x1, int y1, int x2, int y2) {
        // 将圆心钳制到矩形范围内，得到矩形上离圆心最近的点
        int x = clamp(xCenter, x1, x2);
        int y = clamp(yCenter, y1, y2);

        // 最近点距离平方 <= 半径平方，即存在公共点；相切（相等）也算重叠
        return ((x - xCenter)*(x-xCenter) + (y - yCenter) * (y - yCenter)) <= radius * radius;
    }
};
```
{% endraw %}

### 代码解析

- 两行 `clamp` 完成最近点定位：`clamp(v, lo, hi)` 等价于 `min(max(v, lo), hi)`，是 C++17 `<algorithm>` 提供的标准函数。
- 最后一行同时覆盖三种几何情形：圆心在矩形内（距离 0）、圆与矩形相交（距离 < r）、圆与矩形相切（距离 = r），逻辑高度浓缩。

## 测试用例

{% raw %}
```cpp
TEST(Daily, 1401) {
    Solution s;

    // 示例 1：圆与矩形相切，算重叠
    EXPECT_TRUE(s.checkOverlap(1, 0, 0, 1, -1, 3, 1));

    // 示例 2：圆与矩形完全分离
    EXPECT_FALSE(s.checkOverlap(1, 1, 1, 1, -3, 2, -1));

    // 圆心在矩形内部，必然重叠
    EXPECT_TRUE(s.checkOverlap(1, 0, 0, -1, -1, 3, 3));

    // 圆在矩形远处，不重叠
    EXPECT_FALSE(s.checkOverlap(1, 10, 0, 1, -1, 3, 1));
}
```
{% endraw %}

## 总结

这道题是「几何模拟」里的经典最小模型：一段 clamp、一个勾股判定，就把三种几何情形（圆心在矩形内、相交、相切）统一到一个不等式里。值得记住的两点：一是最近点法可以推广——把 clamp 换到其他凸体上就能做「圆与圆角矩形」「胶囊体碰撞」等判定；二是注意本题与 836 题的判定差异——836 要求相交**面积为正**（相切不算），1401 只要求**存在公共点**（相切算），同为「重叠」，边界语义完全相反，读题时务必抠准定义。
