//
//  TimeLine.h
//  VideoEditor2
//
//  Created by Alexander on 10/12/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TimeLineStateDescriptor.h"

#define kSlotTimeLineStateShown @"kTimeLineStateShown"
#define kSlotTimeLineStateHidden @"kSlotTimeLineStateHidden"
#define kSlotTimeLineStateShowing @"kSlotTimeLineStateShowing"
#define kSlotTimeLineStateHidding @"kSlotTimeLineStateHidding"

@interface TimeLine : NSObject

-(TimeLineStateDescriptor*) getStateForTime: (double) time;
-(void) setState:(NSString*) state forTime: (double) time additionalInfo: (NSObject*) info;

-(double) getTimeOfFirstAppearance;
-(double) getTimeOfLastAppearance;

@end
