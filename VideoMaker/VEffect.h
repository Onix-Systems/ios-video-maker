//
//  VEffect.h
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VFrameProvider.h"

@interface VEffect : VFrameProvider

@property (nonatomic,strong) VFrameProvider* frameProvider;
@property (nonatomic) CGSize finalSize;

@end
