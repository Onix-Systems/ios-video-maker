//
//  PickerAsset.m
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "PickerAsset.h"
#import "VideoEditorAssetsCollection.h"

@implementation PickerAsset

- (UIImage *)thumbnailImage {
    return [UIImage imageWithCGImage:self.asset.thumbnail];
}

- (UIImage *)originalImage {
    return [UIImage imageWithCGImage:self.asset.defaultRepresentation.fullResolutionImage
                               scale:self.asset.defaultRepresentation.scale
                         orientation:(UIImageOrientation)self.asset.defaultRepresentation.orientation];
}

- (BOOL) selected {
    VideoEditorAssetsCollection *collection = [VideoEditorAssetsCollection currentlyEditedCollection];
    
    return [collection hasAsset:self];
}

- (void) setSelected:(BOOL)selected {
    VideoEditorAssetsCollection *collection = [VideoEditorAssetsCollection currentlyEditedCollection];
    BOOL isAreadySelected = self.selected;
    
    if (selected && !isAreadySelected) {
        [collection addAsset:self];
    }
    
    if (!selected && isAreadySelected) {
        [collection removeAsset:self];
    }
}

- (NSInteger) selectionNumber {
    VideoEditorAssetsCollection *collection = [VideoEditorAssetsCollection currentlyEditedCollection];
    return [collection getIndexOfAsset:self] + 1;
}

- (NSURL*) getURL {
    return [self.asset valueForProperty: ALAssetPropertyAssetURL];
}

@end
