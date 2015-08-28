//
//  AlbumviewCollectionViewCell.m
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectCollectionViewCell.h"

@implementation ImageSelectCollectionViewCell

-(void) setAsset:(PickerAsset*) asset {
    _asset = asset;
    [self updateState];
}

- (IBAction)selectButtonAction:(id)sender {
    self.asset.selected = !self.asset.selected;
    [self updateState];
    if (!self.asset.selected && self.delegate) {
        [self.delegate assetWasUnselected];
    }
}

-(void) updateState {
    self.imageView.image = self.asset.thumbnailImage;
    
    if (self.asset.selected) {
        self.selectButton.backgroundColor = [UIColor blueColor];
        
        [self.selectButton setTitle:[NSString stringWithFormat: @"%ld", self.asset.selectionNumber] forState: UIControlStateNormal];
    } else {
        self.selectButton.backgroundColor = [UIColor clearColor];
        [self.selectButton setTitle:@" " forState: UIControlStateNormal];
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
    
    self.selectButton.layer.cornerRadius = (self.selectButton.bounds.size.height / 2);
    
    self.selectButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.selectButton.layer.borderWidth = 1.0;
    
    [self.selectButton setNeedsLayout];
}

@end
