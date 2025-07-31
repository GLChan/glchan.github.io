---
title: 项目 Flutter 2 升级 Flutter 3
date: 2022-09-30 21:27:16
categories:
  - Mobile Development
  - Flutter
tags: Flutter Flutter3
---

Flutter 3 带来了许多重要的改进和新特性，但升级过程中也遇到了一些挑战。

## Flutter 3 的主要新特性

### 1. 平台支持扩展

- **macOS 和 Linux**：正式稳定支持
- **Web**：性能大幅提升，PWA 支持增强
- **Windows**：生产就绪的桌面应用支持

### 2. 性能提升

- **Material You**：全新的 Material Design 支持
- **渲染引擎优化**：更流畅的动画和更低的内存占用
- **Dart 2.17**：更好的性能和开发体验

### 3. 开发体验改进

- **Lint 规则更新**：更严格的代码质量检查
- **Flutter Inspector**：调试工具增强
- **Hot Reload**：更快的代码重载速度

## 升级前的准备工作

### 1. 环境检查

首先检查当前的 Flutter 版本和环境：

```bash
# 查看当前Flutter版本
flutter --version

# 检查Flutter环境
flutter doctor -v

# 查看当前项目的Flutter版本
cat pubspec.yaml | grep flutter
```

### 2. 依赖检查

创建依赖检查脚本：

```bash
#!/bin/bash
# check_dependencies.sh

echo "检查项目依赖兼容性..."

# 检查主要依赖包的Flutter 3兼容性
flutter pub deps --json > deps.json

echo "当前主要依赖包："
cat pubspec.yaml | grep -A 20 "dependencies:" | grep "  " | grep -v "flutter:"
```

## 升级步骤详解

### 步骤 1：Flutter SDK

```bash
# 切换到stable channel（如果还没有）
flutter channel stable

# 升级Flutter到最新版本
flutter upgrade

# 验证升级结果
flutter --version
# 应该显示Flutter 3.x.x

# 清理缓存
flutter clean
```

### 步骤 2：pubspec.yaml

```yaml
# pubspec.yaml
name: your_app_name
description: Your app description

publish_to: "none"

version: 1.0.0+1

environment:
  # 从Flutter 2.x升级到3.x
  sdk: ">=2.17.0 <4.0.0" # 更新Dart SDK版本
  flutter: ">=3.0.0" # 指定Flutter最低版本

dependencies:
  flutter:
    sdk: flutter

  # 更新主要依赖包到兼容版本
  cupertino_icons: ^1.0.5
  http: ^0.13.5
  provider: ^6.0.3
  shared_preferences: ^2.0.15

  # 常用的包
  url_launcher: ^6.1.5
  image_picker: ^0.8.5+3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # 更新Lint规则
  flutter_lints: ^2.0.1 # 从^1.0.0升级

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
```

### 步骤 3：更新 analysis_options.yaml

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

# Flutter 3推荐的额外Lint规则
linter:
  rules:
    # Material Design 3相关
    use_colored_box: true
    use_decorated_box: true

    # 性能相关
    avoid_unnecessary_containers: true
    sized_box_for_whitespace: true

    # 代码质量
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_const_declarations: true

    # 新增的推荐规则
    use_super_parameters: true
    unnecessary_late: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

### 步骤 4：执行依赖更新

```bash
# 获取新的依赖版本
flutter pub get

# 如果有依赖冲突，尝试升级
flutter pub upgrade

# 清理并重新获取依赖
flutter clean
flutter pub get
```

## 主要破坏性变更处理

### 1. ThemeData 变更

```dart
// Flutter 2写法
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // 旧的属性可能已弃用
        accentColor: Colors.blueAccent,
      ),
      home: HomePage(),
    );
  }
}

// Flutter 3推荐写法
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // 使用新的颜色系统
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        // 采用Material 3设计
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
```

### 2. AppBar 样式更新

```dart
// Flutter 2写法
AppBar(
  backgroundColor: Colors.blue,
  elevation: 4.0,
  title: Text('My App'),
  centerTitle: true,
)

// Flutter 3写法 - Material 3风格
AppBar(
  title: const Text('My App'),
  centerTitle: true,
  // Material 3会自动应用新的样式
  // 如需自定义，使用AppBarTheme
)

// 在ThemeData中自定义AppBar
ThemeData(
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 4,
  ),
)
```

### 3. 文本样式更新

```dart
// Flutter 2写法
Text(
  'Hello World',
  style: Theme.of(context).textTheme.headline6,
)

// Flutter 3写法 - 新的文本样式命名
Text(
  'Hello World',
  style: Theme.of(context).textTheme.titleLarge, // headline6 -> titleLarge
)

// 完整的文本样式映射
class TextStyleHelper {
  static TextStyle? getHeadline1(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge; // headline1 -> displayLarge
  }

  static TextStyle? getHeadline2(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium; // headline2 -> displayMedium
  }

  static TextStyle? getHeadline3(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall; // headline3 -> displaySmall
  }

  static TextStyle? getHeadline4(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium; // headline4 -> headlineMedium
  }

  static TextStyle? getHeadline5(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall; // headline5 -> headlineSmall
  }

  static TextStyle? getHeadline6(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge; // headline6 -> titleLarge
  }
}
```

