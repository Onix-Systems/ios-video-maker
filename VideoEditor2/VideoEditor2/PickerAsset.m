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

@interface PickerAsset ()

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) DZNPhotoMetadata* dznMetaData;

@end

@implementation PickerAsset

+(PickerAsset*) makeFromALAsset: (ALAsset *) asset
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


- (UIImage *)thumbnailImage
{
    if (self.asset != nil) {
        return [UIImage imageWithCGImage:self.asset.thumbnail];
    }

    return nil;
}

- (NSURL *)thumbnailImageURL
{
    if (self.dznMetaData != nil) {
        return self.dznMetaData.thumbURL;
    }
    
    return nil;
}

- (UIImage *)originalImage
{
    if (self.asset != nil) {
        return [UIImage imageWithCGImage:self.asset.defaultRepresentation.fullResolutionImage scale:self.asset.defaultRepresentation.scale orientation:(UIImageOrientation)self.asset.defaultRepresentation.orientation];
    }
    
    return nil;
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
        [collection addAsset:self];
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

- (NSURL*) getURL
{
    if (self.asset != nil) {
        return [self.asset defaultRepresentation].url;
    }
    
    if (self.dznMetaData != nil) {
        return self.dznMetaData.sourceURL;
    }

    return nil;
}

- (NSDate*) getDate
{
    if (self.asset != nil) {
        return [self.asset valueForProperty:ALAssetPropertyDate];
    }
    return nil;
}

- (BOOL) isVideo
{
    if (self.asset != nil && [self.asset valueForProperty: ALAssetPropertyType] == ALAssetTypeVideo) {
        return true;
    }
    return false;
}

- (NSNumber*) duration
{
    if (self.asset != nil) {
        return [self.asset valueForProperty: ALAssetPropertyDuration];
    }
    return @0.0;
}

@end
