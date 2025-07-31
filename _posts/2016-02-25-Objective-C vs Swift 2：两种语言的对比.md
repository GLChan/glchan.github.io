---
title: Objective-C vs Swift：两种语言的对比
date: 2016-02-25 19:09:43
categories: 
- Mobile Development 
- iOS
tags: Objective-C Swift

---



## 1. **语法对比**

Swift 语法更加简洁、现代化，而 Objective-C 语法较为冗长。

### **变量声明**

#### Objective-C:

```objc
NSString *name = @"Tom";
NSInteger age = 25;
```

#### Swift:

```swift
let name: String = "Tom"
let age: Int = 25
```

Swift 省略了 `*` 号，不需要 `@` 前缀，且类型推断可省略 `: String`。

------

### **方法调用**

#### Objective-C:

```objc
[self doSomethingWithName:@"Tom" age:25];
```

#### Swift:

```swift
self.doSomethingWithName("Tom", age: 25)
```

Swift 语法更接近自然语言，参数默认必须带标签。

------

## 2. **类型安全**

Swift 是 **强类型** 语言，而 Objective-C 使用动态类型（`id`），容易导致运行时错误。

#### Objective-C:

```objc
id value = @"Hello";
value = @123;  // 可能导致运行时错误
```

#### Swift:

```swift
var value: String = "Hello"
value = 123  // 编译错误，类型不匹配
```

Swift 在编译时就能检测到类型错误，提高了安全性。

------

## 3. **可选类型（Optionals）**

Swift 引入了 `Optional`，比 Objective-C 的 `nil` 指针更安全。

#### Objective-C:

```objc
NSString *name = nil;  // 可能引发崩溃
```

#### Swift:

```swift
var name: String? = nil  // 可选类型，避免崩溃
```

Swift 需要 `if let` 或 `guard let` 进行解包，确保安全访问。

------

## 4. **内存管理**

Swift 使用 **ARC（自动引用计数）**，Objective-C 也支持 ARC，但在 `C` 语言桥接时仍需手动管理。

#### Objective-C:

```objc
@property (nonatomic, strong) NSString *name;
```

#### Swift:

```swift
var name: String
```

Swift **不需要手动声明 `strong`**，默认所有引用都是强引用。

------

## 5. **错误处理**

Swift 引入了 `do-try-catch` 结构，比 Objective-C 的 `NSError` 机制更清晰。

#### Objective-C:

```objc
NSError *error = nil;
NSString *content = [NSString stringWithContentsOfFile:@"file.txt" encoding:NSUTF8StringEncoding error:&error];
if (error) {
    NSLog(@"Error: %@", error.localizedDescription);
}
```

#### Swift:

```swift
do {
    let content = try String(contentsOfFile: "file.txt", encoding: NSUTF8StringEncoding)
} catch {
    print("Error: \(error)")
}
```

Swift 的 `try-catch` 让错误处理更清晰，并强制开发者处理错误。

------

## 6. **集合操作**

Swift 提供更现代的集合操作，而 Objective-C 依赖 `NSArray` 和 `NSDictionary`，语法较繁琐。

#### Objective-C:

```objc
NSArray *array = @[@"Apple", @"Banana"];
NSMutableArray *mutableArray = [array mutableCopy];
[mutableArray addObject:@"Cherry"];
```

#### Swift:

```swift
var array = ["Apple", "Banana"]
array.append("Cherry")
```

Swift 让数组操作更加直观。

------

## 7. **闭包（Blocks vs. Closures）**

Swift 的 `closure` 比 Objective-C 的 `block` 更简洁。

#### Objective-C:

```objc
void (^printMessage)(NSString *) = ^(NSString *message) {
    NSLog(@"%@", message);
};
printMessage(@"Hello");
```

#### Swift:

```swift
let printMessage = { (message: String) in
    print(message)
}
printMessage("Hello")
```

Swift 省去了 `^` 符号，写法更加简洁。

------

## 8. **枚举（Enum）**

Swift 的 `enum` 更加强大，支持 `switch` 语法，而 Objective-C 的 `enum` 只是 `C` 风格的整数类型。

#### Objective-C:

```objc
typedef NS_ENUM(NSInteger, Fruit) {
    FruitApple,
    FruitBanana,
    FruitCherry
};
Fruit myFruit = FruitApple;
```

#### Swift:

```swift
enum Fruit {
    case Apple, Banana, Cherry
}
var myFruit = Fruit.Apple
```

Swift 枚举可以存储关联值，使其更具表达力。

------

## 9. **GCD（Grand Central Dispatch）**

Swift 使 `GCD` 更易读，而 Objective-C 仍需 C 语言风格的 API。

#### Objective-C:

```objc
dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"Hello");
});
```

#### Swift:

```swift
dispatch_async(dispatch_get_main_queue()) {
    print("Hello")
}
```

Swift 让 GCD 代码更加直观。

------

## 10. **字符串拼接**

Swift 使用 `String` 类型，更加现代化，而 Objective-C 仍需 `NSString`。

#### Objective-C:

```objc
NSString *fullName = [NSString stringWithFormat:@"%@ %@", @"John", @"Doe"];
```

#### Swift:

```swift
let fullName = "John" + " " + "Doe"
```

Swift 让字符串操作更简洁。

------

## **总结**

| **对比点**     | **Objective-C**             | **Swift**                  |
| -------------- | --------------------------- | -------------------------- |
| **语法**       | 冗长，`[]` 语法             | 简洁，`.` 语法             |
| **类型安全**   | 动态类型（id）              | 静态类型，编译时检查       |
| **内存管理**   | ARC+手动管理                | 完全 ARC                   |
| **错误处理**   | `NSError`                   | `try-catch`                |
| **可选类型**   | `nil` 可能崩溃              | `Optional` 安全性高        |
| **集合操作**   | `NSArray`，较繁琐           | `Array`，更直观            |
| **闭包**       | `Blocks` 语法复杂           | `Closure` 语法简洁         |
| **枚举**       | C 风格，整数类型            | 现代枚举，支持关联值       |
| **GCD**        | `dispatch_get_main_queue()` | `DispatchQueue.main.async` |
| **字符串拼接** | `stringWithFormat:`         | `+` 操作符                 |

Swift 通过更现代化的语法、更强的安全性、更高的可读性和更强的错误处理能力，使得开发更加高效。尽管 Objective-C 仍然用于维护老项目，但 Swift 已经明显更优越。