### 4. 按钮样式更新

```dart
// Flutter 2写法
RaisedButton(
  onPressed: () {},
  child: Text('Press Me'),
  color: Colors.blue,
)

FlatButton(
  onPressed: () {},
  child: Text('Flat Button'),
)

// Flutter 3写法 - 使用新的按钮组件
ElevatedButton(
  onPressed: () {},
  child: const Text('Press Me'),
)

TextButton(
  onPressed: () {},
  child: const Text('Text Button'),
)

OutlinedButton(
  onPressed: () {},
  child: const Text('Outlined Button'),
)
```

### 5. 导航相关更新

```dart
// Flutter 2写法
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => SecondPage()),
);

// Flutter 3推荐写法 - 使用GoRouter
// pubspec.yaml中添加: go_router: ^5.0.0

import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/details',
          builder: (BuildContext context, GoRouterState state) {
            return const DetailsPage();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

// 导航使用
context.go('/details');
```

## iOS 平台特定注意事项

### 1. 更新 iOS 配置

```xml
<!-- ios/Runner/Info.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- 确保最低iOS版本支持 -->
    <key>MinimumOSVersion</key>
    <string>11.0</string>

    <!-- Flutter 3需要的新权限配置 -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to take photos</string>

    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo library access</string>
</dict>
</plist>
```

### 2. 更新 Podfile

```ruby
# ios/Podfile
platform :ios, '11.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # Flutter 3兼容性设置
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
      ]
    end
  end
end
```

### 3. iOS 构建脚本更新

```bash
#!/bin/bash
# build_ios.sh

echo "开始iOS构建流程..."

# 清理之前的构建
flutter clean
cd ios && rm -rf Pods Podfile.lock && cd ..

# 获取依赖
flutter pub get

# 安装iOS依赖
cd ios && pod install && cd ..

# 构建iOS应用
flutter build ios --release

echo "iOS构建完成！"
```

## 性能优化和新特性应用

### 1. Material 3 设计语言应用

```dart
class ModernCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ModernCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Material 3的新特性
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. 新的导航栏组件

```dart
class ModernBottomNavigation extends StatefulWidget {
  @override
  _ModernBottomNavigationState createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: '搜索',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const SearchPage();
      case 2:
        return const FavoritePage();
      case 3:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }
}
```

### 3. 性能优化最佳实践

```dart
// 使用const构造函数优化性能
class OptimizedWidget extends StatelessWidget {
  const OptimizedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        // 尽可能使用const
        Text('Static Text'),
        SizedBox(height: 16),
        Icon(Icons.star),
      ],
    );
  }
}

// 使用RepaintBoundary优化重绘
class ExpensiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: ComplexPainter(),
        size: Size(200, 200),
      ),
    );
  }
}

// 使用AutomaticKeepAliveClientMixin保持状态
class KeepAliveWidget extends StatefulWidget {
  @override
  _KeepAliveWidgetState createState() => _KeepAliveWidgetState();
}

class _KeepAliveWidgetState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return const Text('This widget will be kept alive');
  }
}
```

## 常见问题和解决方案

### 1. 依赖冲突解决

```bash
# 问题：依赖版本冲突
# 解决方案：
flutter pub deps
flutter pub upgrade --major-versions

# 如果仍有冲突，手动指定版本
# pubspec.yaml
dependency_overrides:
  meta: ^1.8.0
  collection: ^1.16.0
```

### 2. iOS 构建错误

```bash
# 问题：iOS构建失败
# 解决方案：
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
flutter clean
flutter build ios
```

### 3. Material 3 兼容性问题

```dart
// 问题：某些组件在Material 3下显示异常
// 解决方案：逐步迁移，保持兼容性
class CompatibleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // 可以选择性启用Material 3
        useMaterial3: true,

        // 自定义主题确保兼容性
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
```

### 4. 调试工具使用

```dart
// 性能调试
class PerformanceDebugging {
  static void enablePerformanceOverlay() {
    // 在MaterialApp中添加
    // debugShowMaterialGrid: true,
    // showPerformanceOverlay: true,
  }

  static void profileWidgetBuilds() {
    // 使用Flutter Inspector
    // flutter pub global activate devtools
    // flutter pub global run devtools
  }
}
```

### 5. 内存优化

```dart
class MemoryOptimizedImageWidget extends StatelessWidget {
  final String imageUrl;

  const MemoryOptimizedImageWidget({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      // 内存优化配置
      cacheWidth: 400,
      cacheHeight: 400,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const CircularProgressIndicator();
      },
    );
  }
}
```

## 升级后的验证项

### 功能验证

- 应用正常启动
- 所有页面正常显示
- 导航功能正常
- 网络请求正常
- 本地存储功能正常
- 推送通知正常

### 性能验证

- 启动时间没有明显延长
- 内存使用正常
- 动画流畅度良好
- 列表滚动性能正常

### 兼容性验证

- iOS 不同版本兼容性
- 不同屏幕尺寸适配
- 深色模式正常
- 辅助功能支持

### 构建验证

- Debug 构建正常
- Release 构建正常
- 打包大小合理
- 签名和发布正常

## 总结

升级过程比较繁琐，需要保持耐心，注意一些 API 的更新和使用。
