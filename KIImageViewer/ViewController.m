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

@property (weak, nonatomic) IBOutlet KIZoomImageView *izv;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.izv setImage:[UIImage imageNamed:@"1.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showImageAction:(UIButton *)sender {
    NSInteger tag = sender.tag - 200;
    
    [KIImageViewer showWithDataSource:self initialIndex:tag];
}


- (NSURL *)imageViewer:(KIImageViewer *)imageViewer imageURLAtIndex:(NSInteger)index {
    if (index == 0) {
        return [NSURL URLWithString:@"http://7xk4hl.com2.z0.glb.qiniucdn.com/images/status/57a7fb949535670b223a2391/1470981252.jpg?imageMogr2/auto-orient/thumbnail/!50p"];
    }
    return [NSURL URLWithString:@"http://7xjcby.com1.z0.glb.clouddn.com/file/146492239680777v8el9pkht.png?imageMogr2/auto-orient/thumbnail/!50p"];
}

- (UIImage *)imageViewer:(KIImageViewer *)imageViewer placeholderImageAtIndex:(NSInteger)index {
    if (index == 0) {
        return [UIImage imageNamed:@"c.jpg"];
    }
    return [UIImage imageNamed:@"d.jpg"];
}

- (NSInteger)numberOfImages:(KIImageViewer *)imageViewer {
    return 4;
}

- (UIView *)imageViewer:(KIImageViewer *)imageViewer targetViewAtIndex:(NSInteger)index {
    return [self.view viewWithTag:100+index];
}

@end
