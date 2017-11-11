//
//  String+Emoji.swift
//  Emoji Names
//
//  Created by Cal Stephens on 11/10/17.
//  Copyright © 2017 Cal Stephens. All rights reserved.
//

import UIKit

extension String {
    
    var isEmoji: Bool {
        guard !isEmpty else {
            return false
        }
        
        let notEmoji = "abcdefghijklmnopqrstuvwxyz1234567890-=!@#$%^&*()_+,./;'[]\\<>?:\"{}| "
        
        for character in self {
            if notEmoji.contains("\(character)".lowercased()) {
                return false
            }
        }
        
        return true
    }
    
    var emojiName: String {
        let cfstring = NSMutableString(string: self) as CFMutableString
        var range = CFRangeMake(0, CFStringGetLength(cfstring))
        CFStringTransform(cfstring, &range, kCFStringTransformToUnicodeName, false)
        let capitalName = "\(cfstring)"
        
        if !capitalName.hasPrefix("\\") { //is number emoji
            var splits = capitalName.components(separatedBy: "\\")
            return ((capitalName as NSString).length > 1 ? "keycap " : "") + splits[0]
        }
            
        else {
            var splits = capitalName.components(separatedBy: "}")
            if splits.last == "" { splits.removeLast() }
            
            for i in 0 ..< splits.count {
                if (splits[i] as NSString).length > 3 {
                    splits[i] = (splits[i] as NSString).substring(from: 3).lowercased()
                }
            }
            
            if splits.count == 1 {
                return splits[0]
            }
            
            if splits.count == 2{
                if splits[1].hasPrefix("emoji modifier") || splits[1].hasPrefix("variation selector"){ //skin tone emojis
                    return splits[0]
                }
                else { //flags are awful
                    var flagName = ""
                    for split in splits {
                        let splitNS = split.uppercased() as NSString
                        flagName += splitNS.substring(from: splitNS.length - 1)
                    }
                    
                    if let countryName = countryNameForCode(flagName){
                        flagName = countryName
                    }
                    
                    return flagName + " flag"
                }
            }
        }
        
        if self == "👁‍🗨" { return "eye in speech bubble" }
        //still nothing somehow
        return "family" //can only be family as far as I know
    }
    
    var emojiImage: UIImage {
        let size = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        UIGraphicsBeginImageContext(size.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(size)
        context?.setAllowsAntialiasing(true)
        context?.setShouldAntialias(true)
        
        let emoji = self as NSString
        let font = UIFont.systemFont(ofSize: 75.0)
        let attributes = [NSAttributedStringKey.font : font as AnyObject]
        let drawSize = emoji.boundingRect(with: size.size, options: .usesLineFragmentOrigin, attributes: attributes, context: NSStringDrawingContext()).size
        
        let xOffset = (size.width - drawSize.width) / 2
        let yOffset = (size.height - drawSize.height) / 2
        let drawPoint = CGPoint(x: xOffset, y: yOffset)
        let drawRect = CGRect(origin: drawPoint, size: drawSize)
        emoji.draw(in: drawRect.integral, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
