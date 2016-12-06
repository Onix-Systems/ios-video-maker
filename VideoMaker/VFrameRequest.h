//
//  VFrameRequest.h
//  VideoEditor2
//
//  Created by Alexander on 10/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^VFrameRequestCompletionBlock)(void);

@interface VFrameRequest : NSObject

@property (nonatomic) AVAsynchronousVideoCompositionRequest* videoCompositionRequest;

@property (nonatomic) double time;

-(void) addCompletionBlock: (VFrameRequestCompletionBlock) completionBlock;
-(void) markRequestAsFinished;

-(VFrameRequest*) cloneWithDifferentTimeValue: (double) newTime;

@end
