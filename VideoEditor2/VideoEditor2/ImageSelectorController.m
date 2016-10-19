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
#import "VAssetCollage.h"
#import "AssetsCollection.h"

#import "VDocument.h"

@interface ImageSelectorController () <ImageSelectorSplitControllerDelegate>

@property (nonatomic, strong) ImageSelectorSplitController *splitController;

@end

@implementation ImageSelectorController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VDocument* currentDoccument = [VDocument getCurrentDocument];
    
    self.splitController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorSplitController"];
    
    ImageSelectorPreviewController *previewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorPreviewController"];
    
    ImageSelectorCollectionViewController *collectionController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorCollectionViewController"];
    [collectionController loadDataFromDataSource:self.dataSource];
    
    collectionController.selectionStorage = currentDoccument.tmpAssetsCollection;
   
    ImageSelectorCollageController *collageController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorCollageController"];
    collageController.parentSplitController = self.splitController;
    
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

- (void) willPresentLeftController {
    ImageSelectorCollectionViewController* collectionViewConrtroller =  [self getCollectionViewConrtroller];
    
    VDocument* currentDoccument = [VDocument getCurrentDocument];

    collectionViewConrtroller.selectionStorage = currentDoccument.tmpAssetsCollection;
    
    self.splitController.navigationItem.title = @"SELECT";
    [self.splitController showOkButton];
}

- (void) willPresentRightController {
    AssetsCollection* newCollection = [AssetsCollection new];
    newCollection.isNumerable = NO;
    
    ImageSelectorCollectionViewController* collectionViewConrtroller =  [self getCollectionViewConrtroller];
    ImageSelectorCollageController* collageConrtroller =  [self getCollageControler];
    
    collectionViewConrtroller.selectionStorage = newCollection;
    collageConrtroller.assetsCollection = newCollection;
   
    VAsset* lastActiveAsset = collectionViewConrtroller.lastActiveAsset;
    if (lastActiveAsset != nil) {
        VAsset* asset = [self.dataSource getAssetWithID:[lastActiveAsset getIdentifier]];
        
        [asset downloadWithCompletion:^(UIImage *resultImage, BOOL requestFinished, BOOL requestError) {
            [newCollection addAsset:asset];
        }];
        
        NSLog(@"[newCollection addAsset:lastActiveAsset]=%@", [lastActiveAsset getIdentifier]);
    }
    
    self.splitController.navigationItem.title = @"Select collage layout";
    [self.splitController hideOkButton];
}

-(void)dealloc {
    NSLog(@"ImageSelectorController dealloc");
}

@end
