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

#import "ZOZolaZoomTransition.h"

@interface CollageCreationViewController () <PlayerViewDelegate, UIViewControllerTransitioningDelegate, ZOZolaZoomTransitionDelegate>

@property (weak, nonatomic) IBOutlet UIView* collageLayoutViewConainer;


@property (weak, nonatomic) IBOutlet UIImageView *switchForKenBurns;
@property (weak, nonatomic) IBOutlet UIImageView *switchForSlidingPanels;
@property (weak, nonatomic) IBOutlet UIImageView *switchForOrigami;

@property (strong, nonatomic) NSString* activeEffect;

@property (strong, nonatomic) VAssetCollage* assetCollage;
@property (strong, nonatomic) VAssetCollage* assetCollageKB;
@property (strong, nonatomic) VAssetCollage* assetCollageSP;
@property (strong, nonatomic) VAssetCollage* assetCollageOR;

@property (weak, nonatomic) IBOutlet UILabel *kenBurnsLabel;

@property (strong, nonatomic) PlayerView* playerView;
@property (strong, nonatomic) PlayerView* backgroundPlayerView;

@property (strong, nonatomic) VideoComposition* videoComposition;
@property (strong, nonatomic) VideoComposition* videoCompositionKB;
@property (strong, nonatomic) VideoComposition* videoCompositionSP;
@property (strong, nonatomic) VideoComposition* videoCompositionOR;

@property (nonatomic, strong) UIView* transitionView;

@property (nonatomic) BOOL kbEnabled;

@end

@implementation CollageCreationViewController

-(VideoComposition*) makeVideoCompositionForCollage: (VAssetCollage*) collage ofSize: (CGSize) videoCompositionSize
{
    AssetsCollection* collageAssetsCollection = [AssetsCollection new];
    VSegmentsCollection* collageSegmentsCollection = nil;

    [collageAssetsCollection addAsset:collage];
    
    collageSegmentsCollection = [VSegmentsCollection new];
    collageSegmentsCollection.assetsCollection = collageAssetsCollection;
    return [collageSegmentsCollection makeVideoCompositionWithFrameSize:videoCompositionSize];
}

-(void) setupCollageWithAssets:(AssetsCollection *)assetsCollection andLayout: (CollageLayout*)collageLayout
{
    CGSize videoCompositionSize = CGSizeMake(600, 600);
    
    self.assetCollage = [VAssetCollage new];
    self.assetCollage.finalSize = videoCompositionSize;
    self.assetCollage.assetsCollection = assetsCollection;
    self.assetCollage.collageLayout = collageLayout;
    self.assetCollage.collageEffect = kCollageEffectNone;
    self.videoComposition = [self makeVideoCompositionForCollage:self.assetCollage ofSize:videoCompositionSize];
    
    self.kbEnabled = NO;
    if (collageLayout.frames.count == 1) {
        self.kbEnabled = YES;
        
        self.assetCollageKB = [VAssetCollage new];
        self.assetCollageKB.finalSize = CGSizeMake(600, 600);
        self.assetCollageKB.assetsCollection = assetsCollection;
        self.assetCollageKB.collageLayout = collageLayout;
        self.assetCollageKB.collageEffect = kCollageEffectKenBurns;
        self.videoCompositionKB = [self makeVideoCompositionForCollage:self.assetCollageKB ofSize:videoCompositionSize];
    }
    self.kenBurnsLabel.enabled = self.kbEnabled;
    
    self.assetCollageSP = [VAssetCollage new];
    self.assetCollageSP.finalSize = CGSizeMake(600, 600);
    self.assetCollageSP.assetsCollection = assetsCollection;
    self.assetCollageSP.collageLayout = collageLayout;
    self.assetCollageSP.collageEffect = kCollageEffectSlidingPanels;
    self.assetCollageSP.previewMode = YES;
    self.videoCompositionSP = [self makeVideoCompositionForCollage:self.assetCollageSP ofSize:videoCompositionSize];
    
    self.assetCollageOR = [VAssetCollage new];
    self.assetCollageOR.finalSize = CGSizeMake(600, 600);
    self.assetCollageOR.assetsCollection = assetsCollection;
    self.assetCollageOR.collageLayout = collageLayout;
    self.assetCollageOR.collageEffect = kCollageEffectOrigami;
    self.videoCompositionOR = [self makeVideoCompositionForCollage:self.assetCollageOR ofSize:videoCompositionSize];
    
    [self selectEffect:kCollageEffectNone];
}

