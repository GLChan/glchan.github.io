---
title: jQuery File Upload 插件使用
date: 2017-03-09 11:00:37
categories:
  - Frontend Development
  - jQuery
tags: jQuery IE8
---

前阵子有在开发前端，用到了这个`jQuery File Upload`插件用来上传文件，也遇到了个适配 IE8 的坑，记录一下。

- [Demo](https://blueimp.github.io/jQuery-File-Upload/)
- [Github](https://github.com/blueimp/jQuery-File-Upload)

<!--more-->

### 简单用法

```
$('#proImgsUpload').fileupload({
	url : url,
	autoUpload : true, // 默认

	add : function(e, data){ // 打开文件的回调
		data.submit(); // 文件开始上传的事件
	},

	progressall : function(e, data){
		var progress = parseInt(data.loaded / data.total * 100, 10); // 上传进度
	},

	done : function(e, data){
		// 上传成功
	}
});
```

### 适配 IE8

在图片上传成功之后，data.result IE8 无法取出服务器返回的数据，而 chrome 可以。后来网上找了很多方法尝试＝ ＝，才发现 IE8 里面返回的`data.dataType: iframe`。而 Chrome 返回的只有`data.data: FormData`。
