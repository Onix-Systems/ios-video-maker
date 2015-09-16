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

-(void) displayAsset: (PickerAsset*) asset autoPlay: (BOOL) autoPlay
{
    if (asset.isVideo) {
        self.playerView.hidden = NO;
        self.scrollView.hidden = YES;
        self.gridImageView.hidden = YES;
        
        [asset loadVideoAsset:^(AVAsset *asset) {
            [self.playerView playVideoFromAsset:asset autoPlay:autoPlay];
        }];
        
    } else {
        self.playerView.hidden = YES;
        self.scrollView.hidden = NO;
        self.gridImageView.hidden = NO;
        
        NSInteger requestTag = ++self.scrollView.tag;
        
        [asset loadOriginalImage:^(UIImage *resultImage) {
            if (requestTag == self.scrollView.tag) {
                [self.scrollView displayImage: resultImage];
            }
        }];
    }

}

@end
