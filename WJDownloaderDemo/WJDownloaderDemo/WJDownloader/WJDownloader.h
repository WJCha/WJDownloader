//
//  WJDownloader.h
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/8.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJDownloader : NSObject


/**
 根据资源下载 URL 地址完成下载

 @param url 资源下载地址
 */
- (void)wj_downloadWithURL:(NSURL *)url;


/**
 继续下载
 */
- (void)wj_resume;


/**
 暂停任务， 可以恢复，缓存没有删除
 */
- (void)wj_pause;


/**
  取消下载，缓存会删除
 */
- (void)wj_cancel;

@end
