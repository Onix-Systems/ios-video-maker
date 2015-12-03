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

@property (strong, nonatomic) VAssetCollage* assetCollage;
@property (strong, nonatomic) AssetsCollection* assetsCollection;
@property (strong, nonatomic) VSegmentsCollection* segmentsCollection;

@property (weak, nonatomic) IBOutlet UILabel *kenBurnsLabel;

@property (strong, nonatomic) PlayerView* playerView;

@property (nonatomic, strong) UIView* transitionView;

@property (nonatomic) BOOL kbEnabled;

@end

@implementation CollageCreationViewController

-(void) setupCollageWithAssets:(AssetsCollection *)assetsCollection andLayout: (CollageLayout*)collageLayout
{
    dispatch_async(dispatch_get_main_queue(), ^{
        VAssetCollage* assetCollage = [VAssetCollage new];
        assetCollage.finalSize = CGSizeMake(600, 600);
        assetCollage.assetsCollection = assetsCollection;
        assetCollage.collageLayout = collageLayout;
        assetCollage.collageEffect = kCollageEffectNone;
        
        self.kbEnabled = NO;
        if (collageLayout.frames.count == 1) {
            self.kbEnabled = YES;
        }
        self.kenBurnsLabel.enabled = self.kbEnabled;
        
        if (self.assetCollage != nil) {
            assetCollage.collageEffect = self.assetCollage.collageEffect;
        }
        self.assetCollage = assetCollage;
        
        self.assetsCollection = [AssetsCollection new];
        [self.assetsCollection addAsset:self.assetCollage];
        
        self.segmentsCollection = [VSegmentsCollection new];
        self.segmentsCollection.assetsCollection = self.assetsCollection;

        [self showUpdatedCollagePreview];
    });
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
    if (self.playerView != nil) {
        [self.playerView cleanPlayer];
    }
    
    if (self.assetCollage != nil) {
        if (self.assetCollage.collageEffect == collageEffect) {
            self.assetCollage.collageEffect = @"";
        } else {
            self.assetCollage.collageEffect = collageEffect;
        }
    }
    [self updateSwitches];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.segmentsCollection resetSegmentsState];
        [self showUpdatedCollagePreview];
    });

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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUpdatedCollagePreview];
    });

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.playerView cleanPlayer];
}

- (void) showUpdatedCollagePreview
{
    if (self.collageLayoutViewConainer == nil || self.segmentsCollection == nil) {
        return;
    }
    
    
    CGSize videoCompositionSize = CGSizeMake(600, 600);

    VideoComposition* videoComposition = [self.segmentsCollection makeVideoCompositionWithFrameSize:videoCompositionSize];
    
    if (self.segmentsCollection != nil) {
        if (self.playerView == nil) {
            self.playerView = [PlayerView new];
            self.playerView.autoRewind = YES;
            self.playerView.delegate = self;
            
            self.playerView.frame = self.collageLayoutViewConainer.bounds;
            
            [self.collageLayoutViewConainer addSubview:self.playerView];
        }
        
        [self.playerView playVideoFromAsset:videoComposition.mutableComposition videoComposition:videoComposition.mutableVideoComposition audioMix:videoComposition.mutableAudioMix autoPlay:YES];
        
        //self.playerView.renderingStats = videoComposition;
    }
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
