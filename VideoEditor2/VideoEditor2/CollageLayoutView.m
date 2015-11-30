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

- (void)dealloc
{
    [self unsubscribeFromAssetsCollectionNotifications];
}

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

-(void) setAssetsCollection:(AssetsCollection *)assetsCollection
{
    [self unsubscribeFromAssetsCollectionNotifications];
    
    _assetsCollection = assetsCollection;
    
    [self subscribeToAssetsCollectionNotifications];
    
    [self updateAssetsView];
}

-(void) subscribeToAssetsCollectionNotifications
{
    if (self.assetsCollection != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAssetsView) name:kAssetsCollectionAssetAddedNitification object:self.assetsCollection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAssetsView) name:kAssetsCollectionAssetRemovedNitification object:self.assetsCollection];
    }
}

-(void) unsubscribeFromAssetsCollectionNotifications
{
    if (self.assetsCollection != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetAddedNitification object:self.assetsCollection];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetRemovedNitification object:self.assetsCollection];
    }
}

-(void) updateAssetsView
{
    [self clearImagesRefreshTimer];
    
    NSArray* assets = [self.assetsCollection getAssets];
    
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView* imageView = self.imageViews[i];
        
        if (assets.count > 0) {
            imageView.layer.borderWidth = 0;
            
            NSInteger j = i % assets.count;
            VAsset* asset = assets[j];
            
            [asset getPreviewImageForSize:imageView.bounds.size withCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
    });
}

-(CGRect) getFrameForPlusBagde
{
    CGFloat size  = 30;
    
    return CGRectMake(self.bounds.size.width - (size * 2), size, size, size);
}

-(void) clearImagesRefreshTimer
{
    if (self.imageRefreshTimer != nil) {
        [self.imageRefreshTimer invalidate];
        self.imageRefreshTimer = nil;
    }
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
    
    
    [self clearImagesRefreshTimer];
    self.imageRefreshTimer = [NSTimer timerWithTimeInterval:0.25 target:self selector:@selector(updateAssetsView) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.imageRefreshTimer forMode:NSDefaultRunLoopMode];

    
    [self updateAssetsView];
}

@end
