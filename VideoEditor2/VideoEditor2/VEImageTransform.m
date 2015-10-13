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

-(CGAffineTransform) getImageTransformForFrameAtTime:(double)time toSize:(CGSize) finalSize
{
    return CGAffineTransformIdentity;
}

-(CIImage*) getImageForFrameSize: (CGSize) frameSize atTime: (double) time
{
    CIImage* originalFrame = [[self getInputFrameProvider:0] getImageForFrameSize:frameSize atTime:time];
    CGAffineTransform imageTransform = [self getImageTransformForFrameAtTime:time toSize:frameSize];
    
    CIFilter* filter = [CIFilter filterWithName:@"CIAffineTransform"];
    [filter setDefaults];
    [filter setValue:originalFrame forKey:kCIInputImageKey];
    [filter setValue:[NSValue valueWithBytes:&imageTransform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    return [filter valueForKey:kCIOutputImageKey];
}

@end
