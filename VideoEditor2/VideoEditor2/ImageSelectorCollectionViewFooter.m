//
//  ImageSelectorCollectionViewFooter.m
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorCollectionViewFooter.h"

@implementation ImageSelectorCollectionViewFooter

- (void) hideButton
{
    self.loadMore.hidden = YES;
    self.loadMore.enabled = NO;
    [self.loadMore setNeedsDisplay];
}

- (void) showLoadMore
{
    self.loadMore.enabled = YES;
    self.loadMore.hidden = NO;
    [self.loadMore setNeedsDisplay];
}

@end
