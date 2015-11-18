//
//  VRequestForFrame.m
//  VideoEditor2
//
//  Created by Alexander on 10/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "VFrameRequest.h"

@interface VFrameRequest()

@property (nonatomic, strong) NSMutableArray<VFrameRequestCompletionBlock>* completionBlocks;

@end

@implementation VFrameRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.completionBlocks = [NSMutableArray new];
    }
    return self;
}

-(void)addCompletionBlock:(VFrameRequestCompletionBlock)completionBlock
{
    [self.completionBlocks addObject:completionBlock];
}

-(void) markRequestAsFinished
{
    for (VFrameRequestCompletionBlock completionBlock in self.completionBlocks) {
        completionBlock();
    }
    
    [self.completionBlocks removeAllObjects];
}

-(VFrameRequest*) cloneWithDifferentTimeValue:(double)newTime
{
    VFrameRequest* newRequestObj = [VFrameRequest new];
    
    newRequestObj.videoCompositionRequest = self.videoCompositionRequest;
    newRequestObj.time = newTime;
    
    newRequestObj.completionBlocks = self.completionBlocks;
    
    return newRequestObj;
}

@end
