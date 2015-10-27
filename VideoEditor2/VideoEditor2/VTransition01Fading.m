//
//  VTransition01Fading.m
//  VideoEditor2
//
//  Created by Alexander on 10/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition01Fading.h"
#import "VEFadeInFadeOut.h"

#define kVTransitionDuration 0.4

@implementation VTransition01Fading

-(CGSize) getOriginalSize
{
    return [self.content1 getOriginalSize];
}

-(double) getDuration
{
    return kVTransitionDuration;
}

-(double) getContent1AppearanceDuration
{
    return kVTransitionDuration / 2;
}

-(double) getContent2AppearanceDuration
{
    return kVTransitionDuration / 2;
}

-(void)setContent1:(VFrameProvider *)content1
{
    VEFadeInFadeOut* fadeEffect = [VEFadeInFadeOut new];
    fadeEffect.frameProvider = content1;
    fadeEffect.fadeInDuration = 0;
    fadeEffect.fadeOutDuration = [self getContent1AppearanceDuration];
    
    [super setContent1:fadeEffect];
}

-(void)setContent2:(VFrameProvider *)content2
{
    VEFadeInFadeOut* fadeEffect = [VEFadeInFadeOut new];
    fadeEffect.frameProvider = content2;
    fadeEffect.fadeInDuration = [self getContent2AppearanceDuration];
    fadeEffect.fadeOutDuration = 0;
    
    [super setContent2:fadeEffect];
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    CIImage* result = nil;
    
    double duration = [self getDuration];
    double content1Duration = [self getContent1AppearanceDuration];
    double content2Duration = [self getContent2AppearanceDuration];
    
    if (request.time < content1Duration) {
        double content1Time = [self.content1 getDuration] - [self getContent1AppearanceDuration] + request.time;
        VFrameRequest* content1FrameRequest = [request cloneWithDifferentTimeValue:content1Time];
        
        result = [self.content1 getFrameForRequest:content1FrameRequest];
        
    } else if (request.time > (duration - content2Duration)) {
        double content2Time = request.time - (duration - content2Duration);
        VFrameRequest* content2FrameRequest = [request cloneWithDifferentTimeValue:content2Time];
        
        result = [self.content2 getFrameForRequest:content2FrameRequest];
    } else {
        result = [self.backgroundFrameProvider getFrameForRequest:request];
    }
    
    return result;
}

@end
