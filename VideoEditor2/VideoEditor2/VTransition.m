//
//  VTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition.h"

#import "VStillImage.h"

@implementation VTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        VStillImage* background = [VStillImage new];
        background.image = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
        self.backgroundFrameProvider = background;
    }
    return self;
}

-(void)setBackgroundFrameProvider:(VFrameProvider *)backgroundFrameProvider
{
    _backgroundFrameProvider = backgroundFrameProvider;
}

-(CGSize) getOriginalSize
{
    return [self.content1 getOriginalSize];
}

-(double) getDuration
{
    return 0.0;
}

-(double) getContent1AppearanceDuration
{
    return 0;
}

-(double) getContent2AppearanceDuration
{
    return 0;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    CIImage* result = [self.backgroundFrameProvider getFrameForRequest:request];
    
    return result;
}

@end
