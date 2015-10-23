//
//  VTransition01Fading.m
//  VideoEditor2
//
//  Created by Alexander on 10/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition01Fading.h"

#import "VEFadeInFadeOut.h"

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
    if (request.time < [self getContent1AppearanceDuration]) {
        double content1Time = [self.content1 getDuration] - [self getContent1AppearanceDuration] + request.time;
        VFrameRequest* content1FrameRequest = [request cloneWithDifferentTimeValue:content1Time];
        
        return [self.content1 getFrameForRequest:content1FrameRequest];
        
    } else if (request.time > [self getContent1AppearanceDuration]) {
        double content2Time = request.time - [self getContent1AppearanceDuration];
        VFrameRequest* content2FrameRequest = [request cloneWithDifferentTimeValue:content2Time];
        
        return [self.content2 getFrameForRequest:content2FrameRequest];
    } else {
        return [self.backgroundFrameProvider getFrameForRequest:request];
    }
}

@end
