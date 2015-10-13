//
//  ImageSelectorCollageController.m
//  VideoEditor2
//
//  Created by Alexander on 9/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorCollageController.h"
#import "CollageLayoutSelectorView.h"
#import "CollageLayoutView.h"
#import "CollageCreationViewController.h"

@interface ImageSelectorCollageController () <UIScrollViewDelegate, CollageLayoutSelectorViewDelegate>

@property (weak, nonatomic) IBOutlet CollageLayoutSelectorView *layoutsView;
@property (nonatomic, weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) NSInteger destinationPageNo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacingConstraint;
@property (nonatomic) CGFloat originalBottomSpacing;

@end

@implementation ImageSelectorCollageController

-(void) viewDidLoad {
    
    self.originalBottomSpacing = self.bottomSpacingConstraint.constant;
    
    self.destinationPageNo = -1;
    
    self.layoutsView.delegate = self;
    self.layoutsView.collageLayoutSelectorDelegate = self;
    
    self.pageControl.numberOfPages = [self.layoutsView getCollageLayoutViews].count;
}

-(void) setAssetsCollection:(AssetsCollection *)assetsCollection {
    [self.layoutsView cleanExisitngCoollageLayoutViews];
    
    _assetsCollection = assetsCollection;
    
    [self.layoutsView addCoollageLayoutViewForCollageLaout: [CollageLayout layoutWithFrames:
                                                             @[
                                                               [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)]
                                                               ]] withAssetsCollection: self.assetsCollection];
    
    [self.layoutsView addCoollageLayoutViewForCollageLaout: [CollageLayout layoutWithFrames:
                                                             @[
                                                               [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(0, 1, 1, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                                                               ]] withAssetsCollection: self.assetsCollection];
    
    [self.layoutsView addCoollageLayoutViewForCollageLaout: [CollageLayout layoutWithFrames:
                                                             @[
                                                               [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 2)],
                                                               [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 2)]
                                                               ]] withAssetsCollection: self.assetsCollection];

    [self.layoutsView addCoollageLayoutViewForCollageLaout: [CollageLayout layoutWithFrames:
                                                             @[
                                                               [NSValue valueWithCGRect:CGRectMake(0, 0, 2, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(0, 1, 2, 1)]
                                                               ]] withAssetsCollection: self.assetsCollection];
    
    [self.layoutsView addCoollageLayoutViewForCollageLaout: [CollageLayout layoutWithFrames:
                                                             @[
                                                               [NSValue valueWithCGRect:CGRectMake(0, 0, 2, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(0, 1, 1, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                                                               ]] withAssetsCollection: self.assetsCollection];
    
    [self.layoutsView addCoollageLayoutViewForCollageLaout: [CollageLayout layoutWithFrames:
                                                             @[
                                                               [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(0, 1, 2, 1)]
                                                               ]] withAssetsCollection: self.assetsCollection];
    
    [self.layoutsView addCoollageLayoutViewForCollageLaout: [CollageLayout layoutWithFrames:
                                                             @[
                                                               [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 2)],
                                                               [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                                                               [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                                                               ]] withAssetsCollection: self.assetsCollection];

    self.pageControl.numberOfPages = [self.layoutsView getCollageLayoutViews].count;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.destinationPageNo < 0) {
        self.pageControl.currentPage = [self.layoutsView getCurrentPageNo];
    } else {
        if (self.destinationPageNo == [self.layoutsView getCurrentPageNo]) {
            self.destinationPageNo = -1;
        }
    }
}

- (IBAction)pageControlValueChanged:(UIPageControl *)sender {
    self.destinationPageNo = self.pageControl.currentPage;
    [self.layoutsView setCurrentPageNo:self.pageControl.currentPage];
}

- (void) viewWillLayoutSubviews
{
    CGFloat height = self.view.bounds.size.height;
    
    if (height > 300) {
        self.pageControl.hidden = NO;
        self.pageControl.alpha = 1;
        self.bottomSpacingConstraint.constant = self.originalBottomSpacing;
        
    } else if (height > 250) {
        self.pageControl.hidden = NO;
        self.pageControl.alpha = (height - 250) / 50;
        self.bottomSpacingConstraint.constant = self.originalBottomSpacing;
        
    } else if (height > 200) {
        self.pageControl.hidden = NO;
        self.pageControl.alpha = 0;
        self.bottomSpacingConstraint.constant = self.originalBottomSpacing * ((height - 200) / 50);
        
    } else {
        self.pageControl.hidden = YES;
        self.bottomSpacingConstraint.constant = 0;
    }
}

-(void)willStartResizing
{
    [self.layoutsView willStartResizing];
}

-(void)didFinishedResizing
{
    [self.layoutsView didFinishedResizing];
    self.pageControl.currentPage = [self.layoutsView getCurrentPageNo];
}

-(void) collageLayoutSelectorGotSelectedLayout: (CollageLayoutView*) collageLayoutView
{
    if ([collageLayoutView.assetsCollection getAssets].count <= 0) {
        //do nothing
        return;
    }
    
    CollageCreationViewController* collageCreationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollageCreationViewController"];
    
    [collageCreationViewController setupCollageWithAssets:collageLayoutView.assetsCollection andLayout:collageLayoutView.collageLayout];
    
    [self presentViewController:collageCreationViewController animated:YES completion:^{
    }];

}

@end
