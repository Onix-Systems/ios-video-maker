//
//  FirstViewController.swift
//  VideoEditor
//
//  Created by Alexander on 8/10/15.
//  Copyright (c) 2015 Onix-Systems. All rights reserved.
//

import UIKit


class ThemeCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var selectedCheckmark: UILabel!
    
    override var selected : Bool {
        didSet {
            self.selectedCheckmark.hidden = !(self.selected)
            self.setNeedsDisplay()
        }
        
    }
    
    func initSelectionCheckmark() {
        self.selectedCheckmark.layer.cornerRadius = (self.selectedCheckmark.bounds.height / 2)
        
        self.selectedCheckmark.layer.borderColor = (UIColor.whiteColor()).CGColor
        self.selectedCheckmark.layer.borderWidth = 1.0
        self.selectedCheckmark.hidden = !(self.selected)
    }
}

class ThemeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var selectedThemeNo = -1;

    @IBOutlet weak var themesCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.themesCollection.dataSource = self
        self.themesCollection.delegate = self
        self.themesCollection.allowsSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellView = self.themesCollection.dequeueReusableCellWithReuseIdentifier("ThemeCell", forIndexPath: indexPath) as! ThemeCollectionViewCell
        
        cellView.initSelectionCheckmark()
        if (indexPath.row == self.selectedThemeNo) {
            cellView.selected = true
        }
        
        return cellView
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (self.selectedThemeNo != indexPath.row) {
            self.selectedThemeNo = indexPath.row
        }
    }
    
    @IBAction func doneButtonTouched(sender: AnyObject) {
        UIView.animateWithDuration(0.3) {
            self.tabBarController?.selectedIndex = 1
        }
    }
}

