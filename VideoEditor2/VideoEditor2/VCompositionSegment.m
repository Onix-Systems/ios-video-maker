//
//  VideoCompositionSegment.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VCompositionSegment.h"

@interface VCompositionSegment ()

@property (nonatomic, readwrite) CMTime duration;
@property (nonatomic, readwrite) BOOL isLoaded;

@end

@implementation VCompositionSegment

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.duration = kCMTimeZero;
        self.isLoaded = NO;
    }
    return self;
}

@end
