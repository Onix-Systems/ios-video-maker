//
//  VEAspectFit.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEAspectFit.h"

@implementation VEAspectFit

-(CGAffineTransform) getImageTransformForTime:(double)time
{
    CGSize originalSize = [self getInputFrameProvider:0].finalSize;
    
    CGFloat yScale = originalSize.height / self.finalSize.height;
    CGFloat xScale = originalSize.width / self.finalSize.width;
    CGFloat scale = 1 / (xScale > yScale ? xScale : yScale);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat xShift = (self.finalSize.width - (originalSize.width * scale)) / 2;
    CGFloat yShift = (self.finalSize.height - (originalSize.height * scale)) / 2;
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(xShift, yShift);
    
    return CGAffineTransformConcat(scaleTransform, translationTransform);
}

@end
