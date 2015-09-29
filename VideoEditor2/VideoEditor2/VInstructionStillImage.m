//
//  VInstructionStillImage.m
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VInstructionStillImage.h"
#import <CoreImage/CoreImage.h>

@interface VInstructionStillImage()


@end

@implementation VInstructionStillImage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.containsTweening = NO;
    }
    return self;
}

-(void) processRequest: (AVAsynchronousVideoCompositionRequest*) request usingCIContext: (CIContext*) ciContext
{
    CVPixelBufferRef buffer = request.renderContext.newPixelBuffer;
    CGSize bufferSize = CGSizeMake(CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer));
    
    CGAffineTransform imageTransform = [VCompositionInstruction getAspectFitTransformFromSize: self.image.extent.size toSize:bufferSize];
    
    CIFilter* filter = [CIFilter filterWithName:@"CIAffineTransform"];
    [filter setDefaults];
    [filter setValue:self.image forKey:kCIInputImageKey];
    [filter setValue:[NSValue valueWithBytes:&imageTransform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    CIImage *resultImage = [filter valueForKey:kCIOutputImageKey];
    
    [ciContext render:resultImage toCVPixelBuffer:buffer];
    [request finishWithComposedVideoFrame:buffer];
    
    CFRelease(buffer);
}


@end
