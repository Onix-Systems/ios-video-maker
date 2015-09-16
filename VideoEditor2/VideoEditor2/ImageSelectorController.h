//
//  ImageSelectorController.h
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImageSelectDataSource.h"

@interface ImageSelectorController : UIViewController

@property (nonatomic, strong) BaseImageSelectDataSource* dataSource;

@end
