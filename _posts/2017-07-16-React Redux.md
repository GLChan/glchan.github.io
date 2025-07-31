---
title: Redux 状态管理实践
date: 2017-07-16 19:07:45
categories: 
- Frontend Development 
- React
tags: React Redux
---


## 什么是 Redux？

Redux 是一个基于 JavaScript 的状态容器，深受 Flux 架构启发。它通过单一数据源（Single Source of Truth）和不可变状态（Immutable State）管理应用状态。Redux 的核心理念是**单一数据流**，所有状态变化都通过 action 和 reducer 集中处理。

### 核心概念
- **Store**：应用状态的单一存储，所有状态保存在这里。
- **State**：Store 中的数据，描述应用当前状态。
- **Action**：描述状态变化的 payload，包含 `type` 和可选数据。
- **Reducer**：纯函数，根据 action 更新 state，返回新状态。
- **Dispatch**：触发 action，更新 Store。

## Redux 如何与 React 集成？

React 本身不包含内置状态管理工具，而 Redux 通过 `react-redux` 库与 React 集成。`react-redux` 提供了 `<Provider>` 组件和 `connect` 高阶组件，将 Redux Store 与 React 组件连接。

- `<Provider>`：将 Store 注入 React 应用，使子组件可访问。
- `connect`：将组件与 Store 绑定，映射 state 和 dispatch 到 props。

## 一个简单的待办事项应用示例

下面用 React 和 Redux 实现一个基本的TODO，包含添加和删除任务功能。

### 1. 安装依赖
```bash
npm install redux react-redux
```

### 2. 定义 Action Types 和 Creators
```javascript
// actions.js
export const ADD_TODO = 'ADD_TODO';
export const DELETE_TODO = 'DELETE_TODO';

export const addTodo = text => ({
  type: ADD_TODO,
  payload: { text }
});

export const deleteTodo = id => ({
  type: DELETE_TODO,
  payload: { id }
});
```

### 3. 创建 Reducer
```javascript
// reducers.js
import { ADD_TODO, DELETE_TODO } from './actions';

const initialState = {
  todos: []
};

const todoReducer = (state = initialState, action) => {
  switch (action.type) {
    case ADD_TODO:
      return {
        ...state,
        todos: [
          ...state.todos,
          { id: Date.now(), text: action.payload.text }
        ]
      };
    case DELETE_TODO:
      return {
        ...state,
        todos: state.todos.filter(todo => todo.id !== action.payload.id)
      };
    default:
      return state;
  }
};

export default todoReducer;
```

### 4. 创建 Store
```javascript
// store.js
import { createStore } from 'redux';
import todoReducer from './reducers';

const store = createStore(todoReducer);

export default store;
```

### 5. 连接 React 组件
```jsx
// TodoApp.js
import React, { Component } from 'react';
import { connect } from 'react-redux';
import { addTodo, deleteTodo } from './actions';

class TodoApp extends Component {
  state = { inputValue: '' };

  handleInputChange = e => {
    this.setState({ inputValue: e.target.value });
  };

  handleAddTodo = () => {
    if (this.state.inputValue) {
      this.props.addTodo(this.state.inputValue);
      this.setState({ inputValue: '' });
    }
  };

  render() {
    const { todos, deleteTodo } = this.props;
    return (
      <div>
        <h1>待办事项</h1>
        <input
          value={this.state.inputValue}
          onChange={this.handleInputChange}
        />
        <button onClick={this.handleAddTodo}>添加</button>
        <ul>
          {todos.map(todo => (
            <li key={todo.id}>
              {todo.text}
              <button onClick={() => deleteTodo(todo.id)}>删除</button>
            </li>
          ))}
        </ul>
      </div>
    );
  }
}

const mapStateToProps = state => ({
  todos: state.todos
});

const mapDispatchToProps = { addTodo, deleteTodo };

export default connect(mapStateToProps, mapDispatchToProps)(TodoApp);
```

### 6. 整合应用
```jsx
// index.js
import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import store from './store';
import TodoApp from './TodoApp';

ReactDOM.render(
  <Provider store={store}>
    <TodoApp />
  </Provider>,
  document.getElementById('root')
);
```


### 7.解释
#### 7.1 Action、Reducer 和 Store 的关系：

- **Action**：是一个对象，描述状态变化的意图，包含 type（必须）和可选的 payload（数据）。例如 { type: 'ADD_TODO', payload: { text: 'Learn Redux' } } 表示添加任务。
- **Reducer**：是一个纯函数，接收当前 state 和 action，根据 action.type 返回新的 state，不直接修改原状态。例如，ADD_TODO 会在 state.todos 中添加新任务。
- **Store**：是 Redux 的核心，保存整个应用的 state。它通过 createStore(reducer) 创建，负责接收 action（通过 dispatch），调用 reducer 更新 state，并通知订阅者（如 React 组件）。

- 关系
  - **Action** 是“指令”，告诉 Store 需要改变状态。
  - **Reducer** 是“规则”，定义如何根据 Action 更新 state。
  - **Store** 是“容器”，管理 state，调度 action 并调用 reducer。

#### 7.2 connect 的作用：

- connect 是 react-redux 提供的高阶组件（HOC），用于将 Redux Store 与 React 组件连接。
- 它通过 mapStateToProps 和 mapDispatchToProps 将 Store 的 state 和 dispatch 方法映射到组件的 props。
- 具体作用：
  - mapStateToProps(state)：将 Store 的 state 映射到组件的 props（如 todos）。
  - mapDispatchToProps：将 dispatch 方法映射为组件的 props（如 addTodo）。
  - 自动订阅 Store 的变化，state 更新时触发组件重新渲染。

### 运行结果
- 输入文本并点击“添加”，通过 `addTodo` action 更新 Store，列表显示新任务。
- 点击“删除”按钮，触发 `deleteTodo` action，移除对应任务。
- 所有状态变化都集中管理，组件只需渲染。
