//
//  WJDownloader.m
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/8.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import "WJDownloader.h"
#import "NSString+WJURLMd5.h"
#import "WJDownloaderFileTool.h"

/** cache 目录 */
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
/** tmp 目录 */
#define kTmpPath NSTemporaryDirectory()


@interface WJDownloader ()<NSURLSessionDataDelegate>
{
    /** 请求文件总大小 */
    long long _totalFileSize;
    /** 本地缓存文件大小 */
    long long _tmpFileSize;
}

/** 下载会话 */
@property(nonatomic, strong) NSURLSession *session;
/** 临时缓存文件路径 */
@property(nonatomic, copy) NSString *tmpFilePath;
/** 下载完成保存的文件路径 */
@property(nonatomic, copy) NSString *cacheFilePath;

/** 文件输出流 */
@property(nonatomic, strong) NSOutputStream *outputStream;

/** 下载任务 */
@property (nonatomic, weak) NSURLSessionDataTask *task;

@end

@implementation WJDownloader

#pragma mark - 懒加载

- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}



#pragma mark - 方法

- (void)wj_downloadWithURL:(NSURL *)url{

    // 1. 确定下载文件的存储
    // 1.1 下载中的文件缓存到 tmp 目录
    // 拼接下载文件的临时路径, 文件名为 URL MD5 加密后的字符串
     self.tmpFilePath = [kTmpPath stringByAppendingPathComponent:[url.absoluteString md5Str]];
    // 1.2 下载完毕移动文件到 cache 目录
    // 拼接下载完成后的 cache 目录路径, 文件名为 url.lastPathComponent
    self.cacheFilePath = [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
    NSLog(@"%@", self.tmpFilePath);
    NSLog(@"%@", self.cacheFilePath);

    // 2. 判断本地有没有存在已经下载好的文件，如果有，return
    if ([WJDownloaderFileTool wj_isFileExists:self.cacheFilePath]) {
        NSLog(@"文件已经下载完毕, 直接返回相应的数据--文件的具体路径, 文件的大小等信息即可");
        self.state = kWJDownloaderStateSuccess;
        return;
    }
    
    
    // 判断如果当前任务不存在(当前 URL 是否有在下载任务中)
    if ([url isEqual:self.task.originalRequest.URL]) {
        // 任务已经存在
        if (self.state == kWJDownloaderStateDownloading) return;
        if (self.state == kWJDownloaderStatePause) {
            [self wj_resume];
            return;
        }
    }
    
    // 下载任务不存在（URL 不一样），先取消任务再添加比较好
    [self wj_cancel];
    
    
    // 3. 读取本地缓存文件的大小
    _tmpFileSize = [WJDownloaderFileTool wj_fileSizeWithPath:self.tmpFilePath];
    NSLog(@"%zd", _tmpFileSize);
    // 4. 根据缓存大小开始相应的下载网络请求
    [self downloadWithURL:url offset:_tmpFileSize];
    

    
}

- (void)downloadWithURL:(NSURL *)url offset:(long long)offset {
    
    // 发送网络请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 设置请求下载范围
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-", offset];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    self.task = task;
    [task resume];
    
}


- (void)wj_resume{
    
    if (self.state == kWJDownloaderStatePause) {
        [self.task resume];
        self.state = kWJDownloaderStateDownloading;
    }
    
    
}

- (void)wj_pause{
    
    if (self.state == kWJDownloaderStateDownloading) {
        [self.task suspend];
        self.state = kWJDownloaderStatePause;
    }
    
    
}



/**
 取消任务，不删除缓存
 */
- (void)wj_cancel{
    [self.session invalidateAndCancel];
    self.session = nil;
    
    self.state = kWJDownloaderStateFailed;

}

/**
 取消任务，删除缓存
 */
- (void)wj_cancelAndClearCache{
    [self wj_cancel];
    // 删除缓存
    [WJDownloaderFileTool wj_removeFilePath:self.tmpFilePath];
}

#pragma mark - NSURLSessionDataDelegate
/**
 当发送请求, 第一次接受到响应的时候调用
 
 @param completionHandler 系统传递给我们的一个回调代码块, 我们可以通过这个代码块, 来告诉系统,如何处理接下来的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    
    /*
     NSLog(@"%@", response);
     
     <NSHTTPURLResponse: 0x608000427480> { URL: http://sw.bos.baidu.com/sw-search-sp/software/353374073d79e/googlechrome_mac_55.0.2883.95.dmg } { status code: 206, headers {
     "Accept-Ranges" = bytes;
     Age = 256401;
     Connection = close;
     "Content-Length" = 63476797;
     "Content-MD5" = "dZ7yVh52NqxeHR/7wdzQpQ==";
     "Content-Range" = "bytes 0-63476796/63476797";
     "Content-Type" = "application/octet-stream";
     Date = "Sun, 09 Apr 2017 03:25:54 GMT";
     Etag = "\"759ef2561e7636ac5e1d1ffbc1dcd0a5\"";
     Expires = "Sun, 09 Apr 2017 04:03:57 GMT";
     "Last-Modified" = "Tue, 03 Jan 2017 02:45:36 GMT";
     "Ohc-Response-Time" = "1 0 0 0 0 0";
     Server = "JSP3/2.0.14";
     "x-bce-debug-id" = "MTAuMTkzLjM0LjE3OlR1ZSwgMDMgSmFuIDIwMTcgMTA6NDk6MDYgQ1NUOjI5NDYzNDM5OA==";
     "x-bce-request-id" = "1b1db9c1-0b38-49c5-99cc-3b8b3ee238ac";
     } }
     
     */
    
    // 类型转换
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    // 5. 本地缓存大小 与 文件总大小 进行比较
    // 5.1 获取请求文件总大小
    _totalFileSize = [httpResponse.allHeaderFields[@"Content-Length"] longLongValue];
    // 建议从 range 中获取总大小
    if (httpResponse.allHeaderFields[@"Content-Range"]) {
        NSString *rangeStr = httpResponse.allHeaderFields[@"Content-Range"];
        _totalFileSize = [[rangeStr componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    // 5.2 判断
    // 缓存大小 == 文件总大小 --> 下载完毕、取消请求 --> 移动文件到 cache 目录
    if (_totalFileSize == _tmpFileSize) {
        NSLog(@"本地已经存在该文件");
        // 移动tmp临时缓存的文件 -> 下载完成的路径cache
        [WJDownloaderFileTool wj_moveFile:self.tmpFilePath toPath:self.cacheFilePath];
        // 状态为下载成功
        self.state = kWJDownloaderStateSuccess;
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        return;
    }
    // 缓存大小 > 文件总大小  --> 缓存有问题 --> 取消原来的请求、删除缓存、重新下载
    if (_tmpFileSize > _totalFileSize) {
        NSLog(@"缓存有问题, 删除缓存, 重新下载");
        // 删除缓存
        [WJDownloaderFileTool wj_removeFilePath:self.tmpFilePath];
        // 取消请求
        completionHandler(NSURLSessionResponseCancel);
        // 重新发送请求
        [self downloadWithURL:response.URL offset:0];
        return;
    }
    
    // 缓存大小 < 文件总大小  --> 继续下载
    // 继续允许接受数据
    NSLog(@"继续接收数据");
    self.state = kWJDownloaderStateDownloading;
    // 打开输出流
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tmpFilePath append:YES];
    [self.outputStream open];
    
    completionHandler(NSURLSessionResponseAllow);
}



/**
 接收数据的时候调用
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"接收数据中");
    
    // 写入数据
    [self.outputStream write:data.bytes maxLength:data.length];
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    // 关闭流
    [self.outputStream close];
    self.outputStream = nil;
    
    if (error == nil) {
        NSLog(@"下载完毕");
        self.state = kWJDownloaderStateSuccess;
        // 移动数据
        [WJDownloaderFileTool wj_moveFile:self.tmpFilePath toPath:self.cacheFilePath];
    } else {
        NSLog(@"下载任务被取消或者有错误, 请检查 URL 地址等是否有误");
        self.state = kWJDownloaderStateFailed;
    }
}

@end
