//
//  VCompositionInstruction.m
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCompositionInstruction.h"
#import "VEStillImage.h"

@interface VCompositionInstruction ()

@property (strong, nonatomic) VEffect* frameProvider;
@property (strong, nonatomic) NSMutableArray* stillImages;
@property (strong, nonatomic) NSMutableArray* registeredTrackIDs;

@end

@implementation VCompositionInstruction

- (instancetype)initWithFrameProvider: (VEffect*) frameProvider
{
    self = [super init];
    if (self) {
        self.enablePostProcessing = YES;
        self.containsTweening = NO;
        self.requiredSourceTrackIDs = nil;
        self.passthroughTrackID = kCMPersistentTrackID_Invalid;
        
        self.frameProvider = frameProvider;
        
        self.registeredTrackIDs = [NSMutableArray arrayWithCapacity:[self.frameProvider getNumberOfInputFrames]];
        
        self.stillImages = [NSMutableArray arrayWithCapacity:[self.frameProvider getNumberOfInputFrames]];
        
        for (int i = 0; i < [self.frameProvider getNumberOfInputFrames]; i++) {
            [self.registeredTrackIDs addObject:
            [NSNumber numberWithInt:kCMPersistentTrackID_Invalid]];
            
            [self.stillImages addObject: [NSNull null]];
        }
    }
    return self;
}

-(void) registerTrackID: (CMPersistentTrackID) trackID asInputFrameProvider: (NSInteger) inputFrameNumber
{
    self.registeredTrackIDs[inputFrameNumber] = [NSNumber numberWithInt:trackID];
    self.stillImages[inputFrameNumber] = [VEStillImage new];
}

-(void)setRequiredSourceTrackIDs:(NSArray<NSValue *> *)requiredSourceTrackIDs
{
    //the operation is not valid - do nothing; use registerTrackID: asInputFrameProvider:
}

-(NSArray<NSValue*>*)requiredSourceTrackIDs
{
    NSMutableArray* requiredSourceTrackIDs = [NSMutableArray new];
    
    for (NSNumber* number in self.registeredTrackIDs) {
        if ([number intValue] != kCMPersistentTrackID_Invalid) {
            [requiredSourceTrackIDs addObject:number];
        }
    }
    
    return requiredSourceTrackIDs;
}

-(void) processRequest:(AVAsynchronousVideoCompositionRequest *)request usingCIContext:(CIContext *)ciContext
{
    CVPixelBufferRef newFrameBuffer = request.renderContext.newPixelBuffer;
    self.frameProvider.finalSize = CGSizeMake(CVPixelBufferGetWidth(newFrameBuffer), CVPixelBufferGetHeight(newFrameBuffer));
    
    for (int i = 0; i < [self.frameProvider getNumberOfInputFrames]; i++) {
        NSNumber *number = self.registeredTrackIDs[i];
        CMPersistentTrackID trackID = number.intValue;
        
        if (trackID != kCMPersistentTrackID_Invalid && self.stillImages[i] != [NSNull null]) {
            VEStillImage* stillImage = self.stillImages[i];

            [stillImage setPixelBuffer: [request sourceFrameByTrackID: trackID]];
            [self.frameProvider setInputFrameProvider:stillImage forInputFrameNum:i];
        }
    }

    double requestTime = (CMTimeGetSeconds(request.compositionTime) - CMTimeGetSeconds(self.timeRange.start)) / CMTimeGetSeconds(self.timeRange.duration);
    
    CIImage* newFrameImage = [self.frameProvider getFrameForTime:requestTime];
    [ciContext render:newFrameImage toCVPixelBuffer:newFrameBuffer];
    
    [request finishWithComposedVideoFrame: newFrameBuffer];
    
    for (int i = 0; i < [self.frameProvider getNumberOfInputFrames]; i++) {
        NSNumber *number = self.registeredTrackIDs[i];
        CMPersistentTrackID trackID = (CMPersistentTrackID)number.longValue;
        
        if (trackID != kCMPersistentTrackID_Invalid && self.stillImages[i] != [NSNull null]) {
            VEStillImage* stillImage = self.stillImages[i];
            
            [stillImage releasePixelBuffer];
        }
    }
    CVPixelBufferRelease(newFrameBuffer);
    
}





@end
