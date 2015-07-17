//
//  ViewController.m
//  MediaComposerDemo
//
//  Created by Vitaliy Savchenko on 15.07.15.
//  Copyright (c) 2015 Onix. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SAVideoRangeSlider.h"

@interface ViewController () <SAVideoRangeSliderDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) SAVideoRangeSlider *mySAVideoRangeSlider;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) NSString *originalVideoPath;
@property (strong, nonatomic) NSString *tmpVideoPath;
@property (strong, nonatomic) UIScrollView *mediaScrollView;
@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat stopTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *tempDir = NSTemporaryDirectory();
    self.tmpVideoPath = [tempDir stringByAppendingPathComponent:@"tmpMov.mov"];
    
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    self.originalVideoPath = [mainBundle pathForResource: @"MaroonSugar" ofType: @"mp4"];
    NSURL *videoFileUrl = [NSURL fileURLWithPath:self.originalVideoPath];
    
    
    self.mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(0, 100, 500, 50) videoUrl:videoFileUrl ];
    self.mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
    [self.mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
    
    self.mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed: 0.996 green: 0.951 blue: 0.502 alpha: 1];
    self.mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed: 0.992 green: 0.902 blue: 0.004 alpha: 1];
    
    self.mySAVideoRangeSlider.delegate = self;
    self.mediaScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 300)];
    self.mediaScrollView .backgroundColor = [UIColor grayColor];
    [self.mediaScrollView  addSubview:self.mySAVideoRangeSlider];
    self.mediaScrollView .contentSize = CGSizeMake(self.mySAVideoRangeSlider.frame.size.width, 0);
    
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changContentSize:)];
    recognizer.delegate = self;
    [self.mediaScrollView  addGestureRecognizer:recognizer];

    [self.view addSubview:self.mediaScrollView ];
}

-(void)changContentSize:(UIPinchGestureRecognizer *)gestureRecognizer {

    CGFloat lastScale = [gestureRecognizer scale];

    CGRect newFrame = self.mySAVideoRangeSlider.frame;
    if (lastScale > 1) {
        newFrame.size.width += 10;
    } else {
        newFrame.size.width -= 10;
    }

    self.mySAVideoRangeSlider.frame = newFrame;

    self.mediaScrollView .contentSize = CGSizeMake(self.mySAVideoRangeSlider.frame.size.width, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelBtnTouchUpInside:(id)sender {
    [self playMovie:self.originalVideoPath];
}

-(void)playMovie: (NSString *) path{
//    NSURL *url = [NSURL fileURLWithPath:path];
//    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
//    [self presentMoviePlayerViewControllerAnimated:theMovie];
//    theMovie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
//    [theMovie.moviePlayer play];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *video1 = [mainBundle pathForResource: @"MaroonSugar" ofType: @"mp4"];
    NSString *video2 = [mainBundle pathForResource: @"WizKhalifaFurious" ofType: @"mp4"];
    
//    NSArray *videoClipPaths = @[video1,video2];
    NSArray *videoClipPaths = [NSArray arrayWithObjects:[NSURL fileURLWithPath:video1], [NSURL fileURLWithPath:video2], nil];
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSError * error = nil;
    NSMutableArray * timeRanges = [NSMutableArray arrayWithCapacity:videoClipPaths.count];
    NSMutableArray * tracks = [NSMutableArray arrayWithCapacity:videoClipPaths.count];
    for (int i=0; i<[videoClipPaths count]; i++) {
        AVAsset *assetClip = [[AVURLAsset alloc] initWithURL:videoClipPaths[i] options:nil];
        AVAssetTrack *clipVideoTrackB = [[assetClip tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        
        [timeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(kCMTimeZero, assetClip.duration)]];
        [tracks addObject:clipVideoTrackB];
    }
    [compositionTrack insertTimeRanges:timeRanges ofTracks:tracks atTime:kCMTimeZero error:&error];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    NSParameterAssert(exporter != nil);
    NSArray *t;
    NSString *u;
    
    t = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    u = [t objectAtIndex:0];
    NSString *finalPath = [u stringByAppendingPathComponent:@"final.mov"];
    NSURL *lastURL = [NSURL fileURLWithPath:finalPath];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.outputURL = lastURL;
    [exporter exportAsynchronouslyWithCompletionHandler:^(void){
        switch (exporter.status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"exporting failed");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporting completed");
                //UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, nil, NULL);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"export cancelled");
                break;
        }
    }];
}

- (IBAction)trimBtnTouchUpInside:(id)sender {
    
    [self deleteTmpFile];
    
    NSURL *videoFileUrl = [NSURL fileURLWithPath:self.originalVideoPath];
    
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:videoFileUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:anAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:anAsset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        
        NSURL *furl = [NSURL fileURLWithPath:self.tmpVideoPath];
        
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        
        CMTime start = CMTimeMakeWithSeconds(self.startTime, anAsset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime-self.startTime, anAsset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self playMovie:self.tmpVideoPath];
                    });
                    
                    break;
            }
        }];
        
    }
}

-(void)deleteTmpFile{
    
    NSURL *url = [NSURL fileURLWithPath:self.tmpVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}

#pragma mark - SAVideoRangeSliderDelegate

- (void)videoRange:(SAVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    self.startTime = leftPosition;
    self.stopTime = rightPosition;
    
}

@end
