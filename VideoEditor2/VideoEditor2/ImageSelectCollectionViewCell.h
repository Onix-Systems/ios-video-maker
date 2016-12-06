//
//  AlbumviewCollectionViewCell.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PickerAsset.h"

@protocol ImageSelectCollectionViewCellDelegate
@required
-(void) assetWasUnselected;
@end

@interface ImageSelectCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) PickerAsset* asset;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel;

@property (weak, nonatomic) id<ImageSelectCollectionViewCellDelegate> delegate;

@end
