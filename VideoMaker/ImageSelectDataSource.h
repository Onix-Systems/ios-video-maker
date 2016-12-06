//
//  PickerAssetDataSource.h
//  VideoEditor2
//
//  Created by Alexander on 8/31/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "BaseImageSelectDataSource.h"

@interface ImageSelectDataSource : BaseImageSelectDataSource

+(PHImageManager*) getImageManager;

-(instancetype)initWithAssetsCollection:(PHAssetCollection *)collection;
@end