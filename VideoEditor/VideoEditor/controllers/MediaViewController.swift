//
//  MediaViewController.swift
//  VideoEditor
//
//  Created by Alexander on 8/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

import UIKit
import MobileCoreServices

class ImagePickerPopoverController : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZNPhotoPickerControllerDelegate {
    
    @IBAction func choseFromDeviceAction() {
        self.showNativeImagePicker(.PhotoLibrary)
    }
    
    @IBAction func takeFromCameraAction() {
        self.showNativeImagePicker(.Camera)
    }
    
    @IBAction func search500pxAction() {
        self.showDZNPicker(DZNPhotoPickerControllerServices.Service500px)
    }
 
    @IBAction func searchFlickrAction() {
        self.showDZNPicker(DZNPhotoPickerControllerServices.ServiceFlickr)
    }

    @IBAction func searchGoogleAction() {
        self.showDZNPicker(DZNPhotoPickerControllerServices.ServiceGoogleImages)
    }
    
    @IBAction func searchInstagramAction() {
        self.showDZNPicker(DZNPhotoPickerControllerServices.ServiceInstagram)
    }
    
    @IBAction func searchBingAction() {
        self.showDZNPicker(DZNPhotoPickerControllerServices.ServiceBingImages)
    }
    
    @IBAction func searchGettyAction() {
        self.showDZNPicker(DZNPhotoPickerControllerServices.ServiceGettyImages)
    }
    
    var searchTerm = "california"
    
    func showDZNPicker(service: DZNPhotoPickerControllerServices) {
        let picker = DZNPhotoPickerController()
        
        picker.supportedServices = service
        
        picker.allowsEditing = true;
        picker.delegate = self;
        
        picker.initialSearchTerm = searchTerm
        picker.enablePhotoDownload = true
        
        self.presentViewController(picker, animated:true) {
        }
       
    }

    var nativeImagePicker : UIImagePickerController?
    func showNativeImagePicker (let sourceType : UIImagePickerControllerSourceType) {
        if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
            return
        }
        
        self.nativeImagePicker = UIImagePickerController()
        
        self.nativeImagePicker!.allowsEditing = false
        
        self.nativeImagePicker!.sourceType = sourceType
        if (sourceType == .Camera) {
            self.nativeImagePicker!.showsCameraControls = true
        }
        
        self.nativeImagePicker!.mediaTypes = [kUTTypeMovie, kUTTypeImage];
        
        self.nativeImagePicker!.delegate = self
        
        presentViewController(self.nativeImagePicker!, animated: true) {
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let newItem = VideoCompositionSegment.createSegmentWithPickerInfo(info, onLoad: {})
        if (newItem != nil) {
            MediaCollectionModel.currentModel!.collectionItems.append(newItem!)
        }
        
        self.nativeImagePicker!.dismissViewControllerAnimated(false, completion: {
            MediaCollectionModel.currentModel!.delegate?.didFinishedWorkwithImagePicker()
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.nativeImagePicker!.dismissViewControllerAnimated(false, completion: {
            MediaCollectionModel.currentModel!.delegate?.didFinishedWorkwithImagePicker()
        })
    }
    
    func photoPickerController(picker: DZNPhotoPickerController!, didFailedPickingPhotoWithError error: NSError!) {
        picker.dismissViewControllerAnimated(true, completion: {
            MediaCollectionModel.currentModel!.delegate?.didFinishedWorkwithImagePicker()
        })
    }
    
    func photoPickerController(picker: DZNPhotoPickerController!, didFinishPickingPhotoWithInfo userInfo: [NSObject : AnyObject]!) {
        let newItem = VideoCompositionSegment.createSegmentWithPickerInfo(userInfo, onLoad: {})
        if (newItem != nil) {
            MediaCollectionModel.currentModel!.collectionItems.append(newItem!)
        }
        picker.dismissViewControllerAnimated(true, completion: {
            MediaCollectionModel.currentModel!.delegate?.didFinishedWorkwithImagePicker()
        })
    }
    
    func photoPickerControllerDidCancel(picker: DZNPhotoPickerController!) {
        picker.dismissViewControllerAnimated(true, completion: {
            MediaCollectionModel.currentModel!.delegate?.didFinishedWorkwithImagePicker()
        })
    }

}

class MediaCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}

class MediaViewController: UIViewController, UICollectionViewDataSource, MediaCollectionModelDelagate, LXReorderableCollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DZNPhotoPickerController.registerFreeService(DZNPhotoPickerControllerServices.Service500px,
            consumerKey:"9sUVdra51AYawcQwQjFaQA7ueUqpaXLEZQJT7Pzy",
            consumerSecret:"CmmZmHfSu1xi9BfVq4cS5RcAAhnR9UylGzPJQjqc"
        )

