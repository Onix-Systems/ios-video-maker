//
//  VEAspectFit.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEAspectFit.h"

@interface VEAspectFit ()

@property (nonatomic,strong) CIImage* cachedResult;

@end

@implementation VEAspectFit

-(void) setFrameProvider:(VFrameProvider *)frameProvider
{
    [super setFrameProvider:frameProvider];
    self.isStatic = frameProvider.isStatic;
    self.cachedResult = nil;
}

-(void) setFinalSize:(CGSize)finalSize
{
    if ((self.finalSize.width != finalSize.width) && (self.finalSize.height != finalSize.height)) {
        [super setFinalSize:finalSize];
        
        self.cachedResult = nil;
        if (self.isStatic) {
            [self getFrameForRequest:nil];
        }
    }
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    if (self.cachedResult != nil) {
        return self.cachedResult;
    }
    
    CGSize originalSize = [self.frameProvider getOriginalSize];
    CIImage* originalFrame = [self.frameProvider getFrameForRequest:request];
    
    CIImage* result = originalFrame;
    CGFloat scale = 1;
    
    if ((originalSize.width == self.finalSize.width) && (originalSize.height <= self.finalSize.height)) {
        //don't scale
    } else if ((originalSize.width <= self.finalSize.width) && (originalSize.height == self.finalSize.height)) {
        //don't scale
    } else {
        CGFloat yScale = originalSize.height / self.finalSize.height;
        CGFloat xScale = originalSize.width / self.finalSize.width;
        scale = 1 / (xScale > yScale ? xScale : yScale);
        
        result = [result vScale:scale];
    }
    
    CGFloat xShift = (self.finalSize.width - (originalSize.width * scale)) / 2;
    CGFloat yShift = (self.finalSize.height - (originalSize.height * scale)) / 2;
    
    result = [result vShiftX:xShift shiftY:yShift];
    CGRect resultFrame = CGRectMake(0,0, self.finalSize.width, self.finalSize.height);
    result = [result vCrop:resultFrame];
    
    if (self.frameProvider.isStatic) {
        result = [result vComposeOverBackground:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]]];
        self.cachedResult = [result renderRectForChaching:resultFrame];
        return self.cachedResult;
    }
    
    return result;
}

@end
