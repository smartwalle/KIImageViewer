//
//  ViewController.m
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "ViewController.h"
#import "KIZoomImageView.h"
#import "KIImageViewer.h"
#import "UIImage+KIImageViewer.h"


@interface ViewController () <KIImageViewerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iv;
//@property (weak, nonatomic) IBOutlet KIImageScrollView *isv;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.isv setImage:[UIImage imageNamed:@"iOS.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showImageAction:(UIButton *)sender {
    
    NSInteger tag = sender.tag - 200;
    
    [KIImageViewer showWithDataSource:self initialIndex:tag];
}


- (NSURL *)imageViewer:(KIImageViewer *)imageViewer imageURLAtIndex:(NSInteger)index {
    return nil;//[NSURL URLWithString:@"http://img.pconline.com.cn/images/upload/upc/tx/wallpaper/1402/12/c1/31189058_1392186616852.jpg"];
}

- (UIImage *)imageViewer:(KIImageViewer *)imageViewer placeholderImageAtIndex:(NSInteger)index {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg", index+1]];
}

- (NSInteger)numberOfImages:(KIImageViewer *)imageViewer {
    return 5;
}

- (UIView *)imageViewer:(KIImageViewer *)imageViewer targetViewAtIndex:(NSInteger)index {
    return [self.view viewWithTag:100+index];
}

@end
