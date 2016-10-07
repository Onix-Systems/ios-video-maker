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

@interface SegmentView()
@property (nonatomic) CGFloat allImagesWidth2;
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

-(void) touchupAction: (UITapGestureRecognizer*) sender
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

- (void) drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGContextClearRect(context, self.bounds);
//    
//    CGContextSetRGBFillColor(context, 1.0, 0.5, 0.5, 1.0);
//    CGContextFillRect(context, self.bounds);
//    
//    CGRect frameRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
//    
//    UIImage* segmentImage = [self.drawer renderThumbnail:[self.segment getFrameForTime:self.segment.cropTimeRange.start frameSize: frameRect.size] frameRect:frameRect];
//    [segmentImage drawInRect:frameRect];
    
//    [self getMovieFrame];

    if (self.segment.asset.isVideo) {
//        [self addedMovieImagesToView];
        
        self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.segment.asset.downloadedAsset];
        self.imageGenerator.appliesPreferredTrackTransform = YES;
        
        if ([self isRetina]) {
            self.imageGenerator.maximumSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height * 2);
        } else {
            self.imageGenerator.maximumSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        }
        
        
        _durationSeconds = CMTimeGetSeconds([self.segment.asset.downloadedAsset duration]);
        
        
//        CMTime thumbTime = CMTimeMakeWithSeconds(30,30);
//        
//        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
//            if (result != AVAssetImageGeneratorSucceeded) {
//                NSLog(@"couldn't generate thumbnail, error:%@", error);
//            }
//            UIImage *videoScreen = [[UIImage alloc] initWithCGImage:im];
//            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
//        };
//        
//        CGSize maxSize = CGSizeMake(128, 128);
//        self.imageGenerator.maximumSize = maxSize;
//        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
        
        
        
        int picMaxHeight = self.frame.size.height;
        
        CGFloat time4Pic = 0;
        
        CGFloat allImagesWidth = 0;
        
        NSMutableArray *times = [NSMutableArray new];
        CGSize videoSize =  [[self.segment.asset getFrameProvider] getOriginalSize];
        
        while (allImagesWidth < self.frame.size.width) {
            if (allImagesWidth == 0) {
                time4Pic = 0;
            } else {
                time4Pic = (allImagesWidth / self.frame.size.width ) * _durationSeconds;
            }
            
            [times addObject: [NSValue valueWithCMTime:CMTimeMake(time4Pic, 1)]];
            
            NSLog(@"%f", time4Pic);
            
            
            UIImageView *tmp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, videoSize.width, videoSize.height)];
            
            CGFloat heightRatio = picMaxHeight > tmp.frame.size.height ? tmp.frame.size.height / picMaxHeight : picMaxHeight / tmp.frame.size.height;
            
            CGRect currentFrame = tmp.frame;
            currentFrame.size.width = currentFrame.size.width * heightRatio;
            currentFrame.size.height = currentFrame.size.height * heightRatio;
            currentFrame.origin.x = allImagesWidth;
            
            tmp.frame = currentFrame;
            allImagesWidth += tmp.frame.size.width;
        }
        
        self.allImagesWidth2 = 0;
        __block SegmentView *weakSelf = self;
        [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times.copy completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
            UIImage *videoScreen = [[UIImage alloc] initWithCGImage:image];
            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
            
            CGFloat heightRatio = picMaxHeight > tmp.frame.size.height ? tmp.frame.size.height / picMaxHeight : picMaxHeight / tmp.frame.size.height;
            
            CGRect currentFrame = tmp.frame;
            currentFrame.size.width = currentFrame.size.width * heightRatio;
            currentFrame.size.height = currentFrame.size.height * heightRatio;
            currentFrame.origin.x = weakSelf.allImagesWidth2;
            
            tmp.frame = currentFrame;
            weakSelf.allImagesWidth2 += tmp.frame.size.width;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addSubview:tmp];
            });

        }];
        
        
    } else {
        [self addedImagesByAsset:self.segment.asset allDuration:self.segment.totalDuration];
    }

