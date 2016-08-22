//
//  Step3.m
//  VideoEditor2
//
//  Created by Alexander on 8/17/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

#import "Step3.h"
#import "DZNPhotoPickerController.h"
#import "ImageSelectMomentsDataSource.h"
#import "ImageSelectorController.h"
#import "ImageSelectDZNDataSource.h"
#import "OneAssetMediaTypeDataSource.h"
//@class BaseImageSelectDataSource;

@interface Step3 () <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIPopoverController *popoverController;
}
@end

@implementation Step3

+(void)initialize {
    //Below is a copy of API keys from original DZNPhotoPickerController repo
    
#define k500pxConsumerKey               @"9sUVdra51AYawcQwQjFaQA7ueUqpaXLEZQJT7Pzy"
#define k500pxConsumerSecret            @"CmmZmHfSu1xi9BfVq4cS5RcAAhnR9UylGzPJQjqc"
    
#define kFlickrConsumerKey              @"8c96746e0818c4ceb119c13c1eb1b05e"
#define kFlickrConsumerSecret           @"f35bf89a60e411a5"
    
#define kInstagramConsumerKey           @"16759bba4b7e4831b80bf3412e7dcb16"
#define kInstagramConsumerSecret        @""
    
#define kGoogleImagesConsumerKey        @"AIzaSyBiRs6vQmTVseUnMqUtJwpaJX-m5o9Djr0"
#define kGoogleImagesSearchEngineID     @"018335320449571565407:tg2a0fkobws"        //cx
    
#define kYahooImagesConsumerKey         @"dj0yJmk9N01LeUVpY1YwcFBHJmQ9WVdrOVpVVm1ObTFITkdjbWNHbzlNVE0zT0RNeU1EazJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iNQ--"
#define kYahooImagesConsumerSecret      @"9a31a307570aa29cf8f069b473d771caf5ebe262"
    
#define kBingImagesAccountKey           @"9V3Rg6PgTrQno6t7pKpT9dLppEaVwVyucUwmHXZXlUo" //5000 request per month (free account)
    
#define kGettyImagesConsumerKey         @"tt4fyd5487kgsjtfkf46v3d4"
#define kGettyImagesConsumerSecret      @"jQhYJvW8HncyMd9UaEbc8vAYKuDyK2UxtmPHAmSnRhpy5" //1000 request per day (free account)

    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerService500px
                                      consumerKey:k500pxConsumerKey
                                   consumerSecret:k500pxConsumerSecret];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceFlickr
                                      consumerKey:kFlickrConsumerKey
                                   consumerSecret:kFlickrConsumerSecret];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceInstagram
                                      consumerKey:kInstagramConsumerKey
                                   consumerSecret:kInstagramConsumerSecret];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGoogleImages
                                      consumerKey:kGoogleImagesConsumerKey
                                   consumerSecret:kGoogleImagesSearchEngineID];
    
    //Bing does not require a secret. Rather just an "Account Key"
//    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceBingImages
//                                      consumerKey:kBingImagesAccountKey
//                                   consumerSecret:nil];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGettyImages
                                      consumerKey:kGettyImagesConsumerKey
                                   consumerSecret:kGettyImagesConsumerSecret];    
}

- (IBAction)cameraButtonAction {
}

- (IBAction)momentsButtonAction {
    ImageSelectMomentsDataSource *dataSource = [ImageSelectMomentsDataSource new];
    [self presentImageSelectorControllerWithSource:dataSource];
}

- (IBAction)internetButtonAction {
    [self showImageSelectorForDZVServices:DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGoogleImages
     |DZNPhotoPickerControllerServiceGettyImages];
}

- (IBAction)photosButtonAction {
    OneAssetMediaTypeDataSource *dataSource = [OneAssetMediaTypeDataSource new];
    [self presentImageSelectorControllerWithSource:dataSource];
}

- (IBAction)videosButtonAction {
    OneAssetMediaTypeDataSource *dataSource = [OneAssetMediaTypeDataSource new];
    dataSource.loadingMediaType = PHAssetMediaTypeVideo;
    [self presentImageSelectorControllerWithSource:dataSource];
}

-(void) showImageSelectorForDZVServices:(DZNPhotoPickerControllerServices) services {
    ImageSelectDZNDataSource *dataSource = [ImageSelectDZNDataSource new];
    dataSource.initialSearchTerm = @"California";
    dataSource.supportedServices = services;
    [self presentImageSelectorControllerWithSource:dataSource];
}

-(void)presentImageSelectorControllerWithSource:(BaseImageSelectDataSource *)dataSource {
    ImageSelectorController *imageSelector = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectorController"];
    imageSelector.dataSource = dataSource;
    
    [self presentViewController:imageSelector animated:YES completion:NULL];
}

@end
