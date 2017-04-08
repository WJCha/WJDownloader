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

/** session */
@property(nonatomic, strong) NSURLSession *session;
/** 临时缓存文件路径 */
@property(nonatomic, copy) NSString *tmpFilePath;
/** 下载完成保存的文件路径 */
@property(nonatomic, copy) NSString *cacheFilePath;

@end

@implementation WJDownloader

- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


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
        return;
    }
    
    // 3. 下载过程中读取本地缓存文件的大小
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
    [task resume];
    
}


#pragma mark - NSURLSessionDataDelegate
/**
 当发送请求, 第一次接受到响应的时候调用
 
 @param completionHandler 系统传递给我们的一个回调代码块, 我们可以通过这个代码块, 来告诉系统,如何处理接下来的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    /*
    NSLog(@"%@", response);
     
    <NSHTTPURLResponse: 0x60000003af60> { URL: http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg } { status code: 206, headers {
        "Accept-Ranges" = bytes;
        "Content-Length" = 11;
        "Content-Range" = "bytes 0-10/11";
        "Content-Type" = "text/html";
        Date = "Sat, 08 Apr 2017 15:51:14 GMT";
        Etag = "\"1063451cdf48cf1:0\"";
        "Last-Modified" = "Wed, 26 Mar 2014 10:35:30 GMT";
        Server = "Microsoft-IIS/7.5";
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
        // 移动tmp临时缓存的文件 -> 下载完成的路径cache
        [WJDownloaderFileTool wj_moveFile:self.tmpFilePath toPath:self.cacheFilePath];
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
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"接收数据中");
}


@end
