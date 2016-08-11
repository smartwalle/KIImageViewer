//
//  KIZoomImageView.h
//  KIImageViewer
//
//  Created by SmartWalle on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KIZoomImageView;
typedef void(^KIZoomImageViewDidClickBlock) (KIZoomImageView *view);

@interface KIZoomImageView : UIScrollView

@property (nonatomic, strong) UIImage           *image;
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;
@property (nonatomic, assign) BOOL              imageViewClipsToBounds;

- (void)resetImageViewFrame;

// 调用此方法之后，会改变 UIImageView 的 Frame，如果想要正常进行缩放操作，需要调用一次 resetImageViewFrame 方法。
- (void)updateImageViewFrame:(CGRect)frame;

- (UITapGestureRecognizer *)zoomTapGesture;
- (UITapGestureRecognizer *)tapGesture;

- (void)setDidClickBlock:(KIZoomImageViewDidClickBlock)block;

@end
