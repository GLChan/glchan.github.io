---
title: Vue 中的 computed 和 watch 的区别、适用场景及原理
date: 2017-07-10 22:27:17
categories: 
- Frontend Development
- Vue
tags: Vue
---







## **`computed` 和 `watch` 的区别**

1. **基本定义**
   - **`computed`**: 计算属 性是基于它们的依赖进行缓存的。计算属性会根据依赖的数据的变化来重新计算，且只有在依赖的值发生变化时才会重新计算。这是它最显著的特性。
   - **`watch`**: 观察者是用来观察 Vue 实例上的数据变动，触发回调函数。它的特点是观察的是数据的变化，并在数据变化时执行回调函数，适合处理异步或开销较大的操作。
2. **性能与依赖关系**
   - **`computed`** 会**缓存计算结果**，只有当其依赖的属性发生变化时，才会重新计算。这意味着多次访问计算属性时，不会重复执行计算操作，提升了性能。
   - **`watch`** 是每次数据变动时都会触发回调，即使你只是访问一次某个值，也会执行回调。`watch` 的回调在数据变化时异步执行，适合做一些如**异步请求**或需要做副作用处理的任务。

------

## **底层原理**

### **`computed` 的底层原理**

计算属性的核心原理是**依赖收集**。当计算属性首次被访问时，Vue 会追踪其依赖的数据。当这些数据发生变化时，Vue 会触发计算属性的重新计算。由于计算属性会缓存结果，它只会在依赖发生变化时重新计算，而不会在每次访问时都计算。

- Vue 会在 **getter** 被触发时，使用 `Dep` 类收集计算属性所依赖的数据的依赖。
- Vue 通过 `Watcher` 类来触发更新和计算。

例如，假设我们有以下代码：

```javascript
new Vue({
  data() {
    return {
      firstName: 'John',
      lastName: 'Doe'
    };
  },
  computed: {
    fullName() {
      return `${this.firstName} ${this.lastName}`;
    }
  }
});
```

在这个例子中，`fullName` 会依赖 `firstName` 和 `lastName` 两个数据属性。当其中任何一个属性发生变化时，计算属性 `fullName` 会重新计算。

### **`watch` 的底层原理**

`watch` 用于观察数据的变化，它通过创建一个 **Watcher** 实例来监听数据的变化。`watch` 的回调会在数据变化时执行，这使得它特别适合处理异步操作或者需要执行副作用的任务。

当你使用 `watch` 时，Vue 会创建一个新的观察者，并监视目标数据。当目标数据发生变化时，回调会被触发。

例如：

```javascript
new Vue({
  data() {
    return {
      name: 'Vue'
    };
  },
  watch: {
    name(newVal, oldVal) {
      console.log(`Name changed from ${oldVal} to ${newVal}`);
    }
  }
});
```

当 `name` 数据属性变化时，`watch` 的回调函数会被调用，打印出旧值和新值。这个过程中，Vue 会创建一个 `Watcher` 实例并将其绑定到 `name` 上，监听数据变化。

------

## **适用场景**

### **`computed` 适用场景**

- **计算属性值**：当你需要基于响应式数据计算出一个值时，应该使用 `computed`，因为它会进行缓存，只有依赖发生变化时才会重新计算。
- **性能优化**：当你需要在模板中使用多个复杂的计算结果时，`computed` 能减少不必要的计算，提升性能。

**例子：**

```javascript
new Vue({
  data() {
    return {
      price: 10,
      quantity: 2
    };
  },
  computed: {
    totalPrice() {
      return this.price * this.quantity;
    }
  }
});
```

在这个例子中，`totalPrice` 是计算属性，它基于 `price` 和 `quantity` 计算出总价，且当 `price` 或 `quantity` 变化时才重新计算。

### **`watch` 适用场景**

- **异步操作**：`watch` 非常适合用于监听数据变化并执行异步操作，如发起 HTTP 请求等。
- **副作用**：如果你需要在数据变化时执行一些副作用（如直接修改 DOM 或调用 API），可以使用 `watch`。

**例子：**

```javascript
new Vue({
  data() {
    return {
      query: ''
    };
  },
  watch: {
    query(newQuery) {
      this.fetchResults(newQuery);
    }
  },
  methods: {
    fetchResults(query) {
      // 模拟异步请求
      console.log(`Fetching results for ${query}`);
    }
  }
});
```

在这个例子中，当 `query` 数据发生变化时，`watch` 会触发 `fetchResults` 方法进行异步操作。