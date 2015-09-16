//
//  ImageSelectorCollectionViewCell.h
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PickerAsset.h"
#import "ImageSelectorStateIndicator.h"

@interface ImageSelectorCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) PickerAsset* asset;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel;
@property (weak, nonatomic) IBOutlet ImageSelectorStateIndicator *stateIndicator;

//@property (weak, nonatomic) id<ImageSelectCollectionViewCellDelegate> delegate;

@end
