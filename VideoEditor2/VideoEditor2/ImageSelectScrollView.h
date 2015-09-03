//
//  ImageSelectScrollView.h
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageSelectScrollView : UIScrollView

- (void)displayImage:(UIImage *)image;
- (void)displayImageFromURL:(NSURL *)url;

@end
