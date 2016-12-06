//
//  VTransition01Dissolve.m
//  VideoEditor2
//
//  Created by Alexander on 11/18/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransition01Dissolve.h"

#define kVTransitionDuration 0.6

@implementation VTransition01Dissolve

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
    return kVTransitionDuration;
}

-(double) getContent2AppearanceDuration
{
    return kVTransitionDuration;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    CIImage* result = nil;
    
    double duration = [self getDuration];
    
    double content1Time = [self.content1 getDuration] - duration + request.time;
    VFrameRequest* content1FrameRequest = [request cloneWithDifferentTimeValue:content1Time];
    
    
    CIFilter *filter = [CIFilter filterWithName:@"CIDissolveTransition"];
    [filter setDefaults];
    
    [filter setValue:[self.content1 getFrameForRequest:content1FrameRequest] forKey:@"inputImage"];
    [filter setValue:[self.content2 getFrameForRequest:request] forKey:@"inputTargetImage"];
    
    [filter setValue:[NSNumber numberWithDouble:request.time/duration] forKey:@"inputTime"];
    
    result = filter.outputImage;
    
    return result;
}

@end
