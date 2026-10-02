---
layout: article
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2069: 模拟行走机器人 II"
categories: LeetCode
---

> 机器人沿矩形边界走，本质是在一个周长为 `2*(w+h-2)` 的环上循环——用总步数对周长取模，再按区间判断位置和朝向。

## 题目

LeetCode 2069. Walking Robot Simulation II（模拟行走机器人 II）

Difficulty: **Medium**

给你一个在 XY 平面上的 `width × height` 的网格，左下角在 `(0, 0)`，右上角在 `(width-1, height-1)`。机器人从 `(0, 0)` 出发，面朝东方。机器人始终沿网格边界行走（不会走入内部）。

实现 `Robot` 类：
- `Robot(int width, int height)`：初始化网格
- `void step(int num)`：执行 `num` 步
- `vector<int> getPos()`：返回当前位置 `[x, y]`
- `string getDir()`：返回当前朝向（"East"/"North"/"West"/"South"）

### 示例

```
输入：
["Robot", "step", "getPos", "getDir"]
[[6, 3], [2], [], []]
输出：[null, null, [4, 0], "East"]
解释：机器人从 (0,0) 向东走 2 步到 (2,0)。（注：示例数值仅供参考）
```

## 解题思路

### 环形路径 + 取模定位

机器人沿网格边界行走，路径是一个闭合的环，周长为 `perimeter = 2 * (width + height - 2)`。

将总步数 `_current_step` 对周长取模，然后根据步数所在区间判断位置和朝向：

| 区间 | 朝向 | 位置计算 |
|------|------|----------|
| `[0, width)` | East | `(step, 0)` |
| `[width, width+height-1)` | North | `(width-1, step-width+1)` |
| `[width+height-1, 2*width+height-2)` | West | `(2*w+h-step-3, height-1)` |
| `[2*width+height-2, perimeter)` | South | `(0, 2*(w+h)-step-4)` |

`step` 的更新用 `(_current_step + num - 1) % perimeter + 1`，保证步数从 1 开始计数。

### 复杂度分析

- **时间复杂度**：`step`、`getPos`、`getDir` 均为 O(1)。
- **空间复杂度**：O(1)。

## 代码实现

```cpp
class Robot {
   private:
    int _width{0};
    int _height{0};
    int _current_step{0};

   public:
    Robot(int width, int height) : _width(width), _height(height) {}

    void step(int num) {
        _current_step = (_current_step + num - 1) % ((_width + _height - 2) * 2) + 1;
    }

    std::vector<int> getPos() {
        if (_current_step < _width) {  // 东边
            return std::vector<int>{_current_step, 0};
        } else if (_current_step < _width + _height - 1) {  // 北边
            return std::vector<int>{_width - 1, _current_step - _width + 1};
        } else if (_current_step < 2 * _width + _height - 2) {  // 西边
            return std::vector<int>{2 * _width + _height - _current_step - 3, _height - 1};
        } else {  // 南边
            return std::vector<int>{0, 2 * (_width + _height) - _current_step - 4};
        }
    }

    std::string getDir() {
        if (_current_step < _width) return "East";
        else if (_current_step < _width + _height - 1) return "North";
        else if (_current_step < 2 * _width + _height - 2) return "West";
        else return "South";
    }
};
```

### 代码解析

- 周长 `2*(width+height-2)`：四条边长度之和，每个角不重复计算。
- `getPos` 和 `getDir` 用相同的区间划分，保证位置与朝向一致。

## 测试用例

```cpp
TEST(Daily, 2069) {
    Robot robot(3, 4);
    robot.step(3);
    auto param_2 = robot.getPos();
    auto param_3 = robot.getDir();
    std::cout << param_2.size() << std::endl;
    std::cout << param_3 << std::endl;
}
```

## 总结

本题的核心是把矩形边界行走转化为**环形路径上的取模定位**：

1. 周长 = `2*(width+height-2)`；
2. 总步数对周长取模；
3. 按东→北→西→南四段区间计算坐标和朝向。
