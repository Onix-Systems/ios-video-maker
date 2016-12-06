//
//  ImageSelectorCollageController.h
//  VideoEditor2
//
//  Created by Alexander on 9/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AssetsCollection.h"

@class ImageSelectorSplitController;

@interface ImageSelectorCollageController : UIViewController

@property (nonatomic, weak) AssetsCollection* assetsCollection;

@property (nonatomic, weak) ImageSelectorSplitController* parentSplitController;

-(void)willStartResizing;
-(void)didFinishedResizing;

@end
