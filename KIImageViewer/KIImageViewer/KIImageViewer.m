//
//  KIImageViewer.m
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "KIImageViewer.h"
#import "UIImage+KIImageViewer.h"

@interface KIImageViewer () <KIImageCollectionViewDelegate>
@property (nonatomic, strong) KIImageCollectionView *collectionView;
@property (nonatomic, assign) NSInteger initialIndex;
@property (nonatomic, assign) CGRect    initialFrame;
@property (nonatomic, assign) BOOL      isLoad;
@end

@implementation KIImageViewer

+ (void)showWithTarget:(UIView *)target {
    KIImageViewer *imageViewer = [[KIImageViewer alloc] init];

    [imageViewer showWithTarget:target];
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

#pragma mark - KIImageCollectionViewDelegate
- (NSInteger)numberOfImages:(KIImageCollectionView *)collectionView {
    return 100;
}

- (void)collectionView:(KIImageCollectionView *)collectionView didClickedItem:(KIImageCollectionViewCell *)cell {
    [self dismiss];
}

- (void)collectionView:(KIImageCollectionView *)collectionView configCell:(KIImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    
    [cell.imageZoomView setImage:image];
    [cell.imageZoomView setImageViewContentMode:UIViewContentModeScaleAspectFill];
    
    if (!self.isLoad && self.initialIndex == indexPath.row) {
        [cell.imageZoomView setImageViewClipsToBounds:NO];
        if (!CGRectIsEmpty(self.initialFrame)) {
            [cell.imageZoomView updateImageViewFrame:self.initialFrame];
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:0
                             animations:^{
                                 [cell.imageZoomView updateImageViewFrame:[image centerFrameToFrame:window.bounds]];
                             } completion:^(BOOL finished) {
                                 [cell.imageZoomView resetImageViewFrame];
                             }];
        }
        self.isLoad = YES;
    }
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

- (void)showWithTarget:(UIView *)view {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect endFrame = keyWindow.bounds;
    CGRect beginFrame = [view.superview convertRect:view.frame toView:keyWindow];
    
    [self setIsLoad:NO];
    [self setInitialIndex:0];
    [self setInitialFrame:beginFrame];
    [self setFrame:endFrame];
    [keyWindow addSubview:self];
    
    [self.collectionView setFrame:endFrame];
    [self.collectionView setImageDelegate:self];
    
    [self hideBackgroundColor];
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self showBackgroundColor];
                     } completion:^(BOOL finished) {
                     }];
}

- (void)dismiss {
    KIImageCollectionViewCell *cell = (KIImageCollectionViewCell *)[self.collectionView.visibleCells firstObject];
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self hideBackgroundColor];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
    if (cell == nil) {
        return ;
    }
    
    if (!CGRectIsEmpty(self.initialFrame)) {
        [cell.imageZoomView setImageViewClipsToBounds:YES];
        [UIView animateWithDuration:0.3f animations:^{
            [cell.imageZoomView setZoomScale:cell.imageZoomView.minimumZoomScale animated:NO];
            [cell.imageZoomView updateImageViewFrame:self.initialFrame];
        }];
    }
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