//    if (self.segment.asset.isVideo) {
//        [self addedMovieImagesToView];
//    }
//    else if ([self.segment.asset isKindOfClass:[VAssetCollage class]]) {
////        VAssetCollage * collage = (VAssetCollage *)self.segment.asset;
////        
//////        VAsset * asset = [collage.assetsCollection getAssets].firstObject;
////        
////        VFrameRequest* frameRequest = [VFrameRequest new];
////        frameRequest.time = 2;
////        
////        VFrameProvider *frameProvider = [collage getFrameProvider];
//////        frameProvider.finalSize = CGSizeMake(600, 600);
////        
////        
////        
////        CIImage* frameContent = [frameProvider getFrameForRequest:frameRequest];
////        CGSize imageSize = [frameProvider getOriginalSize];
////        CGRect frameRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
////        UIImage* segmentImage = [self.drawer renderThumbnail:frameContent frameRect:frameRect];
////        
////        UIImageView *tmp = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
////        tmp.image = segmentImage;
////        [self addSubview:tmp];
//        
//        
//        _durationSeconds = CMTimeGetSeconds(self.segment.totalDuration);
//        
//        int picMaxHeight = self.frame.size.height;
//        
//        CGFloat time4Pic = 0;
//        
//        VAssetCollage * collage = (VAssetCollage *)self.segment.asset;
//        VFrameProvider *frameProvider = [collage getFrameProvider];
//        VFrameRequest* frameRequest = [VFrameRequest new];
//        
//        CGFloat allImagesWidth = 0;
//        while (allImagesWidth < self.frame.size.width) {
//            if (allImagesWidth == 0) {
//                time4Pic = 0;
//            } else {
//                time4Pic = (allImagesWidth / self.frame.size.width ) * _durationSeconds;
//            }
//            
//            NSLog(@"%f", time4Pic);
//            
//            frameRequest.time = time4Pic;
//
//            CIImage* frameContent = [frameProvider getFrameForRequest:frameRequest];
//            CGSize imageSize = [frameProvider getOriginalSize];
//            CGRect frameRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
//            UIImage* segmentImage = [self.drawer renderThumbnail:frameContent frameRect:frameRect];
//            
//            
//            UIImageView *tmp = [[UIImageView alloc] initWithImage:segmentImage];
//            
//            CGFloat heightRatio = picMaxHeight > tmp.frame.size.height ? tmp.frame.size.height / picMaxHeight : picMaxHeight / tmp.frame.size.height;
//            
//            CGRect currentFrame = tmp.frame;
//            currentFrame.size.width = currentFrame.size.width * heightRatio;
//            currentFrame.size.height = currentFrame.size.height * heightRatio;
//            currentFrame.origin.x = allImagesWidth;
//            
//            tmp.frame = currentFrame;
//            allImagesWidth += tmp.frame.size.width;
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self addSubview:tmp];
//            });
//        }
//        
//        
//        
//        
////        [self addImageToView:videoScreen];
//        NSLog(@"d");
//    }
//    else {
////        [self addImageToView:self.segment.asset.downloadedImage];
//        [self addedImagesByAsset:self.segment.asset allDuration:self.segment.totalDuration];
//    }
}

