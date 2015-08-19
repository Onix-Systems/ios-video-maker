//
//  TWPhotoPickerController.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TWPhotoPickerController : UIViewController

@property (nonatomic, copy) void(^cropBlock)(UIImage *image);
@property (weak, nonatomic) ALAssetsGroup *albumToShow;

@end
