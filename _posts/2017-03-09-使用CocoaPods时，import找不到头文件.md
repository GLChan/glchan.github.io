---
title: 使用CocoaPods时，import找不到头文件
date: 2017-03-09 10:56:56
categories: 
- Mobile Development 
- iOS
tags: CocoaPods
---

没有设置头文件的目录

1. 在项目的 `target` -> `builds Settings` -> `User Header Search Paths` 添加`${SRCROOT}` 
2. 值设置成 `recursive`



<!--more-->