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

#define kCollageEffectNone @""
#define kCollageEffectKenBurns @"KenBurns"
#define kCollageEffectSlidingPanels @"SlidingPanels"
#define kCollageEffectShiftingTiles @"ShiftingTiles"

@interface VAssetCollage : VAsset

@property (strong, nonatomic) AssetsCollection* assetsCollection;
@property (strong, nonatomic) CollageLayout* collageLayout;
@property (strong, nonatomic) NSString* collageEffect;

@end
