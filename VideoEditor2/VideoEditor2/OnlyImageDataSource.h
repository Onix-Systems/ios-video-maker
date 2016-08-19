//
//  OnlyImageDataSource.h
//  VideoEditor2
//
//  Created by Vitaliy Savchenko on 19.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

#import "BaseImageSelectDataSource.h"

@interface OnlyImageDataSource : BaseImageSelectDataSource

+(PHImageManager*) getImageManager;

-(instancetype)initWithAssetsCollection:(PHAssetCollection *)collection;

@end
