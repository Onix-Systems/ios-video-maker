//
//  VEffect.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEffect.h"

@implementation VEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frameProvider = nil;
    }
    return self;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    return [self.frameProvider getFrameForRequest:request];
}

-(CGSize) getOriginalSize
{
    return [self.frameProvider getOriginalSize];
}

-(double)getDuration
{
    return [self.frameProvider getDuration];
}

-(void)reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    self.finalSize = finalSize;
    [self.frameProvider reqisterIntoVideoComposition:videoComposition withInstruction:instruction withFinalSize:finalSize];
}

@end
