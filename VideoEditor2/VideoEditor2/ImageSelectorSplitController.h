//
//  ImageSelectSplitController.h
//  VideoEditor2
//
//  Created by Alexander on 9/8/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "VAsset.h"

@protocol ImageSelectorSplitControllerDelegate

-(void)willStartVerticalResizing;
-(void)didFinishedVertivalResizing;

-(void)willPresentLeftController;
-(void)willPresentRightController;

@end

@interface ImageSelectorSplitController : UIViewController

@property (nonatomic, strong) UIViewController* leftViewController;
@property (nonatomic, strong) UIViewController* rightViewController;
@property (nonatomic, strong) UIViewController* bottomViewController;

@property (nonatomic, weak) id<ImageSelectorSplitControllerDelegate> delegate;

- (void) scrollTopViewToTop: (BOOL) toTop;
- (void) scrollLeftViewToLeft: (BOOL) toLeft;

- (void) displayAssetPreview: (VAsset*) asset autoPlay: (BOOL) autoPlay;


@end
