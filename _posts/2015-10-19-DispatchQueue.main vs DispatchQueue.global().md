---
title: DispatchQueue.main vs DispatchQueue.global()
date: 2015-10-19 21:54:56
categories: 
- Mobile Development 
- iOS
tags: iOS Objective-C


---



## **1. DispatchQueue.main.async {}（主队列，异步执行）**

`DispatchQueue.main.async {}` 代表将任务提交到 **主线程（Main Thread）** 的 **主队列（Main Queue）**，并异步执行。由于主线程主要用于 UI 操作，所以所有的 UI 更新都必须在主线程完成。

**示例：在主线程中执行任务**

```objective-c
dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"这是在主线程执行的代码");
    self.label.text = @"更新 UI"; // 只能在主线程修改 UI
});
```

**使用场景：**

- **更新 UI**（如 `UILabel`、`UIImageView`）
- **执行与 UI 交互相关的任务**
- **动画更新**

## **2. DispatchQueue.global().async {}（全局队列，异步执行）**

`DispatchQueue.global().async {}` 代表将任务提交到 **全局队列（Global Queue）**，并在后台线程执行。iOS 提供了多个 **不同优先级的全局队列**，用于处理耗时任务。

**示例：在后台执行耗时任务**

```objective-c
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSLog(@"这是在后台线程执行的代码");
    
    // 执行一些耗时操作
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://example.com/image.jpg"]];
    UIImage *image = [UIImage imageWithData:data];
    
    // 回到主线程更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
});
```

**使用场景：**

- **执行耗时操作**（如下载图片、网络请求、数据库操作）
- **数据处理**（如 JSON 解析、大量计算）
- **文件 I/O 任务**

## **3. 如何在后台执行任务后回到主线程更新 UI？**

当我们在后台线程执行任务后，如果需要更新 UI，必须手动切换回 **主线程**。否则，UI 相关操作可能会引发崩溃或 UI 无响应。

### **示例：后台下载图片并更新 UI**

```objective-c
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    // 耗时操作（后台执行）
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://example.com/image.jpg"]];
    UIImage *image = [UIImage imageWithData:data];
    
    // 切换到主线程更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
});
```

## **4. DispatchQueue.main.async VS DispatchQueue.global().async 总结**

| 特性           | `DispatchQueue.main.async {}` | `DispatchQueue.global().async {}` |
| -------------- | ----------------------------- | --------------------------------- |
| 线程           | 主线程（Main Thread）         | 后台线程（Background Thread）     |
| 适用场景       | UI 操作、动画、界面更新       | 耗时任务（如网络请求、计算）      |
| 是否阻塞主线程 | 否                            | 否                                |
| 是否可并发执行 | 否（串行队列）                | 是（并行队列）                    |



### 注意

1. **不要在主线程执行耗时任务**，否则会阻塞 UI，导致界面卡顿。
2. **在后台线程执行任务后，务必回到主线程更新 UI**，否则 UI 可能不会正确更新。
3. **主队列（Main Queue）是串行的**，即任务按顺序执行，而全局队列（Global Queue）是并行的，可同时执行多个任务。
4. **避免 UI 操作放入全局队列**，否则可能会导致崩溃或 UI 更新异常。



