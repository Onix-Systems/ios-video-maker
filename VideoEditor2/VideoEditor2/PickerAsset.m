//
//  PickerAsset.m
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "PickerAsset.h"
#import "VideoEditorAssetsCollection.h"
#import "DZNPhotoMetadata.h"
#import "ImageSelectDataSource.h"
#import <SDWebImage/SDWebImageManager.h>

#define hiRezSize CGSizeMake(720, 480)

@interface PickerAsset ()

@property (nonatomic, strong) PHAsset* asset;
@property (nonatomic, strong) DZNPhotoMetadata* dznMetaData;

@end

@implementation PickerAsset

+(PickerAsset*) makeFromPHAsset: (PHAsset *) asset
{
    PickerAsset* newAsset = [PickerAsset new];
    newAsset.asset = asset;
    return newAsset;
}

+(PickerAsset*) makeFromDZNMetaData: (DZNPhotoMetadata *) dznMetaData
{
    PickerAsset* newAsset = [PickerAsset new];
    newAsset.dznMetaData = dznMetaData;
    return newAsset;
}

-(void) loadThumbnailImage: (ImageLoadCompletionBlock) completionBlock
{
    if (self.asset != nil) {
        PHImageRequestOptions* options = [PHImageRequestOptions new];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
        [[ImageSelectDataSource getImageManager] requestImageForAsset:self.asset targetSize:CGSizeMake(100.0, 100.0) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            completionBlock(result);
        }];
        return;
    }
    if (self.dznMetaData != nil) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:self.dznMetaData.thumbURL options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            //do nothing
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            completionBlock(image);
        }];
    }
}

-(void) loadOriginalImage: (ImageLoadCompletionBlock) completionBlock
{
    if (self.asset != nil) {
        PHImageRequestOptions* options = [PHImageRequestOptions new];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            if (self.progressIndicator != nil) {
                //NSLog(@"Set progress indicator for %@ to %.3f", [self getIdentifier], progress);
                [self.progressIndicator setDownloadingProgress: (CGFloat)progress];
            }
        };
        
        [[ImageSelectDataSource getImageManager] requestImageForAsset:self.asset targetSize:hiRezSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
            if (self.progressIndicator != nil) {
                [self.progressIndicator setDownloadingProgress: 1];
            }
            completionBlock(result);
        }];
        return;
    }
    if (self.dznMetaData != nil) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:self.dznMetaData.sourceURL options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (self.progressIndicator != nil) {
                //NSLog(@"Set progress indicator for %@ to %.3f", [self getIdentifier], (CGFloat)receivedSize/expectedSize);
                [self.progressIndicator setDownloadingProgress: (CGFloat)receivedSize/expectedSize];
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (self.progressIndicator != nil) {
                [self.progressIndicator setDownloadingProgress: 1];
            }
            completionBlock(image);
        }];
    }
}

- (BOOL) selected
{
    VideoEditorAssetsCollection *collection = [VideoEditorAssetsCollection currentlyEditedCollection];
    
    return [collection hasAsset:self];
}

- (void) setSelected:(BOOL)selected
{
    VideoEditorAssetsCollection *collection = [VideoEditorAssetsCollection currentlyEditedCollection];
    BOOL isAreadySelected = self.selected;
    
    if (selected && !isAreadySelected) {
        [self loadOriginalImage:^(UIImage *resultImage) {
            [collection addAsset:self];
        }];
    }

    if (!selected && isAreadySelected) {
        [collection removeAsset:self];
    }
}

- (NSInteger) selectionNumber
{
    VideoEditorAssetsCollection *collection = [VideoEditorAssetsCollection currentlyEditedCollection];
    return [collection getIndexOfAsset:self] + 1;
}

- (NSString*) getIdentifier
{
    if (self.asset != nil) {
        return self.asset.localIdentifier;
    }
    
    if (self.dznMetaData != nil) {
        return [self.dznMetaData.sourceURL absoluteString];
    }

    return nil;
}

- (NSDate*) getDate
{
    if (self.asset != nil) {
        return self.asset.creationDate;
    }
    return nil;
}

- (BOOL) isVideo
{
    if (self.asset != nil && self.asset.mediaType == PHAssetMediaTypeVideo) {
        return true;
    }
    return false;
}

-(void) loadVideoAsset: (void(^)(AVAsset *asset)) completionBlock
{
    if ([self isVideo]) {
        
        PHVideoRequestOptions* options = [PHVideoRequestOptions new];
        
        [[ImageSelectDataSource getImageManager] requestAVAssetForVideo:self.asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
            completionBlock(asset);
        }];
    }
};

- (NSNumber*) duration
{
    if (self.asset != nil) {
        return @(self.asset.duration);
    }
    return @0.0;
}

@end
