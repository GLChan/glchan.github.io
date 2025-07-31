---
title: React Router 作用和用法
date: 2017-07-15 20:20:55
categories: 
- Frontend Development 
- React
tags: React Router
---


React Router 是一个用于 React 应用的客户端路由库。它允许在单页应用（SPA）中实现页面导航和 URL 管理，与 React 的组件化开发无缝集成。

## **作用：**

- **声明式路由**：通过组件配置路由规则，简化页面切换逻辑。
- **URL 同步**：保持 UI 与浏览器 URL 的同步，支持前进/后退。
- **嵌套路由**：支持多级页面结构，适合复杂应用。

## **基本用法：**

React Router 提供了 `<Router>`、`<Route>`、`<Link>` 等核心组件，配合 `hashHistory` 或 `browserHistory` 管理路由。

- 对比
  - `hashHistory`：哈希变化不触发服务器请求，性能开销小，但 URL 带 # 影响美观。
  - `browserHistory`：支持更好的 SEO（搜索引擎优化），URL 更自然，但初次加载可能因服务器配置不当导致问题。

- **安装**：`npm install react-router`
- **核心组件**：
  - `<Router>`：路由容器，定义历史管理（如 `hashHistory`）。
  - `<Route>`：匹配 URL 路径并渲染组件。
  - `<IndexRoute>`：是一个特殊的路由组件，仅用于定义父路由路径下的默认子路由。
  - `<Link>`：导航链接，替代 `<a>` 标签。

## **示例：**

构建一个简单应用，包含首页和关于页面：

```jsx
import React from 'react';
import { Router, Route, Link, hashHistory } from 'react-router';

const Home = () => <h2>欢迎访问首页</h2>;
const About = () => <h2>关于我们</h2>;

const App = () => (
  <Router history={hashHistory}>
    <div>
      <nav>
        <Link to="/">首页</Link>
        <Link to="/about">关于</Link>
      </nav>
      <Route exact path="/" component={Home} />
      <Route path="/about" component={About} />
    </div>
  </Router>
);

export default App;
```

- `<Link to="/">` 渲染为 `<a href="#/">`，点击切换路由。
- `exact` 确保 `/` 路径精确匹配，避免被 `/about` 覆盖。