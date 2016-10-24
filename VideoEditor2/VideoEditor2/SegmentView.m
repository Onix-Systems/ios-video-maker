//
//  SegmentView.m
//  VideoEditor2
//
//  Created by Alexander on 11/4/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "SegmentView.h"
#import "VAssetCollage.h"
#import "VCollageFrame.h"
#import "NSStringHelper.h"

@interface SegmentView()
@property (nonatomic) CGFloat allImagesWidth;
@end

@implementation SegmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        UITapGestureRecognizer *gestureRecogniger = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchupAction:)];
        gestureRecogniger.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:gestureRecogniger];
    }
    return self;
}

-(void)touchupAction: (UITapGestureRecognizer*) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self.delegate segmentViewTapped:self];
    }
}

-(void)changeHighlightingView:(BOOL)highlighted {
    if (highlighted) {
        self.layer.borderColor = [[UIColor yellowColor] CGColor];
        self.layer.borderWidth = 4;
    } else {
        self.layer.borderColor = [[UIColor clearColor] CGColor];
        self.layer.borderWidth = 0;
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.segment.asset.isVideo) {
        [self addedMovieImagesToView];
    } else {
        [self addedImagesByAsset:self.segment.asset allDuration:self.segment.totalDuration];
    }
}

-(void)addedImagesByAsset:(VAsset *)asset allDuration:(CMTime)duration {
    CGFloat durationSeconds = CMTimeGetSeconds(duration);
    
    CGFloat maxImageHeight = self.frame.size.height;
    
    VFrameProvider *frameProvider = [asset getFrameProvider];
    VFrameRequest* frameRequest = [VFrameRequest new];
    
    CGFloat time4Pic = 0;
    CGFloat allImagesWidth = 0;
    while (allImagesWidth < self.frame.size.width) {
        if (allImagesWidth == 0) {
            time4Pic = 0;
        } else {
            time4Pic = (allImagesWidth / self.frame.size.width ) * durationSeconds;
        }
        
        NSLog(@"%f", time4Pic);
        
        frameRequest.time = time4Pic;
        
        CIImage* frameContent = [frameProvider getFrameForRequest:frameRequest];
        CGSize imageSize = [frameProvider getOriginalSize];
        CGRect frameRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
        UIImage* segmentImage = [self.drawer renderThumbnail:frameContent frameRect:frameRect];
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:segmentImage];
        
        CGFloat heightRatio = maxImageHeight > tmp.frame.size.height ? tmp.frame.size.height / maxImageHeight : maxImageHeight / tmp.frame.size.height;
        
        CGRect currentFrame = tmp.frame;
        currentFrame.size.width = currentFrame.size.width * heightRatio;
        currentFrame.size.height = currentFrame.size.height * heightRatio;
        currentFrame.origin.x = allImagesWidth;
        
        tmp.frame = currentFrame;
        allImagesWidth += tmp.frame.size.width;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:tmp];
        });
        
        //Added last image for fill all segment view line
        if (allImagesWidth >= self.frame.size.width) {
            UIImageView *tmp = [[UIImageView alloc] initWithImage:segmentImage];
            
            CGFloat heightRatio = maxImageHeight > tmp.frame.size.height ? tmp.frame.size.height / maxImageHeight : maxImageHeight / tmp.frame.size.height;
            
            CGRect currentFrame = tmp.frame;
            currentFrame.size.width = currentFrame.size.width * heightRatio;
            currentFrame.size.height = currentFrame.size.height * heightRatio;
            currentFrame.origin.x = allImagesWidth;
            
            tmp.frame = currentFrame;
            allImagesWidth += tmp.frame.size.width;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addSubview:tmp];
            });
        }
    }
}

-(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}

-(void)addedMovieImagesToView {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.segment.asset.downloadedAsset];
    imageGenerator.requestedTimeToleranceAfter = CMTimeMake(((1.0/25)*0.55), 1);
    imageGenerator.requestedTimeToleranceBefore = CMTimeMake(((1.0/25)*0.55), 1);
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    if ([self isRetina]) {
        imageGenerator.maximumSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height * 2);
    } else {
        imageGenerator.maximumSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    
    CMTime assetTime = self.segment.asset.downloadedAsset.duration;
    
    CGFloat durationSeconds = CMTimeGetSeconds(assetTime);
    
    CGFloat maxImageHeight = self.frame.size.height;
    
    CGFloat time4Pic = 0;
    
    CGFloat allImagesWidth = 0;
    
    CGSize videoSize =  [[self.segment.asset getFrameProvider] getOriginalSize];
    
    
    CGFloat heightRatio = maxImageHeight > videoSize.height ? videoSize.height / maxImageHeight : maxImageHeight / videoSize.height;
    
    CGFloat updatedWidth = videoSize.width * heightRatio;
    
    NSMutableArray *times = [NSMutableArray new];
    while (allImagesWidth < self.frame.size.width) {
        if (allImagesWidth == 0) {
            time4Pic = 0;
        } else {
            time4Pic = (allImagesWidth / self.frame.size.width ) * durationSeconds;
        }
        
        assetTime.value = time4Pic * assetTime.timescale;
        [times addObject: [NSValue valueWithCMTime:assetTime]];
        allImagesWidth += updatedWidth;
    }
    
    //Added last times  for fill all segment view line
    [times addObject: [NSValue valueWithCMTime:assetTime]];
    
    self.allImagesWidth = 0;
    __block SegmentView *weakSelf = self;
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times.copy completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        UIImage *videoScreen = [[UIImage alloc] initWithCGImage:image];
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        
        CGFloat heightRatio = maxImageHeight > tmp.frame.size.height ? tmp.frame.size.height / maxImageHeight : maxImageHeight / tmp.frame.size.height;
        
        CGRect currentFrame = tmp.frame;
        currentFrame.size.width = currentFrame.size.width * heightRatio;
        currentFrame.size.height = currentFrame.size.height * heightRatio;
        currentFrame.origin.x = weakSelf.allImagesWidth;
        
        tmp.frame = currentFrame;
        weakSelf.allImagesWidth += tmp.frame.size.width;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:tmp];
        });
    }];
}

- (void)dealloc
{
    NSLog(@"SegmentView is dealloc");
}

@end
