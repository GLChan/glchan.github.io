---
title: Vue 的 nextTick作用与原理
date: 2017-07-05 23:25:07
categories: 
- Frontend Development
- Vue
tags: Vue

---



### 一、`nextTick` 的作用是什么？

在 Vue 中，我们知道数据是响应式的。当你修改了一个数据属性（比如 `this.message = 'Hello'`），Vue 会自动触发 DOM 的更新。但这个更新并不是立即完成的，而是异步执行的。Vue 会把所有的数据变更收集起来，统一在下一次“tick”中处理，以避免不必要的重复渲染，提高性能。

这就引出了一个问题：如果你在修改数据后立即去操作 DOM，会发现 DOM 还没有更新。比如下面这个例子：

```javascript
new Vue({
  el: '#app',
  data: {
    message: '初始值'
  },
  methods: {
    updateMessage() {
      this.message = '新值';
      console.log(this.$el.textContent); // 输出：'初始值'
    }
  }
});
```

你可能会惊讶地发现，`console.log` 输出的是旧值 `'初始值'`，而不是 `'新值'`。这是因为 DOM 更新还没有发生。为了解决这个问题，Vue 提供了 `this.$nextTick` 方法。你可以在数据变更后使用它，确保回调函数在 DOM 更新完成后执行：

```javascript
updateMessage() {
  this.message = '新值';
  this.$nextTick(() => {
    console.log(this.$el.textContent); // 输出：'新值'
  });
}
```

简单来说，`nextTick` 的作用是**让开发者能够在 DOM 更新完成后执行某些操作**。它就像一座桥梁，连接了数据变更和 DOM 渲染之间的异步鸿沟。

### 二、`nextTick` 的实现原理

#### 1. 全局 `nextTick` 和实例方法

在 Vue 中，`nextTick` 有两种形式：

- 全局方法：`Vue.nextTick(callback)`
- 实例方法：`this.$nextTick(callback)`

实际上，`this.$nextTick` 只是对全局 `Vue.nextTick` 的封装，它会把当前的 Vue 实例作为上下文传递进去。源码中可以看到：

```javascript
// src/core/instance/render.js
Vue.prototype.$nextTick = function (fn) {
  return Vue.nextTick(fn, this);
};
```

所以核心逻辑都在全局的 `Vue.nextTick` 中。

#### 2. 异步任务的微任务实现

Vue 的 `nextTick` 的核心思想是利用 JavaScript 的异步机制。具体来说，它会尽量使用 **微任务（microtask）** 来执行回调。微任务是 ES6 中引入的概念，通常由 `Promise` 或 `MutationObserver` 实现，优先级高于宏任务（macrotask，比如 `setTimeout`）。

Vue 的实现会根据浏览器的支持情况选择不同的策略。以下是源码中的关键部分：

```javascript
// src/core/util/env.js

export const nextTick = (function () {
  const callbacks = [] 	// 全局数组，用于存储待执行的回调
  let pending = false 	// 存储是否已经触发了异步任务的状态（防止重复触发）
  let timerFunc					// 负责选择合适的异步方式（Promise、MutationObserver 或 setTimeout）来调度回调执行

  function nextTickHandler () {
    pending = false
    const copies = callbacks.slice(0) // 浅拷贝
    callbacks.length = 0
    for (let i = 0; i < copies.length; i++) { // 遍历执行cb
      copies[i]()
    }
  }
  
	/** 优先级 1 */
  if (typeof Promise !== 'undefined' && isNative(Promise)) {   
    var p = Promise.resolve()
    var logError = err => { console.error(err) }
    timerFunc = () => {
      p.then(nextTickHandler).catch(logError)
      if (isIOS) setTimeout(noop)
    }
  } else if (/** 优先级 2 */
    typeof MutationObserver !== 'undefined' && (isNative(MutationObserver) || MutationObserver.toString() === '[object MutationObserverConstructor]')) {
    var counter = 1
    var observer = new MutationObserver(nextTickHandler)
    var textNode = document.createTextNode(String(counter))
    observer.observe(textNode, {
      characterData: true
    })
    timerFunc = () => {
      counter = (counter + 1) % 2
      textNode.data = String(counter)
    }
  } else {	/** 备用方案 */
    timerFunc = () => {
      setTimeout(nextTickHandler, 0)
    }
  }

  // cb: 用户传入的回调函数, ctx: 回调执行时的上下文（通常是 Vue 实例）
  return function queueNextTick (cb?: Function, ctx?: Object) {
    let _resolve
    callbacks.push(() => {
      if (cb) {
        try {
          cb.call(ctx)
        } catch (e) {
          handleError(e, ctx, 'nextTick')
        }
      } else if (_resolve) {
        _resolve(ctx)
      }
    })
    // 如果pending没有启动，
    if (!pending) {
      pending = true // 表示异步任务已触发
      timerFunc() // 调度所有 callbacks 在下一次“tick”中执行。
    }
    if (!cb && typeof Promise !== 'undefined') {
      return new Promise((resolve, reject) => {
        _resolve = resolve
      })
      
      // return 一个Promise 对象 Vue.nextTick().then
    }
  }
})()
```

- **优先级 1：Promise**  
  如果浏览器支持 `Promise`，Vue 会使用 `Promise.resolve().then()` 来创建一个微任务。

- **优先级 2：MutationObserver**  
  如果 `Promise` 不可用（比如某些老浏览器），Vue 会退而求其次，使用 `MutationObserver`。它通过监听一个文本节点的变动来触发微任务。

- **备用方案：setTimeout**  
  如果前两者都不支持，Vue 会使用 `setTimeout(fn, 0)`，这是一个宏任务。

#### 3. 回调队列和去重

你可能注意到，`nextTick` 内部维护了一个 `callbacks` 数组和一个 `pending` 标志。每次调用 `nextTick`，回调都会被推入 `callbacks`，但 `timerFunc` 只会在 `pending` 为 `false` 时执行一次。等到微任务触发时，`flushCallbacks` 会一次性执行所有队列中的回调，并重置 `pending`。

这种设计避免了重复触发异步任务，保证了效率。比如：

```javascript
this.message = '新值1';
this.$nextTick(() => console.log('回调1'));
this.message = '新值2';
this.$nextTick(() => console.log('回调2'));
```

尽管调用了两次 `nextTick`，但它们会被合并到同一个微任务中执行。

### 三、实际应用场景

通过上面的分析，我们可以总结出 `nextTick` 的几个典型应用场景：

1. **DOM 更新后操作**：比如修改数据后需要获取新的 DOM 尺寸或内容。
2. **批量更新后处理**：在短时间内多次修改数据，只需在最后一次用 `nextTick` 处理结果。
3. **第三方库集成**：当 Vue 的响应式更新和外部 DOM 操作库（如 jQuery）结合时，`nextTick` 可以确保时序正确。
