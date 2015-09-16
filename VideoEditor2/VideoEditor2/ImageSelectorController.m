//
//  ImageSelectorController.m
//  VideoEditor2
//
//  Created by Alexander on 9/9/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "ImageSelectorController.h"

#import "ImageSelectorSplitController.h"
#import "ImageSelectorPreviewController.h"
#import "ImageSelectorCollectionViewController.h"
#import "ImageSelectorCollageController.h"

@interface ImageSelectorController () <ImageSelectorSplitControllerDelegate>

@property (nonatomic, strong) ImageSelectorSplitController *splitController;

@end

@implementation ImageSelectorController

- (void)viewDidLoad
{
    self.splitController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorSplitController"];
    
    ImageSelectorPreviewController *previewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorPreviewController"];
    
    ImageSelectorCollectionViewController *collectionController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorCollectionViewController"];
    [collectionController loadDataFromDataSource:self.dataSource];
    
    ImageSelectorCollageController *collageController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorCollageController"];
    
    self.splitController.leftViewController = previewController;
    self.splitController.bottomViewController = collectionController;
    self.splitController.rightViewController = collageController;
    
    [self addChildViewController:self.splitController];
    self.splitController.view.frame = self.view.frame;
    [self.view addSubview:self.splitController.view];
    [self.splitController didMoveToParentViewController:self];
    
    self.splitController.delegate = self;
}

- (void) willStartVerticalResizing
{
    ImageSelectorCollageController* collageController = (ImageSelectorCollageController*) self.splitController.rightViewController;
    
    [collageController willStartResizing];
}

- (void) didFinishedVertivalResizing
{
    ImageSelectorCollageController* collageController = (ImageSelectorCollageController*) self.splitController.rightViewController;
    
    [collageController didFinishedResizing];
}

@end
