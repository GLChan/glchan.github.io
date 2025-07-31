---
title: Jenkins+fir-cli自动发布iOS应用
date: 2017-03-13 09:40:06
categories: 
- DevOps
- Jenkins
tags:
- CI/CD
- Jenkins
---

最近开发iOS手动打包开始变得频繁，所以集成的自动化也不可避免。在这里记录一下搭建持续集成的服务。

<!--more-->

# 持续集成服务器初级配置 － Jenkis

### 安装
#### 通过Homebrew安装
安装

```
$ brew install jenkins 
```

后台进程服务

```
$ brew services start jenkins
```

如果不想启动后台服务，就只在terminal跑（关闭terminal窗口的同时也会结束进程）

```
$ jenkins
```

### 新建

通过[http://localhost:8080/](http://localhost:8080/) 或者[http://127.0.0.1:8080/](http://127.0.0.1:8080/) 访问Jenkins的管理后台

密码就在， copy进来就能登录

```
/Users/mac用户名/.jenkins/secrets/initialAdminPassword
```

<!--### 插件
之后进入到自定义Jenkins插件安装的界面，共两个选项，可以选择自己想要的，不知道怎么选择的选择左边建议安装(`Install suggested plugins`)的就好。

`Git plugin`，`Subversion Plug-in`也会包括在其中。

-->

### 管理用户

这里可以选择添加也可以选择直接下一步


### 安装XCode插件(旧版本)
- [XCode 插件 wiki](https://wiki.jenkins.io/display/JENKINS/Xcode+Plugin)
- [XCode 插件 1.4.11版本下载地址](https://mvnrepository.com/artifact/org.jenkins-ci.plugins/xcode-plugin/1.4.11)

1. 下载完之后上传到jenkins

### 新建

输入项目名称并选择`构建一个自由风格的软件项目`

### 配置（本地代码）

1. 增加构建步骤
2. 常规构建配置
3. Code signing 和 keychain 配置
4. 高级XCode构建选项

### 自动上传fir

编译完成之后自动上传到fir

1. 增加构建步骤
	- 在Command框中输入
	
	```
	fir publish "ipa文件路径" -T "fir token"
	```
	
---

备注：没有安装fir命令的要先安装fir

参考：[使用Jenkins+fir-cli自动发布Android或iOS应用](http://blog.fir.im/fir-im-practicesguide4/)



