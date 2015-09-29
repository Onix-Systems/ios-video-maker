//
//  VInstrucionPassthrough.h
//  VideoEditor2
//
//  Created by Alexander on 9/29/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCompositionInstruction.h"

@interface VInstrucionPassthrough : VCompositionInstruction

@property (nonatomic) CMPersistentTrackID sourceTrackID;

@end
