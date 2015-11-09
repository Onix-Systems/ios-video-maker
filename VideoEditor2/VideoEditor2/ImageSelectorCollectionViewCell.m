//
//  ImageSelectorCollectionViewCell.m
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorCollectionViewCell.h"

@interface ImageSelectorCollectionViewCell () <ImageSelectorStateIndicatorDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationLabel;
@property (weak, nonatomic) IBOutlet ImageSelectorStateIndicator *stateIndicator;

@property (weak, nonatomic) VAsset* asset;
@property (strong, nonatomic)  NSIndexPath* indexPath;
@property (weak, nonatomic) AssetsCollection* selectionStorage;
@property (weak, nonatomic) id<ImageSelectorCollectionViewCellDelegate> delegate;

@property (nonatomic) NSInteger touchupCounter;
@property (nonatomic) BOOL keepDownloadingState;

@end

@implementation ImageSelectorCollectionViewCell

- (void)dealloc
{
    [self unsubscribeFromDownloadProgressNotifications:_asset];
}

-(void) setAsset: (VAsset*) asset forIndexPath:(NSIndexPath *)indexPath withSelectionStorage: (AssetsCollection*) selectionStorage cellDelegate: (id<ImageSelectorCollectionViewCellDelegate>) delegate
{
    if (_asset != nil) {
        [self unsubscribeFromDownloadProgressNotifications:_asset];
    }
    _asset = asset;
    [self subscribeToDownloadProgressNotifications:_asset];
    
    self.indexPath = indexPath;
    
    [self unsubscribeSelectionStorageNotifications];
    self.selectionStorage = selectionStorage;
    [self subscribeSelectionStorageNotifications];
    
    self.imageView.image = nil;
    
    self.delegate = delegate;
    
    [self updateState];
}

-(void) subscribeToDownloadProgressNotifications: (VAsset*) asset
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgressNotification) name:kVAssetDownloadProgressNotification object:asset];
}

-(void) unsubscribeFromDownloadProgressNotifications: (VAsset*) asset
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVAssetDownloadProgressNotification object:asset];
}

-(void) downloadProgressNotification
{
    if (![self.stateIndicator isSelected]) {
        [self.stateIndicator setDownloading:([self.asset isDownloading] || self.keepDownloadingState) ];
        [self.stateIndicator setDownloadingProgress: [self.asset getDownloadPercent]];
    }
}

-(void) subscribeSelectionStorageNotifications
{
    if (self.selectionStorage != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionStrageSelectionChange) name:kAssetsCollectionAssetAddedNitification object:self.selectionStorage];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionStrageSelectionChange) name:kAssetsCollectionAssetRemovedNitification object:self.selectionStorage];
    }
}

-(void) unsubscribeSelectionStorageNotifications
{
    if (self.selectionStorage != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetAddedNitification object:self.selectionStorage];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kAssetsCollectionAssetRemovedNitification object:self.selectionStorage];
    }
}

-(void) selectionStrageSelectionChange
{
    if ([self.selectionStorage hasAsset:self.asset]) {
        [self.stateIndicator setSelected: [self.selectionStorage getIndexOfAsset:self.asset]];
    } else {
        if ([self.stateIndicator isSelected]) {
            [self.stateIndicator setSelected:-1];
        }
    }
}

-(void)stateIndicatorTouchUpInsideAction {
    
    NSLog(@"stateIndicatorTouchUpInsideAction");
    if (![self.stateIndicator isSelected] && ![self.stateIndicator isDownloading]) {
        self.keepDownloadingState = YES;
        [self.stateIndicator setDownloading:YES];
        [self.stateIndicator setDownloadingProgress:0.0];
        NSLog(@"stateIndicatorTouchUpInsideAction - set downloading state");
    }
    
    [self.delegate selectionActionForIndexPath: self.indexPath];
}

-(void) updateState {
    
    NSInteger currentTag = self.imageView.tag + 1;
    self.imageView.tag = currentTag;
    
    __weak ImageSelectorCollectionViewCell* weakSelf = self;
    
    [self.asset getThumbnailImageImageForSize:self.imageView.bounds.size withCompletion:^(UIImage *resultImage, BOOL requestFinished) {
        if (resultImage != nil && weakSelf.imageView.tag == currentTag) {
            weakSelf.imageView.image = resultImage;
            [weakSelf setNeedsDisplay];
        }
    }];
    
    self.stateIndicator.delegate = self;
    
    [self.stateIndicator setClearState];
    if ([self.selectionStorage hasAsset:self.asset]) {
        [self.stateIndicator setSelected: [self.selectionStorage getIndexOfAsset:self.asset]];
    }
    
    if (self.asset.isVideo) {
        double seconds = round(self.asset.duration);
        double minutes = floor(seconds / 60);
        seconds = seconds - minutes*60;
        
        self.videoDurationLabel.text = [NSString stringWithFormat:@"%.0f:%02.0f", minutes, seconds];
        self.videoDurationLabel.hidden = NO;
    } else {
        self.videoDurationLabel.hidden = YES;
    }
}
@end
