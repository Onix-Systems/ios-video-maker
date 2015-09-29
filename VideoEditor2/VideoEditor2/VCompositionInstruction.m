//
//  VCompositionInstruction.m
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCompositionInstruction.h"

@implementation VCompositionInstruction

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enablePostProcessing = YES;
        self.containsTweening = NO;
        self.requiredSourceTrackIDs = nil;
        self.passthroughTrackID = kCMPersistentTrackID_Invalid;
    }
    return self;
}

+(CGAffineTransform) getAspectFitTransformFromSize: (CGSize) originalSize toSize: (CGSize) requiredSize
{
    CGFloat yScale = originalSize.height / requiredSize.height;
    CGFloat xScale = originalSize.width / requiredSize.width;
    CGFloat scale = 1 / (xScale > yScale ? xScale : yScale);
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat xShift = (requiredSize.width - (originalSize.width * scale)) / 2;
    CGFloat yShift = (requiredSize.height - (originalSize.height * scale)) / 2;
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(xShift, yShift);
    
    return CGAffineTransformConcat(scaleTransform, translationTransform);
}

@end
