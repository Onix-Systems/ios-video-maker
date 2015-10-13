//
//  TimeLineStateDescriptor.h
//  VideoEditor2
//
//  Created by Alexander on 10/12/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeLineStateDescriptor : NSObject

@property (weak, nonatomic) NSString* currentState;
@property (nonatomic) double currentStateTime;
@property (weak, nonatomic) NSObject* currentStateInfo;

@property (weak, nonatomic) NSString* nextState;
@property (nonatomic) double nextStateTime;
@property (weak, nonatomic) NSObject* nextStateInfo;

@end
