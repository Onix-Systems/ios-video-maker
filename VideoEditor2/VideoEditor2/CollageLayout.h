//
//  CollageLayout.h
//  VideoEditor2
//
//  Created by Alexander on 9/20/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollageLayout : NSObject

//array fo CGRect
@property (strong) NSArray* frames;
+(CollageLayout*)layoutWithFrames:(NSArray*) frames;

@end