-(void)addedImagesByAsset:(VAsset *)asset allDuration:(CMTime)duration {
    _durationSeconds = CMTimeGetSeconds(duration);
    
    int picMaxHeight = self.frame.size.height;
    
    CGFloat time4Pic = 0;
    
//    VAssetCollage * collage = (VAssetCollage *)self.segment.asset;
    VFrameProvider *frameProvider = [asset getFrameProvider];
    VFrameRequest* frameRequest = [VFrameRequest new];
    
    CGFloat allImagesWidth = 0;
    while (allImagesWidth < self.frame.size.width) {
        if (allImagesWidth == 0) {
            time4Pic = 0;
        } else {
            time4Pic = (allImagesWidth / self.frame.size.width ) * _durationSeconds;
        }
        
        NSLog(@"%f", time4Pic);
        
        frameRequest.time = time4Pic;
        
        CIImage* frameContent = [frameProvider getFrameForRequest:frameRequest];
        CGSize imageSize = [frameProvider getOriginalSize];
        CGRect frameRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
        UIImage* segmentImage = [self.drawer renderThumbnail:frameContent frameRect:frameRect];
        
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:segmentImage];
        
        CGFloat heightRatio = picMaxHeight > tmp.frame.size.height ? tmp.frame.size.height / picMaxHeight : picMaxHeight / tmp.frame.size.height;
        
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

-(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            
            ([UIScreen mainScreen].scale == 2.0));
}

- (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

-(void)addedMovieImagesToView {
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.segment.asset.downloadedAsset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    if ([self isRetina]) {
        self.imageGenerator.maximumSize = CGSizeMake(self.frame.size.width * 2, self.frame.size.height * 2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    
    NSError *error;
    CMTime actualTime;
    
    _durationSeconds = CMTimeGetSeconds([self.segment.asset.downloadedAsset duration]);
    
    int picMaxHeight = self.frame.size.height;
    
    CGFloat time4Pic = 0;
    
    CGFloat allImagesWidth = 0;
    int time = 0;
    while (allImagesWidth < self.frame.size.width) {
        if (allImagesWidth == 0) {
            time4Pic = 0;
        } else {
            time4Pic = (allImagesWidth / self.frame.size.width ) * _durationSeconds;
        }
        
//        NSLog(@"%f", self.frame.size.width);
        NSLog(@"%f", time4Pic);
        
        CMTime timeFrame = CMTimeMakeWithSeconds(time4Pic, 600);
        
        CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:timeFrame
                                                              actualTime:&actualTime
                                                                   error:&error];
//        CMTime *times = CMTimeMake(time4Pic, 1);
       
        
        time++;
        
        UIImage *videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        
        if (videoScreen == nil) {
            break;
        }
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        
        CGFloat heightRatio = picMaxHeight > tmp.frame.size.height ? tmp.frame.size.height / picMaxHeight : picMaxHeight / tmp.frame.size.height;
        
        CGRect currentFrame = tmp.frame;
        currentFrame.size.width = currentFrame.size.width * heightRatio;
        currentFrame.size.height = currentFrame.size.height * heightRatio;
        currentFrame.origin.x = allImagesWidth;
        
        tmp.frame = currentFrame;
        allImagesWidth += tmp.frame.size.width;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:tmp];
        });
        
        CGImageRelease(halfWayImage);
    }
}

