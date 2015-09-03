//
//  ImageSelect.h
//  VideoEditor2
//
//  Created by Alexander on 8/18/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageSelectDataSource.h"

@interface ImageSelectController : UIViewController

@property (nonatomic) BOOL displayInMomentsStyle;

-(void) loadDataFromDataSource: (BaseImageSelectDataSource*) dataSource;
@end
