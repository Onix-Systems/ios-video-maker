//
//  VCollageFrame.m
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCollageFrame.h"
#import "VStillImage.h"

@interface VCollageFrame()

@property (nonatomic,strong) VStillImage* cachedFrameImage;

@end

@implementation VCollageFrame

- (instancetype)init
{
    self = [super init];
    if (self) {
        VStillImage* backgroundFrameProvider = [VStillImage new];
        backgroundFrameProvider.image = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
        self.backgroundFrameProvider = backgroundFrameProvider;
        self.isStatic = NO;
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

-(void)setFinalSize:(CGSize)finalSize
{
    if ((_finalSize.width != finalSize.width) && (_finalSize.height != finalSize.height)) {
        _finalSize = finalSize;
        self.cachedFrameImage = nil;
    }
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    if (self.cachedFrameImage != nil) {
        return [self.cachedFrameImage getFrameForRequest:request];
    }
    
    CIImage* result = [self.backgroundFrameProvider getFrameForRequest:request];
    
    NSArray* frames = [self.collageLayout getFramesForFinalSize:self.finalSize andTime:request.time];
    
    for (int i = 0; i < frames.count; i++) {
        CGRect frame = [frames[i] CGRectValue];
        VEffect* collageItem = self.collageItems[i];
        collageItem.finalSize = frame.size;
        CIImage* itemImage = [collageItem getFrameForRequest:request];
        
        itemImage = [itemImage vShiftX:frame.origin.x shiftY:frame.origin.y];
        
        result = [itemImage vComposeOverBackground:result];
    }
    
    if ([self isStatic]) {
        self.cachedFrameImage = [VStillImage new];
        self.cachedFrameImage.image = [result renderRectForChaching: CGRectMake(0, 0, self.finalSize.width, self.finalSize.height)];
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
