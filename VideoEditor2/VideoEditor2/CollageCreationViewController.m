//
//  CollageCreationViewController.m
//  VideoEditor2
//
//  Created by Alexander on 9/22/15.
//  Copyright © 2015 Onix-Systems. All rights reserved.
//

#import "CollageCreationViewController.h"

@interface CollageCreationViewController ()

@property (weak, nonatomic) IBOutlet UIView* collageLayoutViewConainer;

@end

@implementation CollageCreationViewController

-(void) setCollageLayoutView:(CollageLayoutView *)collageLayoutView
{
    if (_collageLayoutView) {
        [_collageLayoutView removeFromSuperview];
    }
    
    
    CollageLayoutView* newCollageLayoutView = [[CollageLayoutView alloc] initWithFrame:CGRectZero];
    newCollageLayoutView.collageLayout = collageLayoutView.collageLayout;
    newCollageLayoutView.assetsCollecton = collageLayoutView.assetsCollecton;
    newCollageLayoutView.delegate = nil;
    _collageLayoutView = newCollageLayoutView;
    
    [self setupCollageLayoutView];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollageLayoutView];
}

- (void) setupCollageLayoutView
{
    if (self.collageLayoutViewConainer == nil || self.collageLayoutView == nil) {
        return;
    }

    self.collageLayoutView.frame = self.collageLayoutViewConainer.bounds;
    [self.collageLayoutViewConainer addSubview:self.collageLayoutView];
    
}

- (IBAction)saveButtonAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void) viewDidLayoutSubviews {
    self.collageLayoutView.frame = self.collageLayoutViewConainer.bounds;
}

@end
