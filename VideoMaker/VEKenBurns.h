//
//  VEKenBurns.h
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VEffect.h"

@interface VEKenBurns : VEffect

@property (nonatomic) double startScale;
@property (nonatomic) double endScale;

@property (nonatomic) double startX;
@property (nonatomic) double startY;

@property (nonatomic) double endX;
@property (nonatomic) double endY;

@property (nonatomic) double currentScale;
@property (nonatomic) double currentX;
@property (nonatomic) double currentY;

@end
