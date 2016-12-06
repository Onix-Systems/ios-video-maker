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

-(void)updateAsset:(PHAsset *)asset
{
    self.asset = asset;
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
//    NSLog(@"PHAssetLocalIdentifier = %@", self.asset.localIdentifier);
    return self.asset.localIdentifier;
}

-(void) getThumbnailImageImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    [self createImageLoadRequest:size trackProgress:^(double progress) {
        //do nothing
    } withCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
        if (requestFinished || ![self isVideo]) {
            downloadCompletionBlock(resultImage, requestFinished, requestError);
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
            downloadCompletionBlock(nil, YES, NO);
            return;
        }
        [self downloadVideoAsset:^(AVAsset *asset, AVAudioMix* audioMix) {
            self.downloadedAsset = asset;
            self.downloadedAudioMix = audioMix;
            downloadCompletionBlock(nil, YES, NO);
        }];

    } else {
        if (self.downloadedImage != nil) {
            downloadCompletionBlock(self.downloadedImage, YES, NO);
            return;
        }
        
//        [self getPreviewImageForSize:PHImageManagerMaximumSize withCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
        [self getPreviewImageForSize:CGSizeMake(1024, 768) withCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
            if (requestFinished) {
                self.downloadedImage = resultImage;
            }
            downloadCompletionBlock(resultImage, requestFinished, requestError);
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
        downloadCompletionBlock(self.downloadedImage, YES, NO);
        return;
    }
    
    self.downloadPercent = 0;
    
    self.lastRequestID = [self createImageLoadRequest:size trackProgress:^(double progress) {
        
        if (self.lastRequestID == PHInvalidImageRequestID) {
            return;
        }
        
        self.downloadPercent = progress;
        if (self.downloadPercent < 1.0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
        }
        
    } withCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
        if (self.lastRequestID == PHInvalidImageRequestID) {
            return;
        }

        if (requestFinished) {
            self.lastRequestID = PHInvalidImageRequestID;
            
            if (self.downloadPercent < 1) {
                self.downloadPercent = 1;
            }
        }

        downloadCompletionBlock(resultImage, requestFinished, requestError);
        
        if (requestFinished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
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
        
        if (result == nil) {
            if (info[PHImageErrorKey] != nil) {
                //there is some error
                [self cancelDownloading];
            }
            return;
        }
        
        BOOL requestFinished = YES;
        if(info[PHImageResultIsDegradedKey] != nil) {
            NSNumber* isDegraded = info[PHImageResultIsDegradedKey];
            if (isDegraded.boolValue) {
                requestFinished = NO;
            }
        }
 
        dispatch_async(dispatch_get_main_queue(), ^{
            downloadCompletionBlock(result, requestFinished, NO);
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
        NSLog(@"Asset(%@) Video download progressHandler; self.downloadPercent=%f; progress=%f isDownloading=%@", self, self.downloadPercent, progress,[self isDownloading] ? @"Y" : @"N");
        
        if (self.lastRequestID == PHInvalidImageRequestID) {
            return;
        }
        
        self.downloadPercent = progress;
        if (self.downloadPercent < 1.0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
        }
    };
    
    self.lastRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:self.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        
        if (self.lastRequestID == PHInvalidImageRequestID) {
            return;
        }
        
        NSLog(@"Asset(%@) Video download resultHandler; self.downloadPercent=%f; asset=%@, audioMix=%@", self, self.downloadPercent, asset, audioMix);
        
        if (asset != nil) {
            self.downloadPercent = 1;
            completionBlock(asset, audioMix);
        }
        
        self.lastRequestID = PHInvalidImageRequestID;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
}

-(BOOL) isDownloading
{
    return (self.downloadedImage == nil) && (self.downloadedAsset == nil) && ((self.downloadPercent < 1) && (self.lastRequestID != PHInvalidImageRequestID));
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
        
        CIImage* image = [CIImage imageWithCGImage:self.downloadedImage.CGImage];
        
        int exifOrientation = 1;
        if (self.downloadedImage.imageOrientation == UIImageOrientationRight) {
            exifOrientation = 6;
        } else if (self.downloadedImage.imageOrientation == UIImageOrientationLeft) {
            exifOrientation = 8;
        } else if (self.downloadedImage.imageOrientation == UIImageOrientationDown) {
            exifOrientation = 3;
        }
        
        image = [image imageByApplyingOrientation:exifOrientation];
        
        self.imageFrameProvider.image = image;
        self.imageFrameProvider.imageSize = self.downloadedImage.size;
        
        return self.imageFrameProvider;
    }
}

@end
