//
//  PickerAssetVideoDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectVideoDataSource.h"

@interface ImageSelectVideoDataSource ()

@end

@implementation ImageSelectVideoDataSource

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
    self.isLoading = YES;
    NSMutableArray *assets = [NSMutableArray new];
    
    [BaseImageSelectDataSource.assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            
            [self loadAssetsFromGrop:group into:assets withCmpletion:^(NSError* error){
                //do nothing here since assets are alreayd added in to the array
            }];
        } else {
            self.assets = assets;
            self.isLoading = NO;
            self.didFinishLoading(nil);
        }
        
    } failureBlock:^(NSError *error) {
        self.assets = assets;
        self.isLoading = NO;
        self.didFinishLoading(error);
    }];
}


@end
