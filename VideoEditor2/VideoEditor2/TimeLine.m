//
//  TimeLine.m
//  VideoEditor2
//
//  Created by Alexander on 10/12/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "TimeLine.h"

@interface TimeLine ()

@property (strong, nonatomic) NSMutableArray* timeEvents;
@property (strong, nonatomic) NSMutableArray* timeState;
@property (strong, nonatomic) NSMutableArray* timeInfo;

@end

@implementation TimeLine

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeEvents = [NSMutableArray new];
        self.timeState = [NSMutableArray new];
        self.timeInfo = [NSMutableArray new];
    }
    return self;
}

-(int) getIndexForTime:(double) time
{
    for (int i = 0; i < self.timeEvents.count; i++) {
        NSNumber* timeEvent = self.timeEvents[i];
        if (timeEvent.doubleValue > time) {
            return i;
        }
    }
    
    return (int)self.timeEvents.count;
}

-(void) setState:(NSString *)state forTime:(double)time additionalInfo:(NSObject *)info
{
    int i = [self getIndexForTime:time];

    [self.timeEvents insertObject:[NSNumber numberWithDouble:time] atIndex:i];
    [self.timeState insertObject:state atIndex:i];
    if (info != nil) {
        [self.timeInfo insertObject:info atIndex:i];
    } else {
        [self.timeInfo insertObject:@"" atIndex:i];
    }
}

-(TimeLineStateDescriptor*) getStateForTime:(double)time
{
    TimeLineStateDescriptor* descritor = [TimeLineStateDescriptor new];
    
    int i = [self getIndexForTime:time];
    
    if (i > 0) {
        NSNumber* timeEvent = self.timeEvents[i - 1];
        descritor.currentState = self.timeState[i - 1];
        descritor.currentStateTime = timeEvent.doubleValue;
        descritor.currentStateInfo = self.timeInfo[i - 1];
    }
    
    if (i < self.timeInfo.count) {
        NSNumber* timeEvent = self.timeEvents[i];
        descritor.nextState = self.timeState[i];
        descritor.nextStateTime = timeEvent.doubleValue;
        descritor.nextStateInfo = self.timeInfo[i];
    }
    
    return descritor;
}

-(double) getTimeOfFirstAppearance
{
    for (int i = 0; i < self.timeState.count; i++) {
        NSString* state = self.timeState[i];
        if ([state isEqual:kSlotTimeLineStateShown] || [state isEqual:kSlotTimeLineStateShowing]) {
            NSNumber* timeNumber = self.timeEvents[i];
            return [timeNumber doubleValue];
        }
    }
    return -1;
}

-(double) getTimeOfLastAppearance
{
    NSInteger j = -1;
    
    for (int i = 0; i < self.timeState.count; i++) {
        NSString* state = self.timeState[i];
        if ([state isEqual:kSlotTimeLineStateShown] || [state isEqual:kSlotTimeLineStateShowing]) {
            j = i;
        }
    }
    
    if (j >= 0 && (j + 1) <= self.timeEvents.count) {
        NSNumber* timeNumber = self.timeEvents[j+1];
        return [timeNumber doubleValue];
    }
    return -1;
}

@end
