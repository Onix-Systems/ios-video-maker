//
//  VBookPageOrigamiTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VBookPageOrigamiTransition.h"

#define kTotalTransitionDutation 0.5
#define kSizeIncrease 0.45
#define kFadeOutPercent 0.7

@interface VBookPageOrigamiTransition()

@property (nonatomic) BOOL isHorizontal;

@end

@implementation VBookPageOrigamiTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isHorizontal = arc4random_uniform(2) >= 1 ? YES : NO;
        //self.isHorizontal = NO;
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
    if (self.isHorizontal) {
        imageFrame1 = CGRectMake(0, 0, imageSize.width/2, imageSize.height);
        imageFrame2 = CGRectMake(imageSize.width/2, 0, imageSize.width/2, imageSize.height);
    }
    
    CIImage* backgroundImage = [self.content2 getFrameForRequest:request];
    CIImage* backgroundImage1 = [backgroundImage vCrop:imageFrame1];
    CIImage* backgroundImage2 = [backgroundImage vCrop:imageFrame2];
    
    double content1Time = [self.content1 getDuration] - [self getContent1AppearanceDuration] + request.time;
    VFrameRequest* content1FrameRequest = [request cloneWithDifferentTimeValue:content1Time];
    
    CIImage* frontImage = [self.content1 getFrameForRequest:content1FrameRequest];
    CIImage* frontImage1 = [frontImage vCrop:imageFrame1];
    CIImage* frontImage2 = [frontImage vCrop:imageFrame2];
    
    CIImage* resultImage = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
    
    resultImage = [frontImage1 vComposeOverBackground:resultImage];
    resultImage = [backgroundImage2 vComposeOverBackground:resultImage];

    double rotationPercent = request.time / [self getDuration];
    
    CIFilter* filter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [filter setDefaults];

    if (rotationPercent < 0.5) {
        double fadeoutPercent = rotationPercent * 2;
        CIFilter *fadeOutFilter = [CIFilter filterWithName:@"CIDissolveTransition"];
        [fadeOutFilter setDefaults];
        
        [fadeOutFilter setValue:frontImage2 forKey:@"inputImage"];
        [fadeOutFilter setValue:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]] forKey:@"inputTargetImage"];
        
        [fadeOutFilter setValue:[NSNumber numberWithDouble:fadeoutPercent*kFadeOutPercent] forKey:@"inputTime"];
        
        frontImage2 = fadeOutFilter.outputImage;
        frontImage2 = [frontImage2 vCrop:imageFrame2];

        [filter setValue:frontImage2 forKey:@"inputImage"];
        
        if (self.isHorizontal) {
            double halfOfWidth = imageSize.width / 2;
            double sizeIncrease = (imageSize.height * kSizeIncrease) * rotationPercent;

            [filter setValue:[CIVector vectorWithX:halfOfWidth Y:imageSize.height] forKey:@"inputTopLeft"];
            [filter setValue:[CIVector vectorWithX:halfOfWidth Y:0] forKey:@"inputBottomLeft"];
            [filter setValue:[CIVector vectorWithX:(imageSize.width - (halfOfWidth * rotationPercent * 2)) Y:imageSize.height + sizeIncrease*0.7] forKey:@"inputTopRight"];
            [filter setValue:[CIVector vectorWithX:(imageSize.width - halfOfWidth*(rotationPercent*2)) Y:0 - sizeIncrease*0.3] forKey:@"inputBottomRight"];
            
        } else {
            double halfOfHeight = imageSize.height / 2;
            double sizeIncrease = (imageSize.width * kSizeIncrease) * rotationPercent;

            [filter setValue:[CIVector vectorWithX:0 - sizeIncrease*0.7 Y:imageSize.height - (halfOfHeight * rotationPercent *2)] forKey:@"inputTopLeft"];
            [filter setValue:[CIVector vectorWithX:imageSize.width + sizeIncrease*0.3 Y:imageSize.height - (halfOfHeight * rotationPercent *2)] forKey:@"inputTopRight"];
            [filter setValue:[CIVector vectorWithX:0 Y:halfOfHeight] forKey:@"inputBottomLeft"];
            [filter setValue:[CIVector vectorWithX:imageSize.width Y:halfOfHeight] forKey:@"inputBottomRight"];

        }
        
        CIImage* rotatedImage = filter.outputImage;
        
        resultImage = [rotatedImage vComposeOverBackground:resultImage];
        
    } else {
        double fadeoutPercent = (1 - rotationPercent) * 2;
        CIFilter *fadeOutFilter = [CIFilter filterWithName:@"CIDissolveTransition"];
        [fadeOutFilter setDefaults];
        
        [fadeOutFilter setValue:backgroundImage1 forKey:@"inputImage"];
        [fadeOutFilter setValue:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]] forKey:@"inputTargetImage"];
        
        [fadeOutFilter setValue:[NSNumber numberWithDouble:fadeoutPercent*kFadeOutPercent] forKey:@"inputTime"];
        
        backgroundImage1 = fadeOutFilter.outputImage;
        backgroundImage1 = [backgroundImage1 vCrop:imageFrame1];

        [filter setValue:backgroundImage1 forKey:@"inputImage"];
        
        if (self.isHorizontal) {
            double halfOfWidth = imageSize.width / 2;
            double sizeIncrease = (imageSize.height * kSizeIncrease) * (1 - rotationPercent)*2;
            
            [filter setValue:[CIVector vectorWithX:halfOfWidth * ((1 - rotationPercent)*2) Y:imageSize.height + sizeIncrease*0.7] forKey:@"inputTopLeft"];
            [filter setValue:[CIVector vectorWithX:halfOfWidth * ((1 - rotationPercent)*2) Y:0 - sizeIncrease*0.3] forKey:@"inputBottomLeft"];
            [filter setValue:[CIVector vectorWithX:halfOfWidth Y:imageSize.height] forKey:@"inputTopRight"];
            [filter setValue:[CIVector vectorWithX:halfOfWidth Y:0] forKey:@"inputBottomRight"];
            
        } else {
            double halfOfHeight = imageSize.height / 2;
            double sizeIncrease = (imageSize.width * kSizeIncrease) * (1 - rotationPercent)*2;
            
            [filter setValue:[CIVector vectorWithX:0 Y:halfOfHeight] forKey:@"inputTopLeft"];
            [filter setValue:[CIVector vectorWithX:imageSize.width Y:halfOfHeight] forKey:@"inputTopRight"];
            [filter setValue:[CIVector vectorWithX:0 - sizeIncrease*0.7 Y:halfOfHeight * (1-rotationPercent) * 2] forKey:@"inputBottomLeft"];
            [filter setValue:[CIVector vectorWithX:imageSize.width + sizeIncrease*0.3 Y:halfOfHeight * (1-rotationPercent) * 2] forKey:@"inputBottomRight"];

        }
        
        CIImage* rotatedImage = filter.outputImage;
        
        resultImage = [rotatedImage vComposeOverBackground:resultImage];

    }
    
    return resultImage;
}

@end
