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
#import "ImageSelectController.h"
#import "ImageSelectDZNDataSource.h"


@interface Step3 () <UINavigationControllerDelegate> {
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
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceBingImages
                                      consumerKey:kBingImagesAccountKey
                                   consumerSecret:nil];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGettyImages
                                      consumerKey:kGettyImagesConsumerKey
                                   consumerSecret:kGettyImagesConsumerSecret];    
}

- (IBAction)cameraButtonAction {
}

- (IBAction)internetButtonAction {
    [self showImageSelectForDZVServices:DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGoogleImages | DZNPhotoPickerControllerServiceBingImages
     |DZNPhotoPickerControllerServiceGettyImages];
}

- (IBAction)facebookButtonAction {
}

- (IBAction)instagramButtonAction {
    [self showImageSelectForDZVServices:DZNPhotoPickerControllerServiceInstagram];
}

- (IBAction)instagram2ButtonAction {
    [self showDZVPhotoPickerForServces: DZNPhotoPickerControllerServiceInstagram];
}

- (IBAction)internet2ButtonAction {
    //DZNPhotoPickerController doesn't support more than 4 photo service providers
    [self showDZVPhotoPickerForServces: DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGoogleImages | DZNPhotoPickerControllerServiceBingImages
     |DZNPhotoPickerControllerServiceGettyImages
     ];

}

-(void) showImageSelectForDZVServices:(DZNPhotoPickerControllerServices) services {
    ImageSelectController *imageSelect = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageSelectController"];
    
    ImageSelectDZNDataSource *dataSource = [ImageSelectDZNDataSource new];
    
    dataSource.initialSearchTerm = @"California";
    dataSource.supportedServices = services;
    
    [imageSelect loadDataFromDataSource:dataSource];
    
    [self presentController:imageSelect];
}

- (void) showDZVPhotoPickerForServces: (DZNPhotoPickerControllerServices) services {
    DZNPhotoPickerController *picker = [DZNPhotoPickerController new];
    picker.supportedServices = services;
    picker.allowsEditing = NO;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    picker.initialSearchTerm = @"California";
    picker.enablePhotoDownload = YES;
    picker.allowAutoCompletedSearch = YES;
    
    [picker setFinalizationBlock:^(DZNPhotoPickerController *picker, NSDictionary *info){
        [self dismissController:picker];
    }];
    
    [picker setFailureBlock:^(DZNPhotoPickerController *picker, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }];
    
    [picker setCancellationBlock:^(DZNPhotoPickerController *picker){
        [self dismissController:picker];
    }];
    
    [self presentController:picker];
}

- (void)presentController:(UIViewController *)controller
{
        [self presentViewController:controller animated:YES completion:NULL];
}

- (void)dismissController:(UIViewController *)controller
{
        [controller dismissViewControllerAnimated:YES completion:NULL];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"displayMomentsAlbum"]) {
        ImageSelectController *controller = segue.destinationViewController;
        controller.displayInMomentsStyle = YES;
        [controller loadDataFromDataSource:[ImageSelectMomentsDataSource new]];
    }
}

@end
