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
#import "VEStillImage.h"

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

-(void) insertTimeRange:(CMTimeRange)timeRange ofTrack:(AVAssetTrack *) sourceTrack atTime:(CMTime) atTime intoTrack: (AVMutableCompositionTrack*) destinationTrack
{
    NSError *error = nil;
    
    [destinationTrack insertTimeRange:timeRange ofTrack:sourceTrack atTime:atTime error:&error];
    
    if (error != nil) {
        NSLog(@"Can not insert track timerange (%@) into track (%@) - %@", sourceTrack, destinationTrack, error);
    }

}

-(void) putIntoVideoComosition: (VideoComposition*)videoComposition withinTimeRange: (CMTimeRange) timeRange intoTrackNo: (NSInteger) trackNo
{
    CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration);
    
    AVMutableCompositionTrack *destinationTrack = [videoComposition getVideoTrackNo:trackNo];
    AVAssetTrack* videoTrack;
    
    if (self.asset.isVideo) {
        videoTrack = [self.asset.downloadedAsset tracksWithMediaType:AVMediaTypeVideo][0];
    } else {
        videoTrack = [videoComposition getPlaceholderVideoTrack];
    }
    
    [self insertTimeRange:trackTimeRange ofTrack:videoTrack atTime:timeRange.start intoTrack:destinationTrack];

    VEAspectFit* aspectFitEffect = [VEAspectFit new];
    VCompositionInstruction *instruction = [[VCompositionInstruction alloc] initWithFrameProvider:aspectFitEffect];
    instruction.timeRange = timeRange;
    instruction.containsTweening = self.asset.isVideo || !self.asset.isStatic;

    VEffect* assetFrameProvider = [self.asset createFrameProviderForVideoComposition:videoComposition wihtInstruction:instruction activeTrackNo:trackNo];
    if (assetFrameProvider != nil) {
        [aspectFitEffect setInputFrameProvider:assetFrameProvider forInputFrameNum:0];
    }
    
    [videoComposition appendVideoCompositionInstruction:instruction];

//        AVAssetTrack* audioTrack = [self.asset.downloadedAsset tracksWithMediaType:AVMediaTypeAudio][0];
//        AVMutableCompositionTrack *aTrack = [videoComposition getAudioTrackNo:trackNo];
//        [self insertTimeRange:trackTimeRange ofTrack:audioTrack atTime:timeRange.start intoTrack:aTrack];
}

@end
