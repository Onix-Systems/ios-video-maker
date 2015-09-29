//
//  VideoCompositionImageSegment.h
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VCompositionSegment.h"
#import "VTransitionSegment.h"
#import "VAsset.h"

@interface VAssetSegment : VCompositionSegment

@property (weak, nonatomic) VAsset* asset;

@property (weak, nonatomic) VTransitionSegment* frontTransition;
@property (weak, nonatomic) VTransitionSegment* rearTransition;

@property (nonatomic) CGFloat timeScale;
@property (nonatomic) CMTimeRange cropTimeRange;

-(BOOL) canCropToTimeRange: (CMTimeRange) timeRange;
-(void) getFrameForTime: (CMTime) time withCompletionBlock: (void(^)(UIImage* image)) completionBlock;

-(void) putIntoVideoComosition: (VideoComposition*)videoComposition withinTimeRange: (CMTimeRange) timeRange intoTrackNo: (NSInteger) trackNo;;

@end
