//
//  ViewController.m
//  WJDownloaderDemo
//
//  Created by 陈威杰 on 2017/4/8.
//  Copyright © 2017年 ChenWeiJie. All rights reserved.
//

#import "ViewController.h"
#import "WJDownloader.h"

@interface ViewController ()

@property (nonatomic, strong) WJDownloader *downLoader;

/**
 *  NSTimer
 */
//@property(nonatomic, weak) NSTimer *timer;

@end

@implementation ViewController

- (WJDownloader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[WJDownloader alloc] init];
    }
    return _downLoader;
}

//- (NSTimer *)timer{
//    if (!_timer) {
//        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
//        _timer = timer;
//    }
//    return _timer;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self timer];

}

- (IBAction)startDownload:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://sw.bos.baidu.com/sw-search-sp/software/353374073d79e/googlechrome_mac_55.0.2883.95.dmg"];
//    [self.downLoader wj_downloadWithURL:url];
//    [self.downLoader setDownloadProgress:^(double progress) {
//        NSLog(@"%lf", progress);
//    }];
    
    [self.downLoader wj_downloadWithURL:url success:^(double progress, long long fileSize, NSString *filePath) {
        NSLog(@"进度--%lf， 文件大小--%lld", progress, fileSize);
    } failure:^(NSError *error) {
        NSLog(@"错误---%@", error);
    }];
    
}

- (IBAction)resume:(id)sender {
    [self.downLoader wj_resume];
}
- (IBAction)pause:(id)sender {
    [self.downLoader wj_pause];
}
- (IBAction)cancel:(id)sender {
    [self.downLoader wj_cancel];
}

//- (void)update {

//    NSLog(@"%zd", self.downLoader.state);
//    NSLog(@"%lf", self.downLoader.progress);
//    [self.downLoader setDownloadProgress:^(double progress) {
//        NSLog(@"%lf", progress);
//    }];

//}




@end
