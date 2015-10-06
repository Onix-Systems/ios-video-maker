//
//  VEImageTransform.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEImageTransform.h"

@implementation VEImageTransform

-(NSInteger) getNumberOfInputFrames
{
    return 1;
}

-(CGAffineTransform) getImageTransformForTime:(double)time
{
    return CGAffineTransformIdentity;
}

-(CIImage*) getFrameForTime:(double)time
{
    CIImage* originalFrame = [[self getInputFrameProvider:0] getFrameForTime:time];
    CGAffineTransform imageTransform = [self getImageTransformForTime: time];
    
    CIFilter* filter = [CIFilter filterWithName:@"CIAffineTransform"];
    [filter setDefaults];
    [filter setValue:originalFrame forKey:kCIInputImageKey];
    [filter setValue:[NSValue valueWithBytes:&imageTransform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    return [filter valueForKey:kCIOutputImageKey];
}

@end
