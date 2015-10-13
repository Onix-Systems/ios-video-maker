//
//  VECollage.h
//  VideoEditor2
//
//  Created by Alexander on 10/8/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VEffect.h"

#import "VAssetCollage.h"
#import "VECollageSlot.h"

#define kShowHideDuration 0.750
#define kSlidingDuration 0.50
#define kSlotRoundDuration 2.0

@interface VECollage : VEffect

@property (strong, nonatomic) NSArray<VEffect*>* assetCocmponents;
@property (weak, nonatomic) CollageLayout* collageLayout;
@property (strong, nonatomic) NSArray<VECollageSlot*>* slots;

-(void) putFrames:(NSArray<VEffect*>*) assetCocmponents intoLayout:(CollageLayout *)collageLayout ofSize:(CGSize)finalSize;

-(Class)slotClass;

-(VECollageSlot*) createSlotWithFrameProvider: (VEffect*)assetCocmponent forFrame: (CGRect) frame roundNumber: (NSInteger) roundNumber totalNumberOfRounds:(NSInteger)totalRounds;

@end
