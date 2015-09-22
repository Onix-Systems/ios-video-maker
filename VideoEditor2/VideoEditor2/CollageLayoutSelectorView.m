//
//  CollageLayoutSelectorView.m
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "CollageLayoutSelectorView.h"
#import "CollageLayoutView.h"

@interface CollageLayoutSelectorView () <CollageLayoutViewDelegate>

@property (strong, nonatomic) NSMutableArray* collageLayoutViews;
@property (nonatomic) CGFloat subViewOffset;
@property (nonatomic) CGFloat currentItemWidth;

@property (nonatomic) BOOL resizingInprogress;
@property (nonatomic) NSInteger fixedPageNumber;

@end

@implementation CollageLayoutSelectorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup
{
    self.collageLayoutViews = [NSMutableArray new];
    self.pagingEnabled = YES;
    self.subViewOffset = 20;
    self.resizingInprogress = NO;
}

-(CGRect) getFrameForSubview: (NSInteger) i
{
    CGFloat offset = self.subViewOffset;
    CGFloat width = self.currentItemWidth;
    CGFloat height = width;
    
    return CGRectMake((2*offset + width) * i + offset, 0, width, height);
}


-(void)cleanExisitngCoollageLayoutViews
{
    for (int i=0; i< self.collageLayoutViews.count; i++) {
        CollageLayoutView* collageLayoutView = self.collageLayoutViews[i];
        [collageLayoutView removeFromSuperview];
    }
    
    [self.collageLayoutViews removeAllObjects];
}

-(void) addCoollageLayoutViewForCollageLaout: (CollageLayout*)collageLayout withAssetsCollection: (AssetsCollection*) assetsCollection;
{
    CGRect collageViewFrame = [self getFrameForSubview: self.collageLayoutViews.count];
    
    CollageLayoutView* collageLayoutView = [[CollageLayoutView alloc]initWithFrame:collageViewFrame];
    collageLayoutView.delegate = self;
    
    collageLayoutView.collageLayout = collageLayout;
    collageLayoutView.assetsCollecton = assetsCollection;
    
    [self.collageLayoutViews addObject:collageLayoutView];

    
    [self addSubview:collageLayoutView];
    
    [self setNeedsLayout];
}

-(NSArray*)getCollageLayoutViews {
    return self.collageLayoutViews;
};

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.currentItemWidth = self.bounds.size.height;

    self.pageWidth = self.currentItemWidth + 2*self.subViewOffset;
    self.pageHeight = self.currentItemWidth;
    
    CGRect lastFrame = CGRectMake(0, 0, 0, 0);
    
    for (NSInteger i = 0; i < self.collageLayoutViews.count; i++) {
        lastFrame = [self getFrameForSubview:i];
        CollageLayoutView* collageLayoutView = self.collageLayoutViews[i];
        
        collageLayoutView.frame = lastFrame;
        [collageLayoutView setNeedsLayout];
        [collageLayoutView setNeedsDisplay];
    }
    
    self.contentSize = CGSizeMake(lastFrame.origin.x + lastFrame.size.width + self.subViewOffset, lastFrame.size.height);
    
    if (self.resizingInprogress) {
        [self setCurrentPageNo:self.fixedPageNumber animated:NO];
    }
}

- (NSInteger) getCurrentPageNo
{
    return ceil(round(self.contentOffset.x / (self.currentItemWidth + self.subViewOffset*2)));
}

-(void) setCurrentPageNo: (NSInteger) currentPage
{
    [self setCurrentPageNo:currentPage animated:YES];
}

-(void) setCurrentPageNo: (NSInteger) currentPage animated: (BOOL) animated
{
    CGFloat pageOffset = currentPage*(self.currentItemWidth + self.subViewOffset*2);
    [self setContentOffset: CGPointMake(pageOffset, 0) animated:animated];
}

-(void)willStartResizing
{
    self.pagingEnabled = NO;
    self.resizingInprogress = YES;
    self.fixedPageNumber = [self getCurrentPageNo];
}

-(void)didFinishedResizing
{
    self.pagingEnabled = YES;
    self.resizingInprogress = NO;
}

-(void) collageLayoutViewTouchUpInsideAction: (CollageLayoutView*) collageLayoutView {
    if (self.delegate != nil) {
        [self.collageLayoutSelectorDelegate collageLayoutSelectorGotSelectedLayout:collageLayoutView];
    }
};

@end
