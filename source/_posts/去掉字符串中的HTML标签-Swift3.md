---
title: '去掉字符串中的HTML标签#Swift3#'
date: 2017-03-09 10:45:44
tags:
- iOS
- Swift
- Swift3
---


```
let str = "<p>Hello</p>"

let newStr = str.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

print(newStr)

```
<!--more-->

就这样。