//
//  PickerAssetDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 8/31/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectDataSource.h"
#import "VAssetPHImage.h"

@interface ImageSelectDataSource()

@property (strong,nonatomic) PHAssetCollection* collection;

@end

@implementation ImageSelectDataSource

+(PHImageManager*) getImageManager
{
    return [PHImageManager defaultManager];
}

-(instancetype)initWithAssetsCollection:(PHAssetCollection *)collection
{
    self = [super init];
    if (self) {
        self.collection = collection;
        
        self.assets = [NSArray new];
        
        self.supportSearch = NO;
        self.isLoading = NO;

    }
    return self;
}

-(void)loadAssets {
    self.isLoading = YES;

    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                     ];

    PHFetchResult *results = [PHAsset fetchAssetsInAssetCollection:self.collection options:fetchOptions];
    NSMutableArray* assets = [NSMutableArray new];
    
    for (PHAsset *asset in results) {
        [assets addObject:[VAssetPHImage makeFromPHAsset:asset]];
    }
    
    self.assets = assets;
    self.isLoading = NO;
    self.didFinishLoading(nil);
}

@end
