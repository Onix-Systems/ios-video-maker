//
//  ImageSelectDZNDataSource.h
//  VideoEditor2
//
//  Created by Alexander on 9/1/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseImageSelectDataSource.h"
#import "DZNPhotoServiceClient.h"

@interface ImageSelectDZNDataSource : BaseImageSelectDataSource

@property (nonatomic) DZNPhotoPickerControllerServices supportedServices;
@property (nonatomic) NSString* initialSearchTerm;
@property (nonatomic) NSInteger resultPerPage;

@end
