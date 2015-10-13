//
//  VEAspectFit.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEAspectFit.h"

@implementation VEAspectFit

-(CGAffineTransform) getImageTransformForFrameAtTime:(double)time toSize:(CGSize) finalSize
{
    CGSize originalSize = [self getInputFrameProvider:0].originalSize;
    
    CGFloat yScale = originalSize.height / finalSize.height;
    CGFloat xScale = originalSize.width / finalSize.width;
    CGFloat scale = 1 / (xScale > yScale ? xScale : yScale);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat xShift = (finalSize.width - (originalSize.width * scale)) / 2;
    CGFloat yShift = (finalSize.height - (originalSize.height * scale)) / 2;
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(xShift, yShift);
    
    return CGAffineTransformConcat(scaleTransform, translationTransform);
}

@end
