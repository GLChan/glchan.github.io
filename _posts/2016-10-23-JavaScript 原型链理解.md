---
title: JavaScript 原型链理解
date: 2016-10-23 19:49:35
categories: 
- Frontend Development 
- Javascript
tags: javascript
---



## 什么是原型链？



原型链是 JavaScript 中实现对象继承的一种机制。

每个对象都有一个内部属性（通常通过 `__proto__` 访问，也称为 `[[Prototype]]`），指向其原型对象。

当你访问一个对象的属性时，如果该对象自身没有这个属性，JavaScript 引擎会沿着它的原型链依次查找，直到找到这个属性或者到达链的末尾（即 `null`）。

这种机制允许对象共享属性和方法，实现继承和代码复用。



## 原型链在 JavaScript 中是如何工作的？



**属性查找机制**

当访问一个对象的属性时，JavaScript 首先在对象自身查找。如果对象自身没有这个属性，它会沿着对象的原型链查找，即去查找对象的原型（obj.__proto__）是否有该属性，再查找原型的原型，以此类推，直到查找到顶层原型 `Object.prototype` 或遇到 `null`为止。



**继承与共享**

通过原型链，不同的对象可以共享同一份属性和方法，实现对象间的继承和代码复用。例如，通过构造函数创建的对象，其原型指向构造函数的 `prototype` 属性，构造函数的 `prototype`  上的方法和属性对所有实例都是共享的。



**终止查找**

当原型链查找到 `null `时，表示已经到达原型链的顶端，此时如果依然没有找到该属性，则返回 `undefined`。



**原型链与对象创建**

- 使用构造函数时，新对象的 `[[Prototype]]` 指向构造函数的 `prototype`。

- 使用 `Object.create(proto)` 可以创建一个以 `proto` 为原型的对象。





举例：

```javascript
function Person(name) {
  this.name = name;
}

Person.prototype.sayHello = function() {
  console.log(`Hello, I'm ${this.name}`);
};

const alice = new Person('Alice');

// 当调用 alice.sayHello() 时，首先在 alice 本身查找 sayHello，
// 没有找到，就查找 alice.__proto__（即 Person.prototype），找到了 sayHello 方法，然后执行。
alice.sayHello(); // 输出 "Hello, I'm Alice"
```

在这个例子中：

- `alice` 对象没有自己的 `sayHello` 属性。
- 查找顺序：`alice` → `Person.prototype` → `Object.prototype` → `null`。





## 如何通过原型链实现继承？

**属性继承**

在 Child 构造函数内部，通过 Parent.call(this, name) 调用父类构造函数，实现父类属性的继承。这保证了每个子类实例都有自己独立的属性副本。



**方法继承**

使用 Object.create(Parent.prototype) 将子类的原型设置为父类原型的一个副本，使得子类实例可以通过原型链访问父类的方法。



**修正 constructor**

由于 Child.prototype 被重写后，默认的 constructor 属性指向父类对象，所以需要手动将其修正为 Child。



```javascript
// 定义父类构造函数
function Parent(name) {
  this.name = name;
}

Parent.prototype.sayHello = function() {
  console.log("Hello, I'm " + this.name);
};

// 定义子类构造函数
function Child(name, age) {
  // 通过调用父类构造函数来继承属性
  Parent.call(this, name);
  this.age = age;
}

// 通过 Object.create 方法实现原型链继承
Child.prototype = Object.create(Parent.prototype);

// 修正子类构造函数指向
Child.prototype.constructor = Child;

// 为子类添加自己的方法
Child.prototype.sayAge = function() {
  console.log("I am " + this.age + " years old.");
};

// 测试继承效果
const child = new Child("Alice", 10);
child.sayHello(); // 输出: Hello, I'm Alice
child.sayAge();   // 输出: I am 10 years old.

```





## 原型链的顶端是什么？

在 JavaScript 中，原型链的顶端是 `Object.prototype`，它的内部 `[[Prototype]] `属性为 `null`，表示原型链的**终点**。



## 如何判断一个属性是对象自身的还是通过原型链继承的？

使用 `hasOwnProperty` 方法。

`hasOwnProperty` 方法只会返回 true 当属性直接定义在对象上，而不会遍历原型链。

```javascript
const obj = { a: 1 };
console.log(obj.hasOwnProperty('a')); // true，因为 a 是自身属性
console.log(obj.hasOwnProperty('toString')); // false，因为 toString 是继承自 Object.prototype
```



如果对象可能来自不同的原型环境，可以使用：

```javascript
Object.prototype.hasOwnProperty.call(obj, 'propertyName');
```



