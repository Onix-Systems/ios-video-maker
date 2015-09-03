//
//  PickerAssetDataSource.m
//  VideoEditor2
//
//  Created by Alexander on 8/31/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectDataSource.h"


@interface ImageSelectDataSource()

@property (strong,nonatomic) ALAssetsGroup* group;

@end

@implementation ImageSelectDataSource

-(instancetype)initWithAssetsGroup:(ALAssetsGroup *)group {
    self = [super init];
    if (self) {
        self.group = group;
        
        self.assets = [NSArray new];
        
        self.supportSearch = NO;
        self.isLoading = NO;

    }
    return self;
}

-(void)loadAssets {
    self.isLoading = YES;
    
    NSMutableArray* assets = [NSMutableArray new];
    [self loadAssetsFromGrop:self.group into:assets withCmpletion:^(NSError *error){
        self.assets = assets;
        self.isLoading = YES;
        self.didFinishLoading(error);
    }];
}

@end
