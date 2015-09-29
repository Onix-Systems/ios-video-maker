//
//  VideoCompositionImageSegment.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VAssetSegment.h"
#import "VInstructionStillImage.h"
#import "VInstrucionPassthrough.h"

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
        NSLog(@"Can not insert track timarange (%@) into track (%@) - %@", sourceTrack, destinationTrack, error);
    }

}

-(void) putIntoVideoComosition: (VideoComposition*)videoComposition withinTimeRange: (CMTimeRange) timeRange intoTrackNo: (NSInteger) trackNo
{
    if (self.asset.isVideo) {
        CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration);
        
        AVAssetTrack* videoTrack = [self.asset.downloadedAsset tracksWithMediaType:AVMediaTypeVideo][0];
        AVMutableCompositionTrack *vTrack = [videoComposition getVideoTrackNo:trackNo];
        [self insertTimeRange:trackTimeRange ofTrack:videoTrack atTime:timeRange.start intoTrack:vTrack];
        
//        AVAssetTrack* audioTrack = [self.asset.downloadedAsset tracksWithMediaType:AVMediaTypeAudio][0];
//        AVMutableCompositionTrack *aTrack = [videoComposition getAudioTrackNo:trackNo];
//        [self insertTimeRange:trackTimeRange ofTrack:audioTrack atTime:timeRange.start intoTrack:aTrack];
        
        VInstrucionPassthrough *instruction = [VInstrucionPassthrough new];
        instruction.timeRange = timeRange;
        instruction.sourceTrackID = vTrack.trackID;
        
        [videoComposition appendVideoCompositionInstruction:instruction];

    } else {
        AVAssetTrack* placeholderVideoTrack = [videoComposition getPlaceholderVideoTrack];
        AVMutableCompositionTrack *destinationTrack = [videoComposition getVideoTrackNo:trackNo];
        
        [self insertTimeRange:CMTimeRangeMake(kCMTimeZero, timeRange.duration) ofTrack:placeholderVideoTrack atTime:timeRange.start intoTrack:destinationTrack];
        
        VInstructionStillImage* instruction = [VInstructionStillImage new];
        instruction.timeRange = timeRange;
        instruction.image = [CIImage imageWithCGImage:[self.asset.downloadedImage CGImage]];
        
        [videoComposition appendVideoCompositionInstruction:instruction];
    }
}

@end