        DZNPhotoPickerController.registerFreeService(DZNPhotoPickerControllerServices.ServiceFlickr,
            consumerKey:"8c96746e0818c4ceb119c13c1eb1b05e",
            consumerSecret:"f35bf89a60e411a5"
        )

        DZNPhotoPickerController.registerFreeService(DZNPhotoPickerControllerServices.ServiceInstagram,
            consumerKey:"16759bba4b7e4831b80bf3412e7dcb16",
            consumerSecret:"701c5a99144a401c8285b0c9df999509"
        )

        DZNPhotoPickerController.registerFreeService(DZNPhotoPickerControllerServices.ServiceGoogleImages,
            consumerKey:"AIzaSyBiRs6vQmTVseUnMqUtJwpaJX-m5o9Djr0",
            consumerSecret:"018335320449571565407:tg2a0fkobws"
        )

        DZNPhotoPickerController.registerFreeService(DZNPhotoPickerControllerServices.Service500px,
            consumerKey:"9sUVdra51AYawcQwQjFaQA7ueUqpaXLEZQJT7Pzy",
            consumerSecret:"CmmZmHfSu1xi9BfVq4cS5RcAAhnR9UylGzPJQjqc"
        )

        DZNPhotoPickerController.registerFreeService(DZNPhotoPickerControllerServices.ServiceBingImages,
            consumerKey:"9V3Rg6PgTrQno6t7pKpT9dLppEaVwVyucUwmHXZXlUo",
            consumerSecret:""
        )

        DZNPhotoPickerController.registerFreeService(DZNPhotoPickerControllerServices.ServiceGettyImages,
            consumerKey:"tt4fyd5487kgsjtfkf46v3d4",
            consumerSecret:"jQhYJvW8HncyMd9UaEbc8vAYKuDyK2UxtmPHAmSnRhpy5"
        )
        
        if (MediaCollectionModel.currentModel == nil) {
            MediaCollectionModel.startEditingNewModel()
            MediaCollectionModel.currentModel!.delegate = self
        }
        
        self.collectionView.dataSource = self;
        
        let dragableLayout = LXReorderableCollectionViewFlowLayout()
        let existingLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        dragableLayout.minimumLineSpacing = existingLayout.minimumLineSpacing
        dragableLayout.minimumInteritemSpacing = existingLayout.minimumInteritemSpacing
        dragableLayout.itemSize = existingLayout.itemSize
        dragableLayout.estimatedItemSize = existingLayout.estimatedItemSize
        dragableLayout.sectionInset = existingLayout.sectionInset
        
        self.collectionView.collectionViewLayout = dragableLayout

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("Count of items \(MediaCollectionModel.currentModel!.collectionItems.count)")
        emptyLabel.hidden = (MediaCollectionModel.currentModel!.collectionItems.count > 0) ? true : false
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MediaCollectionModel.currentModel!.collectionItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellView = collectionView.dequeueReusableCellWithReuseIdentifier("MediaCollectionViewCell", forIndexPath: indexPath) as! MediaCollectionViewCell
        
        let currentMediaItem = MediaCollectionModel.currentModel!.collectionItems[indexPath.row]
        
        currentMediaItem.onLoad = {
            currentMediaItem.getThumbnail() {
                (image : UIImage) -> Void in
            
                cellView.imageView.image = image
            }
        }
        
        return cellView
    }
    
    
    var popoverDestinationController : UIViewController?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ImagePickerPopoverControllerSegue") {
            self.popoverDestinationController = segue.destinationViewController as? UIViewController
        }
    }
    
    func didFinishedWorkwithImagePicker() {
        if (self.popoverDestinationController != nil) {
            self.popoverDestinationController!.dismissViewControllerAnimated(false, completion: nil)
            self.popoverDestinationController = nil
        }
        
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, didMoveToIndexPath toIndexPath: NSIndexPath!) {
        let item = MediaCollectionModel.currentModel!.collectionItems[fromIndexPath.indexAtPosition(1)]
        MediaCollectionModel.currentModel!.collectionItems.removeAtIndex(fromIndexPath.indexAtPosition(1))
        MediaCollectionModel.currentModel!.collectionItems.insert(item, atIndex: toIndexPath.indexAtPosition(1))
    }
    
    @IBAction func doneButtonTouched(sender: AnyObject) {
        UIView.animateWithDuration(0.3) {
            self.tabBarController?.selectedIndex = 2
        }
    }
}

