//
//  VRenderingStats.h
//  VideoEditor2
//
//  Created by Alexander on 11/16/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#ifndef VRenderingStats_h
#define VRenderingStats_h

@protocol VRenderingStats

-(double) getMinDuration;
-(double) getMaxDuration;
-(double) getAverageDuration;

@end


#endif /* VRenderingStats_h */
