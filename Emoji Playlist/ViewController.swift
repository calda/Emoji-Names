//
//  ViewController.swift
//  Emoji Playlist
//
//  Created by DFA Film 9: K-9 on 4/14/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit
import iAd

let EIShowHelpPopupNotification = "com.cal.emojicon.show-help-popup"
let EIChangeColorNotification = "com.cal.emojicon.change-color"
let EIShowKeyboardNotification = "com.cal.emojicon.show-keyboard"
let EIHideAdNotification = "com.cal.emojicon.hide-ad"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate {
    
    var emojis : [String] = []
    var savedCells : [Int] = []
    var currentColor : UIColor = UIColor.whiteColor()
    
    let about : [(emoji: String, text: String)] = [
        ("", "how to use Emojicon"),
        ("😀", "1️⃣ open emoji keyboard"),
        ("👇", "2️⃣ type emoji"),
        ("🎨", "3️⃣ choose background color 🔝"),
        ("📲", "4️⃣ save to camera roll"),
        ("🌐", "5️⃣ use it anywhere")
    ]
    
    @IBOutlet weak var hiddenField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showKeyboardButton: UIButton!
    @IBOutlet weak var openKeyboardView: UIView!
    @IBOutlet weak var openKeyboardPosition: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hue: 0.0, saturation: 0.6, brightness: 0.8, alpha: 1.0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChanged:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChanged:", name: UIKeyboardDidChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showHelpPopup:", name: EIShowHelpPopupNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "colorChanged:", name: EIChangeColorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showKeyboard", name: EIShowKeyboardNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hideAd", name: EIHideAdNotification, object: nil)
        
        self.openKeyboardView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        self.openKeyboardView.layer.cornerRadius = 20.0
        self.openKeyboardView.layer.masksToBounds = true
        
        showKeyboardButton.alpha = 0.0
        UIView.animateWithDuration(0.5, delay: 1.0, options: [], animations: {
                self.showKeyboardButton.alpha = 1.0
        }, completion: nil)
    }
    
    @IBAction func showKeyboard() { //called from app delegate or UIButton
        hiddenField.becomeFirstResponder()
        UIView.animateWithDuration(0.3, animations: {
            self.adBanner.alpha = 1.0
            self.showKeyboardButton.alpha = 1.0
        })
    }
    
    func hideAd() {
        self.adBanner.alpha = 0.0
        showKeyboardButton.alpha = 0.0
    }
    
    var keyboardHidden = false
    
    func keyboardChanged(notification: NSNotification) {
        let info = notification.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        
        
        let rawFrame = value.CGRectValue
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        self.keyboardHeight = keyboardFrame.height
        
        updateContentInset()
        
        if !adBanner.bannerLoaded {
            //ad is not on screen
            keyboardHidden = false
            return
        }
        
        adPosition.constant = keyboardHeight
        
        if keyboardHidden {
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { self.view.layoutIfNeeded() }, completion: nil)
        } else {
            self.view.layoutIfNeeded()
        }
        
        keyboardHidden = false
        
    }
    
    func colorChanged(notification: NSNotification) {
        //scroll it to the top
        self.tableView.setContentOffset(CGPointZero, animated: true)
        
        if let color = notification.object as? UIColor {
            currentColor = color
            
            for cell in tableView.visibleCells {
                if let cell = cell as? EmojiCell {
                    cell.labelContainer.backgroundColor = color
                    cell.switchBackToDownloadButton()
                }
            }
        }
    }
    
    func updateContentInset() {
        let contentInset = self.keyboardHeight + (adPosition.constant > 0 ? (adBanner.hidden ? 0 : 50) : 0)
        tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, contentInset, 0.0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        //update frame of Open Keyboard popup
        let screenHeight = UIScreen.mainScreen().bounds.height
        let currentCenter = screenHeight / 2.0
        let availableSpace = screenHeight - contentInset + 20.0
        let availableCenter = availableSpace / 2.0
        let centerOffset = -(currentCenter - availableCenter)
    
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.openKeyboardPosition.constant = centerOffset
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func showHelpPopup(notification: NSNotification) {
        let popup = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("help") 
        
        let nav = LightNavigation(rootViewController: popup)
        nav.navigationBar.translucent = false
        popup.view.frame = CGRectMake(0, 0, -44, self.view.bounds.size.height)
        
        if let presentation = nav.presentationController as? UIPopoverPresentationController, source = notification.object as? UIView {
            presentation.sourceView = source
        }
        
        let closeButton = UIBarButtonItem(title: "got it", style: UIBarButtonItemStyle.Plain, target: self, action: "closeHelpPopup")
        closeButton.tintColor = UIColor.whiteColor()
        popup.navigationItem.rightBarButtonItem = closeButton
        
        popup.navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        let font = UIFont(name: "HelveticaNeue-Light", size: 25.0)!
        popup.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        nav.modalPresentationCapturesStatusBarAppearance = true
        self.presentViewController(nav, animated: true, completion: nil)
        self.keyboardHidden(true)
    }
    
    func closeHelpPopup() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.adPosition.constant = -55
        self.view.layoutIfNeeded()
        keyboardHidden = true
        self.hiddenField.becomeFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var isAnimatingPopup = false
    
    func showOpenKeyboardPopup() {
        
        if isAnimatingPopup { return }
        isAnimatingPopup = true
        self.openKeyboardView.alpha = 1.0
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            self.openKeyboardView.transform = CGAffineTransformIdentity
        }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 2.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.openKeyboardView.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
        }, completion: { _ in
            self.isAnimatingPopup = false
            self.openKeyboardView.alpha = 0.0
        })
        
    }
    
    //pragma MARK: - emoji inputs and table
    
    @IBAction func hiddenInputReceived(sender: UITextField, forEvent event: UIEvent) {
        let rawEmoji = sender.text!
        if rawEmoji == "" { return }
        var emoji = rawEmoji as NSString
        
        let notEmoji = "abcdefghijklmnopqrstuvwxyz1234567890-=!@#$%^&*()_+,./;'[]\\<>?:\"{}| "
        for character in rawEmoji.characters {
            if notEmoji.containsString("\(character)".lowercaseString) {
                sender.text = ""
                //show an alert
                showOpenKeyboardPopup()
                return
            }
        }
        
        if emoji.length > 1 {
            let char2 = emoji.characterAtIndex(1)
            if char2 >= 57339 && char2 <= 57343
            { //is skin tone marker
                emoji = sender.text!.substringFromIndex(sender.text!.endIndex.predecessor().predecessor()) as NSString
            }
            
            if emoji.length % 4 == 0 && emoji.length > 4 { //flags stick together for some reason?
                emoji = emoji.substringFromIndex(emoji.length - 4)
            }
        }
        
        emojis.insert(rawEmoji, atIndex: 0)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
        //tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        let contentHeight = tableView.contentSize.height
        
        var availableHeight = self.view.frame.height - 20.0
        availableHeight -= keyboardHeight
        if adPosition.constant > 0 {
            availableHeight -= adBanner.frame.height
        }
        
        if contentHeight > availableHeight {
            tableView.setContentOffset(CGPointMake(0, 0), animated: true)
        }
        
        sender.text = ""
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //first is color picker title, then picker itself
        if indexPath.item == 0 {
            return tableView.dequeueReusableCellWithIdentifier("backgroundTitle")!
        }
        
        if indexPath.item == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("colorCell", forIndexPath: indexPath) as! ColorPickerCell
            cell.beingDisplayed = true
            let collection = cell.collectionView
            collection.contentOffset = CGPointMake(cell.frame.height * 2, 0)
            delay(0.3) {
                cell.beingDisplayed = false
            }
            return cell
        }
        
        //everything else used Emoji Cell
        let cell = tableView.dequeueReusableCellWithIdentifier("emojiCell") as! EmojiCell
        cell.labelContainer.backgroundColor = currentColor
        
        if indexPath.item > emojis.count + 1 {
            let aboutIndex = indexPath.item - emojis.count - 2
            let aboutText = about[aboutIndex]
            
            if aboutText.text == "how to use Emojicon" {
                return tableView.dequeueReusableCellWithIdentifier("instructions")!
            }
            
            cell.decorateCell(emoji: aboutText.emoji, text: aboutText.text, isLast: aboutText.text.hasSuffix("anywhere"))
        }
        
        else {
            cell.decorateCell(emojis[indexPath.item - 2])
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.item > emojis.count + 1 {
            let aboutIndex = indexPath.item - emojis.count - 2
            let aboutText = about[aboutIndex]
            
            if aboutText.text == "how to use Emojicon" {
                return 30
            }
        }
        
        if indexPath.item == 0 { //is top cell, "background color" title
            return 30
        }
            
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojis.count + about.count + 2
    }
    
    //pragma MARK: - ad delegate
    
    @IBOutlet weak var adBanner: ADBannerView!
    @IBOutlet weak var adPosition: NSLayoutConstraint!
    var keyboardHeight : CGFloat = 0
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        
        //do not show ad if 4S (aspect != 9:16) (9/16 = 0.5625)
        let aspect = self.view.frame.width / self.view.frame.height
        if (aspect > 0.6 || aspect < 0.5) && (self.view.frame.height < 800.0) {
            self.updateContentInset()
            adBanner.hidden = true
            return
        }
        
        if adPosition.constant != keyboardHeight {
            adPosition.constant = keyboardHeight
            UIView.animateWithDuration(1.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                    self.view.layoutIfNeeded()
                }, completion: { success in
                    self.updateContentInset()
            })
        }
        
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adPosition.constant = -banner.frame.height
        UIView.animateWithDuration(1.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { self.view.layoutIfNeeded() }, completion: { success in
                self.updateContentInset()
        })
    }
    
    func keyboardHidden(hidden: Bool) {
        adPosition.constant = (hidden ? -adBanner.frame.height : keyboardHeight)
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        self.keyboardHidden(true)
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        self.adPosition.constant = -banner.frame.height
        self.view.layoutIfNeeded()
        self.hiddenField.becomeFirstResponder()
    }

}