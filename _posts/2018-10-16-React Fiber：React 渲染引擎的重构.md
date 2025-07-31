---
title: React Fiber：React 渲染引擎的重构
date: 2018-10-16 22:26:39
categories: 
- Frontend Development 
- React
tags: 
- React
- Fiber
---


## 什么是 React Fiber？

React Fiber 是 React 内部渲染引擎的重构。它完全重写了 React 的核心算法，从 Stack Reconciler 升级为 Fiber Reconciler。Fiber 的核心目标是：

1. **任务分片（Incremental Rendering）**  
   将渲染任务拆分为多个小任务（work units），并允许在这些任务之间暂停、恢复或重新调度，从而避免主线程的长时间阻塞。

2. **优先级调度**  
   为不同类型的更新分配优先级。例如，动画和用户交互的更新优先级高于后台数据加载的更新。这样可以确保高优先级的任务先执行，提升用户体验。

3. **可中断的渲染**  
   与 Stack Reconciler 的递归模型不同，Fiber 采用了一种基于循环的实现，允许在渲染过程中暂停，处理其他高优先级任务后再继续。

### 为什么需要 React Fiber？

在 React 15 及之前的版本中，React 渲染使用的是“Stack Reconciler”（基于递归的协调器）。它的核心逻辑是通过递归遍历虚拟DOM树，比较新旧节点差异（diffing），然后一次性更新到真实DOM。这种方式虽然简单高效，但在以下场景下会遇到问题：

1. **同步渲染的阻塞问题**  
   Stack Reconciler 的渲染过程是同步的，一旦开始渲染，浏览器主线程会被完全占用，直到渲染完成。这意味着如果组件树非常庞大或计算复杂，可能会导致主线程阻塞，造成页面卡顿或掉帧，影响用户体验。

2. **无法中断的任务**  
   由于渲染过程是递归的，任务无法被中断。这意味着即使有更高优先级的任务（比如用户输入或动画），浏览器也无法及时响应，因为渲染任务必须一次性完成。

3. **性能瓶颈**  
   在高频更新（如动画、实时数据流）或大型应用中，同步渲染的开销会显著增加，难以满足现代前端应用对流畅性的需求。


## Fiber 的核心原理

React Fiber 的核心思想是将渲染过程拆分为两个阶段：**协调阶段（Reconciliation）** 和 **提交阶段（Commit）**。让我们逐步分析这些阶段：

### 1. 协调阶段（Reconciliation）

协调阶段是 React 比较新旧虚拟DOM树、计算差异（diffing）的过程。在 Fiber 中，这个过程被设计为可中断的。以下是其关键机制：

- **Fiber 节点**  
  在 Fiber 中，React 将组件树表示为一棵 Fiber 树。每个组件节点对应一个 Fiber 节点，Fiber 节点不仅包含组件的状态和属性，还包含了指向父节点、子节点和兄弟节点的指针。这种链表结构取代了 Stack Reconciler 的递归遍历，使得渲染过程可以暂停和恢复。

  ```
    Fiber Tree (组件树)
  ├── RootFiber (根节点)
  │   ├── State: null (根节点通常无状态)
  │   ├── Props: null (根节点通常无属性)
  │   ├── Parent: null (根节点无父节点)
  │   ├── Child: AppFiber (指向子节点)
  │   └── Sibling: null (根节点无兄弟节点)
  │
  ├── AppFiber (对应 App 组件)
  │   ├── State: { theme: 'dark' } (组件状态)
  │   ├── Props: { version: '1.0' } (组件属性)
  │   ├── Parent: RootFiber (指向父节点)
  │   ├── Child: HeaderFiber (指向子节点)
  │   └── Sibling: null (无兄弟节点)
  │
  ├── HeaderFiber (对应 Header 组件)
  │   ├── State: { title: 'Welcome' } (组件状态)
  │   ├── Props: { color: 'blue' } (组件属性)
  │   ├── Parent: AppFiber (指向父节点)
  │   ├── Child: null (无子节点)
  │   └── Sibling: MainFiber (指向兄弟节点)
  │
  └── MainFiber (对应 Main 组件)
      ├── State: { count: 0 } (组件状态)
      ├── Props: { data: [...] } (组件属性)
      ├── Parent: AppFiber (指向父节点)
      ├── Child: ListFiber (指向子节点)
      └── Sibling: null (无兄弟节点)
          │
          └── ListFiber (对应 List 组件)
              ├── State: { items: [...] } (组件状态)
              ├── Props: { filter: 'all' } (组件属性)
              ├── Parent: MainFiber (指向父节点)
              ├── Child: null (无子节点)
              └── Sibling: null (无兄弟节点)
  ```


- **工作循环（Work Loop）**  
  Fiber 引入了“工作循环”机制，React 会逐个处理 Fiber 节点，而不是一次性递归遍历整棵树。浏览器会在每一帧的空闲时间调用工作循环，完成一部分渲染任务。如果有更高优先级的任务（如用户输入），工作循环可以暂停，释放主线程。

- **优先级调度**  
  Fiber 为每个更新分配了优先级。例如，动画相关的更新优先级最高，而离屏组件的更新优先级较低。通过优先级调度，React 确保关键任务优先完成。

### 2. 提交阶段（Commit）

提交阶段是将协调阶段计算出的差异应用到真实DOM的过程。与协调阶段不同，提交阶段是同步的，必须一次性完成，以确保 DOM 的更新是原子性的，避免出现不一致的状态。


## 示例

一个简单的示例来感受 Fiber 的效果。常见的列表组件，需要在用户输入时实时更新：

```jsx
class List extends React.Component {
  state = { items: [] };

  handleInput = (e) => {
    // 模拟复杂计算
    const newItems = Array(10000).fill(e.target.value);
    this.setState({ items: newItems });
  };

  render() {
    return (
      <div>
        <input onChange={this.handleInput} />
        <ul>
          {this.state.items.map((item, index) => (
            <li key={index}>{item}</li>
          ))}
        </ul>
      </div>
    );
  }
}
```

在 React 15 中，`handleInput` 触发的大量更新可能会阻塞主线程，导致输入框卡顿。而在 React 16（使用 Fiber）中，渲染任务会被拆分为多个小任务，浏览器可以在每帧的空闲时间处理部分更新，从而保持输入框的响应性。