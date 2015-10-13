//
//  VESlidingPanelsCollageSlot.m
//  VideoEditor2
//
//  Created by Alexander on 10/12/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VESlidingPanelsCollageSlot.h"

@implementation VESlidingPanelsCollageSlot

-(CIImage*) slideInImage:(CIImage*) image toDirection: (NSString*) direction slideTimePercent:(double)slideTimePercent {
    double x = 0;
    double y = 0;
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    
    double k = 1 - ((1 + sin(3.1415 * (-0.5 + slideTimePercent))) / 2);

    if ([direction isEqual:kSlidingPanelsDirectionToLeft]) {
        x = x - width * k;
    }
    
    if ([direction isEqual:kSlidingPanelsDirectionToRight]) {
        x = x + width * k;
    }
    
    if ([direction isEqual:kSlidingPanelsDirectionToTop]) {
        y = y + height * k;
    }
    
    if ([direction isEqual:kSlidingPanelsDirectionToBottom]) {
        y = y - height * k;
    }
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(x, y);
    image = [image imageByApplyingTransform:translationTransform];
    
    //CGRect cropFrame = CGRectMake(0, 0, width, height);
    image = [image imageByCroppingToRect:self.frame];
    
    return image;
}

-(CIImage*) slideOutImage:(CIImage*) image toDirection: (NSString*) direction slideTimePercent:(double)slideTimePercent {
    
    double x = 0;
    double y = 0;
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    
    double k = (1 + sin(3.1415 * (-0.5 + slideTimePercent))) / 2;
    
    if ([direction isEqual:kSlidingPanelsDirectionToLeft]) {
        x = x - width*k;
    }
    
    if ([direction isEqual:kSlidingPanelsDirectionToRight]) {
        x = x + width*k;
    }
    
    if ([direction isEqual:kSlidingPanelsDirectionToTop]) {
        y = y + height * k;
    }
    
    if ([direction isEqual:kSlidingPanelsDirectionToBottom]) {
        y = y - height * k;
    }
    
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(x, y);
    image = [image imageByApplyingTransform:translationTransform];
    
    //CGRect cropFrame = CGRectMake(0, 0, width, height);
    image = [image imageByCroppingToRect:self.frame];
    
    return image;
}

-(CIImage*) getTranstaledImageFromFrameProvider:(VEffect*)frameProvider atTime:(double)time
{
    TimeLineStateDescriptor* stateDescriptor = [self.timeLine getStateForTime:time];
    
    if ([stateDescriptor.currentState isEqualToString:kSlotTimeLineStateHidden]) {
        return nil;
    } else {
        double currentTimePeriodDurationPercent = (time - stateDescriptor.currentStateTime) / (stateDescriptor.nextStateTime - stateDescriptor.currentStateTime);
        
        CIImage* image = [self makeSlotImageFromFrameProvider:frameProvider atTime:time];
        
        if ([stateDescriptor.currentState isEqual:kSlotTimeLineStateShowing]) {
            if (currentTimePeriodDurationPercent < 1) {
                image = [self slideInImage:image toDirection:(NSString*)stateDescriptor.currentStateInfo slideTimePercent:currentTimePeriodDurationPercent];
            }
        }
        if ([stateDescriptor.currentState isEqual:kSlotTimeLineStateHidding]) {
            if (currentTimePeriodDurationPercent < 1) {
                image = [self slideOutImage:image toDirection:(NSString*)stateDescriptor.currentStateInfo slideTimePercent:currentTimePeriodDurationPercent];
            }
        }
        
        return image;
    }
}

@end
