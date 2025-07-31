---
title: FileMaker 数据库工具
date: 2022-06-29 22:08:26
categories:
  - Frontend Development
  - Low-Code
tags:
  - FileMaker
---

## FileMaker 简介

**FileMaker** 是一款**可视化数据库应用构建平台**。它集数据库建模、界面设计、脚本自动化、跨平台访问于一体，适用于：

- 快速构建业务管理系统
- 数据收集和可视化
- 跨团队协作工具
- 移动设备上的定制业务流程

常见应用包括：客户管理（CRM）、库存管理、工单系统、预约排程等。

---

## FileMaker 优点

- **上手快**：无需深入 SQL 就可以建表、连表、查询
- **跨平台**：支持 macOS、Windows、iOS（iPad/iPhone）、Web
- **所见即所得**：表单、布局直接拖拽设计
- **脚本自动化**：无需编程也能实现业务流程自动化
- **集成能力强**：支持 REST API、cURL、JSON、Web Viewer、插件扩展

---

## 基本使用：创建一个客户信息管理系统

### 1. 创建文件并定义字段

- 打开 FileMaker，选择“创建新文件”，命名为 `CustomerManager`
- 添加字段如下：

  - `Name`（文本）
  - `Phone`（文本）
  - `Email`（文本）
  - `Address`（文本）
  - `CreatedAt`（日期）

每一个字段就相当于数据库表中的一列。

### 2. 布局设计

- 切换到 **布局模式**（Layout Mode）
- 拖拽字段到页面
- 添加文本标签
- 插入按钮，例如“新建记录”、“删除记录”

还可以调整对齐、颜色和字体风格，打造用户友好的 UI。

### 3. 新增记录 & 浏览模式

- 切换到 **浏览模式**（Browse Mode）
- 点击右上角的“+”添加新记录
- 输入客户信息即可完成新增

### 4. 搜索功能

- 使用顶部的“查找”功能，输入关键字，例如搜索 Name 包含 "Tom" 的记录
- FileMaker 会展示所有匹配的记录

### 5. 脚本自动化（入门）

FileMaker 允许你通过“脚本工作区”（Script Workspace）创建自动化任务。

**示例脚本：设置 CreatedAt 为今天的日期**

```
If [ IsEmpty ( CreatedAt ) ]
    Set Field [ CreatedAt ; Get ( CurrentDate ) ]
End If
```

可以将此脚本绑定到“保存”按钮上，点击时自动设置日期。

## 发布和共享

- **本地使用**：FileMaker Pro
- **团队协作**：部署到 FileMaker Server 或 FileMaker Cloud
- **Web 访问**：启用 WebDirect 访问（不需客户端）

## 小技巧

- 使用 **关系图**（Relationships Graph）可以链接多个表，实现一对多、多对多的结构
- 通过 **值列表** 提供下拉选择
- 利用 **触发器（Script Triggers）** 在字段变动时执行脚本
