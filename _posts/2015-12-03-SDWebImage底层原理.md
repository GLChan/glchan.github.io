---
title: SDWebImage底层原理
date: 2015-12-03 21:54:56
categories: 
- Mobile Development 
- iOS
tags: iOS Objective-C



---







## **1. SDWebImage 的核心架构**

`SDWebImage` 主要由以下几个关键组件组成：

- **`SDWebImageManager`**：图片加载的管理类，协调缓存、下载和解码。
- **`SDImageCache`**：本地缓存系统，支持内存缓存 (`NSCache`) 和磁盘缓存 (`NSData` / `UIImage`)。
- **`SDWebImageDownloader`**：图片下载器，负责异步从网络获取图片。
- **`SDWebImageDecoder`**：图片解码器，处理 PNG、JPEG 及 WebP 等格式。
- **`UIImageView+WebCache`**：`UIImageView` 的分类，简化调用方式。

其架构如下：

```
UIImageView+WebCache
       │
       ▼
SDWebImageManager
       │
       ├── SDImageCache  (检查内存/磁盘缓存)
       │
       ├── SDWebImageDownloader (执行网络下载)
       ▼
SDWebImageDecoder (解码图片)
```

------

## **2. 图片加载流程**

当调用 `sd_setImageWithURL:` 时，SDWebImage 会执行以下步骤：

```objective-c
#import <SDWebImage/UIImageView+WebCache.h>

[self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://example.com/image.jpg"]
                  placeholderImage:[UIImage imageNamed:@"placeholder"]
                           options:SDWebImageHighPriority];
```

### **2.1 查询内存缓存**

- `SDImageCache` 先检查 `NSCache`，如果命中，则直接返回。
- 适用于 **应用短时间内重复加载的图片**（如头像）。

### **2.2 查询磁盘缓存**

- 若 `NSCache` 未命中，则查找 `Library/Caches` 目录中的 `image.diskCachePath`。
- 若找到，则读取 `NSData` 并解码成 `UIImage`。
- 适用于 **上次运行缓存的图片**。

### **2.3 执行网络下载**

- 若缓存未命中，则使用 `SDWebImageDownloader` 发送 `NSURLSessionDataTask` 请求。
- 默认支持 `HTTP/HTTPS`，并处理 `304` 服务器缓存逻辑。
- 支持 `SDWebImageDownloaderHighPriority` 选项，控制下载优先级。

### **2.4 图片解码与存储**

- 下载完成后，`SDWebImageDecoder` 解析 `JPEG`、`PNG`、`WebP`，并缓存到 `SDImageCache`。
- **默认策略：**
  - `UIImage` 缓存至 `NSCache`（提高 UI 性能）。
  - `NSData` 存入磁盘（减少内存占用）。

------

## **3. SDWebImage 缓存策略**

`SDWebImage` 采用 **多级缓存策略** 来提高效率，主要分为 **内存缓存** 和 **磁盘缓存**。

### **3.1 内存缓存（NSCache）**

- 采用 `NSCache` 进行管理，具备自动淘汰策略。
- 适用于 **短时间频繁使用的图片**（如列表滚动）。
- 示例代码：

```objective-c
SDImageCache *cache = [SDImageCache sharedImageCache];
[cache storeImage:image forKey:@"imageKey" toDisk:NO];
UIImage *cachedImage = [cache imageFromMemoryCacheForKey:@"imageKey"];
```

### **3.2 磁盘缓存（存储 NSData）**

- 存储路径：`Library/Caches/com.hackemist.SDWebImageCache.default`
- 采用 `NSData` 形式存储原始图片数据，减少 `UIImage` 占用内存。
- 采用 **LRU（Least Recently Used）算法** 清理旧缓存。
- 示例代码：

```objective-c
UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:@"imageKey"];
```

### **3.3 服务器缓存（HTTP 缓存控制）**

- 支持 `ETag`、`Last-Modified` 机制，减少重复下载。
- 若服务器返回 `304 Not Modified`，则直接使用本地缓存。

------

## **4. 优化 SDWebImage 的大规模图片加载**

### **4.1 限制同时下载的图片数量**

- 避免过多 `NSURLSession` 并发任务，防止卡顿。
- 代码示例：

```objective-c
[SDWebImageDownloader sharedDownloader].maxConcurrentDownloads = 4;
```

### **4.2 调整图片解码方式**

- `SDWebImage` 默认在 **主线程** 进行 `UIImage` 解码，可能导致卡顿。
- 使用 `SDWebImageAvoidAutoSetImage` 让解码在 **后台** 线程完成。
- 示例代码：

```objective-c
[self.imageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageAvoidAutoSetImage];
```

### **4.3 预加载图片**

- 适用于 **即将出现的列表图片**，减少滚动时的网络延迟。
- 示例代码：

```objective-c
NSArray *urls = @[ [NSURL URLWithString:@"https://example.com/image1.jpg"],
                   [NSURL URLWithString:@"https://example.com/image2.jpg"] ];
[[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
```

### **4.4 控制缓存大小**

- 限制磁盘缓存大小，防止占用过多存储空间。
- 示例代码：

```objective-c
[[SDImageCache sharedImageCache] setMaxCacheSize:50 * 1024 * 1024]; // 50MB
```

------

## **5. 总结**

- `SDWebImage` 通过 **内存缓存 (`NSCache`)、磁盘缓存 (`NSData`) 和 HTTP 缓存 (`304`)** 进行高效管理。
- 采用 `NSURLSessionDataTask` 进行网络请求，并支持 **并发控制、图片解码优化**。
- 通过 **缓存策略、预加载和线程优化**，可以提升大规模图片加载的流畅度。
- 适当 **调整 `maxConcurrentDownloads` 和 `cacheSize`**，可以优化性能，减少 UI 卡顿。