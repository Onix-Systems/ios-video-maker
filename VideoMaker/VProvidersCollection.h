//
//  VProvidersCollection.h
//  VideoEditor2
//
//  Created by Alexander on 10/17/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VFrameProvider.h"
#import "VTransition.h"

@interface VProvidersCollection : VFrameProvider

@property (nonatomic) double startPositionTime;

@property (nonatomic) CGSize finalSize;

-(NSArray<VFrameProvider*>*) getContentItems;
-(NSArray<NSNumber*>*) getTiming;

-(void)addFrameProvider: (VFrameProvider*)frameProvider withFrontTransition:(VTransition*)transition;
-(NSInteger)findItemNoForTime:(double)time;

@end
