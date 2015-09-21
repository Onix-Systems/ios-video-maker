//
//  ImageSelectPreviewController.m
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorPreviewController.h"
#import "ImageSelectorPlayerView.h"
#import "ImageSelectorScrollView.h"

@interface ImageSelectorPreviewController ()

@property (weak, nonatomic) IBOutlet ImageSelectorPlayerView *playerView;

@property (weak, nonatomic) IBOutlet ImageSelectorScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *gridImageView;

@end

@implementation ImageSelectorPreviewController

- (void)viewDidLoad
{
    self.playerView.hidden = YES;
    self.scrollView.hidden = NO;
    self.gridImageView.hidden = NO;
}

-(void) displayAsset: (VAsset*) asset autoPlay: (BOOL) autoPlay
{
    if (asset.isVideo) {
        self.playerView.hidden = NO;
        self.scrollView.hidden = YES;
        self.gridImageView.hidden = YES;
        
        [asset downloadVideoAsset:^(AVAsset *asset, AVAudioMix* audioMix) {
            [self.playerView playVideoFromAsset:asset autoPlay:autoPlay];
        }];
        
    } else {
        self.playerView.hidden = YES;
        self.scrollView.hidden = NO;
        self.gridImageView.hidden = NO;
        
        NSInteger requestTag = ++self.scrollView.tag;
        
        [asset getPreviewImageForSize:self.gridImageView.bounds.size withCompletion:^(UIImage *resultImage, BOOL requestFinished) {
            if (requestTag == self.scrollView.tag) {
                [self.scrollView displayImage: resultImage];
            }
        }];
    }

}

@end
