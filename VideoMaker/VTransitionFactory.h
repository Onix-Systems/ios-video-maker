//
//  VTransitionFactory.h
//  VideoEditor2
//
//  Created by Alexander on 10/26/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VTransition.h"

@interface VTransitionFactory : NSObject

+(VTransition*)makeRandomTransition;

@end
