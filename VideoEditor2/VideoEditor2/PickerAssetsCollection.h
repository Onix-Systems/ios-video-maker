//
//  AssetsCollection.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PickerAsset.h"

@interface PickerAssetsCollection : NSObject

@property (nonatomic,readonly) NSInteger count;
@property (strong, nonatomic) void(^onLoad)(void);

+(instancetype) makeFromALAssetsGroup: (ALAssetsGroup*) group onLoad: (void(^)(void)) onLoad;

-(PickerAsset*) getAsset: (NSInteger) i;

@end
