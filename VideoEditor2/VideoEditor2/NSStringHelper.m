//
//  NSStringHelper.m
//  VideoEditor2
//
//  Created by Vitaliy Savchenko on 13.09.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

#import "NSStringHelper.h"

@implementation NSStringHelper

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    if (interval) {
        NSInteger time = interval;
//        NSInteger hours = (time / 3600);
        NSInteger minutes = (time / 60) % 60;
        NSInteger seconds = time % 60;
//        NSInteger ms = (fmod(interval, 1) * 1000);
    
        return [NSString stringWithFormat:@"%0.2ld:%0.2ld", (long)minutes, (long)seconds];
    }
    
    return @"00:00";
}

@end
