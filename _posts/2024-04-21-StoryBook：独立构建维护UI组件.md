---
title: StoryBook：独立构建维护UI组件
date: 2024-04-21 23:50:37
categories:
  - Frontend Development
  - Frameworks & Libraries
tags: Storybook
---

Storybook 是一个开源的工具，专门用于构建 UI 组件的开发环境。让我们能够独立开发组件，脱离具体的业务场景，在一个隔离的环境中专注于组件本身的逻辑和表现。Storybook 是 UI 组件的"陈列室"，每个组件都有自己的展示空间。

## 快速上手指南

### 安装和初始化

```bash
# 在现有项目中初始化
npx storybook@latest init

# 启动Storybook
npm run storybook
```

### 创建第一个 Story

举例一个简单的 Button 组件：

```jsx
// components/Button.jsx
export const Button = ({
  primary = false,
  size = "medium",
  label,
  ...props
}) => {
  const mode = primary ? "primary" : "secondary";
  return (
    <button
      type="button"
      className={`button button--${size} button--${mode}`}
      {...props}
    >
      {label}
    </button>
  );
};
```

对应的 Story 文件：

```javascript
// stories/Button.stories.js
import { Button } from "../components/Button";

export default {
  title: "UI/Button",
  component: Button,
  argTypes: {
    backgroundColor: { control: "color" },
  },
};

const Template = (args) => <Button {...args} />;

export const Primary = Template.bind({});
Primary.args = {
  primary: true,
  label: "主要按钮",
};

export const Secondary = Template.bind({});
Secondary.args = {
  label: "次要按钮",
};

export const WithIcon = Template.bind({});
WithIcon.args = {
  label: "带图标按钮",
  icon: "star",
};
```

## 高级功能

### 自动文档生成

Storybook 可以基于你的 Stories 和组件代码自动生成文档：

```javascript
// 在故事配置中启用文档
export default {
  title: "UI/Button",
  component: Button,
  tags: ["autodocs"],
  parameters: {
    docs: {
      description: {
        component: "这是一个可复用的按钮组件，支持多种样式和尺寸。",
      },
    },
  },
};
```

### 交互测试

通过 Play 函数，你可以在 Story 中模拟用户交互：

```javascript
import { userEvent, within } from "@storybook/testing-library";

export const InteractiveButton = {
  args: {
    label: "点击我",
  },
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);
    const button = canvas.getByRole("button");

    await userEvent.click(button);
    // 验证点击后的行为
  },
};
```

### 视觉回归测试

结合 Chromatic 等工具，Storybook 可以进行自动化的视觉回归测试：

```bash
# 安装Chromatic
npm install --save-dev chromatic

# 运行视觉测试
npx chromatic --project-token=<your-project-token>
```

## 实践

### 1. 组织结构

```
stories/
├── atoms/
│   ├── Button.stories.js
│   └── Input.stories.js
├── molecules/
│   ├── SearchBox.stories.js
│   └── FormField.stories.js
└── organisms/
    ├── Header.stories.js
    └── ProductCard.stories.js
```

### 2. 覆盖所有状态

为每个组件创建覆盖所有可能状态的 Stories：

```javascript
export const LoadingButton = {
  args: {
    label: "加载中...",
    loading: true,
    disabled: true,
  },
};

export const ErrorButton = {
  args: {
    label: "重试",
    variant: "error",
  },
};
```

### 3. 使用 Args 进行动态控制

充分利用 Args 让 Stories 具有交互性：

```javascript
export default {
  argTypes: {
    size: {
      control: { type: "select" },
      options: ["small", "medium", "large"],
    },
    disabled: {
      control: "boolean",
    },
    onClick: { action: "clicked" },
  },
};
```

### 4. 添加文档

```javascript
export const Primary = {
  args: {
    primary: true,
    label: "Button",
  },
  parameters: {
    docs: {
      storyDescription: "主要按钮用于最重要的操作，在一个页面中应该只有一个。",
    },
  },
};
```

## 与其它工具的集成

### TypeScript 支持

Storybook 对 TypeScript 有完整的支持：

```typescript
// Button.stories.ts
import type { Meta, StoryObj } from "@storybook/react";
import { Button } from "./Button";

const meta: Meta<typeof Button> = {
  title: "Example/Button",
  component: Button,
  parameters: {
    layout: "centered",
  },
  tags: ["autodocs"],
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {
  args: {
    primary: true,
    label: "Button",
  },
};
```

### 设计系统集成

Storybook 是构建设计系统的理想工具：

```javascript
// 主题配置
export const withTheme = (Story, context) => {
  const theme = context.globals.theme || "light";
  return (
    <ThemeProvider theme={themes[theme]}>
      <Story />
    </ThemeProvider>
  );
};

export const globalTypes = {
  theme: {
    name: "Theme",
    description: "Global theme for components",
    defaultValue: "light",
    toolbar: {
      icon: "circlehollow",
      items: ["light", "dark"],
    },
  },
};
```

## 性能优化

### 1. 懒加载 Stories

```javascript
// 使用动态导入
const LazyComponent = lazy(() => import("./HeavyComponent"));

export const LazyStory = () => (
  <Suspense fallback={<div>Loading...</div>}>
    <LazyComponent />
  </Suspense>
);
```

### 2. 优化构建配置

```javascript
// .storybook/main.js
module.exports = {
  webpackFinal: async (config) => {
    // 添加自定义webpack配置
    config.optimization = {
      ...config.optimization,
      splitChunks: {
        chunks: "all",
      },
    };
    return config;
  },
};
```

## 部署

### 静态部署

```bash
# 构建静态文件
npm run build-storybook

# 部署到各种平台
# Netlify, Vercel, GitHub Pages等
```

### 团队协作

Storybook 可以部署为在线文档，让整个团队都能访问：

- 设计师可以查看最新的组件实现
- 产品经理能够了解功能细节
- 其他开发者可以学习组件用法

## 常见问题

### 1. 样式不显示

确保导入了必要的 CSS 文件：

```javascript
// .storybook/preview.js
import "../src/index.css";
```

### 2. 第三方库兼容

某些第三方库可能需要特殊配置：

```javascript
// .storybook/main.js
module.exports = {
  webpackFinal: async (config) => {
    config.resolve.fallback = {
      ...config.resolve.fallback,
      fs: false,
      path: false,
    };
    return config;
  },
};
```
