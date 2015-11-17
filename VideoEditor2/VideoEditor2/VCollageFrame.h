//
//  VCollageFrame.h
//  VideoEditor2
//
//  Created by Alexander on 10/19/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VEffect.h"
#import "CollageLayout.h"

#define kCollageFrameDuration 2.0;

@interface VCollageFrame : VFrameProvider

@property (nonatomic) CGSize finalSize;
@property (nonatomic, strong) VFrameProvider* backgroundFrameProvider;

@property (strong, nonatomic) CollageLayout* collageLayout;
@property (strong, nonatomic) NSArray<VEffect*>* collageItems;

@end
