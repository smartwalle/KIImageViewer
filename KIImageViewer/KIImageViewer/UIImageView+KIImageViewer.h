//
//  UIImageView+KIImageViewer.h
//  KIImageViewer
//
//  Created by SmartWalle on 16/8/13.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImageViewer.h"

@interface UIImageView (KIImageViewer)

- (void)setupImageViewerWithURL:(NSURL *)url placeholderImage:(UIImage *)image;

- (void)setupImageViewerWithDelegate:(id<KIImageViewerDelegate>)delegate initialIndex:(NSInteger)index;

- (void)removeImageViewer;

@end
