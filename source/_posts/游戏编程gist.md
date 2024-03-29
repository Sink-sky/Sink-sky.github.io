---
title: 游戏编程gist
date: 2022-08-30 15:10:07
categories:
  - Gist
tags:
  - Coding
---

- 从源头去做事件通知 谁改变谁去通知 (并未避免初始化的问题)
- 事件分发两种 异步和同步 同步可能出现连续触发导致诡异的调用层级，异步则可能需要更多的代码检查上下文
- 客户端以服务端时间线为准，那如果时间线客户端先于服务端执行，不可避免的会碰到回滚的问题。但等待服务端时间线执行之后客户端再执行，延迟就会比较高。
- 逻辑与表现分离，对表现来说可以多帧渲染不影响逻辑，对逻辑来说可以跨双端跑。
- 为什么要有我的概念，因为网络游戏两者并不能算是对等实体，其他玩家行为是服务器转发来的合法数据，本地玩家行为是体验优先本地立即响应却不具有一致性的。
- 数据热更要比代码热更来得更加方便，但依旧可能读取不一致的数据出错
- 字面量不具有逻辑，逻辑交由上下文管理，因此是上下文无关的，可以方便在不同逻辑之间做交换
- 字面量之间要做出区分，即需要传给逻辑后表现出多态行为，就得包含自解释数据
- 编辑器编辑策划配置数据要么通过表格的语义来决定，要么就像编程一样通过“元数据”增加表达语义能力，来组织关系
- 事件注册这种异步调用需要注意不同 Entity 上的使用，这种事件监听转换为单次的消息通知，然后自己分发事件监听可以避免异步逻辑
- 组合 ~ 波粒二象性 组合机制
- 继承 ~ 子类能在所有父类上下文中使用
- Python 每一个函数都是一个多态，最好相同的名字有一致的语义，结构性子类型系统依赖于类型中隐式的模式，困难的是维护重要的隐式模式
- Python 多重继承 可以用来解决冲突的问题，但更适合层次需要经常调整的逻辑，一次函数调用就像是走过一个协议栈
- 注意代码（或系统上的）中的相互指涉以及自我指涉，逻辑上的不完备会导致死循环或者悖论导致错误

1. 首先考虑目标是什么，这个目标会有什么性质，这些性质会约束原语语义，以及定下整个框架模型
2. 团队人员需要统一概念，需要有相似的惯用法，这样代码沟通成本会降低
3. 代码风格最后跟语言风格尽量一致，能最大的利用生态，而且就像顺着纹理下刀一样，会更省力
