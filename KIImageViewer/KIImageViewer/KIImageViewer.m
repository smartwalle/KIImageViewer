//
//  KIImageViewer.m
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "KIImageViewer.h"
#import "UIImage+KIImageViewer.h"
#import "UIImageView+WebCache.h"

#define kEffectViewTag 9090950

@interface KIImageViewer () <KIImageCollectionViewDelegate>
@property (nonatomic, weak) id<KIImageViewerDelegate> delegate;
@property (nonatomic, strong) KIImageCollectionView *collectionView;

@property (nonatomic, assign) NSInteger initialIndex;
@property (nonatomic, assign) BOOL      isLoad;
@property (nonatomic, assign) BOOL      statusBarHidden;
@end

@implementation KIImageViewer

+ (void)showWithDataSource:(id<KIImageViewerDelegate>)dataSource initialIndex:(NSInteger)index {
    if (dataSource == nil) {
        return ;
    }
    
    KIImageViewer *imageViewer = [[KIImageViewer alloc] init];
    NSInteger total = 0;
    if ([dataSource respondsToSelector:@selector(numberOfImages:)]) {
        total = [dataSource numberOfImages:imageViewer];
    }
    
    if (index < 0 || index >= total) {
        index = 0;
    }
    
    [imageViewer setDelegate:dataSource];
    [imageViewer setInitialIndex:index];
    [imageViewer show];
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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.collectionView setFrame:self.bounds];
    [[self viewWithTag:kEffectViewTag] setFrame:self.bounds];
}

#pragma mark - KIImageCollectionViewDelegate
- (NSInteger)numberOfImages:(KIImageCollectionView *)collectionView {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(numberOfImages:)]) {
        return [self.delegate numberOfImages:self];
    }
    return 0;
}

- (void)collectionView:(KIImageCollectionView *)collectionView didClickedItem:(KIImageCollectionViewCell *)cell {
    [self dismiss];
}

- (void)collectionView:(KIImageCollectionView *)collectionView configCell:(KIImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    UIImage *placeholderImage = nil;
    NSURL *imageURL = nil;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:placeholderImageAtIndex:)]) {
        placeholderImage = [self.delegate imageViewer:self placeholderImageAtIndex:indexPath.row];
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:imageURLAtIndex:)]) {
        imageURL = [self.delegate imageViewer:self imageURLAtIndex:indexPath.row];
    }
    [cell.imageZoomView.imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    if (!self.isLoad && self.initialIndex == indexPath.row) {
        [cell.imageZoomView setImage:placeholderImage];
        [cell.imageZoomView.imageView setClipsToBounds:NO];
        
        CGRect frame = [self viewFrameAtIndex:indexPath.row];
        
        if (!CGRectIsEmpty(frame)) {
            [cell.imageZoomView updateImageViewFrame:frame];
        } else {
            [cell setAlpha:0.0f];
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             if (!CGRectIsEmpty(frame)) {
                                 [cell.imageZoomView updateImageViewFrame:[placeholderImage centerFrameToFrame:window.bounds]];
                             } else {
                                 [cell setAlpha:1.0];
                             }
                         } completion:^(BOOL finished) {
                             [cell.imageZoomView resetImageViewFrame];
                             [self loadImageWithURL:imageURL placeholderImage:placeholderImage cell:cell];
                         }];
        self.isLoad = YES;
    } else {
        [self loadImageWithURL:imageURL placeholderImage:placeholderImage cell:cell];
    }
}

#pragma mark - Methods
- (void)updateBackgroundColorWithAlpha:(CGFloat)alpha {
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:alpha]];
    [[self viewWithTag:kEffectViewTag] setAlpha:alpha];
}

- (void)showBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.8f];
}

- (void)hideBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.0f];
}

- (UIView *)targetViewAtIndex:(NSInteger)index {
    UIView *v = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:targetViewAtIndex:)]) {
        v = [self.delegate imageViewer:self targetViewAtIndex:index];
    }
    return v;
}

- (CGRect)viewFrameAtIndex:(NSInteger)index {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *targetView = [self targetViewAtIndex:index];
    if (targetView == nil) {
        return CGRectZero;
    }
    CGRect frame = [targetView.superview convertRect:targetView.frame toView:keyWindow];
    return frame;
}

- (void)show {
    self.statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [self setIsLoad:NO];
    [self setFrame:keyWindow.bounds];
    [keyWindow addSubview:self];
    
    CGFloat version = [[UIDevice currentDevice].systemVersion floatValue];
    if (version > 8.0) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [effectView setTag:kEffectViewTag];
        effectView.frame = self.bounds;
        [self addSubview:effectView];
        [self sendSubviewToBack:effectView];
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.initialIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
    
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
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden withAnimation:UIStatusBarAnimationFade];
    
    KIImageCollectionViewCell *cell = (KIImageCollectionViewCell *)[self.collectionView.visibleCells firstObject];
    CGRect frame = CGRectZero;
    
    if (cell != nil) {
        [cell.imageZoomView.imageView sd_cancelCurrentImageLoad];
        [cell.imageZoomView.imageView sd_cancelCurrentAnimationImagesLoad];
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        frame = [self viewFrameAtIndex:indexPath.row];
    }
    
    [UIView animateWithDuration:0.3f
                          delay:0
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self hideBackgroundColor];
                         [cell.imageZoomView setZoomScale:cell.imageZoomView.minimumZoomScale animated:NO];
                         if (!CGRectIsEmpty(frame)) {
                             [cell.imageZoomView.imageView setClipsToBounds:YES];
                             [cell.imageZoomView updateImageViewFrame:frame];
                         } else {
                             [cell setAlpha:0.0];
                         }
                         
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

- (void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cell:(KIImageCollectionViewCell *)cell {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [cell.imageZoomView setImage:placeholderImage];
    [cell.imageZoomView updateImageViewFrame:[placeholderImage centerFrameToFrame:window.bounds]];
    
    [cell.imageZoomView.imageView sd_setImageWithURL:url
                                    placeholderImage:placeholderImage
                                             options:0
                                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                if (image != nil) {
                                                    [cell.imageZoomView resetImageViewFrame];
                                                    [cell.imageZoomView updateImageViewFrame:[image centerFrameToFrame:window.bounds]];
                                                }
                                            }];
}

#pragma mark - Getters & Setters
- (UIWindow *)keyWindow {
    return [UIApplication sharedApplication].keyWindow;
}

- (KIImageCollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[KIImageCollectionView alloc] init];
        [_collectionView setImageDelegate:self];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
    }
    return _collectionView;
}

@end
