//
//  VCollageFrame.m
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCollageFrame.h"
#import "VStillImage.h"

@implementation VCollageFrame

- (instancetype)init
{
    self = [super init];
    if (self) {
        VStillImage* backgroundFrameProvider = [VStillImage new];
        backgroundFrameProvider.image = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
        self.backgroundFrameProvider = backgroundFrameProvider;
    }
    return self;
}

-(CGSize) getOriginalSize
{
    return self.finalSize;
}

-(double) getDuration
{
    return kCollageFrameDuration;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    CIImage* result = [self.backgroundFrameProvider getFrameForRequest:request];
    
    NSArray* frames = [self.collageLayout getFramesForFinalSize:request.frameSize andTime:request.time];
    
    for (int i = 0; i < frames.count; i++) {
        CGRect frame = [frames[i] CGRectValue];
        VEffect* collageItem = self.collageItems[i];
        collageItem.finalSize = frame.size;
        CIImage* itemImage = [collageItem getFrameForRequest:request];
        
        CGAffineTransform transform = CGAffineTransformMakeTranslation(frame.origin.x, frame.origin.y);
        itemImage = [itemImage imageByApplyingTransform:transform];
        
        result = [itemImage imageByCompositingOverImage:result];
    }
    
    return result;
}

-(void) reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    self.finalSize = finalSize;
    NSArray* frames = [self.collageLayout getStillFramesForFinalSize:finalSize];
    for (int i = 0; i < frames.count; i++) {
        VEffect* collageItem = self.collageItems[i];
        CGRect itemFrame = [frames[i] CGRectValue];
        [collageItem reqisterIntoVideoComposition:videoComposition withInstruction:instruction withFinalSize:itemFrame.size];
    }
}

@end
