//
//  TransitionFilter.m
//  TransitionEffectsPreview
//
//  Created by Alexander on 20.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

#import "TransitionFilter.h"

@interface TransitionFilter() <TransitionFilterProtocol>
@property CIFilter *filter;
@property NSArray *dynamicAttributes;
@end

@implementation TransitionFilter

+(NSArray*) filterNames {
    return @[
             @"CIAccordionFoldTransition",
             @"CIBarsSwipeTransition",
             @"CICopyMachineTransition",
             @"CIDisintegrateWithMaskTransition",
             @"CIDissolveTransition",
             @"CIFlashTransition",
             @"CIModTransition",
             @"CIPageCurlTransition",
             @"CIPageCurlWithShadowTransition",
             @"CIRippleTransition",
             @"CISwipeTransition"
    ];
};

+(CIContext *)getContext  {
    static CIContext* context = nil;
    
    if (context == nil) {
        context = [CIContext contextWithOptions:nil];
    }
    
    return context;
}

+(id<TransitionFilterProtocol>) instantiateFilterWithName: (NSString*) name {
    NSArray *filterNames = [TransitionFilter filterNames];
    
    NSInteger indexOfName = [filterNames indexOfObject:name];
    
    if (indexOfName == NSNotFound) {
        return nil;
    }
 
    TransitionFilter *transition = [TransitionFilter new];
    transition.filter = [CIFilter filterWithName:name];
    
    transition.dynamicAttributes = @[@"inputTime"];

    if ([name isEqual:@"CIDisintegrateWithMaskTransition"]) {
        //neet to set up inputMaskImage attribute
    }
    
    return transition;
};

-(void) setDynamicAttributesForStep: (NSInteger) step totalSteps: (NSInteger) totalSteps {
    CGFloat multipler = (float)(step + 1) / ((float)totalSteps);
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    filters[@"zzz"] = self.filter.attributes;
    

    for(NSString *param in self.dynamicAttributes) {
        NSNumber *minValue = self.filter.attributes[param][@"CIAttributeSliderMin"];
        NSNumber *maxValue = self.filter.attributes[param][@"CIAttributeSliderMax"];
        NSNumber *value = @(minValue.doubleValue + ((maxValue.doubleValue - minValue.doubleValue) * multipler));
        
        [self.filter setValue:value forKey:param];
    }
};

-(CGImageRef) renderTransitionFrom: (CIImage*) from to: (CIImage*) to step: (NSInteger) step totalSteps: (NSInteger) totalSteps {
    if (!self.filter) {
        return nil;
    }
    [self.filter setDefaults];
    
    [self.filter setValue:from forKey:@"inputImage"];
    [self.filter setValue:to forKey:@"inputTargetImage"];
    
    [self setDynamicAttributesForStep:step totalSteps:totalSteps];
    
    CIImage *result = [self.filter valueForKey:kCIOutputImageKey];
    CGRect extent = [result extent];
    CGImageRef cgImage = [[TransitionFilter getContext] createCGImage:result fromRect:extent];
    
    return cgImage;
};

@end
