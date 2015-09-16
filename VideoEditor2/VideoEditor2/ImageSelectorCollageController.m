//
//  ImageSelectorCollageController.m
//  VideoEditor2
//
//  Created by Alexander on 9/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorCollageController.h"
#import "CollageLayoutSelectorView.h"

@interface ImageSelectorCollageController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet CollageLayoutSelectorView *layoutsView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) NSInteger destinationPageNo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacingConstraint;
@property (nonatomic) CGFloat originalBottomSpacing;

@end

@implementation ImageSelectorCollageController

-(void) viewDidLoad {
    
    self.originalBottomSpacing = self.bottomSpacingConstraint.constant;
    
    self.destinationPageNo = -1;
    
    self.layoutsView.delegate = self;

    [self.layoutsView addCoollageLayout:@[
                                         [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)],
                                         ]];
    
    [self.layoutsView addCoollageLayout:@[
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)],
                              [NSValue valueWithCGRect:CGRectMake(0, 1, 1, 1)],
                              [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                              [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                              ]];
    
    [self.layoutsView addCoollageLayout:@[
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 2)],
                              [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 2)]
                              ]];
    
    [self.layoutsView addCoollageLayout:@[
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 2, 1)],
                              [NSValue valueWithCGRect:CGRectMake(0, 1, 2, 1)]
                              ]];
    
    [self.layoutsView addCoollageLayout:@[
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 2, 1)],
                              [NSValue valueWithCGRect:CGRectMake(0, 1, 1, 1)],
                              [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                              ]];
    
    [self.layoutsView addCoollageLayout:@[
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)],
                              [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                              [NSValue valueWithCGRect:CGRectMake(0, 1, 2, 1)]
                              ]];
    
    [self.layoutsView addCoollageLayout:@[
                              [NSValue valueWithCGRect:CGRectMake(0, 0, 1, 2)],
                              [NSValue valueWithCGRect:CGRectMake(1, 0, 1, 1)],
                              [NSValue valueWithCGRect:CGRectMake(1, 1, 1, 1)]
                              ]];
    
    self.pageControl.numberOfPages = [self.layoutsView getLayouts].count;
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

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"Collage contrller viewWillTransitionToSize: %f x %f", size.width, size.height);
}

- (void) viewWillLayoutSubviews
{
    NSLog(@"Collage contrller viewWillLayoutSubviews");
    
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

@end
