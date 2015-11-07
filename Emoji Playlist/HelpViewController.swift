//
//  HelpViewController.swift
//  Emoji Playlist
//
//  Created by DFA Film 9: K-9 on 4/29/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    @IBOutlet weak var pageCollection: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var screenshotCollection: UICollectionView!
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewWillAppear(animated: Bool) {
        pageCollection.collectionViewLayout = CellPagingLayout(pageWidth: self.view.frame.width)
        (pageCollection.collectionViewLayout as! CellPagingLayout).pageControl = pageControl
        pageCollection.decelerationRate = UIScrollViewDecelerationRateFast
        
        screenshotCollection.collectionViewLayout = CellPagingLayout(pageWidth: self.view.frame.width * 0.75)
        (screenshotCollection.collectionViewLayout as! CellPagingLayout).pageControl = pageControl
        screenshotCollection.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(screenshotCollection.collectionViewLayout)
        NSNotificationCenter.defaultCenter().removeObserver(pageCollection.collectionViewLayout)
    }
    
    var texts = ["use them anywhere", "🎧 playlists", "📱 contact pictures", "👥 social networks", "🙏🏻 nice!"]
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if collectionView.restorationIdentifier == "screenshots" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("screenshot", forIndexPath: indexPath) as! ScreenshotCell
            
            let image = UIImage(named: "s\(indexPath.item)")!
            cell.decorate(image)
            
            return cell
        }
            
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("text", forIndexPath: indexPath) as! TextCell
            cell.decorate(texts[indexPath.item])
            return cell
        }
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.0
    }
    
}

class ScreenshotCell : UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    func decorate(image: UIImage) {
        self.image.image = image
    }
    
}

class TextCell : UICollectionViewCell {
    
    @IBOutlet weak var text: UILabel!
    
    func decorate(text: String) {
        self.text.text = text
    }
    
}

class LightNavigation : UINavigationController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}