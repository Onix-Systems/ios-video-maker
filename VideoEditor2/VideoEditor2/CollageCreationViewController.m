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


@property (weak, nonatomic) IBOutlet UIImageView *switchForKenBurns;
@property (weak, nonatomic) IBOutlet UIImageView *switchForSlidingPanels;
@property (weak, nonatomic) IBOutlet UIImageView *switchForOrigami;


@property (strong, nonatomic) VAssetCollage* assetCollage;
@property (strong, nonatomic) AssetsCollection* assetsCollection;
@property (strong, nonatomic) VSegmentsCollection* segmentsCollection;

@property (strong, nonatomic) PlayerView* playerView;

@end

@implementation CollageCreationViewController

-(void) setupCollageWithAssets:(AssetsCollection *)assetsCollection andLayout: (CollageLayout*)collageLayout
{
    VAssetCollage* assetCollage = [VAssetCollage new];
    assetCollage.finalSize = CGSizeMake(1024, 1024);
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
        [self.switchForKenBurns setHighlighted: YES];
    } else {
        [self.switchForKenBurns setHighlighted: NO];
    }
    
    if ([collageEffect isEqualToString: kCollageEffectSlidingPanels]) {
        [self.switchForSlidingPanels setHighlighted: YES];
    } else {
        [self.switchForSlidingPanels setHighlighted: NO];
    }
    
    if ([collageEffect isEqualToString: kCollageEffectOrigami]) {
        [self.switchForOrigami setHighlighted: YES];
    } else {
        [self.switchForOrigami setHighlighted: NO];
    }
}

- (void)selectEffect:(NSString *)collageEffect
{
    if (self.assetCollage != nil) {
        if (self.assetCollage.collageEffect == collageEffect) {
            self.assetCollage.collageEffect = @"";
        } else {
            self.assetCollage.collageEffect = collageEffect;
        }
    }
    [self.segmentsCollection resetSegmentsState];
    [self showUpdatedCollagePreview];
    
    [self updateSwitches];
}

- (IBAction)switch1ThouchUp:(id)sender {
    [self selectEffect:kCollageEffectKenBurns];
}
- (IBAction)switch2TouchUp:(id)sender {
    [self selectEffect:kCollageEffectSlidingPanels];
}
- (IBAction)switch3TouchUp:(id)sender {
    [self selectEffect:kCollageEffectOrigami];
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
        self.playerView.autoRewind = YES;
        self.playerView.delegate = self;
        
        self.playerView.frame = self.collageLayoutViewConainer.bounds;
        [self.collageLayoutViewConainer addSubview:self.playerView];
    }

    VideoComposition* videoComposition = [self.segmentsCollection makeVideoCompositionWithFrameSize:CGSizeMake(600, 600)];
    
    [self.playerView playVideoFromAsset:videoComposition.mutableComposition videoComposition:videoComposition.mutableVideoComposition audioMix:videoComposition.mutableAudioMix autoPlay:YES];
}

-(void) playerStateDidChanged:(PlayerView *)playerView
{
}

-(void) playerTimeDidChanged:(PlayerView *)playerView
{
    
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
