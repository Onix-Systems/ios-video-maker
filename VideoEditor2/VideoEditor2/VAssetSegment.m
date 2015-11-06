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


@interface VAssetSegment()

@property (nonatomic, readwrite) CMTime totalDuration;
@property (nonatomic, readwrite) CMTime transitionFreeDuration;

@property (nonatomic, strong) VFrameProvider* assetFrameProvider;

@end

@implementation VAssetSegment

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.totalDuration = CMTimeMakeWithSeconds(0, 1000);
        self.transitionFreeDuration = self.totalDuration;
        self.cropTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1000), self.transitionFreeDuration);
    }
    return self;
}

-(void)setAsset:(VAsset *)asset
{
    _asset = asset;
    
    VEAspectFit* aspectFitFrameProvider = [VEAspectFit new];
    aspectFitFrameProvider.frameProvider = [self.asset getFrameProvider];
    
    self.assetFrameProvider = aspectFitFrameProvider;
    
}

-(BOOL) canCropToTimeRange: (CMTimeRange) timeRange
{
    return false;
}


-(CIImage*) getFrameForTime: (CMTime) time frameSize: (CGSize) frameSize;
{
    VFrameRequest* frameRequest = [VFrameRequest new];
    
    frameRequest.time = CMTimeGetSeconds(time);
    frameRequest.frameSize = frameSize;
    frameRequest.videoCompositionRequest = nil;
    
    return [self.assetFrameProvider getFrameForRequest:frameRequest];
}

-(void) calculateTiming
{
    double totalDuration = self.asset.duration;
    
    if (totalDuration == 0 && !self.asset.isVideo) {
        totalDuration = 2.0;
    }
    
    self.totalDuration = CMTimeMakeWithSeconds(totalDuration, 1000);
    
    self.transitionFreeDuration = self.totalDuration;
    
    if (self.frontTransition != nil) {
        self.transitionFreeDuration = CMTimeSubtract(self.transitionFreeDuration, CMTimeMakeWithSeconds([self.frontTransition getContent2AppearanceDuration], 1000));
    }
    
    if (self.rearTransition != nil) {
        self.transitionFreeDuration = CMTimeSubtract(self.transitionFreeDuration, CMTimeMakeWithSeconds([self.rearTransition getContent1AppearanceDuration], 1000));
    }
    
    self.cropTimeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(0, 1000), self.transitionFreeDuration);
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
        
    if (self.asset.isVideo) {
        VCoreVideoFrameProvider* videoFrameProvider = (VCoreVideoFrameProvider*) [self.asset getFrameProvider];
        
        videoFrameProvider.activeTrackNo = trackNo;
    }

//        AVAssetTrack* audioTrack = [self.asset.downloadedAsset tracksWithMediaType:AVMediaTypeAudio][0];
//        AVMutableCompositionTrack *aTrack = [videoComposition getAudioTrackNo:trackNo];
//        [self insertTimeRange:trackTimeRange ofTrack:audioTrack atTime:timeRange.start intoTrack:aTrack];
    
    return self.assetFrameProvider;
}

-(BOOL)isStatic {
    return !self.asset.isVideo || self.asset.isStatic;
}

@end
