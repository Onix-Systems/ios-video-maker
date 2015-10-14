//
//  VAssetCollage.m
//  VideoEditor2
//
//  Created by Alexander on 9/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VAssetCollage.h"

#import "VECollage.h"
#import "VEKenBurnsCollage.h"
#import "VESlidingPanelsCollage.h"

@implementation VAssetCollage

-(BOOL) isVideo
{
    return NO;
}

-(BOOL) isStatic
{
    return NO;
}

- (double) duration
{
    double duration = kSlotRoundDuration;
    
    if (self.assetsCollection != nil && self.collageLayout != nil) {
        NSInteger assetsCount = self.assetsCollection.getAssets.count;
        NSInteger framesCount = self.collageLayout.frames.count;
        
        duration = kSlotRoundDuration * ((assetsCount / framesCount) + ((assetsCount % framesCount > 0) ? 1 : 0));
    }
    
    return duration;
}

-(void)setCollageEffect:(NSString *)collageEffect
{
    _collageEffect = collageEffect;
}

-(void)setAssetsCollection:(AssetsCollection *)assetsCollection
{
    _assetsCollection = assetsCollection;
}

-(VEffect*) createFrameProviderForVideoComposition:(VideoComposition *)videoComposition wihtInstruction:(VCompositionInstruction *)videoInstructoin activeTrackNo:(NSInteger)activeTrackNo
{
    NSInteger lastUsedTrackNo = 1;
    NSArray* assets = [self.assetsCollection getAssets];
    NSMutableArray* assetComponents = [NSMutableArray new];
    
    for (int i = 0; i < assets.count; i++) {
        VAsset *asset = assets[i];
        
        NSInteger trackNo = activeTrackNo;
        if (asset.isVideo) {
            trackNo = lastUsedTrackNo++;
        }
        [assetComponents addObject:[asset createFrameProviderForVideoComposition:videoComposition wihtInstruction:videoInstructoin activeTrackNo:trackNo]];
    }
    
    CGFloat collageHeight = MIN(videoComposition.mutableComposition.naturalSize.height, videoComposition.mutableComposition.naturalSize.height);
    
    VECollage* collageEffect = nil;
    
    if ([self.collageEffect isEqualToString:kCollageEffectKenBurns]) {
        collageEffect = [VEKenBurnsCollage new];
    } else if ([self.collageEffect isEqualToString:kCollageEffectSlidingPanels]) {
        collageEffect = [VESlidingPanelsCollage new];
    } else {
        collageEffect = [VECollage new];
    }

    [collageEffect putFrames:assetComponents intoLayout:self.collageLayout ofSize:CGSizeMake(collageHeight, collageHeight)];
    
    return collageEffect;
}

@end
