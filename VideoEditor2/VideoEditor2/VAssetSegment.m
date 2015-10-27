//
//  VideoCompositionImageSegment.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VAssetSegment.h"
#import "VCompositionInstruction.h"
#import "VEAspectFit.h"
#import "VStillImage.h"
#import "VCoreVideoFrameProvider.h"

@implementation VAssetSegment

-(BOOL) canCropToTimeRange: (CMTimeRange) timeRange
{
    return false;
}

-(void) getFrameForTime: (CMTime) time withCompletionBlock: (void(^)(UIImage* image)) completionBlock
{
    
}

-(CMTime) duration
{
    double duration = self.asset.duration;
    
    if (duration == 0 && !self.asset.isVideo) {
        duration = 2.0;
    }
    
    return CMTimeMakeWithSeconds(duration, 1000);
}

-(VFrameProvider*) putFramePrividerIntoVideoComosition: (VideoComposition*)videoComposition withinTimeRange: (CMTimeRange) timeRange intoTrackNo: (NSInteger) trackNo
{
    if (!self.asset.isVideo) {
        AVAssetTrack* sourceTrack = [videoComposition getPlaceholderVideoTrack];
        AVMutableCompositionTrack *destinationTrack = [videoComposition getVideoTrackNo:trackNo];
        CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration);
        
        NSError *error = nil;
        [destinationTrack insertTimeRange:trackTimeRange ofTrack:sourceTrack atTime:timeRange.start error:&error];
        if (error != nil) {
            NSLog(@"Can not insert track timerange (%@) into track (%@) - %@", sourceTrack, destinationTrack, error);
        }
    }
    
    VEAspectFit* aspectFitEffect = [VEAspectFit new];
    aspectFitEffect.frameProvider = [self.asset getFrameProvider];
        
    if (self.asset.isVideo) {
        VCoreVideoFrameProvider* videoFrameProvider = (VCoreVideoFrameProvider*) aspectFitEffect.frameProvider;
        
        videoFrameProvider.activeTrackNo = trackNo;
    }

//        AVAssetTrack* audioTrack = [self.asset.downloadedAsset tracksWithMediaType:AVMediaTypeAudio][0];
//        AVMutableCompositionTrack *aTrack = [videoComposition getAudioTrackNo:trackNo];
//        [self insertTimeRange:trackTimeRange ofTrack:audioTrack atTime:timeRange.start intoTrack:aTrack];
    
    return aspectFitEffect;
}

-(BOOL)isStatic {
    return !self.asset.isVideo || self.asset.isStatic;
}

@end
