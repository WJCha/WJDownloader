//
//  WJDownloaderFileTool.m
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/8.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import "WJDownloaderFileTool.h"

@implementation WJDownloaderFileTool

+ (BOOL)wj_isFileExists:(NSString *)filePath{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


+ (long long)wj_fileSizeWithPath:(NSString *)filePath{
    
    if (![self wj_isFileExists:filePath]) {
        return 0;
    }
    
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    long long size = [fileInfo[NSFileSize] longLongValue];
    return size;
}

+ (void)wj_moveFile:(NSString *)fromPath toPath:(NSString *)toPath{
    
    if (![self wj_isFileExists:fromPath]) return;
    
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];

}


+ (void)wj_removeFilePath:(NSString *)filePath{
    
    if (![self wj_isFileExists:filePath]) return;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
}

@end
