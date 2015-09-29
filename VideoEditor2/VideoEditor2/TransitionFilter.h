//
//  TransitionFilter.h
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface TransitionFilter : NSObject

@property (strong, nonatomic, readonly) NSString* filterName;
+ (TransitionFilter*) transitionFilterWithFilterName: (NSString*) filterName;

+ (NSString*) getRandomFilterName;

- (instancetype)initWithFilterName: (NSString*) filterName;
-(CIImage*) getTransitionFromImage: (CIImage*) fromImage toImage: (CIImage*) toImage inputTime: (double) inputTime;

@end