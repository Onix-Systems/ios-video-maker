//
//  PickerAsset.h
//  VideoEditor2
//
//  Created by Alexander on 8/19/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface PickerAsset : NSObject

@property (nonatomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, readonly) UIImage *originalImage;

@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic) BOOL selected;
@property (nonatomic,readonly) NSInteger selectionNumber;

- (NSURL*) getURL;

@end
