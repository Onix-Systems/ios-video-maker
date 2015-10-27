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
@property (nonatomic, readonly) CMTime duration;

-(BOOL)isStatic;

-(BOOL) canCropToTimeRange: (CMTimeRange) timeRange;
-(void) getFrameForTime: (CMTime) time withCompletionBlock: (void(^)(UIImage* image)) completionBlock;

-(VFrameProvider*) putFramePrividerIntoVideoComosition: (VideoComposition*)videoComposition withinTimeRange: (CMTimeRange) timeRange intoTrackNo: (NSInteger) trackNo;

@end
