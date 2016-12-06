//
//  VAssetWebImage.h
//  VideoEditor2
//
//  Created by Alexander on 9/18/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VAsset.h"
#import "DZNPhotoMetadata.h"

@interface VAssetWebImage : VAsset

+(VAsset*) makeFromDZNMetaData: (DZNPhotoMetadata *) dznMetaData;

@end
