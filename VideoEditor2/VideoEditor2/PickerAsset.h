//
//  PickerAsset.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "DZNPhotoMetadata.h"

@interface PickerAsset : NSObject

@property (nonatomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, readonly) NSURL *thumbnailImageURL;
@property (nonatomic, readonly) UIImage *originalImage;

@property (nonatomic) BOOL selected;
@property (nonatomic,readonly) NSInteger selectionNumber;
@property (nonatomic,readonly) BOOL isVideo;
@property (nonatomic,readonly) NSNumber* duration;

- (NSURL*) getURL;
- (NSDate*) getDate;

+(PickerAsset*) makeFromALAsset: (ALAsset *) asset;
+(PickerAsset*) makeFromDZNMetaData: (DZNPhotoMetadata *) dznMetaData;

@end
