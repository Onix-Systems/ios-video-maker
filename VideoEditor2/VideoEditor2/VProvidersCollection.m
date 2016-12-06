//
//  VProvidersCollection.m
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VProvidersCollection.h"
#import "VStillImage.h"
#import "VEAspectFill.h"
#import "CollageSlidingLayout.h"
#import "VEKenBurns.h"

@interface VProvidersCollection()

@property (strong, nonatomic, readwrite) NSMutableArray<VFrameProvider*>* contentItems;
@property (strong, nonatomic, readwrite) NSMutableArray<NSNumber*>* timing;

@end

@implementation VProvidersCollection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentItems = [NSMutableArray new];
        self.timing = [NSMutableArray new];
    }
    return self;
}

-(CGSize)getOriginalSize
{
    return self.finalSize;
}

-(double)getDuration
{
    if (self.contentItems.count > 0) {
        NSInteger lastItem = self.contentItems.count - 1;
        NSNumber* lastTime = self.timing[lastItem];
        
        return [lastTime doubleValue] + [self.contentItems[lastItem] getDurationWithoutTransitions];
    }

    return 0;
}

- (NSArray<VFrameProvider *> *)getContentItems
{
    return self.contentItems;
}

-(NSArray<NSNumber *> *)getTiming
{
    return self.timing;
}

-(void)addFrameProvider: (VFrameProvider*)frameProvider withFrontTransition:(VTransition*)transition
{
    double lastItemFinalTime = [self getDuration];
    
    if (transition != nil) {
        double transitionStartTime = MAX(0, lastItemFinalTime - [transition getContent1AppearanceDuration]);
        
        VFrameProvider* lastItem = self.contentItems[self.contentItems.count - 1];
        lastItem.transitionDurationRear = transition.getContent1AppearanceDuration;
        frameProvider.transitionDurationFront = transition.getContent2AppearanceDuration;
        
        [self.contentItems addObject:transition];
        [self.timing addObject:[NSNumber numberWithDouble:transitionStartTime]];
        
        double transitionDuration = [transition getDuration];
        double transitionRearShift = [transition getContent2AppearanceDuration];
        
        lastItemFinalTime = transitionStartTime + transitionDuration - transitionRearShift;
    }
    
    [self.contentItems addObject:frameProvider];
    [self.timing addObject:[NSNumber numberWithDouble:lastItemFinalTime]];
}

-(NSInteger)findItemNoForTime:(double)time
{
    for (int i = 0; i < self.contentItems.count; i++) {
        double currentItemTimeStart = [self.timing[i] doubleValue];
        double currentItemTimeEnd = currentItemTimeStart + [self.contentItems[i] getDuration];
        if ((time >= currentItemTimeStart) && (time <= currentItemTimeEnd)) {
            return i;
        }
    }
    return -1;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    NSInteger itemNo = [self findItemNoForTime:request.time];
    
    if (itemNo >= 0) {
        VFrameProvider* currentItem = self.contentItems[itemNo];
        
        double itemTime = request.time - [self.timing[itemNo] doubleValue] + currentItem.transitionDurationFront;
        VFrameRequest* requestWithItemTime = [request cloneWithDifferentTimeValue:itemTime];
                                                        
        return [currentItem getFrameForRequest:requestWithItemTime];
    }
    
    return nil;
}

-(void)reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    self.finalSize = videoComposition.frameSize;
    
    for (int i = 0; i < self.contentItems.count; i++) {
        [self.contentItems[i] reqisterIntoVideoComposition:videoComposition withInstruction:instruction withFinalSize:finalSize];
    }
}

@end
