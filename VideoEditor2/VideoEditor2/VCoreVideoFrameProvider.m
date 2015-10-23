//
//  VCoreVideoPBImage.m
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCoreVideoFrameProvider.h"

@interface VCoreVideoFrameProvider ()

@property (nonatomic,strong) AVAssetTrack* videoTrack;

@property (nonatomic,strong) CIImage* image;
@property (nonatomic) CVPixelBufferRef pixelBuffer;
@property (nonatomic) CGSize lastPixelBufferSize;

@end

@implementation VCoreVideoFrameProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.image = nil;
        self.pixelBuffer = nil;
        self.activeTrackNo = -1;
    }
    return self;
}

-(void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    
    self.videoDuration = CMTimeGetSeconds(asset.duration);
    
    self.videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    
    self.videoSize = self.videoTrack.naturalSize;
}

-(CGSize) getOriginalSize
{
    return self.videoSize;
}

-(double) getDuration
{
    return self.videoDuration;
}

-(void)setPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (self.pixelBuffer != nil) {
        [self releasePixelBuffer];
    }
    
    //_pixelBuffer = CVPixelBufferRetain(pixelBuffer);
    self.image = [CIImage imageWithCVPixelBuffer: pixelBuffer];

}

-(void) releasePixelBuffer
{
    if (self.pixelBuffer != nil) {
        //CVPixelBufferRelease(self.pixelBuffer);
        _pixelBuffer = nil;
    }
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    [self setPixelBuffer:[request.videoCompositionRequest sourceFrameByTrackID:self.registeredTrackID]];
    
    [request addCompletionBlock:^{
        [self releasePixelBuffer];
    }];
    
    return self.image;
}

-(void)reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    AVMutableCompositionTrack* destinationTrack = nil;
    
    if (self.activeTrackNo > 0) {
        destinationTrack = [videoComposition getVideoTrackNo:self.activeTrackNo];
    } else {
        destinationTrack = [videoComposition getFreeVideoTrack];
    }

    self.registeredTrackID = destinationTrack.trackID;

    AVAssetTrack* sourceTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
    CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, instruction.timeRange.duration);
    
    NSError *error = nil;
    [destinationTrack insertTimeRange:trackTimeRange ofTrack:sourceTrack atTime:instruction.timeRange.start error:&error];
    if (error != nil) {
        NSLog(@"Can not insert track timerange (%@) into track (%@) - %@", sourceTrack, destinationTrack, error);
    }
    
    [instruction registerTrackIDAsInputFrameProvider: self.registeredTrackID];
}

@end
