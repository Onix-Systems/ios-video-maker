//
//  PickerAssetDataSource.h
//  VideoEditor2
//
//  Created by Alexander on 8/31/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BaseImageSelectDataSource.h"

@interface ImageSelectDataSource : BaseImageSelectDataSource
-(instancetype)initWithAssetsGroup:(ALAssetsGroup *)group;
@end