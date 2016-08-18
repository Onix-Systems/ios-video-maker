//
//  VideoCompositionImageSegment.h
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VAssetSegment.h"
#import "VAsset.h"
#import "VTransition.h"

@interface VAssetSegment : NSObject

@property (weak, nonatomic) VAsset* asset;

@property (nonatomic) CGFloat timeScale;
@property (nonatomic) CMTimeRange cropTimeRange;

@property (nonatomic, readonly) CMTime totalDuration;
@property (nonatomic, readonly) CMTime transitionFreeDuration;

@property (nonatomic, weak) VTransition* frontTransition;
@property (nonatomic, weak) VTransition* rearTransition;

-(BOOL)isStatic;

-(BOOL) canCropToTimeRange: (CMTimeRange) timeRange;
-(CIImage*) getFrameForTime: (CMTime) time frameSize: (CGSize) frameSize;

-(void) calculateTiming;

-(VFrameProvider*) putFramePrividerIntoVideoComosition: (VideoComposition*)videoComposition withinTimeRange: (CMTimeRange) timeRange intoTrackNo: (NSInteger) trackNo;

-(void) resetSegmentState;
@end
