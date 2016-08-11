//
//  KIImageCollectionView.m
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "KIImageCollectionView.h"
#import "UIImage+KIImageViewer.h"

@interface KIImageCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@end

@implementation KIImageCollectionView

- (void)dealloc {
#if DEBUG
    NSLog(@"Release KIImageCollectionView");
#endif
}

- (id)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:layout]) {
        [self _initFinished];
    }
    return self;
}

- (void)_initFinished {
    [self registerClass:[KIImageCollectionViewCell class] forCellWithReuseIdentifier:@"KIImageCollectionViewCell"];
    
    [self setPagingEnabled:YES];
    [self setDelegate:self];
    [self setDataSource:self];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.frame.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KIImageCollectionViewCell *cell = (KIImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"KIImageCollectionViewCell" forIndexPath:indexPath];
    KIZoomImageView *zv = cell.imageZoomView;
    
    __weak KIImageCollectionView *weakSelf = self;
    [zv setDidClickBlock:^(KIZoomImageView *view) {
        if (!CGRectIsEmpty(weakSelf.initialFrame)) {
            [view setImageViewClipsToBounds:YES];
            [UIView animateWithDuration:0.3 animations:^{
                [view setZoomScale:view.minimumZoomScale animated:NO];
                [view updateImageViewFrame:weakSelf.initialFrame];
            }];
            [weakSelf.superview performSelector:@selector(dismiss)];
        }
    }];
    
    UIImage *image = [UIImage imageNamed:@"1.jpg"];
    
    [zv setImage:image];
    
    if (!self.isLoad && self.initialIndex == indexPath.row) {
        [zv setImageViewClipsToBounds:NO];
        [zv setImageViewContentMode:UIViewContentModeScaleAspectFill];
        
        if (!CGRectIsEmpty(self.initialFrame)) {
            [zv updateImageViewFrame:self.initialFrame];
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:0
                             animations:^{
                                 [zv updateImageViewFrame:[image centerFrameToFrame:window.bounds]];
                             } completion:^(BOOL finished) {
                                 [zv resetImageViewFrame];
                                 self.isLoad = YES;
                             }];
        } else {
            self.isLoad = YES;
        }
    }
    return cell;
}

@end

@implementation KIImageCollectionViewCell

- (void)dealloc {
#if DEBUG
    NSLog(@"Release KIImageCollectionViewCell");
#endif
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.imageZoomView setFrame:self.bounds];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self addSubview:self.imageZoomView];
}

- (KIZoomImageView *)imageZoomView {
    if (_imageZoomView == nil) {
        _imageZoomView = [[KIZoomImageView alloc] init];
    }
    return _imageZoomView;
}

@end