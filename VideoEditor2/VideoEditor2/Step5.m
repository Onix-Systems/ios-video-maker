//
//  Step5.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "Step5.h"

#import "PlayerView.h"
#import "VDocument.h"
#import "APLCompositionDebugView.h"
#import "SegmentsCollectionView.h"
#import "VEButton.h"
#import "Step3.h"
#import "NSStringHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface Step5 () <PlayerViewDelegate, SegmentsCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *createFilmView;
@property (weak, nonatomic) IBOutlet UIButton *createFilmButton;
@property (weak, nonatomic) IBOutlet UIImageView *createFilmImage;
@property (weak, nonatomic) IBOutlet PlayerView *playerView;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet VEButton *deleteButton;

@property (weak, nonatomic) VSegmentsCollection* segmentsCollection;
@property (weak, nonatomic) IBOutlet SegmentsCollectionView *segmentsCollectionView;

@property (strong, nonatomic) AVAsset* currentDebugViewAsset;

@property (strong, nonatomic) VideoComposition* videoComposition;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic) BOOL isVideoSuspended;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@end

@implementation Step5

-(void)viewDidLoad {
    [super viewDidLoad];
    self.createFilmButton.layer.cornerRadius = 4;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.playButton.enabled = NO;
    
    self.playerView.delegate = self;
    
    self.segmentsCollectionView.delegate = self;
    
    self.isVideoSuspended = NO;
    
    [self.deleteButton setEnabledWithAplha:NO];
    
    [self configureView];
}

-(void)configureView {
    [[VDocument getCurrentDocument] updateAssetsCollection];
    self.videoComposition = [[VDocument getCurrentDocument].segmentsCollection makeVideoCompositionWithFrameSize:CGSizeMake(1280, 720)];
    
    [self.playerView playVideoFromAsset:self.videoComposition.mutableComposition videoComposition:self.videoComposition.mutableVideoComposition audioMix:self.videoComposition.mutableAudioMix autoPlay:NO];
    
    self.segmentsCollection = [VDocument getCurrentDocument].segmentsCollection;
    self.segmentsCollectionView.segmentsCollection = self.segmentsCollection;
    
    if (self.segmentsCollection.segmentsCount && self.segmentsCollection.segmentsCount > 0) {
        self.createFilmView.hidden = YES;
        self.createFilmImage.hidden = YES;
        self.saveButton.enabled = YES;
        self.saveButton.alpha = 1.0;
    } else {
        self.createFilmView.hidden = NO;
        self.createFilmImage.hidden = NO;
        self.saveButton.enabled = NO;
        self.saveButton.alpha = 0.5;
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.playerView cleanPlayer];
}

- (IBAction)saveButtonAction:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video exporting" message:@"The video will be saved to your Photo Library" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelButton];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.playerView.isPlayingNow) {
            [self.playerView pause];
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.videoComposition exportMovieToFileWithCompletion:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *title = @"Video Saved";
            NSString *message = @"Saved To Photo Album";
            
            if (error) {
                title = @"Error";
                message = @"Video Saving Failed";
            }
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:okButton];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }];
        
    }];
    [alertController addAction:okButton];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)playButtonAction:(id)sender
{
    if (self.playerView.isPlayingNow) {
        [self.playerView pause];
    } else {
        if (self.playerView.isReadyToPlay) {
            [self.playerView play];
        }
    }
}

- (IBAction)fastBackButtonAction:(id)sender {
    
}

- (IBAction)backButtonAction:(id)sender {
    [self.playerView.player seekToTime: kCMTimeZero];
}

- (IBAction)fastForwardButtonAction:(id)sender {
}

- (IBAction)forwardButtonAction:(id)sender {
    [self.playerView.player seekToTime: [self.playerView maxDuration]];
}

- (IBAction)deleteButtonAction:(id)sender {
    [[VDocument getCurrentDocument].assetsCollection removeAsset:[self.segmentsCollectionView getSelectedSegment]];
    [self.segmentsCollectionView endEditing:YES];
    [self configureView];
}

- (IBAction)addButtonAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    Step3 *vc = [storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerStep3"];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void) playerStateDidChanged: (PlayerView*) playerView
{
    if (self.playerView.isReadyToPlay) {
        self.playButton.enabled = YES;
        if (self.currentDebugViewAsset != self.videoComposition.mutableComposition) {
            self.currentDebugViewAsset = self.videoComposition.mutableComposition;
        }

        if (self.playerView.isPlayingNow) {
            [self.playButton setImage:[UIImage imageNamed:@"Pause-1"] forState:UIControlStateNormal];
        } else {
            [self.playButton setImage:[UIImage imageNamed:@"Play-1"] forState:UIControlStateNormal];
        }
    } else {
        self.playButton.enabled = NO;
    }
}

-(void) playerTimeDidChanged:(PlayerView *)playerView
{
    [self updateTimeLabel:playerView.playerTime maxDuration:[playerView maxDuration]];
    [self.segmentsCollectionView synchronizeToPlayerTime:CMTimeGetSeconds(playerView.playerTime)];
}

- (void)playerUpdatedDuration:(PlayerView *)playerView {
    [self updateTimeLabel:playerView.playerTime maxDuration:[playerView maxDuration]];
}

-(void)updateTimeLabel:(CMTime)currentTime maxDuration:(CMTime)duration {
    NSString *currentStr = [NSStringHelper stringFromTimeInterval:CMTimeGetSeconds(currentTime)];
    NSString *durationStr = [NSStringHelper stringFromTimeInterval:CMTimeGetSeconds(duration)];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", currentStr, durationStr];
}

#pragma SegmentsCollectionViewDelegate
-(void) willStartScrolling
{
    if (self.playerView.isPlayingNow) {
        self.isVideoSuspended = YES;
        [self.playerView pause];
    }
}

-(void) didScrollToTime:(double)time
{
    [self.playerView.player seekToTime:CMTimeMakeWithSeconds(time, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)didFinishScrolling
{
    if (self.isVideoSuspended) {
        self.isVideoSuspended = NO;
        [self.playerView play];
    }
}

- (void)assetSelected:(VAsset *)asset {
    [self.deleteButton setEnabledWithAplha:YES];
}

- (void)assetDeselected:(VAsset *)asset {
    [self.deleteButton setEnabledWithAplha:NO];
}

- (void)panGestureAction:(UITapGestureRecognizer *)sender {
    [self.segmentsCollectionView deselectSelectedSegmentView];
}

@end
