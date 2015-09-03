//
//  ImageSelectCollectionViewFooter.h
//  VideoEditor2
//
//  Created by Alexander on 9/3/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageSelectCollectionViewFooter : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *loadMore;

- (void) hideButton;
- (void) showLoadMore;
- (void) showNoPhotosFound;

@end
