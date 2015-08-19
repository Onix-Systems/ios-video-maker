//
//  AssetsCollection.m
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "PickerAssetsCollection.h"
#import "TWPhotoLoader.h"

@interface PickerAssetsCollection()

@property (strong, nonatomic) NSMutableArray *assets;

@end

@implementation PickerAssetsCollection

+(instancetype) makeFromALAssetsGroup: (ALAssetsGroup*) group onLoad: (void(^)(void)) onLoad {
    
    PickerAssetsCollection *collection = [PickerAssetsCollection new];
    collection.onLoad = onLoad;
    
    [TWPhotoLoader loadAllPhotosFromAlbum:group completion:^(NSArray *photos, NSError *error) {
        if (photos != nil) {
            for (TWPhoto *photo in photos) {
                PickerAsset *asset = [PickerAsset new];
                asset.asset = photo.asset;
                [collection.assets addObject:asset];
            }
        }
        collection.onLoad();
    }];
    
    return collection;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assets = [NSMutableArray new];
    }
    return self;
}

-(NSInteger)count {
    return self.assets.count;
}

-(PickerAsset*) getAsset:(NSInteger)i {
    assert(i >=0 && i <= self.assets.count);
    
    return self.assets[i];
}

@end
