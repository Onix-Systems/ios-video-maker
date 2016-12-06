//
//  VFoldingOrigamiTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/24/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VFoldingOrigamiTransition.h"

#define kTotalTransitionDutation 0.5
#define kSizeDecrease 0.45
#define kFadeOutPercent 0.85

#define kFoldingMovementDirectionTop 1
#define kFoldingMovementDirectionNone 0
#define kFoldingMovementDirectionBottom -1

@interface VFoldingOrigamiTransition()

@property (nonatomic) NSInteger foldingMovementDirection;

@end

@implementation VFoldingOrigamiTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.foldingMovementDirection = arc4random_uniform(3) - 1;
    }
    return self;
}

-(CGSize) getOriginalSize
{
    return [self.content1 getOriginalSize];
}

-(double) getDuration
{
    return kTotalTransitionDutation;
}

-(double) getContent1AppearanceDuration
{
    return kTotalTransitionDutation;
}

-(double) getContent2AppearanceDuration
{
    return kTotalTransitionDutation;
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    CGSize imageSize = [self.content1 getOriginalSize];

    CGRect imageFrame1 = CGRectMake(0, 0, imageSize.width, imageSize.height/2);
    CGRect imageFrame2 = CGRectMake(0, imageSize.height/2, imageSize.width, imageSize.height/2);

    double content1Time = [self.content1 getDuration] - [self getContent1AppearanceDuration] + request.time;
    VFrameRequest* content1FrameRequest = [request cloneWithDifferentTimeValue:content1Time];
    
    CIImage* oldImage = [self.content1 getFrameForRequest:content1FrameRequest];
    
    double foldingPercent = request.time / [self getDuration];
    
    CIFilter *fadeOutFilter = [CIFilter filterWithName:@"CIDissolveTransition"];
    [fadeOutFilter setDefaults];
    [fadeOutFilter setValue:oldImage forKey:@"inputImage"];
    [fadeOutFilter setValue:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]] forKey:@"inputTargetImage"];
    [fadeOutFilter setValue:[NSNumber numberWithDouble:foldingPercent*kFadeOutPercent] forKey:@"inputTime"];
    oldImage = fadeOutFilter.outputImage;
    
    CIImage* oldImage1 = [oldImage vCrop:imageFrame1];
    CIImage* oldImage2 = [oldImage vCrop:imageFrame2];

    CIImage* nextImage = [self.content2 getFrameForRequest:request];
    nextImage = [nextImage vCrop:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    CIFilter* filter1 = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [filter1 setDefaults];
    [filter1 setValue:oldImage1 forKey:@"inputImage"];
    
    CIFilter* filter2 = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [filter2 setDefaults];
    [filter2 setValue:oldImage2 forKey:@"inputImage"];
    
    double oldImageFoldedHight = imageSize.height * (1 - foldingPercent);
    
    CIImage* nextImage1 = nil;
    CIImage* nextImage2 = nil;
    
    double sizeDecrease = imageSize.height * foldingPercent * kSizeDecrease / 2;
    
    if (self.foldingMovementDirection == kFoldingMovementDirectionTop) {
        [filter2 setValue:[CIVector vectorWithX:0 Y:imageSize.height] forKey:@"inputTopLeft"];
        [filter2 setValue:[CIVector vectorWithX:imageSize.width Y:imageSize.height] forKey:@"inputTopRight"];
        [filter2 setValue:[CIVector vectorWithX:0 + sizeDecrease Y:(imageSize.height - oldImageFoldedHight/2)] forKey:@"inputBottomLeft"];
        [filter2 setValue:[CIVector vectorWithX:imageSize.width - sizeDecrease Y:(imageSize.height - oldImageFoldedHight/2)] forKey:@"inputBottomRight"];
        
        [filter1 setValue:[CIVector vectorWithX:0 + sizeDecrease Y:(imageSize.height - oldImageFoldedHight/2)] forKey:@"inputTopLeft"];
        [filter1 setValue:[CIVector vectorWithX:imageSize.width - sizeDecrease Y:(imageSize.height - oldImageFoldedHight/2)] forKey:@"inputTopRight"];
        [filter1 setValue:[CIVector vectorWithX:0 Y:(imageSize.height - oldImageFoldedHight)] forKey:@"inputBottomLeft"];
        [filter1 setValue:[CIVector vectorWithX:imageSize.width Y:(imageSize.height - oldImageFoldedHight)] forKey:@"inputBottomRight"];
        
        nextImage2 = nil;
        nextImage1 = [nextImage vShiftX:0 shiftY:(-1 * imageSize.height) + (imageSize.height - oldImageFoldedHight)];
        
    } else if (self.foldingMovementDirection == kFoldingMovementDirectionNone) {
        [filter2 setValue:[CIVector vectorWithX:0 Y:(imageSize.height/2 + oldImageFoldedHight/2)] forKey:@"inputTopLeft"];
        [filter2 setValue:[CIVector vectorWithX:imageSize.width Y:(imageSize.height/2 + oldImageFoldedHight/2)] forKey:@"inputTopRight"];
        [filter2 setValue:[CIVector vectorWithX:0 + sizeDecrease Y:imageSize.height/2] forKey:@"inputBottomLeft"];
        [filter2 setValue:[CIVector vectorWithX:imageSize.width - sizeDecrease Y:imageSize.height/2] forKey:@"inputBottomRight"];
        
        [filter1 setValue:[CIVector vectorWithX:0 + sizeDecrease Y:imageSize.height/2] forKey:@"inputTopLeft"];
        [filter1 setValue:[CIVector vectorWithX:imageSize.width - sizeDecrease Y:imageSize.height/2] forKey:@"inputTopRight"];
        [filter1 setValue:[CIVector vectorWithX:0 Y:(imageSize.height/2 - oldImageFoldedHight/2)] forKey:@"inputBottomLeft"];
        [filter1 setValue:[CIVector vectorWithX:imageSize.width Y:(imageSize.height/2 - oldImageFoldedHight/2)] forKey:@"inputBottomRight"];

        nextImage2 = [nextImage vCrop:imageFrame2];
        nextImage1 = [nextImage vCrop:imageFrame1];

        nextImage2 = [nextImage2 vShiftX:0 shiftY:(+1 * imageSize.height/2) - (imageSize.height - oldImageFoldedHight)/2];
        nextImage1 = [nextImage1 vShiftX:0 shiftY:(-1 * imageSize.height/2) + (imageSize.height - oldImageFoldedHight)/2];

    } else {
        // kFoldingMovementDirectionBottom
        
        [filter2 setValue:[CIVector vectorWithX:0 Y:oldImageFoldedHight] forKey:@"inputTopLeft"];
        [filter2 setValue:[CIVector vectorWithX:imageSize.width Y:oldImageFoldedHight] forKey:@"inputTopRight"];
        [filter2 setValue:[CIVector vectorWithX:0 + sizeDecrease Y:oldImageFoldedHight/2] forKey:@"inputBottomLeft"];
        [filter2 setValue:[CIVector vectorWithX:imageSize.width - sizeDecrease Y:oldImageFoldedHight/2] forKey:@"inputBottomRight"];
        
        [filter1 setValue:[CIVector vectorWithX:0 + sizeDecrease Y:oldImageFoldedHight/2] forKey:@"inputTopLeft"];
        [filter1 setValue:[CIVector vectorWithX:imageSize.width - sizeDecrease Y:oldImageFoldedHight/2] forKey:@"inputTopRight"];
        [filter1 setValue:[CIVector vectorWithX:0 Y:0] forKey:@"inputBottomLeft"];
        [filter1 setValue:[CIVector vectorWithX:imageSize.width Y:0] forKey:@"inputBottomRight"];
        
        nextImage2 = [nextImage vShiftX:0 shiftY:(+1 * imageSize.height) - (imageSize.height - oldImageFoldedHight)];
        nextImage1 = nil;
    }
    
    oldImage1 = filter1.outputImage;
    oldImage2 = filter2.outputImage;
    
    CIImage* resultImage = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
    
    resultImage = [oldImage1 vComposeOverBackground:resultImage];
    resultImage = [oldImage2 vComposeOverBackground:resultImage];
    if (nextImage1 != nil) {
        resultImage = [nextImage1 vComposeOverBackground:resultImage];
    }
    if (nextImage2 != nil) {
        resultImage = [nextImage2 vComposeOverBackground:resultImage];
    }

    
    return resultImage;
}

@end
