//
//  VideoCompositionVideoSegment.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTransitionSegment.h"

#import "TransitionFilter.h"

@interface VTransitionSegment ()

@property (strong, nonatomic) TransitionFilter* transitionFilter;

@end

@implementation VTransitionSegment


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitionType = [TransitionFilter getRandomFilterName];
        self.transitionDuration = CMTimeMake(2, 1000);
    }
    return self;
}

-(CMTime) duration
{
    return kCMTimeZero;
    //return self.transitionDuration;
}

-(void)setTransitionType:(NSString *)transitionType
{
    _transitionType = transitionType;
    
    self.transitionFilter = [TransitionFilter transitionFilterWithFilterName:self.transitionType];
}

-(CIImage*) drawTransitionForTime: (CMTime)inputTime frontFrame:(CIImage*)frontFrame rearFrame:(CIImage*)rearFrame
{
    return [self.transitionFilter getTransitionFromImage: frontFrame toImage:rearFrame inputTime: CMTimeGetSeconds(inputTime) / CMTimeGetSeconds(self.duration)];
}

-(void) putIntoVideoComosition: (VideoComposition*)videoComposition withinTimeRange: (CMTimeRange) timeRange;
{

}

@end
