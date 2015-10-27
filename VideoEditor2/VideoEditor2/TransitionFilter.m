//
//  TransitionFilter.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "TransitionFilter.h"

#define kDefaultTransitionFilterDuration 0.4

@interface TransitionFilter ()

@property (strong, nonatomic, readwrite) NSString* filterName;
@property (strong, nonatomic) CIFilter* filter;

@end

@implementation TransitionFilter
                               //@"",
                               //@"",
                               //@"",
                               //@"",

-(CGSize) getOriginalSize
{
    return [self.content1 getOriginalSize];
}

-(double) getDuration
{
    return kDefaultTransitionFilterDuration;
}

-(double) getContent1AppearanceDuration
{
    return kDefaultTransitionFilterDuration;
}

-(double) getContent2AppearanceDuration
{
    return kDefaultTransitionFilterDuration;
}

- (instancetype)initWithFilterName: (NSString*) filterName withInputParameters:(NSDictionary<NSString *,id> *)params
{
    self = [super init];
    if (self) {
        self.filterName = filterName;
        self.filter = [CIFilter filterWithName:self.filterName withInputParameters:params];
        if (params == nil) {
            [self.filter setDefaults];
        }
    }
    return self;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{

    double content1Time = [self.content1 getDuration] - [self getContent1AppearanceDuration] + request.time;
    VFrameRequest* content1FrameRequest = [request cloneWithDifferentTimeValue:content1Time];
    CIImage* fromImage = [self.content1 getFrameForRequest:content1FrameRequest];
    
    CIImage* toImage = [self.content2 getFrameForRequest:request];

    [self.filter setValue:fromImage forKey:@"inputImage"];
    [self.filter setValue:toImage forKey:@"inputTargetImage"];
    
    double inputTime = request.time / [self getDuration];
    
    [self.filter setValue:[NSNumber numberWithDouble:inputTime] forKey:@"inputTime"];
    
    CIImage* result = self.filter.outputImage;
    
    return result;
}

@end