-(void)addImageToView:(UIImage *)image {
    
    int picMaxHeight = self.frame.size.height;
    
    CGFloat allImagesWidth = 0;
    while (allImagesWidth < self.frame.size.width) {
        UIImageView *tmp = [[UIImageView alloc] initWithImage:image];
        
        CGFloat heightRatio = picMaxHeight > tmp.frame.size.height ? tmp.frame.size.height / picMaxHeight : picMaxHeight / tmp.frame.size.height;
        
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



-(void)getMovieFrame{
    
//    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:_videoUrl options:nil];
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.segment.asset.downloadedAsset];
    self.imageGenerator.appliesPreferredTrackTransform = YES;
    
    if ([self isRetina]){
        self.imageGenerator.maximumSize = CGSizeMake(self.frame.size.width*2, self.frame.size.height*2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    
    
    
    // First image
    NSError *error;
    CMTime actualTime;
//    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
//    if (halfWayImage != NULL) {
//        UIImage *videoScreen;
//        if ([self isRetina]){
//            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
//        } else {
//            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
//        }
//        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
//        CGRect rect=tmp.frame;
//        rect.size.width=picWidth;
//        tmp.frame=rect;
//        [self addSubview:tmp];
//        picWidth = tmp.frame.size.width;
//        CGImageRelease(halfWayImage);
//    }
    
    
    _durationSeconds = CMTimeGetSeconds([self.segment.asset.downloadedAsset duration]);
    
    int picWidth = self.frame.size.height; // / _durationSeconds;
    
    int picsCnt = ceil(self.frame.size.width / picWidth);
    
    NSMutableArray *allTimes = [[NSMutableArray alloc] init];
    
    int time4Pic = 0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        // Bug iOS7 - generateCGImagesAsynchronouslyForTimes
        int prefreWidth=0;
        for (int i=0, ii=0; i<picsCnt; i++){
            time4Pic = (i+1)*picWidth;
            
            CMTime timeFrame = CMTimeMakeWithSeconds(_durationSeconds*time4Pic/self.frame.size.width, 600);
            
//            [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
            
            
            CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
            
            UIImage *videoScreen;
            if ([self isRetina]){
                
//                [self orientationForTrack:self.segment.asset.downloadedAsset];
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
//                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
            } else {
                videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
            }
            
            
            
            UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
            
            CGFloat heightRatio = picWidth > tmp.frame.size.height ? tmp.frame.size.height / picWidth : picWidth / tmp.frame.size.height;
            
            CGFloat widthRatio = picWidth > tmp.frame.size.width ? tmp.frame.size.width / picWidth : picWidth / tmp.frame.size.width;
            
            CGRect currentFrame = tmp.frame;
            currentFrame.size.width = currentFrame.size.width * heightRatio;
            currentFrame.size.height = currentFrame.size.height * heightRatio;
            currentFrame.origin.x = ii*currentFrame.size.width;
            
//            currentFrame.size.width=picWidth;
//            prefreWidth+=currentFrame.size.width;
//            
//            if( i == picsCnt-1){
//                currentFrame.size.width-=6;
//            }
            tmp.frame = currentFrame;
//            int all = (ii)*tmp.frame.size.width;
            
//            if (all > self.frame.size.width){
//                int delta = all - self.frame.size.width;
//                currentFrame.size.width -= delta;
//            }
            
            ii++;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addSubview:tmp];
            });
            CGImageRelease(halfWayImage);
            
        }
        
        
        return;
    }
    
    for (int i=1; i<picsCnt; i++){
        time4Pic = i*picWidth;
        
        CMTime timeFrame = CMTimeMakeWithSeconds(_durationSeconds*time4Pic/self.frame.size.width, 600);
        
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    
    NSArray *times = allTimes;
    
    __block int i = 1;
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times
                                              completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime,
                                                                  AVAssetImageGeneratorResult result, NSError *error) {
                                                  
                                                  if (result == AVAssetImageGeneratorSucceeded) {
                                                      
                                                      
                                                      UIImage *videoScreen;
                                                      if ([self isRetina]){
                                                          videoScreen = [[UIImage alloc] initWithCGImage:image scale:2.0 orientation:UIImageOrientationUp];
                                                      } else {
                                                          videoScreen = [[UIImage alloc] initWithCGImage:image];
                                                      }
                                                      
                                                      
                                                      UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
                                                      
                                                      int all = (i+1)*tmp.frame.size.width;
                                                      
                                                      
                                                      CGRect currentFrame = tmp.frame;
                                                      currentFrame.origin.x = i*currentFrame.size.width;
                                                      if (all > self.frame.size.width){
                                                          int delta = all - self.frame.size.width;
                                                          currentFrame.size.width -= delta;
                                                      }
                                                      tmp.frame = currentFrame;
                                                      i++;
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self addSubview:tmp];
                                                      });
                                                      
                                                  }
                                                  
                                                  if (result == AVAssetImageGeneratorFailed) {
                                                      NSLog(@"Failed with error: %@", [error localizedDescription]);
                                                  }
                                                  if (result == AVAssetImageGeneratorCancelled) {
                                                      NSLog(@"Canceled");
                                                  }
                                              }];
}




@end
