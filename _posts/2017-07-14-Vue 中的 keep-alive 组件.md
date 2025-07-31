---
title: Vue 中的 keep-alive 组件
date: 2017-07-14 19:35:32
categories: 
- Frontend Development
- Vue
tags: Vue


---





## 一、`keep-alive` 的作用是什么？

在 Vue 应用中，当项目中切换组件（比如通过 `v-if` 或路由切换）时，默认情况下组件会被销毁和重新创建。这虽然能保证状态的隔离，但如果组件内容复杂（比如包含大量数据或 DOM 元素），频繁的销毁和创建会带来性能开销。

`keep-alive` 的主要作用是**缓存被包裹的组件实例**，避免每次切换时都重新渲染。被 `keep-alive` 包裹的组件在切换时不会被销毁，而是保存在内存中，下次切换回时直接复用缓存的实例。

#### 使用示例

```vue
<keep-alive>
  <component :is="currentComponent"></component>
</keep-alive>
```
- 当 `currentComponent` 切换时，组件实例会被缓存，而不是重新创建。
- 常见的场景包括 Tab 切换、路由视图缓存等。

### 生命周期影响

使用 `keep-alive` 后，组件会触发特殊的生命周期钩子：
- **activated**：组件从缓存中激活时调用。
- **deactivated**：组件从缓存中移除（但实例未销毁）时调用。
这与普通的 `mounted` 和 `destroyed` 不同，体现了缓存的特性。

## 二、底层原理浅析

它的实现主要依赖 Vue 的虚拟 DOM 和组件管理机制。

### 1. 组件缓存的核心数据结构

`keep-alive` 内部维护了一个缓存对象，通常是 `this.cache`，用来存储已创建的组件实例。默认情况下，缓存使用组件构造函数（`VNode` 的 `componentOptions.Ctor`）作为键，实例作为值。

源码片段：
```javascript
// src/core/components/keep-alive.js
export default {
  name: 'keep-alive',
  abstract: true, // 表示这是一个抽象组件，不会渲染为真实 DOM
  created () {
    this.cache = Object.create(null) // 初始化缓存对象
  },
  render () {
    const vnode = this.$slots.default[0] // 获取子组件的 VNode
    const key = this.key // 缓存键，可以通过 props 配置
    const cachedVNode = this.cache[key]
    if (cachedVNode) {
      // 如果缓存中存在，直接复用
      vnode.componentInstance = cachedVNode.componentInstance
    } else {
      // 否则创建新实例并缓存
      this.cache[key] = vnode
    }
    return vnode
  }
}
```

- **abstract: true**：`keep-alive` 是一个抽象组件，不会生成真实的 DOM 节点，仅用于逻辑处理。
- **cache 对象**：通过 `this.cache` 存储 VNode，key 可以是组件的标签名或自定义的 `key` 属性。

### 2. 渲染与复用逻辑

在 `render` 函数中，`keep-alive` 会：
- 获取默认插槽中的第一个子组件 VNode。
- 检查缓存中是否已有该组件的实例。
- 如果存在，直接复用缓存的 VNode 和其关联的组件实例（`componentInstance`）。
- 如果不存在，创建新实例并存入缓存。

这种机制避免了组件的销毁和重新挂载，节省了 DOM 操作和初始化开销。

### 3. 生命周期钩子的特殊处理

`keep-alive` 通过覆盖组件的生命周期钩子，引入了 `activated` 和 `deactivated`：

- 当组件从缓存中激活时，触发 `activated`。
- 当组件被切换出视图但保留在缓存中时，触发 `deactivated`。
这是在 `render` 过程中通过 `vnode.data.keepAlive = true` 标记实现的，Vue 内部会根据此标记调整生命周期行为。

### 4. 缓存管理

`keep-alive` 提供了 `max` 属性，限制缓存的最大数量。当缓存超过 `max` 时，会根据 LRU（Least Recently Used，最近最少使用）策略移除最旧的缓存项。源码中通过 `pruneCache` 函数实现：

```javascript
if (this.max && Object.keys(this.cache).length > this.max) {
  pruneCache(this.cache, this.key)
}
```
- `pruneCache` 会删除最久未使用的缓存条目，确保内存使用可控。

### 5. 依赖虚拟 DOM

`keep-alive` 的实现依赖 Vue 的虚拟 DOM 机制。它不直接操作真实 DOM，而是通过 VNode 的复用来实现缓存。这与 Vue 的 diff 算法和补丁（patch）流程紧密结合，高效地更新视图。

## 三、实际应用场景

- **Tab 页面缓存**：在多标签页应用中，切换标签时保留每个页面的状态。
- **路由视图优化**：结合 Vue Router，使用 `<keep-alive>` 包裹 `<router-view>`，避免重复加载。
- **复杂表单保存**：防止用户输入的数据在切换时丢失。

