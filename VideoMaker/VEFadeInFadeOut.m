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
    
    double opacity = 1;
    
    if ((self.fadeInDuration > 0) && (request.time < self.fadeInDuration)) {
        opacity = request.time / self.fadeInDuration;
    }
    
    if ((self.fadeOutDuration > 0) && (request.time > ([self getDuration] - self.fadeOutDuration))) {
        opacity = 1 - (request.time - ([self getDuration] - self.fadeOutDuration)) / self.fadeOutDuration;
    }
        
    if (opacity < 1) {
        CIFilter *filter = [CIFilter filterWithName:@"CIDissolveTransition"];
        [filter setDefaults];
        
        [filter setValue:image forKey:@"inputImage"];
        [filter setValue:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]] forKey:@"inputTargetImage"];
        
        [filter setValue:[NSNumber numberWithDouble:(1 - opacity)] forKey:@"inputTime"];
        
        image = (CIImage*)[filter valueForKey:kCIOutputImageKey];
    }
    
    return image;
}


@end
