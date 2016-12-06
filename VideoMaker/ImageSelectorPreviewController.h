//
//  ImageSelectPreviewController.h
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VAsset.h"

@interface ImageSelectorPreviewController : UIViewController

-(void) displayAsset: (VAsset*) asset autoPlay: (BOOL) autoPlay;
@end
