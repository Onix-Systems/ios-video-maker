//
//  VAssetCollage.m
//  VideoEditor2
//
//  Created by Alexander on 9/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VAssetCollage.h"

#import "VProvidersCollection.h"

#import "VCollageBuilder.h"
#import "VKenBurnsCollageBuilder.h"
#import "VSlidingPanelsCollageBuilder.h"
#import "VOrigamiCollageBuilder.h"

@interface VAssetCollage()

@property (strong,nonatomic) VFrameProvider* cachedFrameProvider;
@property (nonatomic) NSInteger collageIdentifierInMemory;

@end

@implementation VAssetCollage

NSInteger collagesCounter = 0;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.collageIdentifierInMemory = collagesCounter;
        collagesCounter++;
        self.previewMode = NO;
    }
    return self;
}

-(BOOL) isVideo
{
    return NO;
}

- (NSString *)getIdentifier {
    return [NSString stringWithFormat:@"collage%ld",self.collageIdentifierInMemory];
}

-(BOOL) isStatic
{
    return NO;
}

-(void)clearCache
{
    self.cachedFrameProvider = nil;
}

- (double) duration
{
    return [self.cachedFrameProvider getDuration];
}

-(void)setCollageEffect:(NSString *)collageEffect
{
    _collageEffect = collageEffect;
    [self clearCache];
}

-(void)setAssetsCollection:(AssetsCollection *)assetsCollection
{
    _assetsCollection = assetsCollection;
    [self clearCache];
}

-(void)setFinalSize:(CGSize)finalSize
{
    if ((_finalSize.width != finalSize.width) && (_finalSize.height != finalSize.height)) {
        _finalSize = finalSize;
        [self clearCache];
    }
}

-(VFrameProvider*)cachedFrameProvider
{
    if (_cachedFrameProvider == nil) {
        NSArray* assets = [self.assetsCollection getAssets];
        NSMutableArray* collageItems = [NSMutableArray new];
        
        for (int i = 0; i < assets.count; i++) {
            VAsset *asset = assets[i];
            
            [collageItems addObject:[asset getFrameProvider]];
        }
        
        CGFloat collageHeight = MIN(self.finalSize.height, self.finalSize.height);
        CGSize collageSize = CGSizeMake(collageHeight, collageHeight);
        
        VCollageBuilder* collageBuilder = nil;
        
        if ([self.collageEffect isEqualToString:kCollageEffectKenBurns]) {
            collageBuilder = [VKenBurnsCollageBuilder new];
        } else if ([self.collageEffect isEqualToString:kCollageEffectSlidingPanels]) {
            collageBuilder = [VSlidingPanelsCollageBuilder new];
        } else if ([self.collageEffect isEqualToString:kCollageEffectOrigami]) {
            collageBuilder = [VOrigamiCollageBuilder new];
        } else {
            collageBuilder = [VCollageBuilder new];
        }
        
        collageBuilder.previewMode = self.previewMode;
        
        _cachedFrameProvider = [collageBuilder makeCollageWithItems:collageItems layoutFrames:self.collageLayout.frames finalSize:collageSize];
    }
    
    return _cachedFrameProvider;
}

-(VFrameProvider*) getFrameProvider
{
    return self.cachedFrameProvider;
}

@end
