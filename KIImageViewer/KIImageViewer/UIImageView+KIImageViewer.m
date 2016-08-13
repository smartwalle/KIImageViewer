//
//  UIImageView+KIImageViewer.m
//  KIImageViewer
//
//  Created by SmartWalle on 16/8/13.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "UIImageView+KIImageViewer.h"

@interface KI__ImageViewTapGestureRecognizer : UITapGestureRecognizer <KIImageViewerDelegate>
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSURL   *url;

@property (nonatomic, weak)   id<KIImageViewerDelegate> dataSource;
@property (nonatomic, assign) NSInteger                 initialIndex;
@end

@implementation KI__ImageViewTapGestureRecognizer

#pragma mark - Lifecycle
- (void)dealloc {
}

#pragma makr - KIImageViewerDelegate
- (NSInteger)numberOfImages:(KIImageViewer *)imageViewer {
    return 1;
}

- (NSURL *)imageViewer:(KIImageViewer *)imageViewer imageURLAtIndex:(NSInteger)index {
    return self.url;
}

- (UIImage *)imageViewer:(KIImageViewer *)imageViewer placeholderImageAtIndex:(NSInteger)index {
    return self.placeholderImage;
}

- (UIView *)imageViewer:(KIImageViewer *)imageViewer targetViewAtIndex:(NSInteger)index {
    return self.view;
}

- (void)imageViewer:(KIImageViewer *)imageView didDisplayImageAtIndex:(NSInteger)index {
    [self.view setAlpha:0.0];
}

- (void)imageViewer:(KIImageViewer *)imageViewer didEndDisplayingImageAtIndex:(NSInteger)index {
    [self.view setAlpha:1.0];
}
@end

@implementation UIImageView (KIImageViewer)

- (void)setupImageViewerWithURL:(NSURL *)url placeholderImage:(UIImage *)image {
    [self setUserInteractionEnabled:YES];
    KI__ImageViewTapGestureRecognizer *tapGesture = [[KI__ImageViewTapGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(ki__tapGestureAction:)];
    tapGesture.url = url;
    tapGesture.placeholderImage = image;
    [self addGestureRecognizer:tapGesture];
}

- (void)setupImageViewerWithDataSource:(id<KIImageViewerDelegate>)dataSource initialIndex:(NSInteger)index {
    [self setUserInteractionEnabled:YES];
    
    KI__ImageViewTapGestureRecognizer *tapGesture = [[KI__ImageViewTapGestureRecognizer alloc] initWithTarget:self
                                                                                                       action:@selector(ki__tapGestureAction:)];
    tapGesture.dataSource = dataSource;
    tapGesture.initialIndex = index;
    [self addGestureRecognizer:tapGesture];
}

- (void)ki__tapGestureAction:(KI__ImageViewTapGestureRecognizer *)sender {
    if (sender.dataSource != nil) {
        [KIImageViewer showWithDataSource:sender.dataSource initialIndex:sender.initialIndex];
    } else {
        [KIImageViewer showWithDataSource:sender initialIndex:0];
    }
}

- (void)removeImageViewer {
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[KI__ImageViewTapGestureRecognizer class]]) {
            [self removeGestureRecognizer:gesture];
        }
    }
}

@end
