//
//  VEFadeInFadeOut.m
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEFadeInFadeOut.h"

@implementation VEFadeInFadeOut

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fadeInDuration = kVEFadeInFadeOutDefaultDuration;
        self.fadeOutDuration = kVEFadeInFadeOutDefaultDuration;
    }
    return self;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    CIImage* image = [self.frameProvider getFrameForRequest:request];
    
//    double opacity = 1;
//    
//    time = request.time - self.startTime;
//    
//    if (self.fadeInDuration > 0 && time < self.fadeInDuration) {
//        opacity = time / self.fadeInDuration;
//    } else if (self.fadeOutDuration > 0 && (self.duration - self.fadeOutDuration) < time) {
//        opacity = 1 - ((time - (self.duration - self.fadeOutDuration)) / self.fadeOutDuration);
//    }
//    
//    if (opacity < 1) {
//        CIFilter *filter = [CIFilter filterWithName:@"CIDissolveTransition"];
//        [filter setDefaults];
//        
//        [filter setValue:image forKey:@"inputImage"];
//        [filter setValue:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]] forKey:@"inputTargetImage"];
//        
//        [filter setValue:[NSNumber numberWithDouble:opacity] forKey:@"inputTime"];
//        
//        image = (CIImage*)[filter valueForKey:kCIOutputImageKey];
//    }
    
    return image;
}


@end
