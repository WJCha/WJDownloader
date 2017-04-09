//
//  WJDownloaderManager.h
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/9.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJDownloader.h"

@interface WJDownloaderManager : NSObject

/**
 单例
 */
+ (instancetype)shareInstance;


/**
 根据 URL 地址进行下载

 @param url 文件地址
 @return 下载器对象
 */
- (WJDownloader *)wj_downloadManagerWithURL:(NSURL *)url;


/**
 根据 URL 地址进行下载

 @param url 文件地址
 @param successBlock 成功
 @param failureBlock 失败
 */
- (void)wj_downloadManagerWithURL:(NSURL *)url successBlock:(void(^)(double progress, long long fileSize, NSString *filePath))successBlock failureBlock:(void(^)(NSError *error))failureBlock;


/**
 根据下载地址暂停对应的任务

 @param url 文件地址
 */
- (void)wj_pauseWithURL:(NSURL *)url;

/**
 根据下载地址取消对应的任务，内部会删除缓存

 @param url 文件地址
 */
- (void)wj_cancelWithURL:(NSURL *)url;

/**
 暂停所有下载任务
 */
- (void)pauseAll;

@end
