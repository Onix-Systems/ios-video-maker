//
//  VAsset.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoComposition.h"

typedef void(^VAssetDownloadCompletionBlock)(UIImage* resultImage, BOOL requestFinished, BOOL requestError);
#define kVAssetDownloadProgressNotification @"kVAssetDownloadProgressNotification"

@interface VAsset : NSObject

@property (nonatomic,readonly) BOOL isVideo;
@property (nonatomic,readonly) BOOL isStatic;
@property (readonly) double duration;

@property (strong, nonatomic) UIImage* downloadedImage;
@property (strong) AVAsset* downloadedAsset;
@property (strong) AVAudioMix* downloadedAudioMix;

- (NSString*) getIdentifier;
-(double) getDownloadPercent;

-(void) getThumbnailImageImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) completionBlock;
-(void) getPreviewImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) completionBlock;

-(void) downloadWithCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock;

-(void) downloadVideoAsset: (void(^)(AVAsset *asset, AVAudioMix* audioMix)) completionBlock;

-(BOOL) isDownloading;
-(void) cancelDownloading;

-(VFrameProvider*) getFrameProvider;

@end
