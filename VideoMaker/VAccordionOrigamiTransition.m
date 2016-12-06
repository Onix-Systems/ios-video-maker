//
//  VAccordionOrigamiTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VAccordionOrigamiTransition.h"

#define kTotalTransitionDutation 0.5
#define kSizeDecrease 0.35
#define kFadeOutPercent 0.85
#define kFoldingShift 0.35

@implementation VAccordionOrigamiTransition

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
    
    CGRect imageFrame1 = CGRectMake(0, 0, imageSize.width * 0.25, imageSize.height);
    CGRect imageFrame2 = CGRectMake(imageSize.width * 0.25, 0, imageSize.width * 0.25, imageSize.height);
    CGRect imageFrame3 = CGRectMake(imageSize.width * 0.5, 0, imageSize.width * 0.25, imageSize.height);
    CGRect imageFrame4 = CGRectMake(imageSize.width * 0.75, 0, imageSize.width * 0.25, imageSize.height);
    
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
    CIImage* oldImage3 = [oldImage vCrop:imageFrame3];
    CIImage* oldImage4 = [oldImage vCrop:imageFrame4];
    
    CIImage* nextImage = [self.content2 getFrameForRequest:request];
    nextImage = [nextImage vCrop:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    CIFilter* filter1 = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [filter1 setDefaults];
    [filter1 setValue:oldImage1 forKey:@"inputImage"];
    
    CIFilter* filter2 = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [filter2 setDefaults];
    [filter2 setValue:oldImage2 forKey:@"inputImage"];

    CIFilter* filter3 = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [filter3 setDefaults];
    [filter3 setValue:oldImage3 forKey:@"inputImage"];

    CIFilter* filter4 = [CIFilter filterWithName:@"CIPerspectiveTransform"];
    [filter4 setDefaults];
    [filter4 setValue:oldImage4 forKey:@"inputImage"];

    double oldImageWidth = imageSize.width * (1 - foldingPercent);
    double newImageWidth = imageSize.width * foldingPercent;
    
    double sizeDecrease = imageSize.height * foldingPercent * kSizeDecrease / 2;
    double foldingShift = (0.25 * oldImageWidth) * kFoldingShift;
    
    [filter1 setValue:[CIVector vectorWithX:newImageWidth + (0.0)  * oldImageWidth Y:0] forKey:@"inputBottomLeft"];
    [filter1 setValue:[CIVector vectorWithX:newImageWidth + (0.0)  * oldImageWidth Y:imageSize.height] forKey:@"inputTopLeft"];
    [filter1 setValue:[CIVector vectorWithX:newImageWidth + (0.25) * oldImageWidth - foldingShift Y:0 + sizeDecrease] forKey:@"inputBottomRight"];
    [filter1 setValue:[CIVector vectorWithX:newImageWidth + (0.25) * oldImageWidth - foldingShift Y:imageSize.height - sizeDecrease] forKey:@"inputTopRight"];
    
    [filter2 setValue:[CIVector vectorWithX:newImageWidth + (0.25) * oldImageWidth - foldingShift Y:0 + sizeDecrease] forKey:@"inputBottomLeft"];
    [filter2 setValue:[CIVector vectorWithX:newImageWidth + (0.25) * oldImageWidth - foldingShift Y:imageSize.height - sizeDecrease] forKey:@"inputTopLeft"];
    [filter2 setValue:[CIVector vectorWithX:newImageWidth + (0.50) * oldImageWidth Y:0] forKey:@"inputBottomRight"];
    [filter2 setValue:[CIVector vectorWithX:newImageWidth + (0.50) * oldImageWidth Y:imageSize.height] forKey:@"inputTopRight"];
    
    [filter3 setValue:[CIVector vectorWithX:newImageWidth + (0.50) * oldImageWidth Y:0] forKey:@"inputBottomLeft"];
    [filter3 setValue:[CIVector vectorWithX:newImageWidth + (0.50) * oldImageWidth Y:imageSize.height] forKey:@"inputTopLeft"];
    [filter3 setValue:[CIVector vectorWithX:newImageWidth + (0.75) * oldImageWidth - foldingShift Y:0 + sizeDecrease] forKey:@"inputBottomRight"];
    [filter3 setValue:[CIVector vectorWithX:newImageWidth + (0.75) * oldImageWidth - foldingShift Y:imageSize.height - sizeDecrease] forKey:@"inputTopRight"];
    
    [filter4 setValue:[CIVector vectorWithX:newImageWidth + (0.75) * oldImageWidth - foldingShift Y:0 + sizeDecrease] forKey:@"inputBottomLeft"];
    [filter4 setValue:[CIVector vectorWithX:newImageWidth + (0.75) * oldImageWidth - foldingShift Y:imageSize.height - sizeDecrease] forKey:@"inputTopLeft"];
    [filter4 setValue:[CIVector vectorWithX:newImageWidth + (1.00) * oldImageWidth Y:0] forKey:@"inputBottomRight"];
    [filter4 setValue:[CIVector vectorWithX:newImageWidth + (1.00) * oldImageWidth Y:imageSize.height] forKey:@"inputTopRight"];

    oldImage1 = filter1.outputImage;
    oldImage2 = filter2.outputImage;
    oldImage3 = filter3.outputImage;
    oldImage4 = filter4.outputImage;
    
    CIImage* resultImage = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];

    nextImage = [nextImage vShiftX:-1*imageSize.width + newImageWidth shiftY:0];
    
    resultImage = [nextImage vComposeOverBackground:resultImage];
    
    resultImage = [oldImage1 vComposeOverBackground:resultImage];
    resultImage = [oldImage2 vComposeOverBackground:resultImage];
    resultImage = [oldImage3 vComposeOverBackground:resultImage];
    resultImage = [oldImage4 vComposeOverBackground:resultImage];
    
    
    return resultImage;
}

@end
