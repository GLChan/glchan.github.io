---
title: UIView的drawRect vs CALayer的display
date: 2015-09-23 19:10:02
categories: 
- Mobile Development 
- iOS
tags: iOS Objective-C

---





## **1. UIView 的 drawRect: 方法**

### **1.1 什么是 drawRect:?**

`drawRect:` 是 `UIView` 提供的绘制方法，它用于在 `UIView` 视图的 **context**（图形上下文）中进行自定义绘制。

```objective-c
@interface MyView : UIView
@end

@implementation MyView
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillRect(context, rect);
}
@end
```

### **1.2 drawRect: 的特点**

- 只有在 `setNeedsDisplay` 或 `setNeedsDisplayInRect:` 触发时，系统才会调用 `drawRect:` 进行重绘。
- 不能手动调用 `drawRect:`，它是由 UIKit 内部决定何时调用的。
- 适用于 **需要自定义绘制内容**（如 `CGContext` 画图、文字渲染）。
- **不会自动缓存绘制内容**，每次 `drawRect:` 都会重新绘制整个 `UIView`。

### **1.3 什么时候使用 drawRect:?**

- 需要自定义图形绘制，例如绘制 **曲线、图标、渐变色**。
- 需要 **动态渲染**，比如根据用户输入修改 `UIView` 内容。

------

## **2. CALayer 的 display: 方法**

### **2.1 什么是 display:?**

`display:` 是 `CALayer` 用于内容渲染的方法，与 `drawRect:` 类似，但它是 `Core Animation` 级别的绘制。

```objective-c
@interface MyLayer : CALayer
@end

@implementation MyLayer
- (void)display {
    self.contents = (__bridge id)[UIImage imageNamed:@"image.png"].CGImage;
}
@end
```

### **2.2 display: 的特点**

- `display:` 是 `CALayer` 直接处理内容的绘制方法，**比 `drawRect:` 更底层**。
- 你可以 **直接设置 `contents`**（通常是 `CGImageRef`），而不必手动绘制。
- 不像 `UIView` 的 `drawRect:` 依赖 `Core Graphics` 进行绘制，`display:` 可以 **手动控制** 何时绘制内容。
- **比 `drawRect:` 更高效**，因为 `CALayer` **可以缓存** 其 `contents`，减少重绘成本。

### **2.3 什么时候使用 display:?**

- 需要直接修改 `CALayer` 的 `contents`，比如图片缓存或纹理映射。
- **避免不必要的 CPU 计算**，将绘制任务交给 GPU 处理。
- 在 **复杂动画** 场景下，减少 `CPU` 参与过多绘制。

------

## **3. UIView 和 CALayer 绘制的核心区别**

|              | UIView (`drawRect:`)             | CALayer (`display:`)                     |
| ------------ | -------------------------------- | ---------------------------------------- |
| **调用方式** | 由 UIKit 自动触发                | 需要手动触发或 `displayLayer:` 代理方法  |
| **绘制方式** | 通过 `CGContext` 进行绘制        | 直接设置 `contents`，通常为 `CGImageRef` |
| **性能**     | 依赖 CPU 计算                    | 依赖 GPU 计算，性能更优                  |
| **适用场景** | 复杂的自定义绘制（如图形、文本） | 直接处理图片、缓存内容                   |

如果你不需要复杂的 `CGContext` 绘制，直接用 `CALayer` 的 `contents` 可能会更高效。

------

## **4. 如何优化 Core Animation 提高流畅度？**

如果你的 App 在动画或 UI 渲染时出现卡顿，可能是 `Core Animation` 负载过高。以下是一些优化建议：

### **4.1 避免不必要的 `drawRect:` 调用**

过多调用 `drawRect:` 会增加 CPU 负担，建议 **缓存绘制结果**，避免每次都重新计算。

```objective-c
// 只在必要时重绘
[self setNeedsDisplay];
```

### **4.2 使用 `shouldRasterize` 提前缓存内容**

如果 `UIView` 或 `CALayer` 需要多次绘制，启用 `rasterization` 可以缓存渲染结果，减少绘制开销。

```objective-c
layer.shouldRasterize = YES;
layer.rasterizationScale = [UIScreen mainScreen].scale;
```

### **4.3 避免 `Offscreen Rendering`（离屏渲染）**

某些 `CALayer` 属性会触发离屏渲染，例如：

- `shadowPath` 未指定时的 `shadow`。
- `mask` 或 `cornerRadius` 配合 `backgroundColor` 使用。

优化方法：

```objective-c
layer.shadowPath = [UIBezierPath bezierPathWithRect:layer.bounds].CGPath;
```

### **4.4 使用 `drawsAsynchronously` 进行异步绘制**

对于复杂 `CALayer` 绘制，可以开启 `drawsAsynchronously` 让 GPU 处理绘制任务。

```objective-c
layer.drawsAsynchronously = YES;
```

### **4.5 避免大量透明视图（`alpha` 层级过深）**

如果界面上有多个透明视图，会增加 `GPU` 负担，建议：

- 通过 `opaque = YES` 关闭不必要的透明度。
- 合并多个透明 `UIView` 以减少 `GPU` 计算量。

```objective-c
view.opaque = YES;
view.backgroundColor = [UIColor whiteColor];
```

------

## **5. 结论**

- `UIView` 主要通过 `drawRect:` 进行绘制，适用于 **复杂的自定义图形**。
- `CALayer` 主要通过 `display:` 进行绘制，更适用于 **直接设置 `contents`** 以提高性能。
- 在优化 Core Animation 时，建议 **避免不必要的 `drawRect:` 调用、减少离屏渲染、使用 `rasterization` 进行缓存**，提高 UI 流畅度。

希望这篇文章能帮助你理解 `UIView` 和 `CALayer` 的绘制机制，并更好地优化动画性能！🚀