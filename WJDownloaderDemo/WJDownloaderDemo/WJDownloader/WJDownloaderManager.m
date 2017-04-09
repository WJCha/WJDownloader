//
//  WJDownloaderManager.m
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/9.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import "WJDownloaderManager.h"
#import "NSString+WJURLMd5.h"

@interface WJDownloaderManager ()

/** 保存下载任务字典 */
@property(nonatomic, strong) NSMutableDictionary<NSString *, WJDownloader *> *downloadTasks;

@end

@implementation WJDownloaderManager

- (NSMutableDictionary<NSString *,WJDownloader *> *)downloadTasks{
    if (!_downloadTasks) {
        _downloadTasks = [NSMutableDictionary dictionary];
    }
    return _downloadTasks;
}


static WJDownloaderManager *_shareInstance = nil;

// 非绝对单例
+ (instancetype)shareInstance{
    if (!_shareInstance) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [[super allocWithZone:zone] init];
        });
    }
    return _shareInstance;
}



- (WJDownloader *)wj_downloadManagerWithURL:(NSURL *)url{
    
    // 对 url 地址进行 md5 加密, 作为下载任务字典的 key
    NSString *urlMd5 = [url.absoluteString md5Str];
    // 根据加密后的地址去下载任务字典中查找是否已经存在下载任务
    WJDownloader *downloader = self.downloadTasks[urlMd5];
    if (downloader) {
        // 如果已经存在，继续下载
        [downloader wj_resume];
        return downloader;
    }
    
    // 任务不存在
    downloader = [[WJDownloader alloc] init];
    // 添加任务到字典
    [self.downloadTasks setObject:downloader forKey:urlMd5];
    // 开始下载任务
    __weak typeof(self) weakSelf = self;
    [downloader wj_downloadWithURL:url success:^(double progress, long long fileSize, NSString *filePath) {
        // 下载完毕，移除任务
        if (1.0 == progress) {
            // 下载完毕，移除任务
            [weakSelf.downloadTasks removeObjectForKey:urlMd5];
        }
    } failure:^(NSError *error) {
        [weakSelf.downloadTasks removeObjectForKey:urlMd5];
    }];
    
    return downloader;
    
}

- (void)wj_downloadManagerWithURL:(NSURL *)url successBlock:(void(^)(double progress, long long fileSize, NSString *filePath))successBlock failureBlock:(void(^)(NSError *error))failureBlock{
    
    // 对 url 地址进行 md5 加密, 作为下载任务字典的 key
    NSString *urlMd5 = [url.absoluteString md5Str];
    // 根据加密后的地址去下载任务字典中查找是否已经存在下载任务
    WJDownloader *downloader = self.downloadTasks[urlMd5];
    if (downloader) {
        // 如果已经存在，继续下载
        [downloader wj_resume];
        return;
    }
    
    // 任务不存在
    downloader = [[WJDownloader alloc] init];
    // 添加任务到字典
    [self.downloadTasks setObject:downloader forKey:urlMd5];

    // 开始下载任务
    __weak typeof(self) weakSelf = self;
    [downloader wj_downloadWithURL:url success:^(double progress, long long fileSize, NSString *filePath) {

        // 执行 block
        if (successBlock) {
            successBlock(progress, fileSize, filePath);
        }
        
        if (1.0 == progress) {
             // 下载完毕，移除任务
            [weakSelf.downloadTasks removeObjectForKey:urlMd5];
        }
        
    } failure:^(NSError *error) {
        [weakSelf.downloadTasks removeObjectForKey:urlMd5];
        if (failureBlock) {
            failureBlock(error);
        }
    }];


    
}




- (void)wj_pauseWithURL:(NSURL *)url{
    NSString *urlMd5 = [url.absoluteString md5Str];
    WJDownloader *downloader = self.downloadTasks[urlMd5];
    [downloader wj_pause];
}

- (void)wj_cancelWithURL:(NSURL *)url{
    NSString *urlMd5 = [url.absoluteString md5Str];
    WJDownloader *downloader = self.downloadTasks[urlMd5];
    [downloader wj_cancelAndClearCache];
}

- (void)pauseAll{
    [[self.downloadTasks allValues] makeObjectsPerformSelector:@selector(wj_pause)];
    
}


@end
