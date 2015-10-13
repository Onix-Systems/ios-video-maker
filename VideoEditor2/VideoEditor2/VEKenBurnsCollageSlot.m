//
//  VEKenBurnsCollageSlot.m
//  VideoEditor2
//
//  Created by Alexander on 10/9/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEKenBurnsCollageSlot.h"

@interface VEKenBurnsCollageSlot ()


@end

@implementation VEKenBurnsCollageSlot

-(double)randomNumber
{
    return ((double)arc4random_uniform(10)) / 10;
}

-(void) setupForFinalSize: (CGRect)frame andOriginalSize: (CGSize) originalSize;
{
    self.frame = frame;
    
    double yScale = frame.size.height / originalSize.height;
    double xScale = frame.size.width / originalSize.width;

    double minScale = MAX(xScale, yScale);
    double maxScale = 1.1 * minScale;

    if (yScale < 1 && xScale < 1) {
        minScale = MAX(xScale, yScale);
        maxScale = 1;
    }
    
    self.startScale = minScale + ((maxScale - minScale) * [self randomNumber]);
    self.endScale = minScale + ((maxScale - minScale) * [self randomNumber]);
    
    double startMaxX = originalSize.width * self.startScale - frame.size.width;
    double startMaxY = originalSize.height * self.startScale - frame.size.height;
    
    self.startX = -1  * (startMaxX * [self randomNumber]);
    self.startY = -1 * (startMaxY * [self randomNumber]);
    
    double endMaxX = originalSize.width * self.endScale - frame.size.width;
    double endMaxY = originalSize.height * self.endScale - frame.size.height;
    
    self.endX = -1 * (endMaxX * [self randomNumber]);
    self.endY = -1 * (endMaxY * [self randomNumber]);
    
    [self setupMovementForTime:0];
}

-(void) setupMovementForTime: (double) time
{
    double k = 0;
    if (time >= self.startTime) {
        k = (time - self.startTime) / (self.endTime - self.startTime);
    }
    
    self.scale = self.startScale + (self.endScale - self.startScale) * k;
    
    self.xShift = self.startX + (self.endX - self.startX) * k;
    self.yShift = self.startY + (self.endY - self.startY) * k;
}

-(CIImage*) getTranstaledImageFromFrameProvider:(VEffect*)frameProvider atTime:(double)time
{
    [self setupMovementForTime:time];
    
    CIImage *resultImage = [super getTranstaledImageFromFrameProvider:frameProvider atTime:time];
    
    return resultImage;
}

@end
