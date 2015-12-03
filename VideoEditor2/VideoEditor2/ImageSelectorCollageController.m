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
    [super viewDidLoad];
    
    self.originalBottomSpacing = self.bottomSpacingConstraint.constant;
    
    self.destinationPageNo = -1;
    
    self.layoutsView.delegate = self;
    self.layoutsView.collageLayoutSelectorDelegate = self;
    
    self.pageControl.numberOfPages = [self.layoutsView getCollageLayoutViews].count;
}

-(void) setAssetsCollection:(AssetsCollection *)assetsCollection {
    [self.layoutsView cleanExisitngCoollageLayoutViews];
    
    _assetsCollection = assetsCollection;
    
    CollageLayout* layout = nil;
    
    layout = [CollageLayout new];
    [layout setFrames: @[
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)]
                         ]];
    [self.layoutsView addCoollageLayoutViewForCollageLayout:layout];
    
    layout = [CollageLayout new];
    [layout setFrames: @[
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)],
                         [NSValue valueWithCGRect:CGRectMake(0, 1, 1, 1)],
                         [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                         [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                         ]];
    [self.layoutsView addCoollageLayoutViewForCollageLayout:layout];

    
    layout = [CollageLayout new];
    [layout setFrames: @[
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 2)],
                         [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 2)]
                         ]];
    [self.layoutsView addCoollageLayoutViewForCollageLayout:layout];

    layout = [CollageLayout new];
    [layout setFrames: @[
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 2, 1)],
                         [NSValue valueWithCGRect:CGRectMake(0, 1, 2, 1)]
                         ]];
    [self.layoutsView addCoollageLayoutViewForCollageLayout:layout];
    
    layout = [CollageLayout new];
    [layout setFrames: @[
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 2, 1)],
                         [NSValue valueWithCGRect:CGRectMake(0, 1, 1, 1)],
                         [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                         ]];
    [self.layoutsView addCoollageLayoutViewForCollageLayout:layout];
    
    layout = [CollageLayout new];
    [layout setFrames: @[
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)],
                         [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                         [NSValue valueWithCGRect:CGRectMake(0, 1, 2, 1)]
                         ]];
    [self.layoutsView addCoollageLayoutViewForCollageLayout:layout];
    
    layout = [CollageLayout new];
    [layout setFrames: @[
                         [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 2)],
                         [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                         [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                         ]];
    [self.layoutsView addCoollageLayoutViewForCollageLayout:layout];
    
    self.layoutsView.assetsCollection = self.assetsCollection;

    self.pageControl.numberOfPages = [self.layoutsView getCollageLayoutViews].count;
}

-(void)updatePageControllFromScrollview
{
    if (self.destinationPageNo < 0) {
        self.pageControl.currentPage = [self.layoutsView getCurrentPageNo];
    } else {
        if (self.destinationPageNo == [self.layoutsView getCurrentPageNo]) {
            self.destinationPageNo = -1;
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updatePageControllFromScrollview];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updatePageControllFromScrollview];
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
    if ([self.assetsCollection getAssets].count <= 0) {
        //do nothing
        return;
    }
    
    CollageCreationViewController* collageCreationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CollageCreationViewController"];
    
    [collageCreationViewController setupCollageWithAssets:self.assetsCollection andLayout:collageLayoutView.collageLayout];
    
    [collageCreationViewController setupTransitionForView:collageLayoutView];

    [self presentViewController:collageCreationViewController animated:YES completion:nil];
}

@end
