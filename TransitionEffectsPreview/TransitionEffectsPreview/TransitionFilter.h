//
//  TransitionFilter.h
//  TransitionEffectsPreview
//
//  Created by Alexander on 20.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@protocol TransitionFilterProtocol

-(CGImageRef) renderTransitionFrom: (CIImage*) from to: (CIImage*) to step: (NSInteger) step totalSteps: (NSInteger) totalSteps;

@end

@interface TransitionFilter : NSObject

+(NSArray*) filterNames;
+(id<TransitionFilterProtocol>) instantiateFilterWithName: (NSString*) name;

@end
