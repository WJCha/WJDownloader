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

@end

@implementation ViewController

- (WJDownloader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[WJDownloader alloc] init];
    }
    return _downLoader;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)startDownload:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://sw.bos.baidu.com/sw-search-sp/software/353374073d79e/googlechrome_mac_55.0.2883.95.dmg"];
    [self.downLoader wj_downloadWithURL:url];
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






@end
