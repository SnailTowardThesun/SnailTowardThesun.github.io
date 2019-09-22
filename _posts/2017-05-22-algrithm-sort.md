---
layout: article
author: SnailTowardThesun
title: 算法系列--各种排序
categories: 算法系列
---

# 算法系列--各种排序
算法系列，也算是一个总结 + 复习的系列了。因为最近看的《算法（第四版）》就是从排序开始讲起的，那我也有学有样从排序开始写起了。

## 选择排序
```
for (size_t i = 0; i < m_data_list.size(); i++)
{
    for (size_t j = i; j < m_data_list.size() - 1; j++)
    {
        if (m_data_list[i] > m_data_list[j + 1])
            swap(m_data_list[i], m_data_list[j + 1]);
    }
}
```

## 插入排序
```
for (size_t i = 1; i < m_data_list.size(); i++)
{
    for (size_t j = i; j > 0; j--)
    {
        if (m_data_list[j] < m_data_list[j - 1])
            swap(m_data_list[j], m_data_list[j - 1]);
    }
}
```

## 希尔排序
```
int N = m_data_list.size();
int h = 0;
while(h < N/3)
{
    h = 3*h + 1;
}

while(h >= 1)
{
    for (int i = h; i < N; ++i)
    {
        for (int j = i; j >= h && m_data_list[j] < m_data_list[j - h]; j -= h)
        {
            swap(m_data_list[j], m_data_list[j-h]);
        }
    }
    h = h/3;
}
```
## 归并排序
自顶向下的归并排序
```
void CMergeSort::merge_sort_top2bottom(vector<long> &data, int lo, int hi)
{
    if (lo >= hi) return;
    if (hi - lo <= ARRAY_LENGTH_WHEN_USING_INSERTION_SORT)
    {
        CInsertionSort::sort_part(data, lo, hi);
        return;
    }
    int mid = lo + (hi - lo)/2;
    merge_sort_top2bottom(data, lo, mid);
    merge_sort_top2bottom(data, mid + 1, hi);
    merge_array(data, lo, mid, hi);
}

void CMergeSort::merge_array(vector<long> &array, int lo, int mid, int hi)
{
    int i = lo, j = mid + 1;
    vector<long> aux(hi+1, 0);
    for (int k = lo; k <= hi; k++)
    {
        aux[k] = array[k];
    }
    for (int k = lo; k <= hi; k++)
    {
        if (i > mid)
        {
            array[k] = aux[j++];
        }
        else if (j > hi)
        {
            array[k] = aux[i++];
        }
        else if (aux[i]<aux[j])
        {
            array[k] = aux[i++];
        }
        else
        {
            array[k] = aux[j++];
        }
    }
}
```

自底向上
```
void CMergeSort::merge_sort_bottom2top(vector<long> &data)
{
    auto N = data.size();
    for (auto sz = 1; sz  < N; sz += sz) 
    {
        for (auto lo = 0; lo < N-sz; lo += sz + sz) 
        {
            auto hi = (lo+sz+sz-1 < N - 1) ? lo+sz+sz-1 : N-1;
            merge_array(data, lo, lo+sz-1, hi);
        }
    }
}
```

## 快速排序
```
bool CQuickSort::quick_sort(vector<long>& array, int start, int end)
{
    if (start < end)
    {
        int q = Partition(array, start, end); // divide into two parts
        quick_sort(array, start, q - 1);
        quick_sort(array, q + 1, end);
    }
    return true;
}

int CQuickSort::Partition(vector<long>& data, int start, int end)
{
    long x = data[start];
    int i = start;
    for (int j = start + 1; j <= end; j++)
    {
        if (data[j] <= x)
        {
            i++;
            swap(data[i], data[j]);
        }
    }
    swap(data[i], data[start]);
    return i;
}
```
