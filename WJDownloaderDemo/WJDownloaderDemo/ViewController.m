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
    
    NSURL *url = [NSURL URLWithString:@"http://free2.macx.cn:8281/tools/photo/SnapNDragPro418.dmg"];
    [self.downLoader wj_downloadWithURL:url];
}


@end
