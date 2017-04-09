//
//  ViewController.m
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/8.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import "ViewController.h"
#import "WJDownloaderManager.h"

@interface ViewController ()

//@property (nonatomic, strong) WJDownloader *downLoader;
@property (nonatomic , strong) NSURL *url;


@end

@implementation ViewController


- (NSURL *)url {
    if (!_url) {
        _url = [NSURL URLWithString:@"http://sw.bos.baidu.com/sw-search-sp/software/353374073d79e/googlechrome_mac_55.0.2883.95.dmg"];
    }
    return _url;
}



- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)startDownload:(id)sender {
    

    
    
    [[WJDownloaderManager shareInstance] wj_downloadManagerWithURL:self.url successBlock:^(double progress, long long fileSize, NSString *filePath) {
        NSLog(@"进度--%lf， 文件大小--%lld, 文件路径--%@", progress, fileSize, filePath);
    } failureBlock:^(NSError *error) {
        NSLog(@"错误---%@", error);
    }];
    
    // 或：
//    WJDownloader *downloader = [[WJDownloaderManager shareInstance] wj_downloadManagerWithURL:self.url];
//    self.downLoader = downloader;
//    [downloader setDownloadProgress:^(double progress) {
//        NSLog(@"%lf", progress);
//    }];
    
    
}

- (IBAction)resume:(id)sender {
//    [self.downLoader wj_resume];
}
- (IBAction)pause:(id)sender {
//    [self.downLoader wj_pause];
    [[WJDownloaderManager shareInstance] wj_pauseWithURL:self.url];
}
- (IBAction)cancel:(id)sender {
//    [self.downLoader wj_cancel];
    [[WJDownloaderManager shareInstance] wj_cancelWithURL:self.url];
}






@end
