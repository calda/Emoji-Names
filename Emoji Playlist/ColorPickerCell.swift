//
//  ColorPickerCell.swift
//  Emoji Playlist
//
//  Created by Cal on 6/20/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerCell : UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var beingDisplayed: Bool = false
    var saturation: CGFloat = 0.7
    var brightness: CGFloat = 0.9
    var cellMap = ["plus", "minus"]
    var currentColor: UIColor = UIColor.whiteColor()
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clearLeading: NSLayoutConstraint!
    @IBOutlet weak var clearIcon: UIImageView!
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if beingDisplayed {
            collectionView.contentOffset = CGPointMake(collectionView.frame.height * 2, 0)
        }
        return 21 + (cellMap.count * 2)
    }
    
    func colorForIndex(indexPath: NSIndexPath) -> UIColor {
        let hue = CGFloat(Double(indexPath.item - cellMap.count) * 0.0473)
        
        let sat: CGFloat
        let bright: CGFloat
        
        if indexPath.item == 20 + cellMap.count { //is black cell
            sat = 0.0
            bright = 1.0 - saturation
        } else {
            sat = saturation
            bright = brightness
        }
        
        let color = UIColor(hue: hue, saturation: sat, brightness: bright, alpha: 1.0)
        return color
    }
    
    func cellTypeForIndex(indexPath: NSIndexPath) -> String {
        if indexPath.item < cellMap.count {
            return cellMap[indexPath.item]
        } else if indexPath.item > (20 + cellMap.count) {
            return cellMap[indexPath.item - (21 + cellMap.count)]
        } else { return "color" }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
        let cellType = cellTypeForIndex(indexPath)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellType, forIndexPath: indexPath) 
        
        if cellType == "color" {
            cell.backgroundColor = colorForIndex(indexPath)
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height = collectionView.frame.height
        return CGSizeMake(height, height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
    //pragma MARK: - User Interaction
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cellType = cellTypeForIndex(indexPath)
        
        if cellType == "color" {
            colorTap(collectionView, indexPath: indexPath)
        }
        else if cellType == "plus" {
            plusTap(collectionView)
        }
        else if cellType == "minus" {
            minusTap(collectionView)
        }
    }
    
    func plusTap(collectionView: UICollectionView) {
        saturation += 0.1
        saturation = min(saturation, 0.8)
        collectionView.reloadData()
        updateSelectedColor()
    }
    
    func minusTap(collectionView: UICollectionView) {
        saturation -= 0.1
        saturation = max(saturation, 0.0)
        collectionView.reloadData()
        updateSelectedColor()
    }
    
    @IBAction func clearTap(sender: AnyObject) {
        //send notification
        currentColor = UIColor.whiteColor()
        NSNotificationCenter.defaultCenter().postNotificationName(EIChangeColorNotification, object: UIColor.whiteColor(), userInfo: nil)
        
        //make sure the plus/minus controls always stay visible
        let newContentOffset: CGPoint
        
        if collectionView.contentOffset.x > (collectionView.frame.height * 2.0) {
            newContentOffset = CGPointMake(collectionView.contentOffset.x - collectionView.frame.height, 0.0)
        } else {
            newContentOffset = collectionView.contentOffset
        }
        
        //animate
        clearLeading.constant = -self.frame.height
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.layoutIfNeeded()
            self.clearIcon.transform = CGAffineTransformMakeRotation(CGFloat(M_PI / 4.0))
            self.collectionView.contentOffset = newContentOffset
        }, completion: nil)
    }
    
    func updateSelectedColor() {
        var hue: CGFloat = 0.0
        var sat: CGFloat = 0.0
        var bright: CGFloat = 0.0
        currentColor.getHue(&hue, saturation: &sat, brightness: nil, alpha: nil)
        
        if sat != 0.0 { //if is not black
            sat = saturation
            bright = brightness
        } else { //if is black
            bright = 1.0 - saturation
        }
        
        let newColor = UIColor(hue: hue, saturation: sat, brightness: bright, alpha: 1.0)
        self.currentColor = newColor
        NSNotificationCenter.defaultCenter().postNotificationName(EIChangeColorNotification, object: newColor, userInfo: nil)
    }
    
    func colorTap(collectionView: UICollectionView, indexPath: NSIndexPath) {
        //send notification
        let newColor = colorForIndex(indexPath)
        NSNotificationCenter.defaultCenter().postNotificationName(EIChangeColorNotification, object: newColor, userInfo: nil)
        
        //animate
        if currentColor == UIColor.whiteColor() {
            clearLeading.constant = 0
            self.clearIcon.transform = CGAffineTransformMakeRotation(CGFloat(3.0 * M_PI/4.0))
            
            let newContentOffset: CGPoint
            //make sure the plus/minus controls always stay visible
            if collectionView.contentOffset.x > (collectionView.frame.height * 2.0) {
                newContentOffset = CGPointMake(collectionView.contentOffset.x + collectionView.frame.height, 0.0)
            } else {
                newContentOffset = collectionView.contentOffset
            }
            
            UIView.animateWithDuration(0.45, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
                self.layoutIfNeeded()
                self.clearIcon.transform = CGAffineTransformMakeRotation(0.0)
                collectionView.contentOffset = newContentOffset
            }, completion: nil)
        }
        
        currentColor = newColor
    }
    
}