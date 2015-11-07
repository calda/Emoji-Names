//
//  CellPagingCollectionLayout.swift
//  About Cal
//
//  Created by Cal on 4/15/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit

let SYNCHRONIZE_TO_PAGE_NOTIFICATION = "SYNCHRONIZE_TO_PAGE_NOTIFICATION"

class CellPagingLayout : UICollectionViewFlowLayout {
    
    var pageWidth : CGFloat {
        get {
            return self.collectionView!.frame.width
        }
    }
    var previousPage : CGFloat = 0
    var pageControl : UIPageControl?
    var enabled = true
    
    init(pageWidth: CGFloat) {
        super.init()
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "syncToPage:", name: SYNCHRONIZE_TO_PAGE_NOTIFICATION, object: nil)
    }
    
    func syncToPage(notification: NSNotification) {
        
        var page = notification.object as! Int
        if page < 0 {
            page = 0
        } else if page > 4 {
            page = 4
        }
        
        self.collectionView!.scrollToItemAtIndexPath(NSIndexPath(forItem: page, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let newOffset = getNewOffsetForVelocity(velocity.x)
        return CGPointMake(newOffset, 0)
    }

    
    func getNewOffsetForVelocity(velocity: CGFloat) -> CGFloat {
        
        if velocity == 0.0 && !enabled {
            return previousPage
        }
        
        let currentOffset = collectionView!.contentOffset.x
        var newOffset : CGFloat
        
        if velocity > 0 {
            newOffset = ceil(currentOffset / pageWidth) * pageWidth
        }
        else if velocity < 0 {
            newOffset = floor(currentOffset / pageWidth) * pageWidth
        }
        else { //no velocity
            let distanceToPrevious = currentOffset - previousPage
            
            if distanceToPrevious > 0 {
                newOffset = ceil(currentOffset / pageWidth) * pageWidth
            }
            else if distanceToPrevious < 0 {
                newOffset = floor(currentOffset / pageWidth) * pageWidth
            }
            else {
                newOffset = previousPage
            }
        }
        
        previousPage = newOffset
        enabled = false
        
        if let pageControl = self.pageControl {
            let pageNumber = newOffset / pageWidth
            pageControl.currentPage = Int(pageNumber)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(SYNCHRONIZE_TO_PAGE_NOTIFICATION, object: Int(newOffset / pageWidth))
        
        return newOffset
    }
    
    
    
}