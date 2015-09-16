//
//  ImageSelectorCollectionViewCell.m
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorCollectionViewCell.h"

@interface ImageSelectorCollectionViewCell () <ImageSelectorStateIndicatorDelegate>

@end

@implementation ImageSelectorCollectionViewCell

-(void) setAsset:(PickerAsset*) asset {
    _asset = asset;
    asset.progressIndicator = self.stateIndicator;
    self.imageView.image = nil;
    [self updateState];
}

-(void)stateIndicatorTouchUpInsideAction {
    self.asset.selected = !self.asset.selected;
    [self updateState];
    
}

-(void) updateState {
    NSInteger currentTag = self.imageView.tag + 1;
    self.imageView.tag = currentTag;
    
    __weak ImageSelectorCollectionViewCell* weakSelf = self;
    
    [self.asset loadThumbnailImage: ^(UIImage* resultImage) {
        if (resultImage != nil && weakSelf.imageView.tag == currentTag) {
            weakSelf.imageView.image = resultImage;
            [weakSelf setNeedsDisplay];
        }
    }];
    
    self.stateIndicator.delegate = self;
    [self.stateIndicator setClearState];
    
    if (self.asset.selected) {
        [self.stateIndicator setSelected: self.asset.selectionNumber];
    }
    
    if (self.asset.isVideo) {
        double seconds = round(self.asset.duration.doubleValue);
        double minutes = floor(seconds / 60);
        seconds = seconds - minutes*60;
        
        self.videoDurationLabel.text = [NSString stringWithFormat:@"%.0f:%02.0f", minutes, seconds];
        self.videoDurationLabel.hidden = NO;
    } else {
        self.videoDurationLabel.hidden = YES;
    }
}
@end
