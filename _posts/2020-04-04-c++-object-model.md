---
layout: article
author: SnailTowardThesun
title: C++对象模型
categories: C++
---

# C++ 对象模型

好久之前，就购买了《深度探索C++对象模型》这本书，刚入手时，翻看了好久，觉得受益匪浅。最近发现，这本书中的知识，在脑海中，已经变得很不清晰了，本着好记性不如烂笔头的传统，打算用一段时间，把其中比较重要，尤其是在实际工作中，真的会使用到的知识，做一番整理。今天开始第一篇，系统介绍下C++ 对象模型。


## 简单对象模型（A Simple object model）

在简单对象模型中，一个对象中，包含了一系列的slots。这些slot均为一个指针，所指向的地址，对应的为类中定义的对象或者方法。

比如定义一个类

```
class foo {
public:
    foo();
    ~foo();

    int number;
    int add();
};
```

那么在定义一个对象`obj`之后，`obj`的结构如下：

| slot | meaning|
| --- | --- | 
| 0 | pointer to foo() |
| 1 | pointer to ~foo() |
| 2 | pointer to number |
| 3 | pointer to add(int num) |

在这种模型下，能够避免因为成员类型的不同，而造成额外存储空间的不同，也就是说，所有对象的大小，均为 `成员数量 x sizeof(pointer)`。

> 注意，这种简单的对象模型，这是一个设想，并没有真的在C++语言中被采用。不过这种指向成员指针的思想却在实际C++对象模型中得以继承。


## 表格驱动对象模型（ A Table-driven Object Model）

与简单对象模型不同，表格驱动模型中，区分了成员变量，与成员函数。在一个对象中，会包含两个指针，一个指针指向存储了所有成员变量的表格，一个指针指向存储了所有成员函数指针的表格。

比如定义一个类：

```
class foo {
public:
    foo();
    ~foo();

    int number;
    int count;

    int add();
    int subtract();
    int multiplied();
    int divided();
};
```

那么在定义个`obj`之后，具体的存储方式如下

| pointer | table | table member |
| --- | --- | --- |
| data pointer | data table | number |
| | | count |
| function pointer | function table| pointer to add |
| | | pointer to multiplied |
| | | pointer to divided |

> 注意，这种表格驱动对象模型也没有被C++语言采用，不过`member function table`的观念，被后续的virtual functions的实现所采纳。


## C++对象模型

由Stroustrup最初设计的C++对象模型是从简单模型演变而来的，其中：

* `非静态成员变量(nonstatic data members)`被放置到对象中。

* `静态成员变量(static data members)`被放置在所有对象之外，单独进行存储。

* `非virtual成员函数，包括静态(static)与非静态(nonstatic)`被放置在所有对象之外。

* 每个对象中都增加一个名为`vptr`的指针，该指针指向一个名为`virtual table`的表格，该表格存储了类中定义的所有`虚函数(virtual function)`

### 非继承下的C++对象模型

比如定义一个类：

```
class foo {
public:
    foo();
    ~foo();

    int number;
    static int count;

    int add();
    static int subtract();
    virtual int multiplied();
    virtual int divided();
};
```

那么定义一个`obj`之后，具体的存储方式如下：

| location | member | table member |
| --- | --- |  --- |
| obj | number | --- |
| | vptr | pointer to multiplied() |
| | | pointer to diviede() |
| out of obj | count |
| | add() |
| | substract() | 


### 单一继承下的C++对象模型

在单一继承的C++对象模型中，派生类对象中，会包含所有父类中的`非静态(nonstatic)成员变量`，能够访问类中定义的所有`静态(static)变量`,`静态(static)与非静态(nonstatic)的成员函数`，对于`虚函数(virtual function)`，如果派生类中对虚函数做`重写(overwrite)`，则会覆盖父类中`虚表(virtual table)`中的函数指针。

```
class Point2D {
public:
    int x;
    int y;

    static int count;

    int get_x();
    int get_y();

    virtual int foo();

    static int get_count();
};

class Point3D_0 : public Point2D {
public:
    int z;

    int get_z();
};

class Point3D_1 : public Point2D {
public:
    int z;

    int get_z();

    virtual int foo();
};
```

Point2D obj的内存布局如下:

