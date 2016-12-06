//
//  VCompositionInstruction.m
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCompositionInstruction.h"
#import "VStillImage.h"
#import <UIKit/UIKit.h>

@interface VCompositionInstruction ()

@property (strong, nonatomic) NSMutableArray* registeredTrackIDs;

@end

@implementation VCompositionInstruction

- (instancetype)initWithFrameProvider: (VFrameProvider*) frameProvider
{
    self = [super init];
    if (self) {
        self.enablePostProcessing = YES;
        self.containsTweening = NO;
        self.requiredSourceTrackIDs = nil;
        self.passthroughTrackID = kCMPersistentTrackID_Invalid;
        
        self.frameProvider = frameProvider;
        
        self.registeredTrackIDs = [NSMutableArray new];
    }
    return self;
}

-(void) registerTrackIDAsInputFrameProvider: (CMPersistentTrackID) trackID
{
    [self.registeredTrackIDs addObject: [NSNumber numberWithInt:trackID]];
}

-(void)setRequiredSourceTrackIDs:(NSArray<NSValue *> *)requiredSourceTrackIDs
{
    //the operation is not valid - do nothing; use registerTrackIDAsInputFrameProvider:
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
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    CVPixelBufferRef newFrameBuffer = [[request renderContext] newPixelBuffer];
    
    VFrameRequest* frameRequest = [VFrameRequest new];
    frameRequest.videoCompositionRequest = request;
    frameRequest.time = CMTimeGetSeconds(request.compositionTime) - CMTimeGetSeconds(self.segmentTimeRange.start);
    
    CIImage* frameContent = [self.frameProvider getFrameForRequest:frameRequest];

    CIImage* frameBackground = [CIImage imageWithColor:[CIColor colorWithRed:0x00 green:0x00 blue:0x00]];
    CIImage* newFrameImage = [frameContent vComposeOverBackground:frameBackground];
    
    [ciContext render:newFrameImage toCVPixelBuffer:newFrameBuffer];
    [request finishWithComposedVideoFrame: newFrameBuffer];
    
    [frameRequest markRequestAsFinished];
    
    CVPixelBufferRelease(newFrameBuffer);
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    double duration = (endTime - startTime)*1000;
    
    if (self.fpsTracker != nil) {
        [self.fpsTracker trackFrameRenderingDuration:duration];
    }
}





@end
