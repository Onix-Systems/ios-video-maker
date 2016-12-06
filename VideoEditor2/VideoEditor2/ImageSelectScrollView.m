//
//  ImageSelectScrollView.m
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectScrollView.h"
#import <UIImageView+WebCache.h>

@interface ImageSelectScrollView ()

@property (nonatomic, weak) IBOutlet UIImageView* imageView;

@end

@implementation ImageSelectScrollView

-(void) displayImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void)displayImageFromURL:(NSURL *)url
{
    [self.imageView sd_setImageWithURL:url];
}

@end
