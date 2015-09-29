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

#import "VInstructionStillImage.h"


@interface VAssetWebImage ()

@property (nonatomic, strong) DZNPhotoMetadata* dznMetaData;
@property (readwrite) double downloadPercent;

@property (strong) UIImage* temporaryImage;

@property (strong) id <SDWebImageOperation> currentDownloadingOperation;

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
    return false;
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
    [[SDWebImageManager sharedManager] downloadImageWithURL:self.dznMetaData.thumbURL options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //do nothing
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        downloadCompletionBlock(image, finished);
    }];
}

-(void) getPreviewImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    if ([self isDownloading]) {
        if (self.temporaryImage != nil) {
            downloadCompletionBlock(self.temporaryImage, NO);
        }
        return;
    }

    if (self.downloadedImage != nil) {
        downloadCompletionBlock(self.downloadedImage, true);
    } else {
        self.downloadPercent = 0;
        
        self.currentDownloadingOperation = [[SDWebImageManager sharedManager] downloadImageWithURL:self.dznMetaData.sourceURL options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (self.downloadPercent < 1) {
                self.downloadPercent = (double)receivedSize/expectedSize;
                NSLog(@"Set download percent= %.f for %@", self.downloadPercent, self);
                [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
            }
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            NSLog(@"got Download result image, finished=%@", finished? @"YES" : @"N");
            
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
            downloadCompletionBlock(image, finished);
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
        NSLog(@"Cancel downloading!");
        [self.currentDownloadingOperation cancel];
        self.currentDownloadingOperation = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kVAssetDownloadProgressNotification object:self];
    }
}

@end
