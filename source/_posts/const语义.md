---
title: const语义
date: 2019-06-04 23:27:08
tags:
	- Cpp
categories:
	- PL
---

执行一段非法C++代码时出现了问题

```c++
#include<iostream>
using namespace std;
int main(void){
	const int a = 1;
	int *p = (int *) &a;
//	cout << "Before:\n";
//	cout << p << " " << &a << endl;
//	cout << *p << " " << a << endl;
	*p = 100;
//	cout << "After:\n";
//	cout << p << " " << &a << endl;
//	cout << *p << " " << a << endl;
	return 0;
}
```

输出为：
```c++
Before:
0x6ffe44 0x6ffe44
1 1
After:
0x6ffe44 0x6ffe44
100 1
```

地址`&a`和`p`是相等的，然而`a`和`*p`的值却不相同。原因在于C++编译器在编译时会采用一种叫做变量折叠的技术。 

> 变量折叠：在编译器里进行语法分析的时候，将常量表达式计算求值，并用求得的值来替换表达式，放入常量表。

将上述代码转换为C语言之后,地址相同值不同的问题没有发生.

查询到这是种编译器优化之后,开启`-O0`依旧无法避免.

最后发现是因为C和C++的const实际执行的语义不同而引起的.

C语言中,const修饰变量将被放在.rodata段中,不代表是个常量,单纯意味着只读,是一种运行时const.

C++语言中,const修饰变量将在编译时直接将变量引用位置替换成对应常量,相当于具有类型保护的define,是一种编译期const.

在C和C++中,const变量确实会被上述代码所改变,但是C++在运行时改变const,再次读取的还是编译器符号表中的常量数据.

解决方法是在变量前加上volatile,volatile告诉编译器每次调用变量都需要从内存重新取值,从而解决问题.

## 参考

[C++ 常量折叠问题的理解](https://blog.csdn.net/misayaaaaa/article/details/69432679)

[Variably modified array at file scope](https://blog.csdn.net/wusuopuBUPT/article/details/18408227)