| location | member | table member |
| --- | --- |  --- |
| obj | x | --- |
| | y | --- |
| | vptr | pointer to Point2D::foo() |
| out of obj | Point2D::count |
| | Point2D::get_x() |
| | Point2D::get_y() |
| | Point2D::get_count() | 


Point3D_0 obj的内存布局如下：

| location | member | table member | table member|
| --- | --- |  --- | --- |
| obj | Point2D | Point2D::vptr | pointer to Point2D::foo() |
|  |  | Point2D::x | --- |
|  |  | Point2D::y | --- |
|  | z | --- |
| out of obj | Point2D::count |
| | Point2D::get_x() |
| | Point2D::get_y() |
| | Point2D::get_count() | 


Point3D_1 obj的内存布局如下：

| location | member | table member | table member|
| --- | --- |  --- | --- |
| obj  | Point2D | Point2D::vptr | pointer to Point3D::foo() |
|  |  | Point2D::x | --- |
|  |  | Point2D::y | --- |
|  | z | --- |
| out of obj | Point2D::count |
| | Point2D::get_x() |
| | Point2D::get_y() |
| | Point2D::get_count() | 


### 多继承（非菱形继承）下的C++对象模型

在多继承（非菱形继承）中，派生类对象会包含所有基类中的`非静态(nonstatic)成员变量`，能够访问类中定义的所有`静态(static)变量`,`静态(static)与非静态(nonstatic)的成员函数`。但是这里需要注意的是`所有基类中的静态(static)与非静态(nonstatic)变量或者函数方法的名字，不能够出现冲突`，否则会造成派生类对象调用时的不明确，编译器会直接报错。

对于`虚函数(virtual function)`，派生类如果没有对父类中的`虚函数(virtual function)`做重写(overwrite)，那么所有父类中的虚函数不能冲突，否则由于调用不明确出现编译错误。如果派生类对父类中的`虚函数(virtual function)`做了重写(overwrite)，那么子类的虚函数被放在声明的第一个基类的虚函数表中。

```
class base1 {
private:
	int a1{ 1 };
public:
	virtual void print() {
		std::cout << "base 1" << std::endl;
	}

	int get_1() { return a1; };
};


class base2 {	
private:
	int a2{ 2 };
public:
	
	virtual void print() {
		std::cout << "base 2" << std::endl;
	}

	int get_2() { return a2; };
};

class child : public base1, public base2 {
private:
	int c{ 0 };
public:
	virtual void print() {
		std::cout << "child" << std::endl;
	}
};
```

child obj 内存布局
| location | member | member |  member|
| --- | --- |  --- | --- |
| obj  | base1 | base1::vptr | pointer to chlid::print() |
|  |  | base1::a1 | --- |
|  |  base2 | base1::vptr | pointer to base2::print() |
|  |  | base2::a2 | --- |
|  | c | --- |
| out of obj | base1::get_1() |
| | base2::get_2() |


### 菱形继承下的C++对象模型

菱形继承指的是基类被某个派生类简单重复继承了多次，从而会在派生类中出现多个基类实例。这种情况下，派生类对象去调用基类中成员变量时，就会出现调用的不明确，从而导致程序的行为不可测。为了解决这种问题，C++对象模型中引入了虚继承的概念。

在虚继承中，派生类会生成一个隐藏的`虚基类指针（vbptr）`用于存放最开始的父类。结构如下：

```
class base {
public:
	int a{ 0 };
    int b{ 1 };
};

class base1 : public virtual  base {
public:
	base1() {
		a = 1;
	}
	virtual void print() {
		std::cout << "base 1" << std::endl;
	}
};


class base2 : public virtual base {	
public:
	base2() {
		a = 2;
	}

	virtual void print() {
		std::cout << "base 2" << std::endl;
	}
};

class child : public base1, public base2 {
private:
    int c { 10 };
public:
	virtual void print() {
		std::cout << "child: " << a << std::endl;
	}
};
```

child obj内存布局
| location | member | member | member | member
| --- | --- |  --- | --- | --- |
| obj | base1 | vbptr, point to child::base |
|  |  | base1::vptr | pointer to child::print() |
|  | base2 |  vbptr, point to child::base | 
|  |  | base2::vptr | pointer to base2::print() |
|  | base | a |
|  |  | b |
|  | c |
