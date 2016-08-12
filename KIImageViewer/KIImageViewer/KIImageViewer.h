//
//  KIImageViewer.h
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIImageCollectionView.h"

@class KIImageViewer;

typedef void(^AAA)(UIImage *image);

@protocol KIImageViewerDelegate <NSObject>
@required
- (NSInteger)numberOfImages:(KIImageViewer *)imageViewer;

- (NSURL *)imageViewer:(KIImageViewer *)imageViewer imageURLAtIndex:(NSInteger)index;

- (UIImage *)imageViewer:(KIImageViewer *)imageViewer placeholderImageAtIndex:(NSInteger)index;

- (UIView *)imageViewer:(KIImageViewer *)imageViewer targetViewAtIndex:(NSInteger)index;

@end

@interface KIImageViewer : UIView

+ (void)showWithDataSource:(id<KIImageViewerDelegate>)dataSource initialIndex:(NSInteger)index;

@end
