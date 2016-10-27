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
@property (nonatomic,strong) AVAssetTrack* audioTrack;

@property (nonatomic,strong) CIImage* image;
@property (nonatomic) CGSize lastPixelBufferSize;
@property (nonatomic) CGAffineTransform preferredTransform;

@property (nonatomic, strong) AVAssetImageGenerator* imageGenerator;

@end

@implementation VCoreVideoFrameProvider

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.image = nil;
        self.activeTrackNo = -1;
        self.isStatic = NO;
    }
    return self;
}

-(void)setAsset:(AVAsset *)asset
{
    _asset = asset;
    
    self.videoDuration = CMTimeGetSeconds(asset.duration);
    
    if ([asset tracksWithMediaType:AVMediaTypeVideo] &&
        [asset tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        self.videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }

    if ([asset tracksWithMediaType:AVMediaTypeAudio] &&
        [asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        self.audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    
    self.videoSize = self.videoTrack.naturalSize;
    
    self.preferredTransform = self.videoTrack.preferredTransform;
    
    if (self.preferredTransform.a == 0 && self.preferredTransform.d == 0) {
        
        self.preferredTransform = CGAffineTransformMake(0, self.preferredTransform.b * -1, self.preferredTransform.c * -1, 0, self.videoSize.height - self.preferredTransform.tx, self.videoSize.width - self.preferredTransform.ty);
        
        self.videoSize = CGSizeMake(self.videoSize.height, self.videoSize.width);
    }
    
    self.imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];

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
    self.image = nil;
    if (pixelBuffer != nil) {
        CIImage* img  = [CIImage imageWithCVPixelBuffer: pixelBuffer];
        if (img != nil) {
            self.image = [img imageByApplyingTransform:self.preferredTransform];
        } else {
            NSLog(@"ERROR - Can't create image from pixelBuffer = \n%@", pixelBuffer);
        }
    } else {
        NSLog(@"ERROR - empty pixelBuffer = \n%@", pixelBuffer);
    }
}

-(CIImage*) getFrameForRequest:(VFrameRequest *)request
{
    if (request.videoCompositionRequest != nil) {
        [self setPixelBuffer:[request.videoCompositionRequest sourceFrameByTrackID:self.registeredTrackID]];
        return self.image;
    } else {
        CMTime actualTime;
        NSError *error;
        
        CGImageRef image = [self.imageGenerator copyCGImageAtTime:CMTimeMake(request.time, 1) actualTime:&actualTime error:&error];
        return [CIImage imageWithCGImage:image];
    }
}

-(void)reqisterIntoVideoComposition:(VideoComposition *)videoComposition withInstruction:(VCompositionInstruction *)instruction withFinalSize:(CGSize)finalSize
{
    AVMutableCompositionTrack* destinationTrack = nil;
    AVMutableCompositionTrack* destinationAudioTrack = nil;
    
    if (self.activeTrackNo > 0) {
        destinationTrack = [videoComposition getVideoTrackNo:self.activeTrackNo];
        destinationAudioTrack = [videoComposition getAudioTrackNo:self.activeTrackNo];
    } else {
        destinationTrack = [videoComposition getFreeVideoTrack];
        destinationAudioTrack = [videoComposition getFreeAudioTrack];
    }

    self.registeredTrackID = destinationTrack.trackID;

    CMTimeRange trackTimeRange = CMTimeRangeMake(kCMTimeZero, instruction.segmentTimeRange.duration);
    NSError *error = nil;
    
    if ([self.asset tracksWithMediaType:AVMediaTypeVideo] &&
        [self.asset tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        AVAssetTrack* sourceTrack = [self.asset tracksWithMediaType:AVMediaTypeVideo][0];
        
        [destinationTrack insertTimeRange:trackTimeRange ofTrack:sourceTrack atTime:instruction.segmentTimeRange.start error:&error];
        if (error != nil) {
            NSLog(@"Can not insert track timerange (%@) into track (%@) - %@", sourceTrack, destinationTrack, error);
        }
    }
    
    if ([self.asset tracksWithMediaType:AVMediaTypeAudio] &&
        [self.asset tracksWithMediaType:AVMediaTypeAudio].count > 0) {
        AVAssetTrack* audioTrack = [self.asset tracksWithMediaType:AVMediaTypeAudio][0];
        [destinationAudioTrack insertTimeRange:trackTimeRange ofTrack:audioTrack atTime:instruction.segmentTimeRange.start error:&error];
        if (error != nil) {
            NSLog(@"Can not insert audio track timerange (%@) into track (%@) - %@", audioTrack, destinationAudioTrack, error);
        }
        
        AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
        [videoComposition appendAudioMixInputParameters:exportAudioMixInputParameters];
    }

    [instruction registerTrackIDAsInputFrameProvider: self.registeredTrackID];
}

@end
