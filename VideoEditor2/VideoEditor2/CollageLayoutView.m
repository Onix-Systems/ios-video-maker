//
//  CollageView.m
//  VideoEditor2
//
//  Created by Alexander on 9/11/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "CollageLayoutView.h"
#import "VAsset.h"
#import "CollageLayoutViewPlusBadge.h"

@interface CollageLayoutView ()

//array of UIImageView
@property (strong, nonatomic) NSMutableArray* imageViews;
@property (strong, nonatomic) CollageLayoutViewPlusBadge* plusBadge;

@property (strong, nonatomic) NSTimer* imageRefreshTimer;

@end

@implementation CollageLayoutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageViews = [NSMutableArray new];
        
        self.plusBadge = [[CollageLayoutViewPlusBadge alloc] initWithFrame:[self getFrameForPlusBagde]];
        self.plusBadge.hidden = YES;
        
        UITapGestureRecognizer *gestureRecogniger = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchupAction:)];
        gestureRecogniger.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:gestureRecogniger];
        
        [self addSubview:self.plusBadge];
    }
    return self;
}


-(void) touchupAction: (UITapGestureRecognizer*) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.delegate != nil) {
            [self.delegate collageLayoutViewTouchUpInsideAction:self];
        }
    }
}

-(void)updateImagesUsingAssetsCollection:(AssetsCollection*) assetsCollection
{
    NSArray* assets = assetsCollection != nil ? [assetsCollection getAssets] : [NSArray new];
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView* imageView = self.imageViews[i];
        
        if (assets.count > 0) {
            imageView.layer.borderWidth = 0;
            
            NSInteger j = i % assets.count;
            VAsset* asset = assets[j];
            
            [asset getPreviewImageForSize:CGSizeMake(600.0, 600.0) withCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
                if (!requestError) {
                    imageView.image = resultImage;
                }
            }];
            
        } else {
            imageView.layer.borderWidth = 1;
            imageView.image = nil;
        }
    }
    
    self.plusBadge.frame = [self getFrameForPlusBagde];
    self.plusBadge.hidden = (assets.count > self.imageViews.count) ? NO : YES;
    
    [self setNeedsDisplay];
}

-(void) setCollageLayout:(CollageLayout *)collageLayout
{
    _collageLayout = collageLayout;
    
    [self.plusBadge removeFromSuperview];

    while (self.collageLayout.frames.count > self.imageViews.count) {
        UIImageView* imageView = [UIImageView new];
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
    
    while (self.collageLayout.frames.count < self.imageViews.count) {
        UIImageView* imageView = self.imageViews[self.imageViews.count - 1];
        [imageView removeFromSuperview];
        [self.imageViews removeLastObject];
    }
    
    self.plusBadge.frame = [self getFrameForPlusBagde];
    [self addSubview:self.plusBadge];
}

-(CGRect) getFrameForPlusBagde
{
    CGFloat size  = 30;
    
    return CGRectMake(self.bounds.size.width - (size * 2), size, size, size);
}

-(void)layoutSubviews {
    CGFloat xScale = self.bounds.size.width / [self.collageLayout getLayoutWidth];
    CGFloat yScale = self.bounds.size.height / [self.collageLayout getLayoutHeight];
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        CGRect rect = [self.collageLayout.frames[i] CGRectValue];
        CGRect frame = CGRectMake(rect.origin.x * xScale, rect.origin.y * yScale, rect.size.width * xScale, rect.size.height * yScale);
        
        imageView.frame = frame;
    }
    
    self.plusBadge.frame = [self getFrameForPlusBagde];

}

@end
