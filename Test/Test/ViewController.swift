//
//  ViewController.swift
//  Test
//
//  Created by Alexander on 10.07.15.
//  Copyright (c) 2015 Alexander. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    var composition = VideoComposition();
    var imagePicker : UIImagePickerController?;

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var debugView: APLCompositionDebugView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.editing = true
 
//        let mainBundle = NSBundle.mainBundle();
        
        self.updateButtonsState()

    }
    
    var playerController : PlayerViewController?
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "playerContoller") {
            self.playerController = segue.destinationViewController as? PlayerViewController
        }
    }
    
    
    var currentPlayerAsset : AVAsset?
    
    func updateButtonsState() {
        self.addButton.enabled = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        self.cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        self.saveButton.enabled = self.composition.canExport()
        
        
        if (self.composition.canPlay()) {
            let newAsset = self.composition.getAsset()
            if (currentPlayerAsset != newAsset) {
                self.currentPlayerAsset = newAsset
                self.playerController!.loadAsset(asset: newAsset, withVideoComposition: self.composition.mutableVideoComposition)
                
                self.debugView.player = self.playerController!.player!;
                self.debugView.synchronizeToComposition(self.composition.mutableComposition, videoComposition: self.composition.mutableVideoComposition, audioMix: self.composition.mutableAudioMix)
                self.debugView.setNeedsDisplay()

            }
        } else {

        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == .Delete) {
            
            self.composition.deleteSegmentAtIndex(indexPath.row)
            
            tableView.reloadData()
            self.updateButtonsState()
        }
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if (sourceIndexPath == destinationIndexPath) {
            return
        }
        
        let segmentToMove = self.composition.getSegment(sourceIndexPath.row)
        self.composition.deleteSegmentAtIndex(sourceIndexPath.row)
        
        self.composition.insert(segmentToMove, atIndex: destinationIndexPath.row)
        
        self.tableView.reloadData()
        self.updateButtonsState()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.composition.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) 
        
        self.composition.getSegment(indexPath.row).getThumbnail(){
            (image : UIImage) -> Void in
            cell.imageView?.image = image
        }
        
        cell.showsReorderControl = true
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.composition.addSegmentWithPickerInfo(info) {
            self.tableView.reloadData()
        }
        
        self.imagePicker?.dismissViewControllerAnimated(true) {}
        
        self.tableView.reloadData()
        self.updateButtonsState()
    }

    func showImagePicker (let sourceType : UIImagePickerControllerSourceType) {
        if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
            return
        }
        
        self.imagePicker = UIImagePickerController()
        
        imagePicker!.allowsEditing = true
        
        imagePicker!.sourceType = sourceType
        if (sourceType == .Camera) {
            imagePicker!.showsCameraControls = true
        }
        
        imagePicker!.mediaTypes = [String(kUTTypeMovie), String(kUTTypeImage)];
        
        imagePicker!.allowsEditing = true;
        
        imagePicker!.delegate = self
        
        presentViewController(imagePicker!, animated: true) {}
        
    }
    
    @IBAction func toolbarAdd2Icon(sender: AnyObject) {
            showImagePicker(.SavedPhotosAlbum)
    }
    
    @IBAction func toolbarAddAction(sender: UIBarButtonItem) {
        showImagePicker(.PhotoLibrary)
    }

    @IBAction func toolbarCameraAction(sender: UIBarButtonItem) {
        showImagePicker(.Camera)
    }

    @IBAction func toolbarSaveAction(sender: UIBarButtonItem) {
        self.saveButton.enabled = false
        self.composition.exportMovieToFile() {
            self.saveButton.enabled = true
        }
    }

    @IBAction func playMovieFormResources(sender: UIBarButtonItem) {
        self.playerController?.loadAsset(fromResource: "MaroonSugar", ofType: "mp4")
    }
}

