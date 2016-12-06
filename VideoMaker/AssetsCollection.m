//
//  AssetsCollection.m
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "AssetsCollection.h"

@interface AssetsCollection ()

@property (strong, nonatomic) NSMutableArray* assets;

@end

@implementation AssetsCollection

+(instancetype) currentlyEditedCollection {
    static AssetsCollection *sharedCollection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCollection = [[self alloc] init];
    });
    return sharedCollection;
};


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assets = [NSMutableArray new];
        self.isNumerable = YES;
    }
    return self;
}

-(BOOL) hasAsset: (VAsset*) asset {
    return [self findIndexOfAsset:asset] >= 0 ? YES : NO;
}

-(NSInteger) getIndexOfAsset: (VAsset*) asset
{
    NSInteger index = [self findIndexOfAsset:asset];
    
    if (index >= 0) {
        return self.isNumerable ? index : NSIntegerMax;
    }
    
    return -1;
}

-(NSInteger) findIndexOfAsset: (VAsset*) asset {
    NSString *assetID = [asset getIdentifier];
    
    NSInteger index = -1;
    for (VAsset* existingAsset in self.assets) {
        index++;
        
        if ([assetID isEqual:[existingAsset getIdentifier]]) {
            return index;
        }
    }
    return -1;
}

-(void) addAsset: (VAsset*) asset {
    if (asset.isVideo && !self.isNumerable) {
        //return;
    }
    
    if ([self findIndexOfAsset:asset] >= 0) {
        [self removeAsset:asset];
    }
    
    [self.assets addObject:asset];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAssetsCollectionAssetAddedNitification object:self];
}

-(void) addArrayAssets: (NSArray*) assets {
    [self.assets addObjectsFromArray:assets];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAssetsCollectionAssetAddedNitification object:self];
}

-(void) removeAsset: (VAsset*) asset {
    NSInteger index = [self findIndexOfAsset:asset];
    
    if (index >= 0) {
        [self.assets removeObject:self.assets[index]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAssetsCollectionAssetRemovedNitification object:self];
    }
}

-(void) removeAllAssets {
    [self.assets removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAssetsCollectionAssetRemovedNitification object:self];
}

-(NSArray*) getAssets
{
    return self.assets;
}

-(AssetsCollection*) findSubcollectionWithAsset: (VAsset*) asset
{
    return nil;
}

@end
