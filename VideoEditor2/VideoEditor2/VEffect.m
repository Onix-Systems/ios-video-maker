//
//  VEffect.m
//  VideoEditor2
//
//  Created by Alexander on 9/30/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VEffect.h"

@interface VEffect ()

@property (nonatomic,strong) NSMutableArray* mutableInputFrameProviders;

@property (nonatomic, strong) NSMutableDictionary* attributes;
@property (nonatomic, strong) NSMutableDictionary* parametes;

@end

@implementation VEffect

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.attributes = [NSMutableDictionary new];
        self.parametes = [NSMutableDictionary new];

        self.mutableInputFrameProviders = [NSMutableArray new];

        self.originalSize = CGSizeZero;
    }
    return self;
}

-(NSDictionary*) getAttributes
{
    return self.attributes;
}

-(void) setupParameterAttributes:(NSString *)paramName defaultValue:(NSObject *)defaultValue
{
    self.attributes[paramName] = defaultValue;
}

-(NSObject*) getParamValue:(NSString *)paramName
{
    NSObject* value = self.parametes[paramName];
    if (value == nil) {
        value = self.attributes[paramName];
    }
    
    return value;
}

-(NSDictionary*) getParameters
{
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    
    for (NSString* paramName in self.parametes) {
        parameters[paramName] = self.parametes[paramName];
    }
    
    for (NSString* paramName in self.attributes) {
        if (parameters[paramName] == nil) {
            parameters[paramName] = self.attributes[paramName];
        }
    }
    
    return parameters;
}

-(NSInteger) getNumberOfInputFrames
{
    return 0;
}

-(VEffect*) getInputFrameProvider: (NSInteger) inputFrameNumber
{
    return self.mutableInputFrameProviders[inputFrameNumber];
}

-(void) setInputFrameProvider: (VEffect*) provider forInputFrameNum: (NSInteger) inputFrameNumber
{
    self.mutableInputFrameProviders[inputFrameNumber] = provider;
}

-(CIImage*) getImageForFrameSize: (CGSize) frameSize atTime: (double) time
{
    return nil;
}

@end
