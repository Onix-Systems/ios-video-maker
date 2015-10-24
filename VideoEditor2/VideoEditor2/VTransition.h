//
//  VTransition.h
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VFrameProvider.h"

#define kVTransitionDuration 0.9

@interface VTransition : VFrameProvider

@property (nonatomic, weak) VFrameProvider* content1;
@property (nonatomic, weak) VFrameProvider* content2;
@property (nonatomic, weak) VFrameProvider* backgroundFrameProvider;

-(double) getContent1AppearanceDuration;
-(double) getContent2AppearanceDuration;

@end
