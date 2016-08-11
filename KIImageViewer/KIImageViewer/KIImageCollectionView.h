//
//  KIImageCollectionView.h
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIZoomImageView.h"

@interface KIImageCollectionView : UICollectionView
@property (nonatomic, assign) NSInteger initialIndex;
@property (nonatomic, assign) CGRect    initialFrame;
@property (nonatomic, assign) BOOL      isLoad;
@end

@interface KIImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) KIZoomImageView *imageZoomView;
@end
