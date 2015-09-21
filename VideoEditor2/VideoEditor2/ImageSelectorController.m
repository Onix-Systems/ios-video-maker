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

#import "VDocument.h"

@interface ImageSelectorController () <ImageSelectorSplitControllerDelegate>

@property (nonatomic, strong) ImageSelectorSplitController *splitController;

@end

@implementation ImageSelectorController

- (void)viewDidLoad
{
    VDocument* currentDoccument = [VDocument getCurrentDocument];
    
    self.splitController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorSplitController"];
    
    ImageSelectorPreviewController *previewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorPreviewController"];
    
    ImageSelectorCollectionViewController *collectionController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorCollectionViewController"];
    [collectionController loadDataFromDataSource:self.dataSource];
    collectionController.selectionStorage = currentDoccument.assetsCollection;
   
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

-(ImageSelectorCollageController*) getCollageControler
{
    return (ImageSelectorCollageController*) self.splitController.rightViewController;
}

-(ImageSelectorCollectionViewController*) getCollectionViewConrtroller
{
    return (ImageSelectorCollectionViewController*) self.splitController.bottomViewController;
}

- (void) willStartVerticalResizing
{
    ImageSelectorCollageController* collageController = [self getCollageControler];
    
    [collageController willStartResizing];
}

- (void) didFinishedVertivalResizing
{
    ImageSelectorCollageController* collageController = [self getCollageControler];
    
    [collageController didFinishedResizing];
}

- (void) didPresentLeftController {
    ImageSelectorCollectionViewController* collectionViewConrtroller =  [self getCollectionViewConrtroller];
    
    VDocument* currentDoccument = [VDocument getCurrentDocument];

    collectionViewConrtroller.selectionStorage = currentDoccument.assetsCollection;
}

- (void) didPresentRightController {
    
}

@end
