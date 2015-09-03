//
//  ImageSelectCollectionViewFooter.m
//  VideoEditor2
//
//  Created by Alexander on 9/3/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectCollectionViewFooter.h"

@implementation ImageSelectCollectionViewFooter

- (void) hideButton
{
    self.loadMore.hidden = YES;
    [self.loadMore setNeedsDisplay];
}

- (void) showLoadMore
{
    self.loadMore.titleLabel.text = @"Load More";
    self.loadMore.enabled = YES;
    self.loadMore.hidden = NO;
    [self.loadMore setNeedsDisplay];
}

- (void) showNoPhotosFound
{
    self.loadMore.titleLabel.text = @"No Photos Found";
    self.loadMore.enabled = NO;
    self.loadMore.hidden = YES;
    
    [self.loadMore setNeedsDisplay];
}

@end
