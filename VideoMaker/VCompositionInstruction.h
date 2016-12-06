//
//  VCompositionInstruction.h
//  VideoEditor2
//
//  Created by Alexander on 9/25/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol VFPSTracker

-(void)trackFrameRenderingDuration: (double)duration;

@end

@class VFrameProvider;

@interface VCompositionInstruction : NSObject <AVVideoCompositionInstruction>

@property (nonatomic) CMTimeRange timeRange;
@property (nonatomic) BOOL enablePostProcessing;
@property (nonatomic) BOOL containsTweening;
@property (nonatomic) NSArray<NSValue *> *requiredSourceTrackIDs;
@property (nonatomic) CMPersistentTrackID passthroughTrackID; // kCMPersistentTrackID_Invalid if not a passthrough instruction

@property (strong, nonatomic) VFrameProvider* frameProvider;
@property (nonatomic) CMTimeRange segmentTimeRange;

@property (weak, nonatomic) id<VFPSTracker> fpsTracker;

- (instancetype)initWithFrameProvider: (VFrameProvider*) frameProvider;

-(void) processRequest: (AVAsynchronousVideoCompositionRequest*) request usingCIContext: (CIContext*) ciContext;

-(void) registerTrackIDAsInputFrameProvider: (CMPersistentTrackID) trackID;

@end
