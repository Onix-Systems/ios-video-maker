//
//  CollageCreationViewController.m
//  VideoEditor2
//
//  Created by Alexander on 9/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CollageCreationViewController.h"
#import "VAssetCollage.h"
#import "VDocument.h"
#import "VSegmentsCollection.h"
#import "PlayerView.h"

@interface CollageCreationViewController () <PlayerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView* collageLayoutViewConainer;

@property (weak, nonatomic) IBOutlet UISwitch *switchForKenBurns;
@property (weak, nonatomic) IBOutlet UISwitch *switchForSlidingPanels;
@property (weak, nonatomic) IBOutlet UISwitch *switchForShiftingTiles;

@property (strong, nonatomic) VAssetCollage* assetCollage;
@property (strong, nonatomic) AssetsCollection* assetsCollection;
@property (strong, nonatomic) VSegmentsCollection* segmentsCollection;

@property (strong, nonatomic) PlayerView* playerView;

@end

@implementation CollageCreationViewController

-(void) setupCollageWithAssets:(AssetsCollection *)assetsCollection andLayout: (CollageLayout*)collageLayout
{
    VAssetCollage* assetCollage = [VAssetCollage new];
    assetCollage.assetsCollection = assetsCollection;
    assetCollage.collageLayout = collageLayout;
    assetCollage.collageEffect = kCollageEffectNone;
    
    if (self.assetCollage != nil) {
        assetCollage.collageEffect = self.assetCollage.collageEffect;
    }
    self.assetCollage = assetCollage;
    
    self.assetsCollection = [AssetsCollection new];
    [self.assetsCollection addAsset:self.assetCollage];
    
    self.segmentsCollection = [VSegmentsCollection new];
    self.segmentsCollection.assetsCollection = self.assetsCollection;
    
    [self showUpdatedCollagePreview];
}

-(void) updateSwitches
{
    NSString* collageEffect = kCollageEffectNone;
    if (self.assetCollage != nil) {
        collageEffect = self.assetCollage.collageEffect;
    }
    
    if ([collageEffect isEqualToString: kCollageEffectKenBurns]) {
        self.switchForKenBurns.on = YES;
    } else {
        self.switchForKenBurns.on = NO;
    }
    
    if ([collageEffect isEqualToString: kCollageEffectSlidingPanels]) {
        self.switchForSlidingPanels.on = YES;
    } else {
        self.switchForSlidingPanels.on = NO;
    }
    
    if ([collageEffect isEqualToString: kCollageEffectShiftingTiles]) {
        self.switchForShiftingTiles.on = YES;
    } else {
        self.switchForShiftingTiles.on = NO;
    }
}

- (IBAction)switchValueChanged:(UISwitch *)sender {
    NSString* collageEffect = kCollageEffectNone;
    
    if (sender.isOn) {
        if (sender == self.switchForKenBurns) {
            collageEffect = kCollageEffectKenBurns;
        }
        if (sender == self.switchForSlidingPanels) {
            collageEffect = kCollageEffectSlidingPanels;
        }
        if (sender == self.switchForShiftingTiles) {
            collageEffect = kCollageEffectShiftingTiles;
        }
    }
    
    if (self.assetCollage != nil) {
        self.assetCollage.collageEffect = collageEffect;
    }
    [self showUpdatedCollagePreview];
    
    [self updateSwitches];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateSwitches];
    
    [self showUpdatedCollagePreview];
}

- (void) showUpdatedCollagePreview
{
    if (self.collageLayoutViewConainer == nil || self.segmentsCollection == nil) {
        return;
    }
    
    if (self.playerView == nil) {
        self.playerView = [PlayerView new];
        self.playerView.delegate = self;
        
        self.playerView.frame = self.collageLayoutViewConainer.bounds;
        [self.collageLayoutViewConainer addSubview:self.playerView];
    }

    VideoComposition* videoComposition = [self.segmentsCollection getVideoComposition];
    [videoComposition setVideoFrameSize:CGSizeMake(600, 600)];
    
    [self.playerView playVideoFromAsset:videoComposition.mutableComposition videoComposition:videoComposition.mutableVideoComposition audioMix:videoComposition.mutableAudioMix autoPlay:YES];
}

-(void) playerStateDidChanged:(PlayerView *)playerView
{
    [playerView play];
}

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender {
    [[VDocument getCurrentDocument].assetsCollection addAsset:self.assetCollage];
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)cancelButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void) viewDidLayoutSubviews {
    if (self.collageLayoutViewConainer != nil && self.playerView != nil) {
        self.playerView.frame = self.collageLayoutViewConainer.bounds;
    }
}

@end
