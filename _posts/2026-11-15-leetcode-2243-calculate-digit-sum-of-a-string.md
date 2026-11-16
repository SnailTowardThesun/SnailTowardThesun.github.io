---
author: SnailTowardThesun
title: "LeetCode刷题的日子--No.2243: 计算字符串的数字和"
categories: LeetCode
tags: [简单, 字符串, 模拟]
---

> 模拟题唯一的陷阱藏在「和是两位数」：13 拼进新串后，下一轮分组对象是字符 1 和 3，不是数字 13——回到逐位表示，一切都顺了。

## 题目

LeetCode 2243. Calculate Digit Sum of a String（计算字符串的数字和）

Difficulty: **Easy**

给你一个由若干数字字符（`0`-`9`）组成的字符串 `s` 和一个整数 `k`。

如果 `s` 的长度**大于** `k`，可以执行一轮操作：

- 把 `s` 分割成长度为 `k` 的**连续组**（最后一组长度可能小于 `k`）；
- 再用每组数字之和组成的新字符串替换 `s`。

不断执行直到 `s` 的长度小于等于 `k`，返回最终的 `s`。

约束：

- `1 <= s.length <= 100`
- `2 <= k <= 100`
- `s` 仅由数字字符组成

### 示例

```text
输入：s = "11111222223", k = 3
输出："135"
解释：第一轮 111|112|222|23 -> 3+4+6+5 = "3465"；
     第二轮 346|5 -> 13+5 = "135"，长度 3 <= 3 结束。

输入：s = "00000000", k = 3
输出："000"
```

## 解题思路

### 按题意模拟，盯住「两位数的和」

每轮三步：

1. 按下标步长 `k` 切出连续组（最后一段可能不足 `k`）；
2. 组内数字求和，把和的**十进制字符串形式**依次拼接成新串；
3. **按新串逐位重新解析**成数字数组，进入下一轮。

第 3 步是唯一的坑：组的和可能超过一位数（`9+9=18`），它以多个字符拼进新串；下一轮的分组对象是**新串的字符**，`"18"` 会被当作 `1` 和 `8` 分进不同的组。把「和的列表」直接当作下一轮输入就错了——必须回到字符串重新逐位解析。

### 手算示例 1（s = "11111222223", k = 3）

| 轮 | 分组 | 和 | 新串 | 长度检查 |
|----|------|-----|------|---------|
| 1 | 111 \| 112 \| 222 \| 23 | 3, 4, 6, 5 | "3465" | 4 > 3 继续 |
| 2 | 346 \| 5 | 13, 5 | "135" | 3 <= 3 结束 |

答案 `"135"`——第 2 轮的和 `13` 是两位数，若还有第 3 轮它会被拆成 `1`、`3` 分组。

### 复杂度分析

- 时间复杂度：`O(n·log_k n)`——每轮 O(n)，串长约缩减为原来的 1/k（组数），轮数对数级；
- 空间复杂度：`O(n)`。

## 代码实现

C++ 与 Python 逻辑逐行对应（分组求和 → 拼串 → 逐位重解析），点击标签切换查看：

<div class="lang-tabs">
  <input type="radio" id="lt2243-cpp" name="lt2243" checked>
  <input type="radio" id="lt2243-py" name="lt2243">
  <div class="lang-tab-nav">
    <label for="lt2243-cpp">C++</label>
    <label for="lt2243-py">Python</label>
  </div>
  <div class="lang-tab-panels">
    <div class="lang-tab-panel">
{% highlight cpp %}
class Solution {
   public:
    string digitSum(string s, int k) {
        auto ret = s;
        vector<int> arr;
        for (auto i : ret) {
            arr.emplace_back(i - '0');
        }

        while (ret.size() > k) {
            ret = "";
            for (int i = 0; i < arr.size(); i += k) {
                int sum = 0;
                for (int j = i; j < i + k && j < arr.size(); j++) {
                    sum += arr[j];
                }

                ret += to_string(sum);  // 和可能两位数，多位拼入新串
            }

            arr.clear();
            for (auto j : ret) {
                arr.emplace_back(j - '0');  // 按新串逐位重新解析
            }
        }

        return ret;
    }
};
{% endhighlight %}
    </div>
    <div class="lang-tab-panel">
{% highlight python %}
class Solution:
    def digitSum(self, s: str, k: int) -> str:
        ret = s
        arr = [int(i) for i in ret]
        while len(ret) > k:
            groups = [arr[i : i + k] for i in range(0, len(arr), k)]  # 最后一段可能不足 k
            arr = [sum(g) for g in groups]
            ret = "".join(map(str, arr))
            arr = [int(i) for i in ret]  # 和可能是两位数，按新串逐位重新解析

        return ret
{% endhighlight %}
    </div>
  </div>
</div>

### 代码解析

- Python 的切片 `arr[i:i+k]` 自动处理最后一段不足 k 的情形，内层不用判边界；C++ 的内层 `j < i + k && j < arr.size()` 承担同样的截断；
- `arr` 在拼出新串后**整体重建**（Python 重新列表推导 / C++ clear 后重填），这就是「回到逐位表示」的实现；
- 和的拼接：Python `"".join(map(str, arr))`，C++ `ret += to_string(sum)`——多位和自然以多位字符拼入；
- `len(s) <= k` 时循环不执行，原样返回。

## 测试用例

```python
def test_solution() -> None:
    solution = Solution()

    # ---- 官方示例 ----
    assert solution.digitSum("11111222223", 3) == "135"
    assert solution.digitSum("00000000", 3) == "000"

    # ---- 多位数和级联：经历 6 轮才收敛（期望值由参考实现机器算出）----
    assert solution.digitSum("01234567890", 2) == "27"

    # ---- 长度本就不超过 k：原样返回 ----
    assert solution.digitSum("1234", 4) == "1234"
    assert solution.digitSum("1", 2) == "1"

    # ---- 大和触发两位数拆分重组 ----
    assert solution.digitSum("999999999", 3) == "36"
```

C++ 侧在 `TEST(Daily, 2243)` 里用同样的 6 组用例断言，`./tests --gtest_filter='Daily.2243*'` 通过；提交前用「字符串直接分组」的参考实现随机对照 2000 组（k 取 2..100），与两个版本结果全部一致——所有期望值均由参考实现机器算出，不手算。

## 总结

- 模拟题按题意逐步照写：分组 → 求和 → 拼串 → 重解析，每轮长度除以 k，O(n·log_k n)；
- 唯一陷阱是两位数的和：下一轮分组对象是新串的字符，把和列表直接迭代就错了；
- 期望值全部机器生成（多轮级联用例手算极易错），延续「不信任手算」的纪律。
