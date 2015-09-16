//
//  ImageSelectCollectionViewController.h
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseImageSelectDataSource.h"

@interface ImageSelectorCollectionViewController : UIViewController

-(void) loadDataFromDataSource: (BaseImageSelectDataSource*) dataSource;

@end
