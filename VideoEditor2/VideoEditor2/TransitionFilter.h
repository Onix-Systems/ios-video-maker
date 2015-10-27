//
//  TransitionFilter.h
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

#import "VTransition.h"

@interface TransitionFilter : VTransition

- (instancetype)initWithFilterName: (NSString*) filterName withInputParameters:(NSDictionary<NSString *,id> *)params;

@end