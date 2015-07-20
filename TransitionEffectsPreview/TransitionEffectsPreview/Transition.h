//
//  Transition.h
//  TransitionEffectsPreview
//
//  Created by Alexander on 19.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

@interface Transition : NSObject

@property (nonatomic) NSString *filterName;
@property (nonatomic) NSInteger numberOfFrames;
@property (nonatomic, strong) CIImage* from;
@property (nonatomic, strong) CIImage* to;

+(NSArray*) filterNames;

-(id)initForFilter: (NSString*) name;
-(UIImage* ) getImageNo: (NSInteger) number;

@end
