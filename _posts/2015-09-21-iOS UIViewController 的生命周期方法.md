---
title: iOS UIViewController 的生命周期方法
date: 2015-09-21 21:56:19
categories: 
- Mobile Development 
- iOS
tags: iOS Objective-C



---



在 iOS 开发中，`UIViewController` 是应用程序的核心组成部分之一，负责管理视图的创建、显示和销毁。理解 `UIViewController` 的生命周期方法对于正确管理资源、优化性能和避免内存泄漏至关重要。

## **UIViewController 的生命周期方法**

### **1. `initWithNibName:bundle:` (初始化控制器)**

**调用时机：**

- 当使用 `initWithNibName:bundle:` 方法手动初始化 `UIViewController` 时调用。
- 如果使用 `storyboard`，通常不会直接调用这个方法。

**示例代码：**

```objective-c
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"ViewController 初始化");
    }
    return self;
}
```

### **2. `loadView` (创建 View)**

**调用时机：**

- 只有在 `view` 属性被访问但 `view` 还未被加载时才会调用。
- 如果使用 **Storyboard** 或 **XIB**，不会手动实现此方法。

**示例代码（通常不建议手动实现）：**

```objective-c
- (void)loadView {
    UIView *customView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    customView.backgroundColor = [UIColor whiteColor];
    self.view = customView;
}
```

### **3. `viewDidLoad` (视图加载完成)**

**调用时机：**

- 视图加载完成后调用，适合初始化 UI 元素、数据加载等。
- 只调用一次。

**示例代码：**

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad: 视图已经加载完成");
}
```

### **4. `viewWillAppear:` (视图即将显示)**

**调用时机：**

- 视图即将出现在屏幕上，每次 `view` 被展示时都会调用。
- 适合进行 UI 刷新、动画准备等。

**示例代码：**

```objective-c
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear: 视图即将显示");
}
```

### **5. `viewDidAppear:` (视图已经显示)**

**调用时机：**

- 视图已经完全出现在屏幕上。
- 适合开始动画、网络请求、数据加载等。

**示例代码：**

```objective-c
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear: 视图已经显示");
}
```

### **6. `viewWillDisappear:` (视图即将消失)**

**调用时机：**

- 视图即将从屏幕上消失时调用。
- 适合停止动画、保存状态等。

**示例代码：**

```objective-c
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear: 视图即将消失");
}
```

### **7. `viewDidDisappear:` (视图已经消失)**

**调用时机：**

- 视图已经从屏幕上消失时调用。
- 适合释放资源、清理任务等。

**示例代码：**

```objective-c
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear: 视图已经消失");
}
```

### **8. `didReceiveMemoryWarning` (内存警告)**

**调用时机：**

- 当设备内存紧张时，系统会调用此方法。
- 适合清理缓存数据、释放不必要的对象等。

**示例代码：**

```objective-c
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning: 收到内存警告");
}
```

### **9. `dealloc` (对象被销毁)**

**调用时机：**

- `UIViewController` 被释放时调用。
- 适合移除通知、释放资源等。

**示例代码：**

```objective-c
- (void)dealloc {
    NSLog(@"dealloc: 控制器被销毁");
}
```

## **生命周期调用顺序总结**

当一个 `UIViewController` 被创建并展示时，它的生命周期方法按照以下顺序调用：

1. `initWithNibName:bundle:` （如果使用 `init` 初始化）
2. `loadView`
3. `viewDidLoad`
4. `viewWillAppear:`
5. `viewDidAppear:`

当 `UIViewController` 从屏幕上消失时，调用顺序如下：

1. `viewWillDisappear:`
2. `viewDidDisappear:`
3. `dealloc`（如果 `ViewController` 没有被强引用）

### 注意事项:

1. **不要在 `viewDidLoad` 里获取视图尺寸**，因为 `view` 还未出现在屏幕上，`frame` 可能不准确。
2. **不要在 `viewWillAppear:` 里执行耗时操作**，否则会影响界面流畅度。
3. **在 `viewDidDisappear:` 里释放资源**，比如停止视频播放、关闭定时器等。
4. **记得在 `dealloc` 里移除 `NSNotification` 监听**，防止 `retain cycle`。



