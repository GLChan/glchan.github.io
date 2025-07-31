---
title: Partytown 第三方库性能解决方案
date: 2024-06-11 23:36:28
categories: 
- Mobile Development 
- Performance
tags: 
- Partytown
---


Partytown的核心理念是将第三方库从主线程中解放出来，在Web Worker中执行，从而避免阻塞主线程的执行。

### 性能痛点

第三方库通常会：
- 阻塞主线程执行
- 延迟页面渲染
- 影响用户交互响应
- 降低Core Web Vitals得分
- 消耗额外的网络带宽

### 现实场景

比如你的网站本来可以在1秒内加载完成，但加载了几个第三方库后，加载时间延长到了3-4秒。更糟糕的是，即使页面看起来已经加载完成，用户点击按钮时却发现没有响应，因为主线程仍在执行第三方库。

## 工作原理

Partytown采用了一种巧妙的架构：

1. **Web Worker环境**：第三方库在Web Worker中执行，完全隔离于主线程
2. **代理机制**：通过代理对象，Web Worker中的库可以访问和操作主线程的DOM
3. **异步通信**：主线程和Web Worker之间通过消息传递进行通信
4. **批量操作**：多个DOM操作会被批量处理，减少通信开销

![Partytown](https://user-images.githubusercontent.com/452425/152393346-6f721a4f-3f66-410a-8878-a2b49e24307f.png)

## 快速上手

### 安装

```bash
npm install @builder.io/partytown
```

### 基本配置

```javascript
// 在HTML中配置
<script>
  partytown = {
    forward: ['gtag', 'fbq', 'ga']
  };
</script>
<script type="text/partytown" src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script type="text/partytown">
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

需要将库文件复制到`public/~partytown`

### React中使用

```jsx
import { Partytown } from '@builder.io/partytown/react';

function App() {
  return (
    <>
      <Partytown forward={['gtag']} />
      <script
        type="text/partytown"
        dangerouslySetInnerHTML={ {
          __html: `
            gtag('config', 'GA_MEASUREMENT_ID');
          `,
        } }
      />
    </>
  );
}
```

## 适用场景

### 常见场景
- Google Analytics等
- 广告库（Google Ads、Facebook Pixel）
- 营销自动化工具
- 客服聊天工具
- 社交媒体插件

### 需要注意的场景
- 需要同步DOM操作的库
- 对时序要求严格的库
- 需要访问特定浏览器API的库

## 实践注意的点

### 1. 合理选择库
不是所有第三方库都适合放在Partytown中运行，需要根据库的特性来判断。

### 2. 配置forward属性
确保将需要在主线程中访问的函数添加到forward数组中。

### 3. 测试验证
在生产环境使用前，务必在开发环境中充分测试所有功能。

### 4. 监控性能
部署后持续监控性能指标，确保达到预期效果。

## 限制

### 技术限制
- 某些API在Web Worker中不可用
- 同步操作可能需要特殊处理
- 调试相对复杂

### 兼容性考虑
- 需要现代浏览器支持
- 某些第三方库可能不兼容