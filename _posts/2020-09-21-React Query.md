---
title: React Query 数据同步管理
date: 2020-09-21 23:14:49
categories: 
- Frontend Development 
- React
tags: React
---

## React Query 是什么？
React Query 是一个轻量但强大的库，用于在 React 应用中管理服务器端状态。专注于处理异步数据、缓存和自动更新。

## 为什么选择 React Query？
1. **告别样板代码**  
   传统的 Redux 或 useReducer + useEffect 组合需要大量手动管理加载状态、错误处理和数据缓存。React Query 提供开箱即用的解决方案，大幅减少重复代码。

2. **内置缓存与同步**  
   React Query 自动缓存查询结果，并在数据失效时重新获取。它还能根据窗口焦点、重新连接等事件自动刷新数据。

3. **声明式 API**  
   通过 hooks（如 `useQuery` 和 `useMutation`），React Query 让数据管理变得直观，与 React 的函数式编程风格无缝融合。

## 示例：同步用户数据

### 安装
```bash
npm install react-query
```

### 配置 Provider
在应用根组件中添加 `QueryClientProvider`：
```jsx
import { QueryClient, QueryClientProvider } from 'react-query';

// QueryClient 是 React Query 的核心实例，用于管理数据缓存、请求状态、后台同步、错误处理等功能。它类似于 React 的全局状态管理工具（如 Redux Store），但专门用于处理 API 数据。
const queryClient = new QueryClient();

// QueryClientProvider 是 React Query 的上下文，它用于让 React 组件树中的所有组件都能访问 QueryClient 实例。
function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <UserList />
    </QueryClientProvider>
  );
}
```

### 查询数据
创建一个组件，使用 `useQuery` 获取用户列表：
```jsx
import { useQuery } from 'react-query';

async function fetchUsers() {
  const response = await fetch('https://api.example.com/users');
  return response.json();
}

function UserList() {
  const { data, isLoading, error } = useQuery('users', fetchUsers);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <ul>
      {data.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### 更新数据
使用 `useMutation` 添加新用户并同步状态：
```jsx
import { useMutation, useQueryClient } from 'react-query';

async function addUser(newUser) {
  const response = await fetch('https://api.example.com/users', {
    method: 'POST',
    body: JSON.stringify(newUser),
    headers: { 'Content-Type': 'application/json' },
  });
  return response.json();
}

function AddUser() {
  const queryClient = useQueryClient();
  const mutation = useMutation(addUser, {
    onSuccess: () => {
      // 成功后刷新用户列表
      queryClient.invalidateQueries('users');
    },
  });

  const handleSubmit = () => {
    mutation.mutate({ name: 'New User' });
  };

  return (
    <button onClick={handleSubmit} disabled={mutation.isLoading}>
      {mutation.isLoading ? 'Adding...' : 'Add User'}
    </button>
  );
}
```

## React Query 的核心优势
1. **状态同步**  
   `useQuery` 自动管理加载、错误和数据状态。你无需手动设置 `isLoading` 或 `error` 变量。

2. **乐观更新**  
   在 `useMutation` 中，可以通过 `onMutate` 提前更新 UI，失败时回滚，提升用户体验：
   ```jsx
   onMutate: async newUser => {
     await queryClient.cancelQueries('users');
     const previousUsers = queryClient.getQueryData('users');
     queryClient.setQueryData('users', old => [...old, newUser]);
     return { previousUsers };
   },
   onError: (err, newUser, context) => {
     queryClient.setQueryData('users', context.previousUsers);
   },
   ```

3. **后台刷新**  
   默认情况下，React Query 会在窗口重新聚焦时刷新数据（可通过 `refetchOnWindowFocus` 配置）。

## 其它用法
1. **分页查询**  
   使用 `useInfiniteQuery` 处理无限滚动：
   ```jsx
   const { data, fetchNextPage } = useInfiniteQuery('users', fetchUsers, {
     getNextPageParam: lastPage => lastPage.nextPage,
   });
   ```

2. **预加载**  
   在路由切换前预取数据：
   ```jsx
   queryClient.prefetchQuery('users', fetchUsers);
   ```

3. **与 TypeScript 集成**  
   React Query 对 TypeScript 有良好的类型支持，只需添加类型：
   ```tsx
   const { data } = useQuery<User[]>('users', fetchUsers);
   ```