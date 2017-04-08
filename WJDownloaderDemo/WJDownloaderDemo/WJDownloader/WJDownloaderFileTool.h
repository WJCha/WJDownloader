//
//  WJDownloaderFileTool.h
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/8.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//
//  文件工具类

#import <Foundation/Foundation.h>

@interface WJDownloaderFileTool : NSObject

/**
  判断文件是否存在

 @param filePath 文件所在路径
 @return bool 值
 */
+ (BOOL)wj_isFileExists:(NSString *)filePath;


/**
 返回当前文件大小

 @param filePath 文件所在路径
 @return 文件大小
 */
+ (long long)wj_fileSizeWithPath:(NSString *)filePath;


/**
 将一个文件从一个路径移动到另外一个路径

 @param fromPath 源文件路径
 @param toPath 目标文件路径
 */
+ (void)wj_moveFile:(NSString *)fromPath toPath:(NSString *)toPath;


/**
 删除文件

 @param filePath 文件路径
 */
+ (void)wj_removeFilePath:(NSString *)filePath;

@end
