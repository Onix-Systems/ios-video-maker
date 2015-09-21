//
//  CollageView.m
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "CollageLayoutView.h"
#import "VAsset.h"

@interface CollageLayoutView ()

//array of UIImageView
@property (strong, nonatomic) NSMutableArray* imageViews;

@end

@implementation CollageLayoutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageViews = [NSMutableArray new];
    }
    return self;
}

-(void) setAssets:(NSArray *)assets
{
    _assets = assets;
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView* imageView = self.imageViews[i];
        
        if (i < self.assets.count) {
            VAsset* asset = self.assets[i];
            
            [asset getPreviewImageForSize:imageView.bounds.size withCompletion:^(UIImage *resultImage, BOOL requestFinished) {
                imageView.image = resultImage;
            }];
             
        } else {
            imageView.image = nil;
        }
    }
    [self setNeedsDisplay];
}

-(void) setLayoutRects:(NSArray *)layoutRects
{
    _layoutRects = layoutRects;
    
    while (self.layoutRects.count > self.imageViews.count) {
        UIImageView* imageView = [UIImageView new];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
    
    while (self.layoutRects.count < self.imageViews.count) {
        UIImageView* imageView = self.imageViews[self.imageViews.count - 1];
        [imageView removeFromSuperview];
        [self.imageViews removeLastObject];
    }
    
    [self setNeedsLayout];
}

-(CGFloat) getLayoutWidth {
    CGFloat layoutSize = 1;
    
    for (NSInteger i = 0; i < self.layoutRects.count; i++) {
        CGRect rect = [self.layoutRects[i] CGRectValue];
        
        layoutSize = MAX(layoutSize, rect.origin.x + rect.size.width);
    }
    
    return layoutSize;
}

-(CGFloat) getLayoutHeight {
    CGFloat layoutSize = 1;
    
    for (NSInteger i = 0; i < self.layoutRects.count; i++) {
        CGRect rect = [self.layoutRects[i] CGRectValue];
        
        layoutSize = MAX(layoutSize, rect.origin.y + rect.size.height);
    }
    
    return layoutSize;
}

-(void)layoutSubviews {
    CGFloat xScale = self.bounds.size.width / [self getLayoutWidth];
    CGFloat yScale = self.bounds.size.height / [self getLayoutHeight];
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        CGRect rect = [self.layoutRects[i] CGRectValue];
        CGRect frame = CGRectMake(rect.origin.x * xScale, rect.origin.y * yScale, rect.size.width * xScale, rect.size.height * yScale);
        
        imageView.frame = frame;
    }
}

@end
