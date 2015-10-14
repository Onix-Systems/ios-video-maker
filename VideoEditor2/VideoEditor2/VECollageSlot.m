//
//  VECollageSlot.m
//  VideoEditor2
//
//  Created by Alexander on 10/9/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VECollageSlot.h"

@implementation VECollageSlot

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeLine = [TimeLine new];
        _startTime = -1;
        _endTime = -1;
    }
    return self;
}

-(void) setupForFinalSize: (CGRect)frame andOriginalSize: (CGSize) originalSize;
{
    self.frame = frame;
    
    CGFloat xScale = originalSize.width / self.frame.size.width;
    CGFloat yScale = originalSize.height / self.frame.size.height;
    self.scale = 1 / (xScale < yScale ? xScale : yScale);
    
    self.xShift = (self.frame.size.width - (originalSize.width * self.scale)) / 2;
    self.yShift = (self.frame.size.height - (originalSize.height * self.scale)) / 2;
}

-(CIImage*) getTranstaledImageFromFrameProvider:(VEffect*)frameProvider atTime:(double)time
{
    TimeLineStateDescriptor* stateDescriptor = [self.timeLine getStateForTime:time];
    
    if ([stateDescriptor.currentState isEqualToString:kSlotTimeLineStateHidden]) {
        return nil;
    } else {
        double opacity = 0.0;
        
        double currentTimePeriodDurationPercent = (time - stateDescriptor.currentStateTime) / (stateDescriptor.nextStateTime - stateDescriptor.currentStateTime);
        if ([stateDescriptor.currentState isEqual:kSlotTimeLineStateShown]) {
            opacity = 1.0;
        } else if ([stateDescriptor.currentState isEqual:kSlotTimeLineStateShowing]) {
            opacity = 1 - 0.7 * currentTimePeriodDurationPercent;
        } else if ([stateDescriptor.currentState isEqual:kSlotTimeLineStateHidding]) {
            opacity = 0.3 + 0.7 * currentTimePeriodDurationPercent;
        }
        CIImage* image = [self makeSlotImageFromFrameProvider:frameProvider atTime:time];
        
        if (opacity < 1) {
            CIFilter *filter = [CIFilter filterWithName:@"CIDissolveTransition"];
            [filter setDefaults];
            
            [filter setValue:image forKey:@"inputImage"];
            [filter setValue:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]] forKey:@"inputTargetImage"];
            
            [filter setValue:[NSNumber numberWithDouble:opacity] forKey:@"inputTime"];
            
            image = (CIImage*)[filter valueForKey:kCIOutputImageKey];
        }
        
        return image;
    }
}

-(CIImage*) makeSlotImageFromFrameProvider:(VEffect*)frameProvider atTime:(double)time
{
    CIImage* image = [frameProvider getImageForFrameSize:self.frame.size atTime:time];
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.scale, self.scale);
    image = [image imageByApplyingTransform:scaleTransform];
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(self.frame.origin.x + self.xShift, self.frame.origin.y + self.yShift);
    image = [image imageByApplyingTransform:translationTransform];
    
    image = [image imageByCroppingToRect:self.frame];
    
    return image;
}

@end
