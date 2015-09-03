//
//  PickerAssetsCameraRollDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectCameraRollDataSource.h"
#import "BaseImageSelectDataSource.h"

@interface ImageSelectCameraRollDataSource ()

@end

@implementation ImageSelectCameraRollDataSource

-(instancetype)init {
    self = [super init];
    if (self) {
        self.assets = [NSArray new];
        self.supportSearch = NO;
        self.isLoading = NO;
    }
    return self;
}

-(void) loadAssets {
    NSMutableArray *assets = [NSMutableArray new];
    self.isLoading = NO;
    
    [BaseImageSelectDataSource.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            
            [self loadAssetsFromGrop:group into:assets withCmpletion:^(NSError *error) {
                //do nothing here since assets are alreayd added in to the array
            }];
        } else {
            self.assets = assets;
            self.isLoading = YES;
            self.didFinishLoading(nil);
        }
        
    } failureBlock:^(NSError *error) {
        self.assets = assets;
        self.isLoading = YES;
        self.didFinishLoading(error);
    }];
}

@end