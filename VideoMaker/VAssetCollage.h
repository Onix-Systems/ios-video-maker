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
#define kCollageEffectOrigami @"Origami"

@interface VAssetCollage : VAsset

@property (nonatomic) CGSize finalSize;
@property (strong, nonatomic) AssetsCollection* assetsCollection;
@property (strong, nonatomic) CollageLayout* collageLayout;
@property (strong, nonatomic) NSString* collageEffect;

@property (nonatomic) BOOL previewMode;

@end
