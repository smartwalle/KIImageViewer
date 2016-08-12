//
//  UIImage+KIImageViewer.m
//  KIImageViewer
//
//  Created by apple on 16/8/11.
//  Copyright © 2016年 SmartWalle. All rights reserved.
//

#import "UIImage+KIImageViewer.h"

@implementation UIImage (KIImageViewer)

- (CGRect)centerFrameToFrame:(CGRect)frame {
    CGFloat fw = frame.size.width;
    CGFloat fh = frame.size.height;
    
    CGFloat iw = self.size.width;
    CGFloat ih = self.size.height;
    
//    CGFloat dw = ABS(fw - iw);
//    CGFloat dh = ABS(fh - ih);
    
    CGFloat scale = fw/ iw;//dw > dh ? fw / iw : fh / ih;
    
    CGFloat nw = fw;
    CGFloat nh = fh;
    
//    if (dw > dh) {
        nh = ih * scale;
//    } else {
//        nw = iw * scale;
//    }
    
    nh = MIN(fh, nh);
    
    CGRect nf = CGRectMake((frame.size.width - nw) * 0.5, (frame.size.height - nh) * 0.5, nw, nh);
    return nf;
}

@end
