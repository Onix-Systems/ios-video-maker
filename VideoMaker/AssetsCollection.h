//
//  AssetsCollection.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAsset.h"

#define kAssetsCollectionAssetAddedNitification @"kAssetsCollectionAssetAddedNitification"
#define kAssetsCollectionAssetRemovedNitification @"kAssetsCollectionAssetRemovedNitification"

@interface AssetsCollection : NSObject

@property (nonatomic) BOOL isNumerable;

-(BOOL) hasAsset: (VAsset*) asset;
-(NSInteger) getIndexOfAsset: (VAsset*) asset;
-(void) addAsset: (VAsset*) asset;
-(void) addArrayAssets: (NSArray*) assets;
-(void) removeAsset: (VAsset*) asset;
-(void) removeAllAssets;

-(NSArray*) getAssets;

-(AssetsCollection*) findSubcollectionWithAsset: (VAsset*) asset;

@end
