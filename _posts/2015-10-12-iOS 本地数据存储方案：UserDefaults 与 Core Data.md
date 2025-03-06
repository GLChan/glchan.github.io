---
title: iOS 本地数据存储：UserDefaults 与 Core Data
date: 2015-10-12 22:56:41
categories: 
- Mobile Development 
- iOS
tags: iOS Objective-C


---



在 iOS 开发中，数据存储是应用程序开发的重要部分。苹果提供了多种本地存储方案，其中 **`NSUserDefaults`（用户默认存储）** 和 **`Core Data`（核心数据框架）** 是最常用的两种方式。

------

## **1. `NSUserDefaults`（用户默认存储）**

### **1.1 什么是 `NSUserDefaults`？**

`NSUserDefaults` 是 iOS 提供的一个轻量级本地存储方式，通常用于存储 **小型配置信息**，如用户偏好设置。

### **1.2 `NSUserDefaults` 的特点**

✅ 适用于存储 **小数据**（如布尔值、整数、字符串）
 ✅ **不适合存储大数据或复杂数据结构**
 ✅ **数据持久化**（即使应用关闭，数据仍然存在）
 ✅ **自动存储到 `plist` 文件**
 ✅ **线程安全**，但不适用于高频数据读写

### **1.3 `NSUserDefaults` 的使用**

**存储数据：**

```objective-c
[[NSUserDefaults standardUserDefaults] setObject:@"John Doe" forKey:@"username"];
[[NSUserDefaults standardUserDefaults] setInteger:25 forKey:@"age"];
[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
[[NSUserDefaults standardUserDefaults] synchronize]; // 立即同步
```

**读取数据：**

```objective-c
NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
NSInteger age = [[NSUserDefaults standardUserDefaults] integerForKey:@"age"];
BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"];
```

**删除数据：**

```objective-c
[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
[[NSUserDefaults standardUserDefaults] synchronize];
```

### **1.4 `NSUserDefaults` 的适用场景**

- **存储用户设置**（如主题模式、语言选择）
- **存储应用状态**（如是否已登录）
- **存储简单的键值对数据**（如上次播放的音乐 ID）

------

## **2. `Core Data`（核心数据框架）**

### **2.1 什么是 `Core Data`？**

`Core Data` 是苹果提供的 **对象持久化框架**，用于管理复杂数据结构。它提供了对象关系映射（ORM）功能，可轻松存储和查询数据。

### **2.2 `Core Data` 的特点**

✅ **适用于存储复杂数据**（如对象、关系型数据）
 ✅ **支持数据查询（fetch）、更新、删除**
 ✅ **支持数据建模（Entity、Attribute、Relationship）**
 ✅ **可以使用 SQLite 作为底层存储**
 ✅ **适合处理大量数据，但学习曲线较陡**

### **2.3 `Core Data` 的基本使用**

**1. 初始化 `NSManagedObjectContext`（管理对象上下文）**

```objective-c
NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
```

**2. 创建并存储数据**

```objective-c
NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
NSManagedObject *newUser = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];

[newUser setValue:@"John Doe" forKey:@"username"];
[newUser setValue:@25 forKey:@"age"];

NSError *error = nil;
if (![context save:&error]) {
    NSLog(@"保存失败: %@", error.localizedDescription);
}
```

**3. 读取数据**

```objective-c
NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
NSArray *users = [context executeFetchRequest:fetchRequest error:nil];
for (NSManagedObject *user in users) {
    NSLog(@"用户名: %@", [user valueForKey:@"username"]);
}
```

**4. 更新数据**

```objective-c
NSManagedObject *user = users.firstObject;
[user setValue:@"Jane Doe" forKey:@"username"];
[context save:nil];
```

**5. 删除数据**

```objective-c
[context deleteObject:user];
[context save:nil];
```

### **2.4 `Core Data` 的适用场景**

- **存储复杂数据结构**（如联系人、订单信息）
- **需要高效的数据查询和管理**
- **需要存储大量数据**（如离线缓存）



