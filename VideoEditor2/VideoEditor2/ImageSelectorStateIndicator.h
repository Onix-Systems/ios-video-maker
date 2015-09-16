//
//  ImageSelectorStateIndicator.h
//  VideoEditor2
//
//  Created by Alexander on 9/14/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PickerAsset.h"

@protocol ImageSelectorStateIndicatorDelegate

-(void)stateIndicatorTouchUpInsideAction;

@end

@interface ImageSelectorStateIndicator : UIView <PickerAssetDownloadProgressIndicator>

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *borderShadowColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *downloadColor;
@property (nonatomic, weak) id<ImageSelectorStateIndicatorDelegate> delegate;


-(void)setClearState;
-(void)setSelected: (NSInteger) selectionNumber;
-(void)setDownloadingProgress: (CGFloat) downloadPercent;


@end
