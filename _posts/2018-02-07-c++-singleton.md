---
layout: article
title: c++单例模型
categories: c++ design-pattern
---

```
#include <iostream>
#include <memory>

class singleton {
public:
    singleton() = default;

    singleton(singleton const &) = delete;

    singleton &operator=(singleton const &) = delete;

    virtual ~singleton() = default;
public:
    static std::shared_ptr<singleton> get_instance() {
        static std::shared_ptr<singleton> ins(new singleton());
        return ins;
    };

// for test
public:
    void hello() {std::cout << "hello, world!" << std::endl;}
};

int main() {
    auto s = singleton::get_instance();
    s->hello();

    return 0;
}
```


