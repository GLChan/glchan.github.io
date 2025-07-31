---
title: Vue 的 $attrs 和 $listeners 的使用
date: 2017-07-18 23:50:33
categories: 
- Frontend Development
- Vue
tags: Vue
---

### **作用：**

- **`$attrs`**：包含父组件传递给子组件的所有未被声明为 `props` 的属性（除 `class` 和 `style` 外）。它帮助实现属性的透传，简化多层组件间的数据传递。
- **`$listeners`**：包含父组件传递给子组件的所有事件监听器（不包括 `.native` 修饰的事件）。它用于透传事件，方便子组件触发父组件的事件。

### **适用场景：**

- **多层组件嵌套**：当需要将父组件的属性或事件透传到更深层的子组件时，使用 `$attrs` 和 `$listeners` 避免逐层手动传递。
- **封装通用组件**：在封装高复用性组件时，使用它们让组件更灵活，支持动态绑定父组件的属性和事件。

### **实际案例：**

假设我们封装一个 `BaseInput` 组件，支持透传属性和事件给内部的原生 `input` 元素：

```vue
<!-- BaseInput.vue -->
<template>
  <div class="input-wrapper">
    <input v-bind="$attrs" v-on="$listeners" />
  </div>
</template>

<script>
export default {
  inheritAttrs: false, // 防止未声明的属性绑定到根元素
  props: ['value'], // 只声明 value 作为 prop
};
</script>
```

使用时：

```vue
<!-- 父组件 -->
<template>
  <BaseInput
    v-model="username"
    placeholder="请输入用户名"
    @focus="handleFocus"
  />
</template>

<script>
export default {
  data() {
    return { username: '' };
  },
  methods: {
    handleFocus() {
      console.log('Input focused!');
    },
  },
};
</script>
```

**分析：**

- `$attrs` 包含 `placeholder` 等未声明为 `props` 的属性，透传给 `input` 元素。
- `$listeners` 包含 `@focus` 事件，绑定到 `input` 上，触发时调用父组件的 `handleFocus`。
- `inheritAttrs: false` 确保未声明的属性不会绑定到 `BaseInput` 的根 `div` 上。