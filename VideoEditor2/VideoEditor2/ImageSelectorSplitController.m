//
//  ImageSelectSplitController.m
//  VideoEditor2
//
//  Created by Alexander on 9/8/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorSplitController.h"
#import "ImageSelectorPreviewController.h"

@interface ImageSelectorSplitController ()

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIImageView *horizontalGrip;
@property (weak, nonatomic) IBOutlet UIImageView *verticalGrip;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPositionConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftPositionConstraint;

@property (nonatomic) CGFloat topGestureBeginConstant;
@property (nonatomic) CGFloat leftGestureBeginConstant;

@end

@implementation ImageSelectorSplitController

-(void) removeController: (UIViewController*) controller
{
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
}

-(void) addController: (UIViewController*) controller toView: (UIView*) view
{
    if (controller != nil && view != nil) {
        [self addChildViewController:controller];
        controller.view.frame = view.bounds;
        [view addSubview:controller.view];

        
        [view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[controllerView]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"controllerView" : controller.view}]];
        [view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[controllerView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"controllerView" : controller.view}]];
        
        [controller didMoveToParentViewController:self];
    }
}

-(void) setLeftViewController:(UIViewController *)leftViewController
{
    if (_leftViewController != nil) {
        [self removeController:_leftViewController];
        _leftViewController = nil;
    }
    
    _leftViewController = leftViewController;
    [self addController:_leftViewController toView:self.leftView];
}

- (void) setRightViewController:(UIViewController *)rightViewController
{
    if (_rightViewController != nil) {
        [self removeController:_rightViewController];
        _rightViewController = nil;
    }
    
    _rightViewController = rightViewController;
    [self addController:_rightViewController toView:self.rightView];
}

- (void) setBottomViewController:(UIViewController *)bottomViewController
{
    if (_bottomViewController != nil) {
        [self removeController:_bottomViewController];
        _bottomViewController = nil;
    }
    
    _bottomViewController = bottomViewController;
    [self addController:_bottomViewController toView:self.bottomView];
}

- (CGFloat) getOffsetForTopPosition
{
    return -1 * (self.leftView.frame.size.height - 100);
}

- (CGFloat) getOffsetForBottomPosition
{
    return 0;
}

- (CGFloat) getOffsetForLeftPositionPosition
{
    return 0;
}

- (CGFloat) getOffsetForRightPositionPosition
{
    return self.rightView.frame.size.width;
}

- (void) initPositions
{
    [self.view layoutIfNeeded];
    self.topPositionConstraint.constant = [self getOffsetForBottomPosition];
    self.leftPositionConstraint.constant = [self getOffsetForRightPositionPosition];

    [self.view layoutIfNeeded];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self addController:self.leftViewController toView:self.leftView];
    [self addController:self.rightViewController toView:self.rightView];
    [self addController:self.bottomViewController toView:self.bottomView];
    
    [self initPositions];
    
    [self.delegate didPresentLeftController];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self initPositions];
}

- (IBAction)horizontalGripPanGestureAction:(UIPanGestureRecognizer *)sender
{
    
    switch (sender.state) {
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (self.topPositionConstraint.constant < self.topGestureBeginConstant) {
                self.topPositionConstraint.constant = [self getOffsetForTopPosition];
            } else {
                self.topPositionConstraint.constant = [self getOffsetForBottomPosition];
                
            }
            
            [self.view setNeedsLayout];
            
            [UIView animateWithDuration:.3f animations:^{
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (finished && self.delegate != nil) {
                    [self.delegate didFinishedVertivalResizing];
                }
            }];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            self.topGestureBeginConstant = self.topPositionConstraint.constant;
            if (self.delegate != nil) {
                [self.delegate willStartVerticalResizing];
            }
            
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self.view];
            
            CGFloat newConstant = self.topGestureBeginConstant;
            newConstant += translation.y;
            
            CGFloat allowedMin = [self getOffsetForTopPosition];
            CGFloat allowedMax = [self getOffsetForBottomPosition];
            
            newConstant = newConstant > allowedMax ? allowedMax : newConstant;
            newConstant = newConstant < allowedMin ? allowedMin : newConstant;
            
            self.topPositionConstraint.constant = newConstant;
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
            break;
        }
        default:
            break;
    }
}

- (void) scrollTopViewToTop: (BOOL) toTop
{
    CGFloat newTopPosition = toTop ? [self getOffsetForTopPosition] : [self getOffsetForBottomPosition];
    
    if (self.delegate != nil) {
        [self.delegate willStartVerticalResizing];
    }
    
    self.topPositionConstraint.constant = newTopPosition;
    [self.view setNeedsLayout];
    
    [UIView animateWithDuration:.3f animations:^{
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished && self.delegate != nil) {
            [self.delegate didFinishedVertivalResizing];
        }
    }];
}

- (IBAction)horizontalGripTapGestureAction:(UITapGestureRecognizer *)sender
{
    [self scrollTopViewToTop: (self.topPositionConstraint.constant == [self getOffsetForBottomPosition])];
}

- (IBAction)verticalGripPanGestureAction:(UIPanGestureRecognizer *)sender {
    
    switch (sender.state) {
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (self.leftPositionConstraint.constant < self.leftGestureBeginConstant) {
                self.leftPositionConstraint.constant = [self getOffsetForLeftPositionPosition];
            } else {
                self.leftPositionConstraint.constant = [self getOffsetForRightPositionPosition];
            }
            
            [self.view setNeedsLayout];
            
            [UIView animateWithDuration:.3f animations:^{
                [self.view layoutIfNeeded];
            }];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            self.leftGestureBeginConstant = self.leftPositionConstraint.constant;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [sender translationInView:self.view];
            
            CGFloat newConstant = self.leftGestureBeginConstant;
            CGFloat x = translation.x;
            newConstant += x;
            
            CGFloat allowedMin = [self getOffsetForLeftPositionPosition];
            CGFloat allowedMax = [self getOffsetForRightPositionPosition];
            
            newConstant = newConstant > allowedMax ? allowedMax : newConstant;
            newConstant = newConstant < allowedMin ? allowedMin : newConstant;
            
            self.leftPositionConstraint.constant = newConstant;
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
            
            break;
        }
        default:
            break;
    }

}

- (void) scrollLeftViewToLeft: (BOOL) toLeft
{
    CGFloat newTopPosition = toLeft ?  [self getOffsetForLeftPositionPosition] : [self getOffsetForRightPositionPosition];
    
    self.leftPositionConstraint.constant = newTopPosition;
    [self.view setNeedsLayout];
    
    [UIView animateWithDuration:.3f animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)verticalGripTapGestureAction:(UITapGestureRecognizer *)sender
{
    [self scrollLeftViewToLeft: (self.leftPositionConstraint.constant != [self getOffsetForLeftPositionPosition])];
}


- (IBAction)okButtonAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)backButtonAction:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void) displayAssetPreview: (VAsset*) asset autoPlay: (BOOL) autoPlay
{
    if (self.leftViewController != nil && [self.leftViewController isKindOfClass:[ImageSelectorPreviewController class]]) {
        ImageSelectorPreviewController* previewController = (ImageSelectorPreviewController*)self.leftViewController;
        
        [previewController displayAsset:asset autoPlay:autoPlay];
    }
}
@end
