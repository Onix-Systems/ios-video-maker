//
//  PickerAsset.m
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "VAsset.h"


@implementation VAsset

- (BOOL) isVideo
{
    return false;
}

- (NSNumber*) duration
{
    return @0.0;
}

- (NSString*) getIdentifier
{
    return nil;
}

-(void) downloadWithCompletion: (VAssetDownloadCompletionBlock) downloadCompletionBlock
{
    
}

-(void) downloadVideoAsset: (void(^)(AVAsset *asset, AVAudioMix* audioMix)) completionBlock
{
    
}

-(double) getDownloadPercent
{
    return 0;
}


-(void) getThumbnailImageImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) completionBlock
{
    
}

-(void) getPreviewImageForSize: (CGSize) size withCompletion: (VAssetDownloadCompletionBlock) completionBlock
{
    
}

-(BOOL) isDownloading
{
    return false;
}

-(void) cancelDownloading
{
    
}

@end
