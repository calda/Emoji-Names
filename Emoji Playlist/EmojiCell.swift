//
//  EmojiCell.swift
//  Emoji Playlist
//
//  Created by DFA Film 9: K-9 on 4/16/15.
//  Copyright (c) 2015 Cal Stephens. All rights reserved.
//

import UIKit
import CoreFoundation

class EmojiCell : UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emojiDisplay: UILabel!
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var saveTarget: UIButton!
    
    @IBOutlet weak var savedDisplay: UIView!
    @IBOutlet weak var savedLeading: NSLayoutConstraint!
    
    @IBOutlet weak var whatsNext: UIButton!
    @IBOutlet weak var whatsNextWidth: NSLayoutConstraint!

    @IBOutlet weak var thenWhatButton: UIButton!
    
    //pragma MARK: - save emoji image
    
    @IBAction func saveButton(sender: AnyObject) {
        playSaveAnimation()
        dispatch_async(dispatch_get_main_queue(), {
            UIImageWriteToSavedPhotosAlbum(self.getEmojiImage(), nil, nil, nil)
        })
    }
    
    @IBAction func buttonTouched(sender: AnyObject) {
        self.backgroundColor = UIColor(white: 0.96, alpha: 1.0)
    }
    
    @IBAction func buttonCanceled(sender: AnyObject) {
        self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
    }
    
    func playSaveAnimation() {
        savedLeading.constant = 0
        savedDisplay.alpha = 1.0
        UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.layoutIfNeeded()
            }, completion: { success in
                
                self.saveButton.hidden = true
                self.saveButton.enabled = false
                self.saveTarget.hidden = true
                self.saveTarget.enabled = false
                self.whatsNext.hidden = false
                self.whatsNextWidth.constant = 103
                self.layoutIfNeeded()
                self.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
                
                self.savedLeading.constant = -375
                UIView.animateWithDuration(1.0, delay: 1.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
                    self.layoutIfNeeded()
                    self.savedDisplay.alpha = 0.0
                    }, completion: { success in
                        self.savedDisplay.alpha = 0.0
                        self.savedLeading.constant = 375
                        self.layoutIfNeeded()
                })
        })
    }
    
    func switchBackToDownloadButton() {
        if whatsNext.hidden == false || saveButton.hidden == false {
            whatsNext.hidden = true
            saveButton.hidden = false
            saveButton.enabled = true
            saveTarget.hidden = false
            saveTarget.enabled = true
            savedDisplay.alpha = 0.0
        }
    }
        
    func getEmojiImage() -> UIImage {
        let size = CGRectMake(0.0, 0.0, 500.0, 500.0)
        UIGraphicsBeginImageContext(size.size)
        let context = UIGraphicsGetCurrentContext()
        
        let color: UIColor
        if let background = self.labelContainer.backgroundColor {
            color = background
        } else {
            color = UIColor.whiteColor()
        }
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, size)
        CGContextSetAllowsAntialiasing(context, true)
        CGContextSetShouldAntialias(context, true)
        //CGContextSetShouldSmoothFonts(context, true)
        
        let font = UIFont.systemFontOfSize(350.0)
        let emoji = emojiDisplay.text! as NSString
        let attributes = [NSFontAttributeName : font as AnyObject]
        let drawSize = emoji.boundingRectWithSize(size.size, options: .UsesLineFragmentOrigin, attributes: attributes, context: NSStringDrawingContext()).size
        
        let xOffset = (size.width - drawSize.width) / 2
        let yOffset = (size.height - drawSize.height) / 2
        let drawPoint = CGPointMake(xOffset, yOffset)
        let drawRect = CGRect(origin: drawPoint, size: drawSize)
        emoji.drawInRect(CGRectIntegral(drawRect), withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
     //pragma MARK: - table cell functions
    
    @IBAction func showHelpPopup(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(EIShowHelpPopupNotification, object: thenWhatButton)
    }
    
    
    func decorateCell(emoji: String) {
        var emojiName = ""
        
        let cfstring = NSMutableString(string: emoji) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstring))
        CFStringTransform(cfstring, &range, kCFStringTransformToUnicodeName, false)
        let capitalName = "\(cfstring)"
        
        if !capitalName.hasPrefix("\\") { //is number emoji
            var splits = capitalName.characters.split{ $0 == "\\" }.map { String($0) }
            emojiName = ((capitalName as NSString).length > 1 ? "keycap " : "") + splits[0]
        }
        
        else {
            var splits = capitalName.characters.split{ $0 == "}" }.map { String($0) }
            for i in 0..<splits.count {
                if (splits[i] as NSString).length > 3 {
                    splits[i] = (splits[i] as NSString).substringFromIndex(3).lowercaseString
                }
            }
            
            if splits.count == 1 {
                emojiName = splits[0]
            }
            
            if splits.count == 2{
                if splits[1].hasPrefix("emoji modifier") || splits[1].hasPrefix("variation selector"){ //skin tone emojis
                    emojiName = splits[0]
                }
                else { //flags are awful
                    var flagName = ""
                    for split in splits {
                        let splitNS = split.uppercaseString as NSString
                        flagName += splitNS.substringFromIndex(splitNS.length - 1)
                    }
                    
                    if let countryName = countryNameForCode(flagName){
                        flagName = countryName
                    }
                    
                    emojiName = flagName + " flag"
                }
            }
        }
        
        if emojiName == "" { //still nothing somehow
            emojiName = "family" //can only be family as far as I know
        }
        
        decorateCell(emoji: emoji, text: emojiName, isLast: false)
        saveButton.hidden = false
        saveButton.enabled = true
        saveTarget.hidden = false
        saveTarget.enabled = true
        savedDisplay.alpha = 0.0
    }
    
    
    func decorateCell(emoji emoji: String, text: String, isLast: Bool) {
        nameLabel.text = text
        emojiDisplay.text = emoji
        
        labelContainer.layer.borderWidth = 0.5
        labelContainer.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).CGColor
        saveButton.hidden = true
        saveButton.enabled = false
        saveTarget.enabled = false
        saveTarget.hidden = true
        whatsNext.hidden = true
        whatsNextWidth.constant = 10
        savedLeading.constant = 375
        thenWhatButton.enabled = false
        thenWhatButton.hidden = true
        
        setNeedsLayout()
        setNeedsDisplay()
        
        if isLast {
            thenWhatButton.enabled = true
            thenWhatButton.hidden = false
        }
    }
    
}
