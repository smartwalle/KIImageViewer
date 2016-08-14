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

@interface KIImageViewer () <KIImageCollectionViewDelegate>
@property (nonatomic, strong) KIImageCollectionView *collectionView;

@property (nonatomic, assign) BOOL      isLoad;
@property (nonatomic, assign) BOOL      statusBarHidden;
@end

@implementation KIImageViewer

+ (void)showWithDelegate:(id<KIImageViewerDelegate>)delegate initialIndex:(NSInteger)index {
    if (delegate == nil) {
        return ;
    }
    
    KIImageViewer *imageViewer = [[KIImageViewer alloc] init];
    NSInteger total = 0;
    if ([delegate respondsToSelector:@selector(numberOfImages:)]) {
        total = [delegate numberOfImages:imageViewer];
    }
    
    if (index < 0 || index >= total) {
        index = 0;
    }
    
    [imageViewer setDelegate:delegate];
    [imageViewer setInitialIndex:index];
    [imageViewer show];
}

#pragma mark - Lifecycle
- (void)dealloc {
#if DEBUG
    NSLog(@"Release KIImageViewer");
#endif
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self setFrame:CGRectMake(0, 0, size.width, size.height)];
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
        
        CGRect bounds = [self mainViewBounds];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:0
                         animations:^{
                             if (!CGRectIsEmpty(frame)) {
                                 [cell.imageZoomView updateImageViewFrame:[placeholderImage centerFrameToFrame:bounds]];
                             } else {
                                 [cell setAlpha:1.0];
                             }
                             [self processLongImage:placeholderImage cell:cell];
                         } completion:^(BOOL finished) {
                             [self loadImageWithURL:imageURL placeholderImage:placeholderImage cell:cell isInitial:YES];
                         }];
        self.isLoad = YES;
    } else {
        [self loadImageWithURL:imageURL placeholderImage:placeholderImage cell:cell isInitial:NO];
    }
    
    if (!self.collectionView.isUpdatingFrame && self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:didDisplayImageAtIndex:)]) {
        [self.delegate imageViewer:self didDisplayImageAtIndex:indexPath.row];
    }
}

- (void)collectionView:(KIImageCollectionView *)collectionView didEndDisplayingCell:(KIImageCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.collectionView.isUpdatingFrame && self.delegate != nil && [self.delegate respondsToSelector:@selector(imageViewer:didEndDisplayingImageAtIndex:)]) {
        [self.delegate imageViewer:self didEndDisplayingImageAtIndex:indexPath.row];
    }
}

#pragma mark - Methods
- (void)setFrame:(CGRect)frame {
    [self.collectionView setFrame:frame];
}

- (void)updateBackgroundColorWithAlpha:(CGFloat)alpha {
    [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:alpha]];
}

- (void)showBackgroundColor {
    [self updateBackgroundColorWithAlpha:0.9f];
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
    UIView *mainView = [self mainView];
    UIView *targetView = [self targetViewAtIndex:index];
    if (targetView == nil) {
        return CGRectZero;
    }
    CGRect frame = [targetView.superview convertRect:targetView.frame toView:mainView];
    return frame;
}

- (void)show {
    UIViewController *rootController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [self showWithController:rootController];
}

- (void)showWithController:(UIViewController *)controller {
    self.statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIView *mainView = [self mainView];
    [self setIsLoad:NO];
    [self setFrame:mainView.bounds];
    [mainView addSubview:self.view];
    
    [self willMoveToParentViewController:controller];
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
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
    NSIndexPath *indexPath = nil;
    CGRect frame = CGRectZero;
    
    if (cell != nil) {
        [cell.imageZoomView.imageView sd_cancelCurrentImageLoad];
        [cell.imageZoomView.imageView sd_cancelCurrentAnimationImagesLoad];
        
        indexPath = [self.collectionView indexPathForCell:cell];
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
                         if (indexPath != nil) {
                             [self collectionView:self.collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
                         }
                         
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
}

- (void)loadImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage cell:(KIImageCollectionViewCell *)cell isInitial:(BOOL)isInitial {
    CGRect bounds = [self mainViewBounds];
    
    if (!isInitial) {
        [cell.imageZoomView setImage:placeholderImage];
        [cell.imageZoomView updateImageViewFrame:[placeholderImage centerFrameToFrame:bounds]];
    }
    
    [self processLongImage:placeholderImage cell:cell];
    
    __weak KIImageViewer *weakSelf = self;
    [cell.imageZoomView.imageView sd_setImageWithURL:url
                                    placeholderImage:placeholderImage
                                             options:0
                                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                if (image != nil) {
                                                    [cell.imageZoomView resetImageViewFrame];
                                                    [cell.imageZoomView updateImageViewFrame:[image centerFrameToFrame:bounds]];
                                                    
                                                    [weakSelf processLongImage:image cell:cell];
                                                }
                                            }];
}

- (void)processLongImage:(UIImage *)image cell:(KIImageCollectionViewCell *)cell {
    CGSize imageSize = image.size;
    if (imageSize.width * 2 < imageSize.height) {
        [cell.imageZoomView setZoomScale:(self.mainViewBounds.size.width/imageSize.width)+0.0009 animated:NO];
        [cell.imageZoomView setContentOffset:CGPointMake(0, 0)];
    }
}

#pragma mark - Getters & Setters
- (UIView *)mainView {
    return [UIApplication sharedApplication].keyWindow;
}

- (CGRect)mainViewBounds {
    return [self mainView].bounds;
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
