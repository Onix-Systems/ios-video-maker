//
//  VEStillImage.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEStillImage.h"

@interface VEStillImage()

@property (nonatomic) CVPixelBufferRef pixelBuffer;

@end

@implementation VEStillImage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.image = nil;
        _pixelBuffer = nil;
    }
    return self;
}

-(CIImage*) getImageForFrameSize: (CGSize) frameSize atTime: (double) time
{
    return self.image;
}

-(void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (self.pixelBuffer != nil) {
        [self releasePixelBuffer];
    }
    
    //_pixelBuffer = CVPixelBufferRetain(pixelBuffer);
    self.image = [CIImage imageWithCVPixelBuffer: pixelBuffer];
    NSLog(@"Image from pixelBuffer is equal to %@", self.image);
    
    self.originalSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
}

-(void) releasePixelBuffer
{
    if (self.pixelBuffer != nil) {
        //CVPixelBufferRelease(self.pixelBuffer);
        _pixelBuffer = nil;
    }
}

@end
