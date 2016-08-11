//
//  KIImageViewer.m
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "KIImageViewer.h"
#import "UIImage+KIImageViewer.h"

@interface KIImageViewer ()
@property (nonatomic, strong) KIImageCollectionView *collectionView;
@end

@implementation KIImageViewer

+ (void)showWithTarget:(UIImageView *)target {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect endFrame = keyWindow.bounds;
    CGRect beginFrame = [target.superview convertRect:target.frame toView:keyWindow];
    
    KIImageViewer *imageViewer = [[KIImageViewer alloc] init];

    [imageViewer setFrame:endFrame];
    [keyWindow addSubview:imageViewer];
    
    [imageViewer.collectionView setAlpha:1.0f];
    [imageViewer.collectionView setFrame:endFrame];
    [imageViewer.collectionView setInitialFrame:beginFrame];

    [imageViewer hideBackgroundColor];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [imageViewer showBackgroundColor];
                     } completion:^(BOOL finished) {
                     }];
}

#pragma mark - Lifecycle
- (void)dealloc {
#if DEBUG
    NSLog(@"Release KIImageViewer");
#endif
}

- (id)init {
    if (self = [super init]) {
        [self _initFinished];
    }
    return self;
}

- (void)_initFinished {
    [self addSubview:self.collectionView];
}

#pragma mark - Methods
- (void)updateBackgroundColorWithAlpha:(CGFloat)alpha {
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:alpha]];
}

- (void)showBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.8f];
}

- (void)hideBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.0f];
}

- (void)dismiss {
    [self showBackgroundColor];
    [self.collectionView setAlpha:1.0];
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self hideBackgroundColor];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Getters & Setters
- (UIWindow *)keyWindow {
    return [UIApplication sharedApplication].keyWindow;
}

- (KIImageCollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[KIImageCollectionView alloc] init];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return _collectionView;
}

@end
