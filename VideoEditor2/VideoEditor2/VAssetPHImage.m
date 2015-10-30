//
//  VAssetPHImage.m
//  VideoEditor2
//
//  Created by Alexander on 9/18/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VAssetPHImage.h"
#import "VStillImage.h"
#import "VCoreVideoFrameProvider.h"

@interface VAssetPHImage ()

@property (nonatomic, strong) PHAsset* asset;

@property (readwrite) double downloadPercent;

@property (nonatomic) PHImageRequestID lastRequestID;

@property (strong,nonatomic) VStillImage* imageFrameProvider;
@property (strong,nonatomic) VCoreVideoFrameProvider* videoFrameProvider;

@end

@implementation VAssetPHImage

+(VAsset*) makeFromPHAsset: (PHAsset *) asset
{
    VAssetPHImage* newAsset = [VAssetPHImage new];
    newAsset.asset = asset;
    return (VAsset*) newAsset;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadPercent = 0;
        
        self.downloadedImage = nil;
        self.downloadedAsset = nil;
        self.downloadedAudioMix = nil;
        
        self.lastRequestID = PHInvalidImageRequestID;
    }
    return self;
}

- (BOOL) isVideo
{
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        return YES;
    }
    return NO;
}

-(BOOL) isStatic
{
    return YES;
}

- (double) duration
{
    return self.asset.duration;
}

- (NSString*) getIdentifier
{
    return self.asset.localIdentifier;
}

-(void) getThumbnailImageImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    [self createImageLoadRequest:size trackProgress:^(double progress) {
        //do nothing
    } withCompletion:^(UIImage *resultImage, BOOL requestFinished) {
        if (requestFinished || ![self isVideo]) {
            downloadCompletionBlock(resultImage, requestFinished);
        }
    }];
}

-(void) downloadWithCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    if ([self isDownloading]) {
        return;
    }
    
    if ([self isVideo]) {
        if (self.downloadedAsset != nil) {
            downloadCompletionBlock(nil, true);
            return;
        }
        [self downloadVideoAsset:^(AVAsset *asset, AVAudioMix* audioMix) {
            self.downloadedAsset = asset;
            self.downloadedAudioMix = audioMix;
            downloadCompletionBlock(nil, true);
        }];

    } else {
        if (self.downloadedImage != nil) {
            downloadCompletionBlock(self.downloadedImage, true);
            return;
        }
        
        [self getPreviewImageForSize:PHImageManagerMaximumSize withCompletion:^(UIImage *resultImage, BOOL requestFinished) {
            if (requestFinished) {
                self.downloadedImage = resultImage;
            }
            downloadCompletionBlock(resultImage, requestFinished);
        }];
    }
}

-(double) getDownloadPercent
{
    return self.downloadPercent;
}

-(void) getPreviewImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    if ([self isDownloading]) {
        return;
    }
    
    if ((![self isVideo]) && (self.downloadedImage != nil)) {
        downloadCompletionBlock(self.downloadedImage, YES);
        return;
    }
    
    self.downloadPercent = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
    
    self.lastRequestID = [self createImageLoadRequest:size trackProgress:^(double progress) {
        NSLog(@"Asset(%@) getPreviewImageForSize(%f, %f) trackProgress; self.downloadPercent=%f; progress=%f", self, size.width, size.height, self.downloadPercent, progress);
        
        self.downloadPercent = progress;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
        
    } withCompletion:^(UIImage *resultImage, BOOL requestFinished) {
        NSLog(@"Asset(%@) getPreviewImageForSize(%f, %f) withCompletion; self.downloadPercent=%f; requestFinished=%@, resultImage=%@", self, size.width, size.height, self.downloadPercent, (requestFinished ? @"Y" : @"N"), resultImage);
        
        if (requestFinished) {
            self.lastRequestID = PHInvalidImageRequestID;
            
            if (self.downloadPercent < 1) {
                self.downloadPercent = 1;
                [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
            }
        }
        downloadCompletionBlock(resultImage, requestFinished);
    }];
}

-(PHImageRequestID)createImageLoadRequest: (CGSize) size trackProgress: (void(^)(double progress)) trackProgress withCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    PHImageRequestOptions* options = [PHImageRequestOptions new];
    
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.networkAccessAllowed = YES;
    options.synchronous = NO;
    
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        trackProgress(progress);
    };
    
    PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        
        BOOL requestFinished = YES;
        if (result == nil) {
            requestFinished = NO;
            
            if (info[PHImageErrorKey] != nil) {
                //there is some error
                [self cancelDownloading];
            }
        }
        
        if(info[PHImageResultIsDegradedKey] != nil) {
            NSNumber* isDegraded = info[PHImageResultIsDegradedKey];
            if (isDegraded.boolValue) {
                requestFinished = NO;
            }
        }
 
        dispatch_async(dispatch_get_main_queue(), ^{
            downloadCompletionBlock(result, requestFinished);
        });
        
    }];
    
    return requestID;
}

-(void) downloadVideoAsset: (void(^)(AVAsset *asset, AVAudioMix* audioMix)) completionBlock
{
    if ([self isDownloading]) {
        return;
    }
    self.downloadPercent = 0;
    
    PHVideoRequestOptions* options = [PHVideoRequestOptions new];
    
    options.networkAccessAllowed = YES;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    options.progressHandler = ^ (double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
        NSLog(@"Asset(%@) Video download progressHandler; self.downloadPercent=%f; progress=%f", self, self.downloadPercent, progress);
        if (self.downloadPercent <= 1) {
            self.downloadPercent = progress;
            [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
        }
    };
    
    self.lastRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        NSLog(@"Asset(%@) Video download resultHandler; self.downloadPercent=%f; asset=%@, audioMix=%@", self, self.downloadPercent, asset, audioMix);
        
        if (self.downloadPercent < 1) {
            self.downloadPercent = 1;
            [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(asset, audioMix);
        });
        
    }];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
}

-(BOOL) isDownloading
{
    return (self.downloadedImage == nil) && (self.downloadedAsset == nil) && (self.downloadPercent < 1 && self.lastRequestID != PHInvalidImageRequestID);
}

-(void) cancelDownloading
{
    self.downloadPercent = 0;
    if (self.lastRequestID != PHInvalidImageRequestID) {
        NSLog(@"Cancel downloading!");
        [[PHImageManager defaultManager] cancelImageRequest:self.lastRequestID];
        self.lastRequestID = PHInvalidImageRequestID;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
    }
}

-(VFrameProvider*)getFrameProvider
{
    if (self.isVideo) {
        self.videoFrameProvider = [VCoreVideoFrameProvider new];
        self.videoFrameProvider.asset = self.downloadedAsset;
        
        return self.videoFrameProvider;
    } else {
        self.imageFrameProvider = [VStillImage new];
        
        self.imageFrameProvider.image = [CIImage imageWithCGImage:[self.downloadedImage CGImage]];
        self.imageFrameProvider.imageSize = self.downloadedImage.size;
        
        return self.imageFrameProvider;
    }
}

@end
