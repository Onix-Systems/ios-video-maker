//
//  CollageCreationViewController.h
//  VideoEditor2
//
//  Created by Alexander on 9/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CollageLayoutView.h"


@protocol CollageCreationViewControllerDelegate

-(void)cancelCollage;
-(void)saveCollage: (VAsset*) collage;

@end

@interface CollageCreationViewController : UIViewController

@property (nonatomic) id<CollageCreationViewControllerDelegate>delegate;

-(void) setupCollageWithAssets:(AssetsCollection *)assetsCollection andLayout: (CollageLayout*)collageLayout;

-(void) setupTransitionForView:(UIView *)transitionView;

@end