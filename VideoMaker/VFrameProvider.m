//
//  VFramePrivider.m
//  VideoEditor2
//
//  Created by Alexander on 10/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VFrameProvider.h"

@implementation VFrameProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isStatic = NO;
    }
    return self;
}

-(CGSize)getOriginalSize
{
    return CGSizeZero;
}

-(double)getDuration
{
    return 0.0;
}

-(double)getDurationWithoutTransitions
{
    return [self getDuration] - self.transitionDurationFront - self.transitionDurationRear;
}

-(CIImage*)getFrameForRequest:(VFrameRequest *)request
{
    return nil;
}

-(void)reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    
}

@end
