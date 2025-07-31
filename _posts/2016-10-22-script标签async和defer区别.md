---
title: script标签async和defer区别
date: 2016-10-22 14:30:11
categories: 
- Frontend Development 
- Html
tags: html

---



`async` 与 `defer` 都是用于异步加载外部 JavaScript 脚本的属性



**async**

- 脚本会异步下载，下载完成后立即执行，可能会在 HTML 解析过程中打断页面渲染。

- 如果有多个 async 脚本，它们的执行顺序不保证与在 HTML 中的顺序一致。



```html
<script async src="js/vendor/jquery.js"></script>
<script async src="js/script2.js"></script>
<script async src="js/script3.js"></script>
```



---

**defer**

- 脚本同样异步下载，但会等到 HTML 完全解析完毕后再按在文档中出现的顺序依次执行。

- 不会打断 HTML 的解析和页面的渲染，适合加载那些依赖 DOM 完全构建的脚本。

```html
<script defer src="js/vendor/jquery.js"></script>
<script defer src="js/script2.js"></script>
<script defer src="js/script3.js"></script>
```



---





总结：

- 如果脚本不依赖于 DOM 且无需顺序，可以使用 async。

- 如果脚本需要在文档解析完成后执行且需要保证顺序，则使用 defer。





相关链接：

[MDN-script](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/script)