-(void) updateSwitches
{
    if ([self.activeEffect isEqualToString: kCollageEffectKenBurns]) {
        [self.switchForKenBurns setHighlighted: YES];
    } else {
        [self.switchForKenBurns setHighlighted: NO];
    }
    
    if ([self.activeEffect isEqualToString: kCollageEffectSlidingPanels]) {
        [self.switchForSlidingPanels setHighlighted: YES];
    } else {
        [self.switchForSlidingPanels setHighlighted: NO];
    }
    
    if ([self.activeEffect isEqualToString: kCollageEffectOrigami]) {
        [self.switchForOrigami setHighlighted: YES];
    } else {
        [self.switchForOrigami setHighlighted: NO];
    }
}

- (void)selectEffect:(NSString *)collageEffect
{
    if (self.activeEffect == collageEffect) {
        self.activeEffect = kCollageEffectNone;
    } else {
        self.activeEffect = collageEffect;
    }
    [self updateSwitches];
    
    [self playCollagePreview];

}

- (IBAction)switch1ThouchUp:(id)sender {
    if (!self.kbEnabled) {
        return;
    }
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
    [self playCollagePreview];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.playerView cleanPlayer];
    [self.backgroundPlayerView cleanPlayer];
}

- (void) playCollagePreview
{
    if (self.collageLayoutViewConainer == nil || self.videoComposition == nil) {
        return;
    }
    
    if (self.playerView == nil) {
        self.playerView = [PlayerView new];
        self.playerView.delegate = self;
        self.playerView.frame = self.collageLayoutViewConainer.bounds;
        [self.collageLayoutViewConainer addSubview:self.playerView];
        
        self.backgroundPlayerView = [PlayerView new];
        self.backgroundPlayerView.delegate = self;
        self.backgroundPlayerView.frame = self.collageLayoutViewConainer.bounds;
        [self.collageLayoutViewConainer addSubview:self.backgroundPlayerView];
    }
    
    [self.playerView pause];
    [self.backgroundPlayerView cleanPlayer];
    PlayerView* tmpPlayerView = self.backgroundPlayerView;
    self.backgroundPlayerView = self.playerView;
    self.playerView = tmpPlayerView;
    [self.collageLayoutViewConainer sendSubviewToBack:self.backgroundPlayerView];
    
    self.playerView.autoRewind = 1;
    
    
    if ([self.activeEffect isEqualToString: kCollageEffectKenBurns]) {
        [self.playerView playVideoFromAsset:self.videoCompositionKB.mutableComposition videoComposition:self.videoCompositionKB.mutableVideoComposition audioMix:self.videoCompositionKB.mutableAudioMix autoPlay:YES];
        
    } else if ([self.activeEffect isEqualToString: kCollageEffectSlidingPanels]) {
        [self.playerView playVideoFromAsset:self.videoCompositionSP.mutableComposition videoComposition:self.videoCompositionSP.mutableVideoComposition audioMix:self.videoCompositionSP.mutableAudioMix autoPlay:YES];
        
    } else if ([self.activeEffect isEqualToString: kCollageEffectOrigami]) {
        [self.playerView playVideoFromAsset:self.videoCompositionOR.mutableComposition videoComposition:self.videoCompositionOR.mutableVideoComposition audioMix:self.videoCompositionOR.mutableAudioMix autoPlay:YES];
        
    } else {
        [self.playerView playVideoFromAsset:self.videoComposition.mutableComposition videoComposition:self.videoComposition.mutableVideoComposition audioMix:self.videoComposition.mutableAudioMix autoPlay:YES];
    }
}

-(void) playerStateDidChanged:(PlayerView *)playerView
{
}

-(void) playerTimeDidChanged:(PlayerView *)playerView
{
    
}

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
    if (self.delegate != nil) {
        if ([self.activeEffect isEqualToString: kCollageEffectKenBurns]) {
            [self.delegate saveCollage:self.assetCollageKB];
            
        } else if ([self.activeEffect isEqualToString: kCollageEffectSlidingPanels]) {
            [self.delegate saveCollage:self.assetCollageSP];
            
        } else if ([self.activeEffect isEqualToString: kCollageEffectOrigami]) {
            [self.delegate saveCollage:self.assetCollageOR];
            
        } else {
            [self.delegate saveCollage:self.assetCollage];
        }
    }
}

