//
//  VAssetCollage.h
//  VideoEditor2
//
//  Created by Alexander on 9/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VAsset.h"
#import "AssetsCollection.h"
#import "CollageLayout.h"

@interface VAssetCollage : VAsset

@property (strong) AssetsCollection* assetsCollection;
@property (strong) CollageLayout* layout;

@end
