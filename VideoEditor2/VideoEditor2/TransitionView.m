//
//  TransitionView.m
//  VideoEditor2
//
//  Created by Alexander on 11/4/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "TransitionView.h"

@interface TransitionView()

@property (strong, nonatomic) UIImage* transitionIcon;

@end

@implementation TransitionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.opaque = NO;
    self.transitionIcon = [UIImage imageNamed:@"transitionIcon"];
}

- (void) drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor clearColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.bounds);
    
    [self.transitionIcon drawInRect:CGRectMake((self.bounds.size.width / 2.0) - (self.transitionIcon.size.width / 2.0), (self.bounds.size.height / 2.0) - (self.transitionIcon.size.height / 2.0), self.transitionIcon.size.width, self.transitionIcon.size.height)];
    
}

@end