- (IBAction)cancelButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
    if (self.delegate != nil) {
        [self.delegate cancelCollage];
    }
}

- (void) viewDidLayoutSubviews {
    if (self.collageLayoutViewConainer != nil && self.playerView != nil) {
        self.playerView.frame = self.collageLayoutViewConainer.bounds;
        self.backgroundPlayerView.frame = self.collageLayoutViewConainer.bounds;
    }
}

-(void) setupTransitionForView:(UIView *)transitionView
{
    self.transitionView = transitionView;
    
    self.transitioningDelegate = self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    if (self.transitionView != nil) {
        ZOZolaZoomTransition *zoomTransition = [ZOZolaZoomTransition transitionFromView:self.transitionView type:ZOTransitionTypePresenting duration:0.5 delegate:self];
        
        zoomTransition.fadeColor = [UIColor clearColor];
        
        return zoomTransition;
    }
    return nil;
}

- (id <UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed
{
    if (self.transitionView != nil) {
        ZOZolaZoomTransition *zoomTransition = [ZOZolaZoomTransition transitionFromView:self.transitionView type:ZOTransitionTypeDismissing duration:0.5 delegate:self];
        
        zoomTransition.fadeColor = [UIColor clearColor];
        
        return zoomTransition;
    }
    return nil;
}

- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
        startingFrameForView:(UIView *)targetView
              relativeToView:(UIView *)relativeView
          fromViewController:(UIViewController *)fromViewController
            toViewController:(UIViewController *)toViewController {
    
//    NSLog(@"starting Frame for view= %@", targetView);
//    NSLog(@"starting Frame relativeView= %@", relativeView);
//    NSLog(@"starting Frame transitionView= %@", self.transitionView);
//    NSLog(@"starting Frame collageLayoutViewConainer= %@", self.collageLayoutViewConainer);
    
    if (toViewController == self) {
        CGRect startFrame = [self.transitionView convertRect:targetView.bounds toView:relativeView];
//        NSLog(@"startFrame x= %f, y=%f, w=%f, h=%f", startFrame.origin.x, startFrame.origin.y, startFrame.size.width, startFrame.size.height);
        return startFrame;
    } else {
        [self.view layoutIfNeeded];
        
        CGRect startFrame = [self.collageLayoutViewConainer convertRect:self.collageLayoutViewConainer.bounds toView:relativeView];
//        NSLog(@"startFrame X= %f, y=%f, w=%f, h=%f", startFrame.origin.x, startFrame.origin.y, startFrame.size.width, startFrame.size.height);
        return startFrame;
    }
    
    return CGRectZero;
}

- (CGRect)zolaZoomTransition:(ZOZolaZoomTransition *)zoomTransition
       finishingFrameForView:(UIView *)targetView
              relativeToView:(UIView *)relativeView
          fromViewController:(UIViewController *)fromViewComtroller
            toViewController:(UIViewController *)toViewController {
    
//    NSLog(@"finishing Frame for view= %@", targetView);
//    NSLog(@"finishing Frame relativeView= %@", relativeView);
//    NSLog(@"finishing Frame transitionView= %@", self.transitionView);
//    NSLog(@"finishing Frame collageLayoutViewConainer= %@", self.collageLayoutViewConainer);
    
    if (toViewController == self) {
        [self.view layoutIfNeeded];
        
        CGRect finalFrame = [self.collageLayoutViewConainer convertRect:self.collageLayoutViewConainer.bounds toView:relativeView];
//        NSLog(@"finalFrame X= %f, y=%f, w=%f, h=%f", finalFrame.origin.x, finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
        return finalFrame;
    } else {
        CGRect finalFrame = [self.transitionView convertRect:self.transitionView.bounds toView:relativeView];
//        NSLog(@"finalFrame x= %f, y=%f, w=%f, h=%f", finalFrame.origin.x, finalFrame.origin.y, finalFrame.size.width, finalFrame.size.height);
        return finalFrame;
    }
    
    return CGRectZero;
}


@end
