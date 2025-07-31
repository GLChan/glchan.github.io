---
title: iOS WebViewJavascriptBridge开发实现Native 与 Web 的通信
date: 2019-03-12 21:56:19
categories: 
- Mobile Development 
- iOS
tags: 
- iOS
- Objective-C
- WebViewJavascriptBridge
---


## WebViewJavascriptBridge 的核心功能

`WebViewJavascriptBridge` 的核心功能包括：

1. **双向通信**：Native 端可以调用 Web 端的 JavaScript 函数，并接收返回值。Web 端可以调用 Native 端的方法，并传递参数。

2. **异步回调**： 支持异步通信，允许 Native 和 Web 端在调用后通过回调函数返回结果。

3. **参数传递**：支持传递字符串、JSON 对象等复杂数据类型，通信内容灵活。

4. **兼容性**：支持 `UIWebView`和 `WKWebView`。开发者可以根据项目需求选择合适的 WebView 组件。

## 开发流程

### 1. 添加 WebViewJavascriptBridge
- 通过 CocoaPods 安装：
  ```ruby
  pod 'WebViewJavascriptBridge', '~> 6.0'
  ```
- 或者手动下载源代码，并将 `WebViewJavascriptBridge` 文件夹添加到项目中。
- 导入头文件：
  ```swift
  import WebViewJavascriptBridge
  ```

### 2. 配置 WebView 和 Bridge
- 初始化 `WKWebView`或 `UIWebView`，并创建 Bridge 实例：
  ```swift
  class WebViewController: UIViewController, WKNavigationDelegate {
      var webView: WKWebView!
      var bridge: WKWebViewJavascriptBridge!
      
      override func viewDidLoad() {
          super.viewDidLoad()
          
          // 初始化 WKWebView
          let config = WKWebViewConfiguration()
          webView = WKWebView(frame: view.bounds, configuration: config)
          webView.navigationDelegate = self
          view.addSubview(webView)
          
          // 初始化 Bridge
          bridge = WKWebViewJavascriptBridge(for: webView)
          bridge.setWebViewDelegate(self)
          
          // 加载 Web 页面
          if let url = URL(string: "https://example.com") {
              webView.load(URLRequest(url: url))
          }
      }
  }
  ```
- 如果使用 `UIWebView`，Bridge 初始化方式类似：
  ```swift
  bridge = WebViewJavascriptBridge(for: uiWebView)
  bridge.setWebViewDelegate(self)
  ```

### 3. Native 端注册处理程序
- 在 Native 端注册处理程序，监听 Web 端的调用：
  ```swift
  bridge.registerHandler("callNative") { (data, responseCallback) in
      print("Received data from Web: \(data ?? "")")
      
      // 处理数据（例如，data 是一个 JSON 对象）
      if let jsonData = data as? [String: Any] {
          let action = jsonData["action"] as? String
          print("Action: \(action ?? "")")
      }
      
      // 返回结果给 Web 端
      responseCallback?("Native handled the request")
  }
  ```

### 4. Web 端配置 JavaScript Bridge
- 在 Web 端引入 `WebViewJavascriptBridge.js`（通常由 Native 端注入或 Web 端直接加载）。
- 初始化 Bridge 并调用 Native 方法：
  ```javascript
  function setupWebViewJavascriptBridge(callback) {
      if (window.WebViewJavascriptBridge) {
          callback(WebViewJavascriptBridge);
      } else {
          document.addEventListener('WebViewJavascriptBridgeReady', function() {
              callback(WebViewJavascriptBridge);
          }, false);
      }
  }
  
  setupWebViewJavascriptBridge(function(bridge) {
      // 调用 Native 方法
      bridge.callHandler('callNative', { action: 'showAlert' }, function(response) {
          console.log('Received response from Native:', response);
      });
  });
  ```

### 5. Native 端调用 Web 方法
- 在 Native 端调用 Web 端的 JavaScript 函数：
  ```swift
  bridge.callHandler("callWeb", data: ["message": "Hello from Native"]) { response in
      print("Received response from Web: \(response ?? "")")
  }
  ```
- 在 Web 端注册处理程序：
  ```javascript
  bridge.registerHandler('callWeb', function(data, responseCallback) {
      console.log('Received data from Native:', data);
      responseCallback('Web handled the request');
  });
  ```

## 注意事项

### 1. Bridge 的初始化时机
- Bridge 必须在 WebView 加载页面之前初始化，否则可能导致通信失败。
- 如果 Web 页面需要动态加载，建议在 `webView(_:didFinish:)` 回调中调用 JavaScript 初始化逻辑。

### 2. 数据传递与序列化
- 传递复杂数据（如 JSON 对象）时，需要确保 Native 和 Web 端的数据格式一致。
- `WebViewJavascriptBridge` 内部会自动序列化和反序列化数据，但开发者仍需检查数据是否正确解析。

### 3. 安全性
- 避免在 Web 端暴露敏感的 Native 方法，防止恶意调用。
- 如果需要传递敏感数据，建议使用加密或签名机制。

### 4. 调试与测试
- 使用 Safari 的 Web Inspector 调试 Web 端代码：
  - 在 iOS 设备上启用 Web Inspector（设置 > Safari > 高级 > Web 检查器）。
  - 在 macOS 的 Safari 中，选择 `开发 > 设备 > WebView`。
- 使用 Xcode 的调试工具查看 Native 端的日志和 Bridge 通信。


## 实际案例：Native 调用 Web 显示弹窗

让我们通过一个简单的示例，展示 Native 如何调用 Web 端显示一个弹窗：

### Native 端代码：
```swift
class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var bridge: WKWebViewJavascriptBridge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupBridge()
        
        // 加载本地 HTML 文件
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
    
    func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
    
    func setupBridge() {
        bridge = WKWebViewJavascriptBridge(for: webView)
        bridge.setWebViewDelegate(self)
        
        // 注册 Native 处理程序
        bridge.registerHandler("callNative") { (data, responseCallback) in
            print("Received data from Web: \(data ?? "")")
            responseCallback?("Native handled the request")
        }
    }
    
    @IBAction func showAlertTapped() {
        bridge.callHandler("showAlert", data: ["message": "Hello from Native"]) { response in
            print("Received response from Web: \(response ?? "")")
        }
    }
}
```

### Web 端代码（index.html）：
```html
<!DOCTYPE html>
<html>
<head>
    <title>WebView Demo</title>
    <script src="WebViewJavascriptBridge.js"></script>
</head>
<body>
    <button onclick="callNative()">Call Native</button>
    <script>
        function setupWebViewJavascriptBridge(callback) {
            if (window.WebViewJavascriptBridge) {
                callback(WebViewJavascriptBridge);
            } else {
                document.addEventListener('WebViewJavascriptBridgeReady', function() {
                    callback(WebViewJavascriptBridge);
                }, false);
            }
        }
        
        setupWebViewJavascriptBridge(function(bridge) {
            // 注册 Web 处理程序
            bridge.registerHandler('showAlert', function(data, responseCallback) {
                alert(data.message);
                responseCallback('Alert shown');
            });
            
            // 调用 Native 方法
            window.callNative = function() {
                bridge.callHandler('callNative', { action: 'log' }, function(response) {
                    console.log('Received response from Native:', response);
                });
            };
        });
    </script>
</body>
</html>
```

在这个示例中：
- Native 端通过 `showAlertTapped` 调用 Web 端的 `showAlert` 方法，传递消息并在 Web 端显示弹窗。
- Web 端通过按钮调用 Native 端的 `callNative` 方法，传递数据并接收返回值。