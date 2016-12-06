//
//  VEAspectFill.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEAspectFill.h"

@interface VEAspectFill ()

@property (nonatomic,strong) CIImage* cachedResult;

@end

@implementation VEAspectFill

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    if (self.cachedResult != nil) {
        return self.cachedResult;
    }

    CIImage* originalFrame = [self.frameProvider getFrameForRequest:request];
    
    CGSize originalSize = [self.frameProvider getOriginalSize];
    
    CGFloat yScale = originalSize.height / self.finalSize.height;
    CGFloat xScale = originalSize.width / self.finalSize.width;
    CGFloat scale = 1 / (xScale < yScale ? xScale : yScale);
    
    CGFloat xShift = (self.finalSize.width - (originalSize.width * scale)) / 2;
    CGFloat yShift = (self.finalSize.height - (originalSize.height * scale)) / 2;
    
    CIImage* result = [originalFrame vScaleX:scale scaleY:scale];
    result = [result vShiftX:xShift shiftY:yShift];

    CGRect resultFrame = CGRectMake(0,0, self.finalSize.width, self.finalSize.height);
    result = [result vCrop:resultFrame];
    
    if (self.frameProvider.isStatic) {
        self.cachedResult = [result renderRectForChaching:resultFrame];
        return self.cachedResult;
    }
    
    return result;

}

@end
