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

@interface ViewController ()
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

- (IBAction)showImageAction:(id)sender {
    
//    [self.iv setFrame:[self.iv.image centerFrameToFrame:[UIApplication sharedApplication].keyWindow.bounds]];
    
    [KIImageViewer showWithTarget:self.iv];
//    [KIFullImageView showWithTarget:self.iv smallImage:[UIImage imageNamed:@"iOS.png"] fullImage:[UIImage imageNamed:@"iOS.png"]];
}



@end
