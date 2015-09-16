//
//  ImageSelectorScrollView.m
//  VideoEditor2
//
//  Created by Alexander on 9/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorScrollView.h"

@interface ImageSelectorScrollView ()

@property (nonatomic, weak) IBOutlet UIImageView* imageView;

@end

@implementation ImageSelectorScrollView

-(void) displayImage:(UIImage *)image
{
    self.imageView.image = image;
}

@end
