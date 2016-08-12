//
//  KIImageCollectionView.h
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIZoomImageView.h"

@class KIImageCollectionView, KIImageCollectionViewCell;

@protocol KIImageCollectionViewDelegate <NSObject>
@optional
- (NSInteger)numberOfImages:(KIImageCollectionView *)collectionView;
- (void)collectionView:(KIImageCollectionView *)collectionView didClickedItem:(KIImageCollectionViewCell *)cell;
- (void)collectionView:(KIImageCollectionView *)collectionView configCell:(KIImageCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@interface KIImageCollectionView : UICollectionView
@property (nonatomic, weak) id<KIImageCollectionViewDelegate> imageDelegate;
@end

@interface KIImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) KIZoomImageView *imageZoomView;
@end
