//
//  VEKenBurns.m
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEKenBurns.h"

@implementation VEKenBurns

-(NSInteger) getNumberOfInputFrames
{
    return 1;
}

-(double)randomNumber
{
    return ((double)arc4random_uniform(10)) / 10;
}

-(void) setupMovement
{
    CGSize destinationSize = self.finalSize;
    CGSize originalSize = [self.frameProvider getOriginalSize];
    
    double xScale = destinationSize.width / originalSize.width;
    double yScale = destinationSize.height / originalSize.height;
    
    double aspectFillScale = MAX(xScale, yScale);
    
    double aspectFillX = -1 * ((originalSize.width * aspectFillScale) - destinationSize.width) / 2;
    double aspectFillY = -1 * ((originalSize.height * aspectFillScale) - destinationSize.height) / 2;

    if ([self randomNumber] >= 0.5) {
        //zoom in
        self.startScale = aspectFillScale;
        self.startX = aspectFillX;
        self.startY = aspectFillY;
        
        self.endScale = aspectFillScale * 1.05;
        self.endX = aspectFillX - ((destinationSize.width*1.05 - destinationSize.width) * [self randomNumber]);
        self.endY = aspectFillY - ((destinationSize.height*1.05 - destinationSize.height) * [self randomNumber]);
        
    } else {
        //zoom out
        self.startScale = aspectFillScale * 1.05;
        self.startX = aspectFillX - ((destinationSize.width*1.05 - destinationSize.width) * [self randomNumber]);
        self.startY = aspectFillY - ((destinationSize.height*1.05 - destinationSize.height) * [self randomNumber]);
        
        self.endScale = aspectFillScale;
        self.endX = aspectFillX;
        self.endY = aspectFillY;
    }
    
    [self setupMovementForMovementPercent:0];
}

-(void) setupMovementForMovementPercent: (double) percent
{
    double k = percent;
    if (k > 1) {
        k = 1;
    }
    if (k < 0) {
        k = 0;
    }
    
    self.currentScale = self.startScale + (self.endScale - self.startScale) * k;
    
    self.currentX = self.startX + (self.endX - self.startX) * k;
    self.currentY = self.startY + (self.endY - self.startY) * k;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    double totalDuration = [self.frameProvider getDuration];
    double movementPercent = request.time / totalDuration;
    [self setupMovementForMovementPercent:movementPercent];
    
    CIImage* image = [self.frameProvider getFrameForRequest:request];
    
    image = [image vScale:self.currentScale];
    image = [image vShiftX:self.currentX shiftY:self.currentY];
    image = [image vCrop:CGRectMake(0, 0, self.finalSize.width, self.finalSize.height)];
    
    return image;
}

-(void)reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    [super reqisterIntoVideoComposition:videoComposition withInstruction:instruction withFinalSize:finalSize];
    
    [self setupMovement];
    
//    for (int i = 0; i < 5; i++) {
//        
//        if ((ABS(self.startX - self.endX) > 25) || (ABS(self.startY - self.endY) > 25) || (ABS(self.startScale - self.endScale) > 0.05)) {
//            return;
//        } else {
//            NSLog(@"VEKenBurns movement is too small startX=%f startY=%f endX=%f endY=%f startScale=%f endScale=%f",self.startX, self.startY, self.endX, self.endY, self.startScale, self.endScale);
//        }
//    }
    
}

@end
