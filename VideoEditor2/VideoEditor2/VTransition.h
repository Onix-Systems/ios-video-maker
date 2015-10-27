//
//  VTransition.h
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VFrameProvider.h"

@interface VTransition : VFrameProvider

@property (nonatomic, strong) VFrameProvider* content1;
@property (nonatomic, strong) VFrameProvider* content2;
@property (nonatomic, strong) VFrameProvider* backgroundFrameProvider;

-(double) getContent1AppearanceDuration;
-(double) getContent2AppearanceDuration;

@end
