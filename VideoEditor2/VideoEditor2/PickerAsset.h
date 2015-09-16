//
//  PickerAsset.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>
#import "DZNPhotoMetadata.h"

typedef void(^ImageLoadCompletionBlock)(UIImage* resultImage);

@protocol PickerAssetDownloadProgressIndicator

-(void) setDownloadingProgress: (CGFloat) downloadPercent;

@end

@interface PickerAsset : NSObject

@property (nonatomic) BOOL selected;
@property (nonatomic,readonly) NSInteger selectionNumber;
@property (nonatomic,readonly) BOOL isVideo;
@property (nonatomic,readonly) NSNumber* duration;
@property (nonatomic, weak) id<PickerAssetDownloadProgressIndicator> progressIndicator;

-(void) loadThumbnailImage: (ImageLoadCompletionBlock) completionBlock;
-(void) loadOriginalImage: (ImageLoadCompletionBlock) completionBlock;
-(void) loadVideoAsset: (void(^)(AVAsset *asset)) completionBlock;

- (NSString*) getIdentifier;
- (NSDate*) getDate;

+(PickerAsset*) makeFromPHAsset: (PHAsset *) asset;
+(PickerAsset*) makeFromDZNMetaData: (DZNPhotoMetadata *) dznMetaData;

@end
