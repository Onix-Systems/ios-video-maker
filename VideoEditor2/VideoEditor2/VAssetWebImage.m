//
//  VAssetWebImage.m
//  VideoEditor2
//
//  Created by Alexander on 9/18/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VAssetWebImage.h"
#import <UIKit/UIKit.h>

#import <SDWebImage/SDWebImageManager.h>

#import "VStillImage.h"


@interface VAssetWebImage ()

@property (nonatomic, strong) DZNPhotoMetadata* dznMetaData;
@property (readwrite) double downloadPercent;

@property (strong) UIImage* temporaryImage;

@property (strong) id <SDWebImageOperation> currentDownloadingOperation;

@property (strong,nonatomic) VStillImage* frameProvider;

@end

@implementation VAssetWebImage


+(VAsset*) makeFromDZNMetaData: (DZNPhotoMetadata *) dznMetaData
{
    VAssetWebImage* newAsset = [VAssetWebImage new];
    newAsset.dznMetaData = dznMetaData;
    
    return (VAsset*) newAsset;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dznMetaData = nil;
        self.downloadPercent = 0;
    }
    return self;
}


- (BOOL) isVideo
{
    return NO;
}

-(BOOL) isStatic
{
    return YES;
}

- (double) duration
{
    return 0.0;
}

- (NSString*) getIdentifier
{
    return [self.dznMetaData.sourceURL absoluteString];
}

-(void) downloadWithCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    [self getPreviewImageForSize:CGSizeZero withCompletion:downloadCompletionBlock];
}

-(double) getDownloadPercent
{
    return self.downloadPercent;
}


-(void) getThumbnailImageImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    [[SDWebImageManager sharedManager] downloadImageWithURL:self.dznMetaData.thumbURL options:(SDWebImageProgressiveDownload | SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //do nothing
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (error) {
            NSLog(@"WebImage (%@) ThumbnailDownloading error=%@", self.dznMetaData.thumbURL, error);
        }
        downloadCompletionBlock(image, finished, (error != nil));
    }];
}

-(void) getPreviewImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    if ([self isDownloading]) {
        if (self.temporaryImage != nil) {
            downloadCompletionBlock(self.temporaryImage, NO, NO);
        }
        return;
    }

    if (self.downloadedImage != nil) {
        downloadCompletionBlock(self.downloadedImage, YES, NO);
    } else {
        self.downloadPercent = 0;
        
        self.currentDownloadingOperation = [[SDWebImageManager sharedManager] downloadImageWithURL:self.dznMetaData.sourceURL options:(SDWebImageProgressiveDownload | SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (self.downloadPercent < 1) {
                self.downloadPercent = (double)receivedSize/expectedSize;
//                NSLog(@"Set download percent= %f for %@", self.downloadPercent, self);
                [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
            }
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            NSLog(@"got Download result image, finished=%@", finished? @"YES" : @"N");
            
            if (error != nil) {
                NSLog(@"WebImage (%@) downloading error=%@", self.dznMetaData.sourceURL, error);
            }
            if (finished) {
                self.downloadedImage = image;
                self.currentDownloadingOperation = nil;
                if (self.downloadPercent < 1) {
                    self.downloadPercent = 1;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
                };
                self.temporaryImage = nil;
            } else {
                self.temporaryImage = image;
            }
            downloadCompletionBlock(image, finished, (error != nil));
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
    }
}

-(BOOL) isDownloading
{
    return (self.downloadedImage == nil && self.downloadPercent < 1 && self.currentDownloadingOperation != nil);
}

-(void) cancelDownloading
{
    self.downloadPercent = 0;
    if (self.currentDownloadingOperation != nil) {
        [self.currentDownloadingOperation cancel];
        self.currentDownloadingOperation = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
    }
}

-(VFrameProvider*) getFrameProvider
{
    if (self.frameProvider == nil && self.downloadedImage != nil) {
        self.frameProvider = [VStillImage new];
        self.frameProvider.image = [CIImage imageWithCGImage:[self.downloadedImage CGImage]];
        self.frameProvider.imageSize = self.downloadedImage.size;
    }
    
    return self.frameProvider;
}

@end
