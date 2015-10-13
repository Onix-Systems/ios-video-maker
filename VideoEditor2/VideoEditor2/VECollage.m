//
//  VECollage.m
//  VideoEditor2
//
//  Created by Alexander on 10/8/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VECollage.h"

@implementation VECollage

-(Class) slotClass
{
    return [VECollageSlot class];
}

-(VECollageSlot*) createSlotWithFrameProvider: (VEffect*)assetCocmponent forFrame: (CGRect) frame roundNumber: (NSInteger) roundNumber totalNumberOfRounds:(NSInteger)totalRounds
{
    VECollageSlot* slot = [[self slotClass] new];
    
    if (roundNumber == 0) {
        slot.startTime = 0;
        
        [slot.timeLine setState:kSlotTimeLineStateShown forTime:.0 additionalInfo:nil];
        
    } else {
        [slot.timeLine setState:kSlotTimeLineStateHidden forTime:.0 additionalInfo:nil];
        double showingMoment = (kSlotRoundDuration * roundNumber) - (kShowHideDuration / 2);
        slot.startTime = showingMoment;
        [slot.timeLine setState:kSlotTimeLineStateShowing forTime:showingMoment additionalInfo:nil];
        [slot.timeLine setState:kSlotTimeLineStateShown forTime:(showingMoment + kShowHideDuration) additionalInfo:nil];
    }
    
    if ((roundNumber + 1) < totalRounds) {
        double hidingMoment = (kSlotRoundDuration * (roundNumber + 1)) - (kShowHideDuration / 2);
        [slot.timeLine setState:kSlotTimeLineStateHidding forTime:hidingMoment additionalInfo:nil];
        [slot.timeLine setState:kSlotTimeLineStateHidden forTime:(hidingMoment + kShowHideDuration) additionalInfo:nil];
        slot.endTime = hidingMoment + kShowHideDuration;
    } else {
        slot.endTime = kSlotRoundDuration * totalRounds;
    }
    
    [slot setupForFinalSize:frame andOriginalSize:assetCocmponent.originalSize];

    return slot;
}

-(void) putFrames:(NSArray<VEffect*>*) assetCocmponents intoLayout:(CollageLayout *)collageLayout ofSize:(CGSize)finalSize
{
    self.assetCocmponents = assetCocmponents;
    self.collageLayout = collageLayout;
    self.originalSize = finalSize;
    
    NSInteger assetsCount = self.assetCocmponents.count;
    NSInteger framesCount = self.collageLayout.frames.count;

    NSMutableArray<VECollageSlot*>* slots = [NSMutableArray new];
    NSArray* slotFrames = [self.collageLayout getLayoutFramesForSize: finalSize];
    
    if (self.assetCocmponents.count <= slotFrames.count) {
        for (int i = 0; i < self.collageLayout.frames.count; i++) {
            VEffect* componentFrameProvider = self.assetCocmponents[i % assetsCount];
            NSValue* frameValue = slotFrames[i];
            
            VECollageSlot* slot = [self createSlotWithFrameProvider:componentFrameProvider forFrame:[frameValue CGRectValue] roundNumber:0 totalNumberOfRounds:1];
            [slots addObject: slot];
        }

    } else {
        NSInteger numberOfRaunds = (assetsCount / framesCount) + ((assetsCount % framesCount) > 0 ? 1 : 0);
        for (NSInteger i = 0; i < numberOfRaunds; i++) {
            for (NSInteger j = 0; j < framesCount; j++) {
                NSInteger k = i * framesCount + j;
                NSInteger l = k % assetsCount;
                
                VEffect* componentFrameProvider = self.assetCocmponents[l];
                NSValue* frameValue = slotFrames[j];
                    
                VECollageSlot* slot = [self createSlotWithFrameProvider:componentFrameProvider forFrame:[frameValue CGRectValue]  roundNumber:i totalNumberOfRounds:numberOfRaunds];
                [slots addObject: slot];
            }
        }
    }
    self.slots = slots;
}

-(CIImage*) getImageOfTime:(double)time
{
    CIImage *resultImage = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
    
    for (int i = 0; i < self.slots.count; i++) {
        VECollageSlot *slot = self.slots[i];
        
        if ((slot.startTime <= time) && (slot.endTime >= time)) {
            NSInteger j = i % self.assetCocmponents.count;
            VEffect* componentFrameProvider = self.assetCocmponents[j];
            
            CIImage* slotImage = [slot getTranstaledImageFromFrameProvider:componentFrameProvider atTime:time];
            
            if (slotImage != nil) {
                resultImage = [slotImage imageByCompositingOverImage:resultImage];
            }
        }
    }
    
    return resultImage;
}

-(CIImage*) getImageForFrameSize: (CGSize) frameSize atTime: (double) time
{
    return [self getImageOfTime:time];
}

@end
