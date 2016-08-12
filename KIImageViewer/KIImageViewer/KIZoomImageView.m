//
//  KIZoomImageView.m
//  KIImageViewer
//
//  Created by SmartWalle on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "KIZoomImageView.h"

@class _ImageView;
@interface _ImageView : UIImageView
@end

@implementation _ImageView
- (void)setImage:(UIImage *)image {
    [super setImage:image];
}
@end

@interface KIZoomImageView () <UIScrollViewDelegate>
@property (nonatomic, strong) _ImageView    *imageView;
@property (nonatomic, assign) CGPoint       pointToCenterAfterResize;
@property (nonatomic, assign) CGFloat       scaleToRestoreAfterResize;

@property (nonatomic, strong) UITapGestureRecognizer *zoomTapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, copy) KIZoomImageViewDidClickBlock zoomImageViewDidClickBlock;
@end

@implementation KIZoomImageView

#pragma mark - Lifecycle
- (void)dealloc {
#if DEBUG
    NSLog(@"Release KIZoomImageView");
#endif
}

- (instancetype)init {
    if (self = [super init]) {
        [self _initFinished];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _initFinished];
}

- (void)_initFinished {
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    [self setBouncesZoom:YES];
    [self setDecelerationRate:UIScrollViewDecelerationRateFast];
    [self setDelegate:self];
    [self setUserInteractionEnabled:YES];
    [self setCanCancelContentTouches:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:self.tapGesture];
    
    self.zoomTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(zoomTapGestureAction:)];
    [self.zoomTapGesture setNumberOfTapsRequired:2];
    [self.tapGesture requireGestureRecognizerToFail:self.zoomTapGesture];
    [self addGestureRecognizer:self.zoomTapGesture];
}

- (void)setFrame:(CGRect)frame {
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self updateImageViewFrame];
}

#pragma mark - Event Response
- (void)tapGestureAction:(UITapGestureRecognizer *)sender {
    if (self.zoomImageViewDidClickBlock != nil) {
        self.zoomImageViewDidClickBlock(self);
    }
}

- (void)zoomTapGestureAction:(UITapGestureRecognizer *)sender {
    CGFloat zoomScale = 0;
    
    if (self.zoomScale > self.minimumZoomScale) {
        zoomScale = self.minimumZoomScale;
    } else {
        zoomScale = self.minimumZoomScale * 2;
    }
    
    [self setZoomScale:zoomScale animated:YES];
}


#pragma mark - Methods
- (void)updateImageViewFrame {
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    if (frameToCenter.size.width <= boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) * 0.5;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height <= boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) * 0.5;
    } else {
        frameToCenter.origin.y = 0;
    }
    
    self.imageView.frame = frameToCenter;
}

- (void)configureForImageSize:(CGSize)imageSize {
    self.contentSize = imageSize;
    [self updateMaxMinZoomScalesForCurrentBounds];
    
    self.zoomScale = self.minimumZoomScale;
}

- (void)updateMaxMinZoomScalesForCurrentBounds {
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.image.size;
    
    CGFloat xScale = boundsSize.width  / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;   // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);
    
    CGFloat maxScale = MAX(imageSize.width / boundsSize.width, imageSize.height / boundsSize.height);//1.0 / [[UIScreen mainScreen] scale];
    
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    if (isinf(xScale) || isinf(yScale)) {
        return ;
    }
    
    if (boundsSize.width > imageSize.width && boundsSize.height > imageSize.height) {
        self.minimumZoomScale = MIN(xScale, yScale);
        self.maximumZoomScale = self.minimumZoomScale*3;
    } else {
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = MAX(maxScale, 3.0);
    }
}

- (void)prepareToResize {
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.pointToCenterAfterResize = [self convertPoint:boundsCenter toView:self.imageView];
    
    self.scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (self.scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON) {
        self.scaleToRestoreAfterResize = 0;
    }
}

- (void)recoverFromResizing {
    [self updateMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, self.scaleToRestoreAfterResize);
    
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:self.pointToCenterAfterResize fromView:self.imageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (void)resetImageViewFrame {
    [self setZoomScale:1.001 animated:NO];
    CGRect frame = self.imageView.frame;
    frame.size = self.image.size;
    frame.origin = CGPointMake(0, 0);
    [self.imageView setFrame:frame];
    
    [self configureForImageSize:self.image.size];
    
    [self updateImageViewFrame];
}

- (void)updateImageViewFrame:(CGRect)frame {
    [self.imageView setFrame:frame];
}

#pragma mark - Getters & Setters
- (CGPoint)maximumContentOffset {
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset {
    return CGPointZero;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[_ImageView alloc] init];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    [self.imageView setImage:image];
    [self resetImageViewFrame];
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setDidClickBlock:(KIZoomImageViewDidClickBlock)block {
    self.zoomImageViewDidClickBlock = block;
}

@end
