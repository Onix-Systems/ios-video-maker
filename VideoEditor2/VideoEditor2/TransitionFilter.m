//
//  TransitionFilter.m
//  VideoEditor2
//
//  Created by Alexander on 9/23/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "TransitionFilter.h"

@interface TransitionFilter ()

@property (strong, nonatomic, readwrite) NSString* filterName;

@end

@implementation TransitionFilter

+ (NSString*) getRandomFilterName
{
    
    NSArray* possibleNames = @[
                               @"CIAccordionFoldTransition",
                               @"CIBarsSwipeTransition",
                               @"CICopyMachineTransition",
                               //@"CIDisintegrateWithMaskTransition",
                               @"CIDissolveTransition",
                               @"CIFlashTransition",
                               @"CIModTransition",
                               //@"CIPageCurlTransition",
                               //@"CIPageCurlWithShadowTransition",
                               //@"CIRippleTransition",
                               @"CISwipeTransition"
                               ];
    NSInteger randomNumber = arc4random_uniform((int)possibleNames.count);

    return possibleNames[randomNumber];
}

+ (TransitionFilter*) transitionFilterWithFilterName: (NSString*) filterName
{
    return [[TransitionFilter alloc] initWithFilterName: filterName];
}

- (instancetype)initWithFilterName: (NSString*) filterName
{
    self = [super init];
    if (self) {
        self.filterName = filterName;
    }
    return self;
}

-(CIImage*) getTransitionFromImage: (CIImage*) fromImage toImage: (CIImage*) toImage inputTime: (double) inputTime
{
    CIFilter* filter = [CIFilter filterWithName: self.filterName];
    [filter setDefaults];
    
    [filter setValue:fromImage forKey:@"inputImage"];
    [filter setValue:toImage forKey:@"inputTargetImage"];
    
    [filter setValue:[NSNumber numberWithDouble:inputTime] forKey:@"inputTime"];
    
    return (CIImage*)[filter valueForKey:kCIOutputImageKey];
}

@end
