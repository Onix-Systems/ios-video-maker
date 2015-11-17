//
//  VTwistingOrigamiTransition.m
//  VideoEditor2
//
//  Created by Alexander on 10/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VTwistingOrigamiTransition.h"

#define kTotalTransitionDutation 0.7
#define kSizeIncrease 0.20
#define kFadeOutPercent 1.05

#define kMovingUp 0
#define kMovingRight 1
//#define kMovingDown 2
//#define kMovingLeft 3


@interface VTwistingOrigamiTransition ()

@property (nonatomic) NSInteger movingDirection;
@property (nonatomic) NSInteger numberOfRotations;

@end

@implementation VTwistingOrigamiTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.movingDirection = arc4random_uniform(2);
        self.numberOfRotations = 3 + arc4random_uniform(2);
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

    double content1Time = [self.content1 getDuration] - [self getContent1AppearanceDuration] + request.time;
    VFrameRequest* content1FrameRequest = [request cloneWithDifferentTimeValue:content1Time];
    CIImage* oldImage = [self.content1 getFrameForRequest:content1FrameRequest];

    CIImage* nextImage = [self.content2 getFrameForRequest:request];
    CIImage* resultImage = [nextImage vCrop:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    
    double movingPercent = request.time / [self getDuration];

    NSInteger numberOfRotationPhases = (self.numberOfRotations * 2) - 1;
    double phaseLength = 1.0 / numberOfRotationPhases;
    int phaseNumber = ceil(movingPercent / phaseLength);
    int roundNumber = ceil(phaseNumber/2.0);
    int rotatingPartNumber = 1;
    if(roundNumber >=2) {
        rotatingPartNumber = phaseNumber % 2 > 0 ? roundNumber - 1 : roundNumber;
    }
    double rotationPhasePercent = (movingPercent - phaseLength * (phaseNumber - 1)) / phaseLength;

    double rotatingPartHeight = imageSize.height / self.numberOfRotations;
    double rotatingPartWidth = imageSize.width / self.numberOfRotations;
    
    CIImage* partOfOldImage = nil;
    
    double fadeoutPercent = (phaseNumber % 2 > 0 ? rotationPhasePercent : 1-rotationPhasePercent)*kFadeOutPercent;
    CIFilter *fadeOutFilter = [CIFilter filterWithName:@"CIDissolveTransition"];
    [fadeOutFilter setDefaults];
    [fadeOutFilter setValue:oldImage forKey:@"inputImage"];
    [fadeOutFilter setValue:[CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]] forKey:@"inputTargetImage"];
    [fadeOutFilter setValue:[NSNumber numberWithDouble:fadeoutPercent] forKey:@"inputTime"];
    CIImage* rotatingPart = fadeOutFilter.outputImage;
    
    if(self.movingDirection == kMovingUp) {
        
        partOfOldImage = [oldImage vCrop:CGRectMake(0, (imageSize.height/self.numberOfRotations)*roundNumber, imageSize.width, imageSize.height)];
        
        CGRect rotatingPartRect = CGRectMake(0, (rotatingPartNumber - 1)*rotatingPartHeight, imageSize.width, rotatingPartHeight);
        rotatingPart = [rotatingPart vCrop:rotatingPartRect];
        
        CIFilter* filter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
        [filter setDefaults];
        [filter setValue:rotatingPart forKey:@"inputImage"];
        
        if (phaseNumber % 2 == 1) {
            double topY = rotatingPartHeight * roundNumber;
            double sizeIncrease = imageSize.width * kSizeIncrease * rotationPhasePercent;
            
            if (phaseNumber == 1) {
                [filter setValue:[CIVector vectorWithX:0 Y:topY] forKey:@"inputTopLeft"];
                [filter setValue:[CIVector vectorWithX:imageSize.width Y:topY] forKey:@"inputTopRight"];
                
                [filter setValue:[CIVector vectorWithX:0-sizeIncrease Y:topY - (1-rotationPhasePercent)*rotatingPartHeight] forKey:@"inputBottomLeft"];
                [filter setValue:[CIVector vectorWithX:imageSize.width+sizeIncrease Y:topY - (1-rotationPhasePercent)*rotatingPartHeight] forKey:@"inputBottomRight"];
                rotatingPart = filter.outputImage;
                
                rotatingPart = [rotatingPart vCrop:CGRectMake(0, 0, imageSize.width, topY)];
                
            } else {
                [filter setValue:[CIVector vectorWithX:0-sizeIncrease Y:topY - (1-rotationPhasePercent)*rotatingPartHeight] forKey:@"inputTopLeft"];
                [filter setValue:[CIVector vectorWithX:imageSize.width+sizeIncrease Y:topY - (1-rotationPhasePercent)*rotatingPartHeight] forKey:@"inputTopRight"];
                
                [filter setValue:[CIVector vectorWithX:0 Y:topY] forKey:@"inputBottomLeft"];
                [filter setValue:[CIVector vectorWithX:imageSize.width Y:topY] forKey:@"inputBottomRight"];
                rotatingPart = filter.outputImage;
                
                rotatingPart = [rotatingPart vCrop:CGRectMake(0, 0, imageSize.width, topY)];
                
            }
        } else {
            
            double topY = rotatingPartHeight * roundNumber;
            double sizeIncrease = imageSize.width * kSizeIncrease * (1 - rotationPhasePercent) / 2;
            
            [filter setValue:[CIVector vectorWithX:0 Y:topY] forKey:@"inputTopLeft"];
            [filter setValue:[CIVector vectorWithX:imageSize.width Y:topY] forKey:@"inputTopRight"];
            
            [filter setValue:[CIVector vectorWithX:0-sizeIncrease Y:topY + rotationPhasePercent*rotatingPartHeight] forKey:@"inputBottomLeft"];
            [filter setValue:[CIVector vectorWithX:imageSize.width+sizeIncrease Y:topY + rotationPhasePercent*rotatingPartHeight] forKey:@"inputBottomRight"];
            rotatingPart = filter.outputImage;
            
        }
        
    } else if (self.movingDirection == kMovingRight) {
        partOfOldImage = [oldImage vCrop:CGRectMake(0, 0, imageSize.width - (imageSize.width/self.numberOfRotations)*roundNumber, imageSize.height)];
        
        CGRect rotatingPartRect = CGRectMake(imageSize.width - (rotatingPartNumber)*rotatingPartWidth, 0, rotatingPartWidth, imageSize.height);
        rotatingPart = [rotatingPart vCrop:rotatingPartRect];
        
        CIFilter* filter = [CIFilter filterWithName:@"CIPerspectiveTransform"];
        [filter setDefaults];
        [filter setValue:rotatingPart forKey:@"inputImage"];
        
        if (phaseNumber % 2 == 1) {
            double leftX = imageSize.width - rotatingPartWidth * roundNumber;
            double sizeIncrease = imageSize.height * kSizeIncrease * rotationPhasePercent;
            
            if (phaseNumber == 1) {
                [filter setValue:[CIVector vectorWithX:leftX Y:0] forKey:@"inputBottomLeft"];
                [filter setValue:[CIVector vectorWithX:leftX Y:imageSize.height] forKey:@"inputTopLeft"];
                
                [filter setValue:[CIVector vectorWithX:leftX + (1 - rotationPhasePercent)*rotatingPartWidth Y:0-sizeIncrease] forKey:@"inputBottomRight"];
                [filter setValue:[CIVector vectorWithX:leftX + (1 - rotationPhasePercent)*rotatingPartWidth Y:imageSize.height+sizeIncrease] forKey:@"inputTopRight"];
                
            } else {
                [filter setValue:[CIVector vectorWithX:leftX + (1 - rotationPhasePercent)*rotatingPartWidth Y:0-sizeIncrease] forKey:@"inputBottomLeft"];
                [filter setValue:[CIVector vectorWithX:leftX + (1 - rotationPhasePercent)*rotatingPartWidth Y:imageSize.height+sizeIncrease] forKey:@"inputTopLeft"];
                
                [filter setValue:[CIVector vectorWithX:leftX Y:0] forKey:@"inputBottomRight"];
                [filter setValue:[CIVector vectorWithX:leftX Y:imageSize.height] forKey:@"inputTopRight"];
                
            }
        } else {
            double leftX = imageSize.width - rotatingPartWidth * roundNumber;
            double sizeIncrease = imageSize.height * kSizeIncrease * (1 - rotationPhasePercent);
            
            [filter setValue:[CIVector vectorWithX:leftX Y:0] forKey:@"inputBottomLeft"];
            [filter setValue:[CIVector vectorWithX:leftX Y:imageSize.height] forKey:@"inputTopLeft"];
            
            [filter setValue:[CIVector vectorWithX:leftX - rotationPhasePercent*rotatingPartWidth Y:0-sizeIncrease] forKey:@"inputBottomRight"];
            [filter setValue:[CIVector vectorWithX:leftX - rotationPhasePercent*rotatingPartWidth Y:imageSize.height+sizeIncrease] forKey:@"inputTopRight"];
            
        }
        rotatingPart = filter.outputImage;
    }
    
    resultImage = [partOfOldImage vComposeOverBackground:resultImage];
    
    resultImage = [rotatingPart vComposeOverBackground:resultImage];
    
    return resultImage;
}

@end
