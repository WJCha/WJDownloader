//
//  WJDownloader.h
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/8.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 下载状态控制
 */
typedef NS_ENUM(NSInteger, WJDownloaderState) {
    /** 未知下载 */
    kWJDownloaderStateUnKnown,
    /** 下载暂停 */
    kWJDownloaderStatePause,
    /** 正在下载 */
    kWJDownloaderStateDownloading,
    /** 下载成功 */
    kWJDownloaderStateSuccess,
    /** 下载失败 */
    kWJDownloaderStateFailed
};



typedef void(^downloadFileSizeType)(long long fileSize);
typedef void(^downloadSuccessType)(NSString *cacheFilePath);
typedef void(^downloadErrorType)(NSError *error);


@interface WJDownloader : NSObject


/**
 *  下载状态
 */
@property(nonatomic, assign) WJDownloaderState state;

/** 状态改变 block */
@property(nonatomic, copy) void(^downloadStateChange)(WJDownloaderState state);

/**
 *  下载进度
 */
@property(nonatomic, assign) double progress;

/** 下载进度 block */
@property(nonatomic, copy) void(^downloadProgress)(double progress);

/** 文件下载信息 block */
@property(nonatomic, copy) downloadFileSizeType downloadFileSize;

/** 下载成功的文件路径 block */
@property(nonatomic, copy) downloadSuccessType downloadSuccessFilePath;

/** 下载错误信息 block */
@property(nonatomic, copy) downloadErrorType downloadError;


/**
 根据资源下载 URL 地址完成下载

 @param url 资源下载地址
 */
- (void)wj_downloadWithURL:(NSURL *)url;

- (void)wj_downloadWithURL:(NSURL *)url success:(void(^)(double progress, long long fileSize, NSString *filePath))success failure:(void(^)(NSError *error))failure;




/**
 继续下载
 */
- (void)wj_resume;


/**
 暂停任务， 可以恢复，缓存没有删除
 */
- (void)wj_pause;


/**
  取消下载任务，缓存不删除
 */
- (void)wj_cancel;

/**
 取消下载任务，缓存会删除
 */
- (void)wj_cancelAndClearCache;

@end
