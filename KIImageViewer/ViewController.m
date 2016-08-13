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
#import "UIImageView+KIImageViewer.h"

@interface ViewController () <KIImageViewerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iv;
@property (weak, nonatomic) IBOutlet UIImageView *iv2;
@property (weak, nonatomic) IBOutlet UIImageView *iv3;
@property (weak, nonatomic) IBOutlet UIImageView *iv4;
@property (weak, nonatomic) IBOutlet UIImageView *iv5;
@property (weak, nonatomic) IBOutlet UIImageView *iv6;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.iv setupImageViewerWithDelegate:self initialIndex:0];
    [self.iv2 setupImageViewerWithDelegate:self initialIndex:1];
    [self.iv3 setupImageViewerWithDelegate:self initialIndex:2];
    [self.iv4 setupImageViewerWithDelegate:self initialIndex:3];
    [self.iv5 setupImageViewerWithDelegate:self initialIndex:4];
    [self.iv6 setupImageViewerWithDelegate:self initialIndex:5];
}


- (NSURL *)imageViewer:(KIImageViewer *)imageViewer imageURLAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%d.jpg", index+1]];
}

- (UIImage *)imageViewer:(KIImageViewer *)imageViewer placeholderImageAtIndex:(NSInteger)index {
    return [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", index+1]];
}

- (NSInteger)numberOfImages:(KIImageViewer *)imageViewer {
    return 6;
}

- (UIView *)imageViewer:(KIImageViewer *)imageViewer targetViewAtIndex:(NSInteger)index {
    return [self.view viewWithTag:100+index];
}

- (void)imageViewer:(KIImageViewer *)imageView didDisplayImageAtIndex:(NSInteger)index {
     [[self.view viewWithTag:100+index] setAlpha:0.0];
}

- (void)imageViewer:(KIImageViewer *)imageViewer didEndDisplayingImageAtIndex:(NSInteger)index {
     [[self.view viewWithTag:100+index] setAlpha:1.0];
}

@end
