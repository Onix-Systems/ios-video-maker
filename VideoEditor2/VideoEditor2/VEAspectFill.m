//
//  VEAspectFill.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEAspectFill.h"

@implementation VEAspectFill

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    CIImage* originalFrame = [self.frameProvider getFrameForRequest:request];
    
    CGSize originalSize = [self.frameProvider getOriginalSize];
    
    CGFloat yScale = originalSize.height / self.finalSize.height;
    CGFloat xScale = originalSize.width / self.finalSize.width;
    CGFloat scale = 1 / (xScale < yScale ? xScale : yScale);
    
    CGFloat xShift = (self.finalSize.width - (originalSize.width * scale)) / 2;
    CGFloat yShift = (self.finalSize.height - (originalSize.height * scale)) / 2;
    
    CIImage* result = [originalFrame vScaleX:scale scaleY:scale];
    result = [result vShiftX:xShift shiftY:yShift];
    result = [result vCrop:CGRectMake(0,0, self.finalSize.width, self.finalSize.height)];
    
    return result;
}

@end
