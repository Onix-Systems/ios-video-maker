//
//  Transition.m
//  TransitionEffectsPreview
//
//  Created by Alexander on 19.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "Transition.h"
#import <Foundation/Foundation.h>
#import "TransitionFilter.h"

static NSInteger defaultNumberOfFrames = 10;

@interface Transition()
@property NSMutableArray *imageSet;
@property (strong) id<TransitionFilterProtocol> transitionFilter;
@end

@implementation Transition

@synthesize from = _from;
@synthesize to = _to;
@synthesize filterName = _filterName;
@synthesize numberOfFrames = _numberOfFrames;

+(NSArray*) filterNames {
    return [TransitionFilter filterNames];
};

-(id)initForFilter: (NSString*) name {
    self = [super init];
    if (self) {
        self.filterName = name;
        self.numberOfFrames = defaultNumberOfFrames;
    }
    return self;
}

-(void) setFilterName:(NSString *)name {
    _filterName = name;
    self.imageSet = nil;
    
    self.transitionFilter = [TransitionFilter instantiateFilterWithName:name];
    NSLog(@"Set filter name\"%@\" TF=%@", name, self.transitionFilter);
}

-(void) setFrom:(CIImage *)fromImage {
    _from = fromImage;
    self.imageSet = nil;
    NSLog(@"setFrom -  self=%@ from=%@", self, self.from);
}

-(void) setTo:(CIImage *)toImage {
    _to = toImage;
    self.imageSet = nil;
    NSLog(@"setTo - self=%@ to=%@", self, self.to);
}

-(void) setNumberOfFrames:(NSInteger)number {
    _numberOfFrames = number;
    self.imageSet = nil;
}

- (UIImage* ) getImageNo: (NSInteger) number {
    NSLog(@"getImageNo:%ld self=%@ from=%@ to=%@", (long)number, self, self.from, self.to);
    if (number < 0 || number >= self.numberOfFrames || self.from == nil || self.to == nil) {
        return nil;
    }
    
    if (self.imageSet == nil) {
        self.imageSet = [NSMutableArray arrayWithCapacity:self.numberOfFrames];
        
        for (int i = 0; i < self.numberOfFrames; i++) {
            self.imageSet[i] = [NSNull null];
        }
    }
    
    if (self.imageSet[number] == [NSNull null]) {
        UIImage *newImage = [UIImage imageWithCGImage:[self.transitionFilter renderTransitionFrom:self.from to:self.to step:number totalSteps:self.numberOfFrames]];
        NSLog(@"Create image #%ld of %ld with TF=%@ from=%@ to=%@ - img=%@", (long)number, (long)self.numberOfFrames, self.transitionFilter, self.from, self.to, newImage);
        if (newImage) {
            self.imageSet[number] = newImage;
        } else {
            return nil;
        }
    }
    return self.imageSet[number];
}

@end
