//
//  TimePionter.m
//  VideoEditor2
//
//  Created by Alexander on 11/5/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "TimePionter.h"

@interface TimePionter()

@property (nonatomic, strong) UIImage* timePointer;

@end

@implementation TimePionter

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void) setup
{
    self.opaque = NO;
    self.timePointer = [UIImage imageNamed:@"pointer"];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.backgroundColor = [UIColor clearColor];
    
    CGContextClearRect(context, self.bounds);
    
    CGContextSetRGBFillColor(context, 255.0/255.0, 255.0/255.0, 255.0/255.0, 1.0);
    
    double lineWidth = 2;
    double pointerWidth = self.timePointer.size.width/2;
    double pointerHeight = (self.timePointer.size.height/2) + 3;
    
    CGContextFillRect(context, CGRectMake((self.bounds.size.width/2.0) - (lineWidth/2.0), pointerHeight, lineWidth, self.bounds.size.height - pointerHeight));
    
    [self.timePointer drawInRect:CGRectMake((self.bounds.size.width/2.0) - (pointerWidth/2.0), pointerHeight - 8, pointerWidth, pointerHeight)];
}

@end
