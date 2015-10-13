//
//  VESlidingPanelsCollage.m
//  VideoEditor2
//
//  Created by Alexander on 10/12/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VESlidingPanelsCollage.h"

#import "VESlidingPanelsCollageSlot.h"

@interface VESlidingPanelsCollage ()

@end

@implementation VESlidingPanelsCollage



-(Class) slotClass
{
    return [VESlidingPanelsCollageSlot class];
}

-(NSString*) getRandomMovingDirectoin
{
    switch (arc4random_uniform(4)) {
        case 0: return kSlidingPanelsDirectionToLeft;
        case 1: return kSlidingPanelsDirectionToRight;
        case 2: return kSlidingPanelsDirectionToTop;
            
        default:
            return kSlidingPanelsDirectionToBottom;
    }
}

-(VECollageSlot*) createSlotWithFrameProvider: (VEffect*)assetCocmponent forFrame: (CGRect) frame roundNumber: (NSInteger) roundNumber totalNumberOfRounds:(NSInteger)totalRounds
{
    VECollageSlot* slot = [[self slotClass] new];
    
    if (roundNumber > 0) {
        [slot.timeLine setState:kSlotTimeLineStateHidden forTime:.0 additionalInfo:nil];
    }
    
    double showingMoment = (kSlotRoundDuration * roundNumber);
    slot.startTime = showingMoment;
    [slot.timeLine setState:kSlotTimeLineStateShowing forTime:showingMoment additionalInfo:[self getRandomMovingDirectoin]];
    //[slot.timeLine setState:kSlotTimeLineStateShowing forTime:showingMoment additionalInfo:kSlidingPanelsDirectionToTop];
    [slot.timeLine setState:kSlotTimeLineStateShown forTime:(showingMoment + kSlidingDuration) additionalInfo:nil];
    
    double hidingMoment = (kSlotRoundDuration * (roundNumber + 1)) - kSlidingDuration;
    [slot.timeLine setState:kSlotTimeLineStateHidding forTime:hidingMoment additionalInfo:[self getRandomMovingDirectoin]];
    //[slot.timeLine setState:kSlotTimeLineStateHidding forTime:hidingMoment additionalInfo:kSlidingPanelsDirectionToTop];
    [slot.timeLine setState:kSlotTimeLineStateHidden forTime:(hidingMoment + kSlidingDuration) additionalInfo:nil];
    slot.endTime = hidingMoment + kSlidingDuration;

    [slot setupForFinalSize:frame andOriginalSize:assetCocmponent.originalSize];
    
    return slot;
}

@end
