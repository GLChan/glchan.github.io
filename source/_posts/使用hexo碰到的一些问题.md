---
title: HEXO👋
date: 2016-10-21 11:21:00
---
hexo使用起来算是比较方便，在不同机器上使用会碰到一些坑，懒得下次到处翻，做做记录吧。

### ERROR

``` bash
{ [Error: Cannot find module './build/Release/DTraceProviderBindings'] code: 'MODULE_NOT_FOUND' }
{ [Error: Cannot find module './build/default/DTraceProviderBindings'] code: 'MODULE_NOT_FOUND' }
{ [Error: Cannot find module './build/Debug/DTraceProviderBindings'] code: 'MODULE_NOT_FOUND' }

```

解决方法: 

``` bash
$ npm uninstall hexo
$ npm install hexo --no-optional
```

如果还不行，重新装`hexo-cli`：
 
``` bash
$ npm uninstall hexo-cli -g
$ npm install hexo-cli -g
```

### 换了电脑之后`hexo d`无效？
解决方法: 删除博客目录下的`.deploy_git`文件夹
